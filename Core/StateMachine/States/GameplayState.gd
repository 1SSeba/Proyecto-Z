extends "res://Core/StateMachine/State.gd"
class_name GameplayState
# Estado principal del juego - simplificado

var current_level: int = 1
var player_node: Node

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
	
	# Configurar el estado del juego
	if has_node("/root/GameStateManager"):
		var game_state_manager = get_node("/root/GameStateManager")
		if game_state_manager.has_method("change_state"):
			game_state_manager.change_state("PLAYING")
	
	# Notificar que el gameplay empezó
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("gameplay_started", {"level": current_level})
	
	# Buscar el jugador en la escena
	_find_player()

func _find_player():
	"""Busca y configura referencias al jugador"""
	player_node = get_tree().get_first_node_in_group("player")
	
	if player_node:
		if state_machine and state_machine.debug_mode:
			print("✅ Player found and connected")
		
		# Conectar señales del jugador si existen
		if player_node.has_signal("died"):
			player_node.died.connect(_on_player_died)
		if player_node.has_signal("health_changed"):
			player_node.health_changed.connect(_on_player_health_changed)
	else:
		if state_machine and state_machine.debug_mode:
			print("⚠️ Player not found in scene")

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
	"""Pausa el juego"""
	if state_machine and state_machine.debug_mode:
		print("⏸️ Game paused")
	
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
		print("💀 Player died")
	
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("player_died")
	
	transition_to("GameOverState")

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
