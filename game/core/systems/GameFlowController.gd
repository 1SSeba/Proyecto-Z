extends Node
class_name GameFlowController
# GameFlowController - Controla el flujo general del juego

const LoggableBehavior := preload("res://game/core/utils/LoggableBehavior.gd")
const GAME_FLOW_DEFINITION_SCRIPT := preload("res://game/data/levels/GameFlowDefinition.gd")

# Referencias a managers principales
@onready var state_machine: Node
@onready var scene_controller: Node
@onready var game_state_manager: Node

const DEFAULT_MAIN_MENU_SCENE := "res://game/scenes/menus/MainMenu.tscn"
const DEFAULT_GAMEPLAY_SCENE := "res://game/scenes/gameplay/Main.tscn"
const DEFAULT_LOBBY_SCENE := "res://game/scenes/environments/Lobby/Lobby.tscn"
const DEFAULT_LOADING_STATE: StringName = &"LoadingState"
const DEFAULT_PLAYING_STATE: StringName = &"PlayingState"

var data_service: Node = null
var flow_definition: Resource = null

var is_initialized: bool = false
var _logger: LoggableBehavior

signal flow_initialized
signal game_flow_changed(new_flow: String)
signal scene_change_requested(scene_path: String)

func _ready():
	_logger = LoggableBehavior.new("GameFlowController")
	_logger.log_info("Initializing...")
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
		_logger.log_warn("StateMachine not found")

	if not scene_controller:
		_logger.log_warn("SceneController not found")

	if not game_state_manager:
		_logger.log_warn("GameStateManager not found")

	_load_data_definitions()

	is_initialized = true
	flow_initialized.emit()
	_logger.log_info("Ready")

# Control del flujo del juego
func start_new_game():
	if not is_initialized:
		_logger.log_error("Not initialized yet")
		return

	_logger.log_info("Starting new game")
	game_flow_changed.emit("new_game")

	# Prefer GameStateManager simple path
	if game_state_manager and game_state_manager.has_method("start_game"):
		game_state_manager.start_game()
		# Cargar escena principal de gameplay
		var main_path = _get_gameplay_scene_path()
		if scene_controller:
			scene_controller.change_scene(main_path)
		else:
			get_tree().change_scene_to_file(main_path)
		return

	# Fallback to StateMachine if configured
	if state_machine:
		state_machine.transition_to(_get_loading_state_name(), {"next_state": _get_playing_state_name()})

func continue_game():
	if not is_initialized:
		_logger.log_error("Not initialized yet")
		return

	_logger.log_info("Continuing game")
	game_flow_changed.emit("continue_game")

	# Lógica para cargar partida guardada
	if state_machine:
		state_machine.transition_to(_get_loading_state_name(), {"next_state": _get_playing_state_name(), "load_save": true})

func return_to_main_menu():
	_logger.log_info("Returning to main menu")
	game_flow_changed.emit("main_menu")

	# Simple: ir directo al MainMenu scene
	var menu_path = _get_main_menu_scene_path()
	if scene_controller:
		scene_controller.change_scene(menu_path)
	else:
		get_tree().change_scene_to_file(menu_path)

func go_to_lobby():
	"""Navigate to the main lobby"""
	_logger.log_info("Going to lobby")
	game_flow_changed.emit("lobby")

	var lobby_path = _get_lobby_scene_path()
	scene_change_requested.emit(lobby_path)

func quit_game():
	_logger.log_info("Quitting game")
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
	return current_state in [_get_playing_state_name(), "PausedState"]

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
	_logger.log_info("=== GAME FLOW CONTROLLER DEBUG ===")
	_logger.log_info("Is Initialized: %s" % is_initialized)
	_logger.log_info("Current Flow State: %s" % get_current_flow_state())
	_logger.log_info("Is In Game: %s" % is_in_game())
	_logger.log_info("Is In Menu: %s" % is_in_menu())
	_logger.log_info("====================================")

func _load_data_definitions() -> void:
	if ServiceManager and ServiceManager.has_service("DataService"):
		data_service = ServiceManager.get_data_service()
	if data_service and data_service.has_method("get_game_flow_definition"):
		var definition = data_service.get_game_flow_definition()
		if definition and definition is GAME_FLOW_DEFINITION_SCRIPT:
			flow_definition = definition
			_logger.log_info("Game flow definition loaded")
			return
	flow_definition = GAME_FLOW_DEFINITION_SCRIPT.new()
	_logger.log_warn("Using fallback GameFlowDefinition")

func _get_main_menu_scene_path() -> String:
	if flow_definition:
		return flow_definition.get_scene_path_or_default(flow_definition.main_menu_scene, DEFAULT_MAIN_MENU_SCENE)
	return DEFAULT_MAIN_MENU_SCENE

func _get_gameplay_scene_path() -> String:
	if flow_definition:
		return flow_definition.get_scene_path_or_default(flow_definition.gameplay_scene, DEFAULT_GAMEPLAY_SCENE)
	return DEFAULT_GAMEPLAY_SCENE

func _get_lobby_scene_path() -> String:
	if flow_definition:
		return flow_definition.get_scene_path_or_default(flow_definition.lobby_scene, DEFAULT_LOBBY_SCENE)
	return DEFAULT_LOBBY_SCENE

func _get_loading_state_name() -> String:
	if flow_definition and flow_definition.loading_state != StringName():
		return String(flow_definition.loading_state)
	return String(DEFAULT_LOADING_STATE)

func _get_playing_state_name() -> String:
	if flow_definition and flow_definition.playing_state != StringName():
		return String(flow_definition.playing_state)
	return String(DEFAULT_PLAYING_STATE)
