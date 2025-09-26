# 🎮 GameFlowController
# Controlador principal simplificado para el flujo del juego

extends Node

enum GameState {
	MAIN_MENU,
	LOADING,
	PLAYING,
	PAUSED,
	GAME_OVER,
	SETTINGS
}

# Estado actual
var current_state: GameState = GameState.MAIN_MENU
var previous_state: GameState = GameState.MAIN_MENU

# Datos de sesión
var session_data: Dictionary = {}

# Señales centralizadas
signal state_changed(from_state: GameState, to_state: GameState)
signal game_started
signal game_paused
signal game_resumed
signal player_died
signal scene_change_requested(scene_path: String)

func _ready():
	print("GameFlowController: Initialized")

# ═══════════════════════════════════════════════════════════════════════════
# 🎯 CONTROL DE ESTADO PRINCIPAL
# ═══════════════════════════════════════════════════════════════════════════

func change_state(new_state: GameState):
	"""Cambiar el estado principal del juego"""
	if new_state == current_state:
		return

	var old_state = current_state
	previous_state = current_state
	current_state = new_state

	print("GameFlow: %s → %s" % [
		GameState.keys()[old_state],
		GameState.keys()[new_state]
	])

	# Ejecutar lógica de transición
	_handle_state_transition(old_state, new_state)

	# Emitir señal
	state_changed.emit(old_state, new_state)

func _handle_state_transition(_from: GameState, to: GameState):
	"""Lógica específica de cada transición"""
	match to:
		GameState.MAIN_MENU:
			_transition_to_main_menu()
		GameState.LOADING:
			_transition_to_loading()
		GameState.PLAYING:
			_transition_to_playing()
		GameState.PAUSED:
			_transition_to_paused()
		GameState.GAME_OVER:
			_transition_to_game_over()
		GameState.SETTINGS:
			_transition_to_settings()

# ═══════════════════════════════════════════════════════════════════════════
# 🎬 TRANSICIONES DE ESCENA
# ═══════════════════════════════════════════════════════════════════════════

func _transition_to_main_menu():
	scene_change_requested.emit("res://game/scenes/menus/MainMenu.tscn")

func _transition_to_loading():
	# Mostrar pantalla de carga si es necesario
	pass

func _transition_to_playing():
	scene_change_requested.emit("res://game/scenes/gameplay/Main.tscn")
	game_started.emit()

func _transition_to_paused():
	game_paused.emit()

func _transition_to_game_over():
	# Lógica de fin de juego
	pass

func _transition_to_settings():
	scene_change_requested.emit("res://game/scenes/menus/SettingsMenu.tscn")

# ═══════════════════════════════════════════════════════════════════════════
# 🎮 MÉTODOS DE CONVENIENCIA
# ═══════════════════════════════════════════════════════════════════════════

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

# ═══════════════════════════════════════════════════════════════════════════
# 📊 CONSULTAS DE ESTADO
# ═══════════════════════════════════════════════════════════════════════════

func get_current_state() -> GameState:
	return current_state

func is_state(state: GameState) -> bool:
	return current_state == state

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func is_paused() -> bool:
	return current_state == GameState.PAUSED

# ═══════════════════════════════════════════════════════════════════════════
# 💾 DATOS DE SESIÓN
# ═══════════════════════════════════════════════════════════════════════════

func set_session_data(key: String, value):
	session_data[key] = value

func get_session_data(key: String, default_value = null):
	return session_data.get(key, default_value)

func clear_session_data():
	session_data.clear()

# ═══════════════════════════════════════════════════════════════════════════
# 🐛 DEBUG
# ═══════════════════════════════════════════════════════════════════════════

func debug_info():
	print("=== GAME FLOW CONTROLLER ===")
	print("Current State: %s" % GameState.keys()[current_state])
	print("Previous State: %s" % GameState.keys()[previous_state])
	print("Session Data: %s" % session_data)
	print("===========================")
