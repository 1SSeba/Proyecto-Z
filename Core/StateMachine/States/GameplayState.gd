extends "res://Core/StateMachine/State.gd"
class_name GameplayState
# Estado principal del juego - integrado con GameStateManager y Main.tscn

var current_level: int = 1
var player_node: Node
var main_scene: Node

func enter(_previous_state: State = null) -> void:
	if state_machine and state_machine.debug_mode:
		print("🎮 Entering GameplayState")
	
	# Obtener datos de transición
	var data = state_machine.get_transition_data()
	if data.has("level"):
		current_level = data["level"]
	
	if state_machine and state_machine.debug_mode:
		print("📍 Loading level: %d" % current_level)
	
	# Configurar input context para gameplay
	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		if input_manager.has_method("set_context"):
			input_manager.set_context("GAMEPLAY")
	
	# Asegurar que estamos en Main.tscn y configurar gameplay
	await _ensure_main_scene()
	
	# Notificar que el gameplay empezó
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("gameplay_started", {"level": current_level})

func _ensure_main_scene():
	"""Asegura que estemos en la escena principal del juego"""
	var current_scene = get_tree().current_scene
	
	# Si no estamos en Main.tscn, cargarla
	if not current_scene or current_scene.scene_file_path != "res://Scenes/Main.tscn":
		print("GameplayState: Loading Main scene...")
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
		# Esperar a que la nueva escena esté lista
		await get_tree().current_scene.ready
	
	main_scene = get_tree().current_scene
	
	# Esperar a que Main.gd esté completamente inicializado
	if main_scene.has_method("is_ready"):
		while not main_scene.is_ready():
			await get_tree().process_frame
	
	# Conectar con el player
	_find_player()

func _find_player():
	"""Busca y configura referencias al jugador"""
	# Intentar obtener el player desde Main.gd
	if main_scene and main_scene.has_method("get_current_player"):
		player_node = main_scene.get_current_player()
	
	# Si no hay player, buscar en grupos
	if not player_node:
		player_node = get_tree().get_first_node_in_group("player")
	
	# Buscar por tipo si no lo encontramos
	if not player_node and main_scene:
		if main_scene.has_method("get_game_world"):
			var game_world = main_scene.get_game_world()
			if game_world:
				for child in game_world.get_children():
					if child is CharacterBody2D and child.get_script() and "Player" in str(child.get_script().resource_path):
						player_node = child
						break
	
	if player_node:
		if state_machine and state_machine.debug_mode:
			print("✅ Player found and connected: %s" % player_node.name)
		
		# Conectar señales del jugador si existen
		if player_node.has_signal("died") and not player_node.died.is_connected(_on_player_died):
			player_node.died.connect(_on_player_died)
		if player_node.has_signal("health_changed") and not player_node.health_changed.is_connected(_on_player_health_changed):
			player_node.health_changed.connect(_on_player_health_changed)
	else:
		if state_machine and state_machine.debug_mode:
			print("⚠️ Player not found - will try again on next frame")
		# Intentar nuevamente en el próximo frame
		await get_tree().process_frame
		_find_player()

func handle_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# Pausar el juego
				_pause_game()
			KEY_TAB:
				# Alternar debug info
				_toggle_debug_info()

func _pause_game():
	"""Pausa el juego usando GameStateManager"""
	if state_machine and state_machine.debug_mode:
		print("⏸️ Game paused via GameStateManager")
	
	# Usar GameStateManager para pausar
	if has_node("/root/GameStateManager"):
		var gsm = get_node("/root/GameStateManager")
		if gsm.has_method("pause_game"):
			gsm.pause_game()
		else:
			gsm.change_state(gsm.GameState.PAUSED)
	else:
		# Fallback al StateMachine básico
		if has_node("/root/EventBus"):
			var event_bus = get_node("/root/EventBus")
			event_bus.publish("game_paused")
		transition_to("PausedState")

func _toggle_debug_info():
	"""Alterna información de debug"""
	if has_node("/root/DebugManager"):
		var debug_manager = get_node("/root/DebugManager")
		if debug_manager.has_method("toggle_console"):
			debug_manager.toggle_console()

# Callbacks de eventos del jugador
func _on_player_died():
	"""Maneja la muerte del jugador"""
	if state_machine and state_machine.debug_mode:
		print("💀 Player died in GameplayState")
	
	# Notificar al GameStateManager
	if has_node("/root/GameStateManager"):
		var gsm = get_node("/root/GameStateManager")
		if gsm.has_method("on_player_died"):
			gsm.on_player_died()
	
	# Notificar via EventBus
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("player_died")
	
	# La transición la manejará GameStateManager
	# transition_to("GameOverState")

func _on_player_health_changed(health: float, max_health: float):
	"""Maneja cambios en la salud del jugador"""
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish_player_health_changed(health, max_health)

func exit() -> void:
	if state_machine and state_machine.debug_mode:
		print("🎮 Exiting GameplayState")
	
	# Desconectar señales del jugador
	if player_node:
		if player_node.has_signal("died"):
			player_node.died.disconnect(_on_player_died)
		if player_node.has_signal("health_changed"):
			player_node.health_changed.disconnect(_on_player_health_changed)
	
	# Notificar que el gameplay terminó
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("gameplay_ended")
