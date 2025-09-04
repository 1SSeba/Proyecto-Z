extends Node2D
# Main.gd - Escena principal del juego que coordina todo el sistema

# =======================
#  REFERENCIAS
# =======================
@onready var ui_layer: CanvasLayer = $UILayer
@onready var game_world: Node2D = $GameWorld
@onready var debug_console: Control = $UILayer/DebugConsole

# Variables de estado
var is_main_ready: bool = false
var current_player: CharacterBody2D = null

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("Main: Starting main scene initialization...")
	
	# Configurar la escena
	_setup_scene_structure()
	
	# Esperar a que GameStateManager esté listo
	await _wait_for_game_state_manager()
	
	# Conectar señales del GameStateManager
	_connect_game_state_signals()
	
	# La escena está lista
	is_main_ready = true
	print("Main: Scene ready - waiting for state changes")

func _setup_scene_structure():
	"""Configura la estructura básica de la escena"""
	# Crear CanvasLayer para UI si no existe
	if not ui_layer:
		ui_layer = CanvasLayer.new()
		ui_layer.name = "UILayer"
		add_child(ui_layer)
	
	# Crear nodo para el mundo del juego si no existe
	if not game_world:
		game_world = Node2D.new()
		game_world.name = "GameWorld"
		add_child(game_world)
	
	# Instanciar debug console si no existe
	if not debug_console:
		# TODO: Mover DebugConsole a la nueva estructura
		# var debug_scene = preload("res://game/scenes/Debug/DebugConsole.tscn")
		pass # Por ahora no tenemos debug console en la nueva estructura
	
	print("Main: Scene structure configured")

func _wait_for_game_state_manager():
	"""Espera a que GameStateManager esté completamente inicializado"""
	while not GameStateManager.is_initialized:
		await get_tree().process_frame
	
	print("Main: GameStateManager is ready")

func _connect_game_state_signals():
	"""Conecta las señales del GameStateManager"""
	# Usar Callables para compatibilidad Godot 4 y evitar conexiones duplicadas
	var cb_state_changed = Callable(self, "_on_game_state_changed")
	if not GameStateManager.is_connected("state_changed", cb_state_changed):
		GameStateManager.connect("state_changed", cb_state_changed)

	var cb_started = Callable(self, "_on_game_started")
	if not GameStateManager.is_connected("game_started", cb_started):
		GameStateManager.connect("game_started", cb_started)

	var cb_paused = Callable(self, "_on_game_paused")
	if not GameStateManager.is_connected("game_paused", cb_paused):
		GameStateManager.connect("game_paused", cb_paused)

	var cb_resumed = Callable(self, "_on_game_resumed")
	if not GameStateManager.is_connected("game_resumed", cb_resumed):
		GameStateManager.connect("game_resumed", cb_resumed)

	var cb_player_died = Callable(self, "_on_player_died")
	if not GameStateManager.is_connected("player_died", cb_player_died):
		GameStateManager.connect("player_died", cb_player_died)

	print("Main: Connected to GameStateManager signals")

# =======================
#  CALLBACKS DEL GAMESTATE
# =======================
func _on_game_state_changed(old_state: GameStateManager.GameState, new_state: GameStateManager.GameState):
	"""Maneja cambios de estado del juego"""
	print("Main: Game state changed: %s → %s" % [
		GameStateManager.GameState.keys()[old_state], 
		GameStateManager.GameState.keys()[new_state]
	])
	
	# Manejar cambios específicos
	match new_state:
		GameStateManager.GameState.PLAYING:
			_setup_gameplay()
		GameStateManager.GameState.MAIN_MENU:
			_cleanup_gameplay()
		GameStateManager.GameState.PAUSED:
			_handle_game_pause()

func _on_game_started():
	"""Maneja el inicio del juego"""
	print("Main: Game started - setting up gameplay")
	_setup_gameplay()

func _on_game_paused():
	"""Maneja la pausa del juego"""
	print("Main: Game paused")
	_handle_game_pause()

func _on_game_resumed():
	"""Maneja la reanudación del juego"""
	print("Main: Game resumed")
	_handle_game_resume()

func _on_player_died():
	"""Maneja la muerte del jugador"""
	print("Main: Player died - cleaning up")
	if current_player:
		current_player.queue_free()
		current_player = null

# =======================
#  GESTIÓN DEL GAMEPLAY
# =======================
func _setup_gameplay():
	"""Configura el mundo del juego para gameplay"""
	print("Main: Setting up gameplay world...")
	
	# Limpiar mundo anterior si existe
	_cleanup_gameplay()
	
	# Cargar y instanciar el jugador
	_spawn_player()
	
	# Configurar cámara (TODO: implementar)
	# _setup_camera()
	
	# Cargar nivel inicial (TODO: implementar)
	# _load_initial_level()
	
	print("Main: Gameplay setup complete")

func _cleanup_gameplay():
	"""Limpia el mundo del juego"""
	print("Main: Cleaning up gameplay world...")
	
	# Remover jugador
	if current_player:
		current_player.queue_free()
		current_player = null
	
	# Limpiar mundo
	for child in game_world.get_children():
		child.queue_free()
	
	print("Main: Gameplay cleanup complete")

func _spawn_player():
	"""Instancia el jugador en el mundo"""
	if current_player:
		print("Main: Player already exists, skipping spawn")
		return
	
	# Cargar escena del jugador
	var player_scene = preload("res://game/characters/Player.tscn")
	if not player_scene:
		print("Main: ERROR - Could not load player scene")
		return
	
	# Instanciar jugador
	current_player = player_scene.instantiate()
	game_world.add_child(current_player)
	
	# Posicionar en el centro (temporal)
	current_player.global_position = Vector2(640, 360)  # Centro de 1280x720
	
	# Conectar señales del jugador
	if current_player.has_signal("died"):
		current_player.died.connect(GameStateManager.on_player_died)
	
	print("Main: Player spawned at %s" % str(current_player.global_position))
	
	# Notificar al GameStateManager
	GameStateManager.player_spawned.emit()

func _handle_game_pause():
	"""Maneja la pausa del juego"""
	# Pausar procesamiento del mundo del juego
	game_world.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Mostrar overlay de pausa (TODO: implementar)
	# _show_pause_overlay()

func _handle_game_resume():
	"""Maneja la reanudación del juego"""
	# Reanudar procesamiento del mundo del juego
	game_world.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Ocultar overlay de pausa (TODO: implementar)
	# _hide_pause_overlay()

# =======================
#  UTILIDADES
# =======================
func get_current_player() -> CharacterBody2D:
	"""Obtiene referencia al jugador actual"""
	return current_player

func get_game_world() -> Node2D:
	"""Obtiene referencia al mundo del juego"""
	return game_world

func get_ui_layer() -> CanvasLayer:
	"""Obtiene referencia a la capa de UI"""
	return ui_layer

func is_ready() -> bool:
	"""Verifica si la escena principal está lista"""
	return is_main_ready

# =======================
#  DEBUG
# =======================
func _input(event):
	"""Maneja input global de la escena principal"""
	# F1 para toggle del debug console
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			if debug_console:
				debug_console.visible = not debug_console.visible

func debug_spawn_enemy():
	"""Debug: Instancia un enemigo (placeholder)"""
	print("Main: Debug spawn enemy - TODO: Implement enemy system")

func debug_reload_level():
	"""Debug: Recarga el nivel actual"""
	print("Main: Debug reload level")
	_setup_gameplay()

func debug_info():
	"""Muestra información de debug"""
	print("=== MAIN DEBUG INFO ===")
	print("Ready: %s" % is_main_ready)
	print("Player: %s" % ("Present" if current_player else "None"))
	print("Game World Children: %d" % game_world.get_child_count())
	print("Current GameState: %s" % GameStateManager.GameState.keys()[GameStateManager.current_state])
	print("StateMachine State: %s" % (GameStateManager.state_machine.get_current_state_name() if GameStateManager.state_machine else "None"))
	print("=======================")
