extends Node

const Log := preload("res://game/core/utils/Logger.gd")

enum GameStateType {
	MAIN_MENU,
	LOADING,
	PLAYING,
	PAUSED,
	GAME_OVER,
	SETTINGS
}

var current_state: GameStateType = GameStateType.MAIN_MENU
var previous_state: GameStateType = GameStateType.MAIN_MENU
var is_initialized: bool = false
var state_machine: Node = null

signal state_changed(old_state: GameStateType, new_state: GameStateType)
signal game_started
signal game_paused
signal game_resumed
signal player_died

func _ready():
	_log_info("GameStateManager: Initializing...")
	is_initialized = true
	_log_info("GameStateManager: Ready")

func change_state(new_state: GameStateType):
	if new_state == current_state:
		return

	var old_state = current_state
	previous_state = current_state
	current_state = new_state

	_log_info("GameStateManager: State changed from %s to %s" % [
		GameStateType.keys()[old_state],
		GameStateType.keys()[new_state]
	])

	state_changed.emit(old_state, new_state)

	match new_state:
		GameStateType.PLAYING:
			game_started.emit()
		GameStateType.PAUSED:
			game_paused.emit()

func get_current_state() -> GameStateType:
	return current_state

func get_previous_state() -> GameStateType:
	return previous_state

func is_state(state: GameStateType) -> bool:
	return current_state == state

func is_playing() -> bool:
	return current_state == GameStateType.PLAYING

func is_paused() -> bool:
	return current_state == GameStateType.PAUSED

func start_game():
	change_state(GameStateType.PLAYING)

func pause_game():
	if current_state == GameStateType.PLAYING:
		change_state(GameStateType.PAUSED)

func resume_game():
	if current_state == GameStateType.PAUSED:
		change_state(GameStateType.PLAYING)
		game_resumed.emit()

func end_game():
	change_state(GameStateType.GAME_OVER)

func return_to_main_menu():
	change_state(GameStateType.MAIN_MENU)

func open_settings():
	change_state(GameStateType.SETTINGS)

func on_player_died():
	player_died.emit()
	end_game()

func debug_info():
	_log_info("=== GAME STATE MANAGER DEBUG ===")
	_log_info("Current State: %s" % GameStateType.keys()[current_state])
	_log_info("Previous State: %s" % GameStateType.keys()[previous_state])
	_log_info("Is Initialized: %s" % is_initialized)
	_log_info("===============================")

# LOGGING HELPERS
func _log_info(message: String):
	Log.info(message)

func _log_warn(message: String):
	Log.warn(message)
	push_warning(message)

func _log_error(message: String):
	Log.error(message)
	push_error(message)
