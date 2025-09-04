extends Node
# GameStateManager.gd - Gestor de estados del juego

# Estados disponibles
enum GameState {
	MAIN_MENU,
	LOADING,
	PLAYING,
	PAUSED,
	GAME_OVER,
	SETTINGS
}

# Variables
var current_state: GameState = GameState.MAIN_MENU
var previous_state: GameState = GameState.MAIN_MENU
var is_initialized: bool = false
var state_machine: Node = null

# Señales
signal state_changed(old_state: GameState, new_state: GameState)
signal game_started
signal game_paused
signal game_resumed
signal player_died
# signal player_spawned # TODO: Implementar cuando sea necesario

func _ready():
	print("GameStateManager: Initializing...")
	is_initialized = true
	print("GameStateManager: Ready")

func change_state(new_state: GameState):
	"""Cambia el estado del juego"""
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
	
	# Emisiones específicas según el estado
	match new_state:
		GameState.PLAYING:
			game_started.emit()
		GameState.PAUSED:
			game_paused.emit()

func get_current_state() -> GameState:
	"""Obtiene el estado actual"""
	return current_state

func get_previous_state() -> GameState:
	"""Obtiene el estado anterior"""
	return previous_state

func is_state(state: GameState) -> bool:
	"""Verifica si está en un estado específico"""
	return current_state == state

func start_game():
	"""Inicia el juego"""
	change_state(GameState.PLAYING)

func pause_game():
	"""Pausa el juego"""
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)

func resume_game():
	"""Reanuda el juego"""
	if current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)
		game_resumed.emit()

func end_game():
	"""Termina el juego"""
	change_state(GameState.GAME_OVER)

func return_to_main_menu():
	"""Vuelve al menú principal"""
	change_state(GameState.MAIN_MENU)

func open_settings():
	"""Abre configuraciones"""
	change_state(GameState.SETTINGS)

func on_player_died():
	"""Maneja la muerte del jugador"""
	player_died.emit()
	end_game()

func debug_info():
	"""Muestra información de debug"""
	print("=== GAME STATE MANAGER DEBUG ===")
	print("Current State: %s" % GameState.keys()[current_state])
	print("Previous State: %s" % GameState.keys()[previous_state])
	print("Is Initialized: %s" % is_initialized)
	print("===============================")
