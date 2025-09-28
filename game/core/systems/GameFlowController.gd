extends Node
class_name GameFlowController
# GameFlowController - Controla el flujo general del juego

# Referencias a managers principales
@onready var state_machine: Node
@onready var scene_controller: Node
@onready var game_state_manager: Node

var is_initialized: bool = false
var debug_service: Node = null

signal flow_initialized
signal game_flow_changed(new_flow: String)
signal scene_change_requested(scene_path: String)

func _ready():
	_log_info("GameFlowController: Initializing...")
	_initialize_flow_controller()

func _initialize_flow_controller():
	# Obtener referencias a los sistemas principales
	state_machine = get_node_or_null("/root/StateMachine")
	scene_controller = get_node_or_null("/root/SceneController")
	game_state_manager = get_node_or_null("/root/GameStateManager")

	# Fallback: intentar obtener desde ServiceManager si existe
	if not state_machine and has_node("/root/ServiceManager"):
		var sm = get_node("/root/ServiceManager")
		if sm.has_method("get_service"):
			state_machine = sm.get_service("StateMachine")

	if not scene_controller and has_node("/root/ServiceManager"):
		var sm2 = get_node("/root/ServiceManager")
		if sm2.has_method("get_service"):
			scene_controller = sm2.get_service("SceneController")

	if not state_machine:
		_log_warn("GameFlowController: StateMachine not found")

	if not scene_controller:
		_log_warn("GameFlowController: SceneController not found")

	if not game_state_manager:
		_log_warn("GameFlowController: GameStateManager not found")

	is_initialized = true
	flow_initialized.emit()
	_log_info("GameFlowController: Ready")

# Control del flujo del juego
func start_new_game():
	if not is_initialized:
		push_error("GameFlowController: Not initialized yet")
		return

	_log_info("GameFlowController: Starting new game")
	game_flow_changed.emit("new_game")

	# Prefer GameStateManager simple path
	if game_state_manager and game_state_manager.has_method("start_game"):
		game_state_manager.start_game()
		# Cargar escena principal de gameplay
		var main_path = "res://game/scenes/gameplay/Main.tscn"
		if scene_controller:
			scene_controller.change_scene(main_path)
		else:
			get_tree().change_scene_to_file(main_path)
		return

	# Fallback to StateMachine if configured
	if state_machine:
		state_machine.transition_to("LoadingState", {"next_state": "PlayingState"})

func continue_game():
	if not is_initialized:
		push_error("GameFlowController: Not initialized yet")
		return

	_log_info("GameFlowController: Continuing game")
	game_flow_changed.emit("continue_game")

	# Lógica para cargar partida guardada
	if state_machine:
		state_machine.transition_to("LoadingState", {"next_state": "PlayingState", "load_save": true})

func return_to_main_menu():
	_log_info("GameFlowController: Returning to main menu")
	game_flow_changed.emit("main_menu")

	# Simple: ir directo al MainMenu scene
	var menu_path = "res://game/scenes/menus/MainMenu.tscn"
	if scene_controller:
		scene_controller.change_scene(menu_path)
	else:
		get_tree().change_scene_to_file(menu_path)

func go_to_lobby():
	"""Navigate to the main lobby"""
	_log_info("GameFlowController: Going to lobby")
	game_flow_changed.emit("lobby")

	var lobby_path = "res://game/scenes/environments/Lobby/Lobby.tscn"
	scene_change_requested.emit(lobby_path)

func quit_game():
	_log_info("GameFlowController: Quitting game")
	game_flow_changed.emit("quit")
	get_tree().quit()

# Métodos de utilidad
func get_current_flow_state() -> String:
	if state_machine:
		return state_machine.get_current_state_name()
	return "unknown"

func is_in_game() -> bool:
	# Prefer GameStateManager when available
	if game_state_manager and game_state_manager.has_method("is_playing"):
		return game_state_manager.is_playing()
	var current_state = get_current_flow_state()
	return current_state in ["PlayingState", "PausedState"]

func is_in_menu() -> bool:
	# Heurística: si no está jugando y escena actual es MainMenu
	if game_state_manager and game_state_manager.has_method("is_playing"):
		if game_state_manager.is_playing():
			return false
	var current_state = get_current_flow_state()
	return current_state in ["MenuState"]

# Compat para Player.gd
func is_playing() -> bool:
	return is_in_game()

func on_player_died():
	if game_state_manager and game_state_manager.has_method("on_player_died"):
		game_state_manager.on_player_died()
		return
	# Fallback: terminar juego y volver a menú
	return_to_main_menu()

# Debug
func debug_info():
	_log_info("=== GAME FLOW CONTROLLER DEBUG ===")
	_log_info("Is Initialized: %s" % is_initialized)
	_log_info("Current Flow State: %s" % get_current_flow_state())
	_log_info("Is In Game: %s" % is_in_game())
	_log_info("Is In Menu: %s" % is_in_menu())
	_log_info("====================================")

#  LOGGING HELPERS

func _ensure_debug_service():
	if debug_service:
		return
	if ServiceManager and ServiceManager.has_service("DebugService"):
		debug_service = ServiceManager.get_service("DebugService")

func _log_info(message: String):
	_ensure_debug_service()
	if debug_service and debug_service.has_method("info"):
		debug_service.info(message)
	else:
		print("[GameFlowController][INFO] %s" % message)

func _log_warn(message: String):
	_ensure_debug_service()
	if debug_service and debug_service.has_method("warn"):
		debug_service.warn(message)
	else:
		push_warning(message)

func _log_error(message: String):
	_ensure_debug_service()
	if debug_service and debug_service.has_method("error"):
		debug_service.error(message)
	else:
		push_error(message)
