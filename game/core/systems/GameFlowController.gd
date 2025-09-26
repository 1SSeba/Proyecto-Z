extends Node
class_name GameFlowController
# GameFlowController - Controla el flujo general del juego

# Referencias a managers principales
@onready var state_machine
@onready var scene_controller

var is_initialized: bool = false

signal flow_initialized
signal game_flow_changed(new_flow: String)

func _ready():
	print("GameFlowController: Initializing...")
	_initialize_flow_controller()

func _initialize_flow_controller():
	# Obtener referencias a los sistemas principales
	state_machine = get_node_or_null("/root/StateMachine")
	scene_controller = get_node_or_null("/root/SceneController")

	if not state_machine:
		push_warning("GameFlowController: StateMachine not found")

	if not scene_controller:
		push_warning("GameFlowController: SceneController not found")

	is_initialized = true
	flow_initialized.emit()
	print("GameFlowController: Ready")

# Control del flujo del juego
func start_new_game():
	if not is_initialized:
		push_error("GameFlowController: Not initialized yet")
		return

	print("GameFlowController: Starting new game")
	game_flow_changed.emit("new_game")

	if state_machine:
		state_machine.transition_to("LoadingState", {"next_state": "PlayingState"})

func continue_game():
	if not is_initialized:
		push_error("GameFlowController: Not initialized yet")
		return

	print("GameFlowController: Continuing game")
	game_flow_changed.emit("continue_game")

	# Lógica para cargar partida guardada
	if state_machine:
		state_machine.transition_to("LoadingState", {"next_state": "PlayingState", "load_save": true})

func return_to_main_menu():
	print("GameFlowController: Returning to main menu")
	game_flow_changed.emit("main_menu")

	if state_machine:
		state_machine.transition_to("MenuState", {"menu_type": "MainMenu"})

func quit_game():
	print("GameFlowController: Quitting game")
	game_flow_changed.emit("quit")
	get_tree().quit()

# Métodos de utilidad
func get_current_flow_state() -> String:
	if state_machine:
		return state_machine.get_current_state_name()
	return "unknown"

func is_in_game() -> bool:
	var current_state = get_current_flow_state()
	return current_state in ["PlayingState", "PausedState"]

func is_in_menu() -> bool:
	var current_state = get_current_flow_state()
	return current_state in ["MenuState"]

# Debug
func debug_info():
	print("=== GAME FLOW CONTROLLER DEBUG ===")
	print("Is Initialized: %s" % is_initialized)
	print("Current Flow State: %s" % get_current_flow_state())
	print("Is In Game: %s" % is_in_game())
	print("Is In Menu: %s" % is_in_menu())
	print("====================================")
