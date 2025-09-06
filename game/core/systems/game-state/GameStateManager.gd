extends Node

enum GameState {
	MAIN_MENU,
	LOADING,
	PLAYING,
	PAUSED,
	GAME_OVER,
	SETTINGS
}

var current_state: GameState = GameState.MAIN_MENU
var previous_state: GameState = GameState.MAIN_MENU
var is_initialized: bool = false
var state_machine: Node = null

signal state_changed(old_state: GameState, new_state: GameState)
signal game_started
signal game_paused
signal game_resumed
signal player_died

func _ready():
	print("GameStateManager: Initializing...")
	is_initialized = true
	print("GameStateManager: Ready")

func change_state(new_state: GameState):
	if new_state == current_state:
		return

	var old_state = current_state
	previous_state = current_state
	current_state = new_state

	print("GameStateManager: State changed from %s to %s" % [
		GameState.keys()[old_state],
		GameState.keys()[new_state]
	])

	state_changed.emit(old_state, new_state)

	match new_state:
		GameState.PLAYING:
			game_started.emit()
		GameState.PAUSED:
			game_paused.emit()

func get_current_state() -> GameState:
	return current_state

func get_previous_state() -> GameState:
	return previous_state

func is_state(state: GameState) -> bool:
	return current_state == state

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func is_paused() -> bool:
	return current_state == GameState.PAUSED

func start_game():
	change_state(GameState.PLAYING)

func pause_game():
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)

func resume_game():
	if current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)
		game_resumed.emit()

func end_game():
	change_state(GameState.GAME_OVER)

func return_to_main_menu():
	change_state(GameState.MAIN_MENU)

func open_settings():
	change_state(GameState.SETTINGS)

func on_player_died():
	player_died.emit()
	end_game()

func debug_info():
	print("=== GAME STATE MANAGER DEBUG ===")
	print("Current State: %s" % GameState.keys()[current_state])
	print("Previous State: %s" % GameState.keys()[previous_state])
	print("Is Initialized: %s" % is_initialized)
	print("===============================")
