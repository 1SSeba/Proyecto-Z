# GameStateManager.gd - Sistema completo de estados para roguelike
extends Node

# =======================
#  INTEGRACIÓN CON STATEMACHINE
# =======================
var state_machine: StateMachine = null

# =======================
#  SEÑALES
# =======================
signal state_changed(old_state: GameState, new_state: GameState)
signal game_started
signal game_paused
signal game_resumed
signal run_started(run_number: int)
signal run_completed(run_number: int, time_elapsed: float)
signal run_failed(run_number: int, time_elapsed: float)
signal player_spawned
signal player_died
signal new_best_time(time: float)
signal statistics_updated

# =======================
#  ESTADOS DEL JUEGO
# =======================
enum GameState {
	LOADING,       # Pantalla de carga inicial
	MAIN_MENU,     # Menú principal
	PLAYING,       # Jugando (dentro de una run)
	PAUSED,        # Juego pausado
	RUN_COMPLETE,  # Run completada exitosamente
	RUN_FAILED,    # Run fallida (muerte)
	GAME_OVER,     # Pantalla específica de game over
	VICTORY        # Pantalla específica de victoria
}

# =======================
#  VARIABLES DE ESTADO
# =======================
var current_state: GameState = GameState.LOADING
var previous_state: GameState = GameState.LOADING
var is_initialized: bool = false

# =======================
#  SISTEMA DE RUNS Y TIEMPO
# =======================
var current_run_number: int = 0
var is_run_active: bool = false
var run_start_time: float = 0.0
var run_pause_time: float = 0.0
var total_pause_duration: float = 0.0
var run_best_time: float = 0.0

# Control de pausa mejorado
var last_pause_input_time: float = 0.0
var pause_input_cooldown: float = 0.2

# =======================
#  ESTADÍSTICAS PERSISTENTES
# =======================
var run_statistics = {
	"total_runs_completed": 0,
	"total_runs_failed": 0,
	"total_runs_started": 0,
	"current_streak": 0,
	"best_streak": 0,
	"total_time_played": 0.0,
	"fastest_completion": 0.0,
	"average_completion_time": 0.0
}

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("GameStateManager: Starting initialization...")
	_log_to_debug("GameStateManager: Starting initialization...", "cyan")
	
	# Configurar para que funcione siempre
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Esperar a que otros managers estén listos
	await _wait_for_dependencies()
	
	# Inicializar StateMachine
	_setup_state_machine()
	
	# Conectar con otros sistemas
	_connect_managers()
	
	# Cargar datos persistentes
	_load_persistent_data()
	
	# Configurar estado inicial (sin transiciones)
	_setup_initial_state()
	
	# Iniciar StateMachine con el estado configurado
	start_state_machine()
	
	is_initialized = true
	print("GameStateManager: Initialization complete - Ready for roguelike!")
	_log_to_debug("GameStateManager: Initialization complete", "green")

func _wait_for_dependencies():
	"""Espera a que los managers dependientes estén listos"""
	# Esperar InputManager
	if _is_input_manager_available():
		if not InputManager.is_ready():
			print("GameStateManager: Waiting for InputManager...")
			await InputManager.wait_for_ready()
	
	# Esperar ConfigManager
	if _is_config_manager_available():
		if not ConfigManager.is_ready():
			print("GameStateManager: Waiting for ConfigManager...")
			await ConfigManager.config_loaded
	
	# Esperar AudioManager
	if _is_audio_manager_available():
		if not AudioManager.is_ready():
			print("GameStateManager: Waiting for AudioManager...")
			await AudioManager.audio_manager_ready

func _connect_managers():
	"""Conecta con otros managers del juego"""
	# InputManager
	if _is_input_manager_available():
		InputManager.input_action_pressed.connect(_on_input_action_pressed)
		print("GameStateManager: Connected to InputManager")
		_log_to_debug("GameStateManager: Connected to InputManager", "green")
	
	# AudioManager - preparar para eventos de audio
	if _is_audio_manager_available():
		print("GameStateManager: Connected to AudioManager")
		_log_to_debug("GameStateManager: Connected to AudioManager", "green")

func _setup_initial_state():
	"""Configura el estado inicial del juego"""
	# Solo configurar el estado inicial sin transiciones complejas
	current_state = GameState.MAIN_MENU

func _setup_state_machine():
	"""Configura e integra el StateMachine"""
	print("GameStateManager: Setting up StateMachine integration...")
	
	# Cargar la clase StateMachine
	var StateMachineClass = load("res://Core/StateMachine/StateMachine.gd")
	
	# Crear StateMachine si no existe
	if not state_machine:
		state_machine = StateMachineClass.new()
		state_machine.debug_mode = true
		state_machine.auto_register_children = false  # Lo manejaremos manualmente
		add_child(state_machine)
		
		# Conectar señales del StateMachine
		state_machine.state_changed.connect(_on_state_machine_changed)
		state_machine.state_entered.connect(_on_state_machine_entered)
		state_machine.state_exited.connect(_on_state_machine_exited)
		
		print("GameStateManager: StateMachine created and configured")
	
	# Agregar estados al StateMachine
	_register_state_machine_states()

func _register_state_machine_states():
	"""Registra los estados del juego en el StateMachine"""
	print("GameStateManager: Registering states...")
	
	# Cargar las clases de estado
	var LoadingStateClass = load("res://Core/StateMachine/States/LoadingState.gd")
	var MainMenuStateClass = load("res://Core/StateMachine/States/MainMenuState.gd")
	var GameplayStateClass = load("res://Core/StateMachine/States/GameplayState.gd")
	var PausedStateClass = load("res://Core/StateMachine/States/PausedState.gd")
	var SettingsStateClass = load("res://Core/StateMachine/States/SettingsState.gd")
	
	# Crear instancias de los estados
	var loading_state = LoadingStateClass.new()
	loading_state.name = "LoadingState"
	
	var main_menu_state = MainMenuStateClass.new()
	main_menu_state.name = "MainMenuState"
	
	var gameplay_state = GameplayStateClass.new()
	gameplay_state.name = "GameplayState"
	
	var paused_state = PausedStateClass.new()
	paused_state.name = "PausedState"
	
	var settings_state = SettingsStateClass.new()
	settings_state.name = "SettingsState"
	
	# Agregar estados al StateMachine
	state_machine.add_child(loading_state)
	state_machine.add_state("LoadingState", loading_state)
	
	state_machine.add_child(main_menu_state)
	state_machine.add_state("MainMenuState", main_menu_state)
	
	state_machine.add_child(gameplay_state)
	state_machine.add_state("GameplayState", gameplay_state)
	
	state_machine.add_child(paused_state)
	state_machine.add_state("PausedState", paused_state)
	
	state_machine.add_child(settings_state)
	state_machine.add_state("SettingsState", settings_state)
	
	print("GameStateManager: All states registered successfully")

# Callbacks del StateMachine
func _on_state_machine_changed(from_state: String, to_state: String):
	"""Maneja cambios de estado del StateMachine"""
	print("GameStateManager: StateMachine transition: %s → %s" % [from_state, to_state])
	_log_to_debug("StateMachine: %s → %s" % [from_state, to_state], "yellow")

func _on_state_machine_entered(state_name: String):
	"""Maneja entrada a estados del StateMachine"""
	print("GameStateManager: Entered StateMachine state: %s" % state_name)

func _on_state_machine_exited(state_name: String):
	"""Maneja salida de estados del StateMachine"""
	print("GameStateManager: Exited StateMachine state: %s" % state_name)

# =======================
#  VERIFICACIONES DE MANAGERS
# =======================
func _is_input_manager_available() -> bool:
	return get_node_or_null("/root/InputManager") != null

func _is_config_manager_available() -> bool:
	return get_node_or_null("/root/ConfigManager") != null

func _is_audio_manager_available() -> bool:
	return get_node_or_null("/root/AudioManager") != null

func is_ready() -> bool:
	return is_initialized

# =======================
#  PERSISTENCIA DE DATOS
# =======================
func _load_persistent_data():
	"""Carga datos persistentes desde ConfigManager"""
	if not _is_config_manager_available():
		print("GameStateManager: ConfigManager not available, using default values")
		_log_to_debug("GameStateManager: ConfigManager not available", "orange")
		return
	
	# Cargar mejor tiempo
	run_best_time = ConfigManager.get_setting("game_progress", "best_time", 0.0)
	
	# Cargar estadísticas
	var stats = ConfigManager.get_section("game_progress")
	if stats.size() > 0:
		run_statistics.total_runs_completed = stats.get("total_completed", 0)
		run_statistics.total_runs_failed = stats.get("total_failed", 0)
		run_statistics.total_runs_started = stats.get("total_started", 0)
		run_statistics.best_streak = stats.get("best_streak", 0)
		run_statistics.total_time_played = stats.get("total_time_played", 0.0)
		run_statistics.fastest_completion = stats.get("fastest_completion", 0.0)
		run_statistics.average_completion_time = stats.get("average_completion_time", 0.0)
	
	# La racha actual siempre empieza en 0
	run_statistics.current_streak = 0
	
	print("GameStateManager: Loaded persistent data - Best: %.3fs, Completed: %d, Failed: %d" % [
		run_best_time, run_statistics.total_runs_completed, run_statistics.total_runs_failed
	])
	_log_to_debug("GameStateManager: Loaded stats - Best: %.3fs" % run_best_time, "cyan")

func _save_persistent_data():
	"""Guarda datos persistentes en ConfigManager"""
	if not _is_config_manager_available():
		return
	
	# Guardar todo en la sección game_progress
	var progress_data = {
		"best_time": run_best_time,
		"total_completed": run_statistics.total_runs_completed,
		"total_failed": run_statistics.total_runs_failed,
		"total_started": run_statistics.total_runs_started,
		"best_streak": run_statistics.best_streak,
		"total_time_played": run_statistics.total_time_played,
		"fastest_completion": run_statistics.fastest_completion,
		"average_completion_time": run_statistics.average_completion_time
	}
	
	ConfigManager.set_section("game_progress", progress_data)
	print("GameStateManager: Saved persistent data")
	_log_to_debug("GameStateManager: Saved persistent data", "green")

# =======================
#  GESTIÓN DE ESTADOS
# =======================
func change_state(new_state: GameState):
	"""Cambia al nuevo estado con validaciones"""
	if new_state == current_state:
		return
	
	# Validar transición
	if not _can_change_to_state(new_state):
		var error_msg = "INVALID transition from %s to %s" % [
			GameState.keys()[current_state], GameState.keys()[new_state]
		]
		print("GameStateManager: %s" % error_msg)
		_log_to_debug("GameStateManager: %s" % error_msg, "red")
		return
	
	var old_state = current_state
	previous_state = current_state
	current_state = new_state
	
	var transition_msg = "%s → %s" % [GameState.keys()[old_state], GameState.keys()[new_state]]
	print("GameStateManager: %s" % transition_msg)
	_log_to_debug("GameStateManager: %s" % transition_msg, "yellow")
	
	# Ejecutar lógica de salida del estado anterior
	_exit_state(old_state)
	
	# Ejecutar lógica de entrada del nuevo estado
	_enter_state(new_state)
	
	# INTEGRACIÓN: También cambiar estado en StateMachine
	if state_machine:
		var state_name = _game_state_to_state_machine_name(new_state)
		if state_machine.has_state(state_name):
			var transition_data = _prepare_transition_data(new_state)
			state_machine.transition_to(state_name, transition_data)
		else:
			print("GameStateManager: Warning - StateMachine state '%s' not found" % state_name)
	
	# Actualizar InputManager
	_update_input_context()
	
	# Emitir señal
	state_changed.emit(old_state, new_state)

func _can_change_to_state(new_state: GameState) -> bool:
	"""Valida si es posible cambiar a un estado"""
	match current_state:
		GameState.LOADING:
			return new_state == GameState.MAIN_MENU
		
		GameState.MAIN_MENU:
			return new_state in [GameState.PLAYING, GameState.LOADING]
		
		GameState.PLAYING:
			return new_state in [GameState.PAUSED, GameState.RUN_COMPLETE, GameState.RUN_FAILED, GameState.MAIN_MENU]
		
		GameState.PAUSED:
			return new_state in [GameState.PLAYING, GameState.MAIN_MENU]
		
		GameState.RUN_COMPLETE:
			return new_state in [GameState.MAIN_MENU, GameState.PLAYING, GameState.VICTORY]
		
		GameState.RUN_FAILED:
			return new_state in [GameState.MAIN_MENU, GameState.PLAYING, GameState.GAME_OVER]
		
		GameState.GAME_OVER, GameState.VICTORY:
			return new_state in [GameState.MAIN_MENU, GameState.PLAYING]
	
	return true

func _enter_state(state: GameState):
	"""Lógica al entrar a un estado"""
	match state:
		GameState.LOADING:
			_resume_game_tree()
		
		GameState.MAIN_MENU:
			_resume_game_tree()
			_play_menu_music()
		
		GameState.PLAYING:
			_resume_game_tree()
			if not is_run_active:
				_start_new_run()
			else:
				game_started.emit()
			_play_gameplay_music()
		
		GameState.PAUSED:
			_pause_game_tree()
			_pause_run_timer()
			game_paused.emit()
			_play_pause_sound()
		
		GameState.RUN_COMPLETE:
			_resume_game_tree()
			_complete_run(true)
		
		GameState.RUN_FAILED:
			_resume_game_tree()
			_complete_run(false)
		
		GameState.GAME_OVER:
			_resume_game_tree()
			_play_game_over_sound()
		
		GameState.VICTORY:
			_resume_game_tree()
			_play_victory_sound()

func _exit_state(state: GameState):
	"""Lógica al salir de un estado"""
	match state:
		GameState.PAUSED:
			_resume_run_timer()
			game_resumed.emit()

# =======================
#  CONTROL DE PAUSA/RESUME
# =======================
func _pause_game_tree():
	"""Pausa el árbol de nodos del juego"""
	get_tree().paused = true
	_log_to_debug("Game tree PAUSED", "orange")

func _resume_game_tree():
	"""Resume el árbol de nodos del juego"""
	get_tree().paused = false
	_log_to_debug("Game tree RESUMED", "green")

# =======================
#  FUNCIONES PÚBLICAS DE CONTROL
# =======================
func start_new_run():
	"""Inicia una nueva run"""
	if is_run_active:
		print("GameStateManager: Cannot start new run - already active")
		_log_to_debug("GameStateManager: Cannot start new run - already active", "orange")
		return false
	
	change_state(GameState.PLAYING)
	return true

func complete_run():
	"""Completa la run exitosamente"""
	if is_run_active:
		change_state(GameState.RUN_COMPLETE)

func fail_run():
	"""Falla la run (por muerte del jugador)"""
	if is_run_active:
		change_state(GameState.RUN_FAILED)

func pause_game():
	"""Pausa el juego si es posible"""
	if current_state == GameState.PLAYING and _can_pause():
		change_state(GameState.PAUSED)

func resume_game():
	"""Resume el juego desde pausa"""
	if current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)

func return_to_main_menu():
	"""Vuelve al menú principal"""
	change_state(GameState.MAIN_MENU)

func toggle_pause():
	"""Alterna entre pausa y resume"""
	if current_state == GameState.PLAYING:
		pause_game()
	elif current_state == GameState.PAUSED:
		resume_game()

func _can_pause() -> bool:
	"""Verifica si se puede pausar (con cooldown)"""
	var current_time = Time.get_unix_time_from_system()
	return current_time - last_pause_input_time >= pause_input_cooldown

# =======================
#  SISTEMA DE RUNS
# =======================
func _start_new_run():
	"""Lógica interna para iniciar nueva run"""
	current_run_number += 1
	is_run_active = true
	run_start_time = Time.get_time_dict_from_system()["unix"]
	total_pause_duration = 0.0
	
	# Actualizar estadísticas
	run_statistics.total_runs_started += 1
	
	run_started.emit(current_run_number)
	player_spawned.emit()
	
	var start_msg = "Started run #%d" % current_run_number
	print("GameStateManager: %s" % start_msg)
	_log_to_debug("GameStateManager: %s" % start_msg, "green")

func _complete_run(success: bool):
	"""Lógica interna para completar run"""
	if not is_run_active:
		return
	
	var final_time = get_current_run_time()
	is_run_active = false
	
	if success:
		run_statistics.total_runs_completed += 1
		run_statistics.current_streak += 1
		run_statistics.total_time_played += final_time
		
		# Actualizar tiempos
		if run_statistics.fastest_completion == 0.0 or final_time < run_statistics.fastest_completion:
			run_statistics.fastest_completion = final_time
		
		# Calcular tiempo promedio
		run_statistics.average_completion_time = run_statistics.total_time_played / run_statistics.total_runs_completed
		
		# Verificar nuevo record
		if run_best_time == 0.0 or final_time < run_best_time:
			run_best_time = final_time
			new_best_time.emit(final_time)
			_play_new_record_sound()
			var record_msg = "🏆 NEW BEST TIME! %.3f seconds" % final_time
			print("GameStateManager: %s" % record_msg)
			_log_to_debug("GameStateManager: %s" % record_msg, "yellow")
		
		run_completed.emit(current_run_number, final_time)
		var complete_msg = "✅ Run #%d completed in %.3f seconds" % [current_run_number, final_time]
		print("GameStateManager: %s" % complete_msg)
		_log_to_debug("GameStateManager: %s" % complete_msg, "green")
		
	else:
		run_statistics.total_runs_failed += 1
		run_statistics.current_streak = 0
		
		run_failed.emit(current_run_number, final_time)
		player_died.emit()
		var fail_msg = "❌ Run #%d failed after %.3f seconds" % [current_run_number, final_time]
		print("GameStateManager: %s" % fail_msg)
		_log_to_debug("GameStateManager: %s" % fail_msg, "red")
	
	# Actualizar mejor racha
	if run_statistics.current_streak > run_statistics.best_streak:
		run_statistics.best_streak = run_statistics.current_streak
	
	# Guardar datos y emitir señal de actualización
	_save_persistent_data()
	statistics_updated.emit()

func _pause_run_timer():
	"""Pausa el timer de la run"""
	if is_run_active:
		run_pause_time = Time.get_time_dict_from_system()["unix"]

func _resume_run_timer():
	"""Resume el timer de la run"""
	if is_run_active and run_pause_time > 0.0:
		var pause_duration = Time.get_time_dict_from_system()["unix"] - run_pause_time
		total_pause_duration += pause_duration
		run_pause_time = 0.0

# =======================
#  GETTERS DE TIEMPO
# =======================
func get_current_run_time() -> float:
	"""Obtiene el tiempo actual de la run (sin pausas)"""
	if not is_run_active:
		return 0.0
	
	var current_time = Time.get_time_dict_from_system()["unix"]
	var elapsed = current_time - run_start_time - total_pause_duration
	
	# Si está pausado, no contar el tiempo de pausa actual
	if current_state == GameState.PAUSED and run_pause_time > 0.0:
		elapsed -= (current_time - run_pause_time)
	
	return elapsed

func get_run_time_formatted() -> String:
	"""Tiempo con milisegundos: MM:SS.mmm"""
	var total_seconds = get_current_run_time()
	var minutes = int(total_seconds) / 60.0
	var seconds = int(total_seconds) % 60
	var milliseconds = int((total_seconds - int(total_seconds)) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]

func get_run_time_formatted_simple() -> String:
	"""Tiempo simple: MM:SS"""
	var total_seconds = get_current_run_time()
	var minutes = int(total_seconds) / 60.0
	var seconds = int(total_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func get_best_time() -> float:
	return run_best_time

func get_best_time_formatted() -> String:
	"""Mejor tiempo con milisegundos"""
	if run_best_time == 0.0:
		return "--:--.---"
	var minutes = int(run_best_time) / 60.0
	var seconds = int(run_best_time) % 60
	var milliseconds = int((run_best_time - int(run_best_time)) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]

func get_best_time_formatted_simple() -> String:
	"""Mejor tiempo simple"""
	if run_best_time == 0.0:
		return "--:--"
	var minutes = int(run_best_time) / 60.0
	var seconds = int(run_best_time) % 60
	return "%02d:%02d" % [minutes, seconds]

# =======================
#  GETTERS DE ESTADO
# =======================
func get_current_state() -> GameState:
	return current_state

func get_previous_state() -> GameState:
	return previous_state

func is_in_state(state: GameState) -> bool:
	return current_state == state

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func is_paused() -> bool:
	return current_state == GameState.PAUSED

func is_in_main_menu() -> bool:
	return current_state == GameState.MAIN_MENU

func get_is_run_active() -> bool:
	"""Verifica si hay una run activa"""
	return is_run_active

func get_current_run_number() -> int:
	return current_run_number

func is_run_finished() -> bool:
	return current_state in [GameState.RUN_COMPLETE, GameState.RUN_FAILED, GameState.GAME_OVER, GameState.VICTORY]

# =======================
#  GETTERS DE ESTADÍSTICAS
# =======================
func get_current_streak() -> int:
	return run_statistics.current_streak

func get_best_streak() -> int:
	return run_statistics.best_streak

func get_total_runs_completed() -> int:
	return run_statistics.total_runs_completed

func get_total_runs_failed() -> int:
	return run_statistics.total_runs_failed

func get_total_runs_started() -> int:
	return run_statistics.total_runs_started

func get_completion_rate() -> float:
	"""Tasa de completación (0.0 a 1.0)"""
	if run_statistics.total_runs_started == 0:
		return 0.0
	return float(run_statistics.total_runs_completed) / float(run_statistics.total_runs_started)

func get_average_completion_time() -> float:
	return run_statistics.average_completion_time

func get_fastest_completion_time() -> float:
	return run_statistics.fastest_completion

func get_total_time_played() -> float:
	return run_statistics.total_time_played

func get_run_statistics() -> Dictionary:
	"""Obtiene todas las estadísticas"""
	return run_statistics.duplicate()

# =======================
#  INTEGRACIÓN CON INPUTMANAGER
# =======================
func _update_input_context():
	"""Actualiza el contexto de InputManager"""
	if not _is_input_manager_available():
		return
	
	var input_context
	match current_state:
		GameState.LOADING:
			input_context = InputManager.InputContext.UI_MENU
		GameState.MAIN_MENU:
			input_context = InputManager.InputContext.UI_MENU
		GameState.PLAYING:
			input_context = InputManager.InputContext.GAMEPLAY
		GameState.PAUSED:
			input_context = InputManager.InputContext.PAUSE
		GameState.RUN_COMPLETE, GameState.RUN_FAILED, GameState.GAME_OVER, GameState.VICTORY:
			input_context = InputManager.InputContext.UI_MENU
	
	InputManager.set_input_context(input_context)

func _on_input_action_pressed(action: String):
	"""Maneja acciones de input con cooldown"""
	var current_time = Time.get_unix_time_from_system()
	
	match action:
		"pause":
			if current_state == GameState.PLAYING and _can_pause():
				last_pause_input_time = current_time
				pause_game()

func on_player_died():
	"""Callback cuando el jugador muere"""
	print("GameStateManager: Player died - transitioning to RUN_FAILED")
	_log_to_debug("Player died!", "red")
	
	# Emitir señal
	player_died.emit()
	
	# Cambiar estado a run fallida
	change_state(GameState.RUN_FAILED)

# =======================
#  INTEGRACIÓN CON AUDIOMANAGER
# =======================
func _play_menu_music():
	if _is_audio_manager_available():
		# AudioManager.play_music(preload("res://audio/menu_music.ogg"))
		pass

func _play_gameplay_music():
	if _is_audio_manager_available():
		# AudioManager.play_music(preload("res://audio/gameplay_music.ogg"))
		pass

func _play_pause_sound():
	if _is_audio_manager_available():
		# AudioManager.play_ui_sfx(preload("res://audio/pause.ogg"))
		pass

func _play_victory_sound():
	if _is_audio_manager_available():
		# AudioManager.play_ui_sfx(preload("res://audio/victory.ogg"))
		pass

func _play_game_over_sound():
	if _is_audio_manager_available():
		# AudioManager.play_ui_sfx(preload("res://audio/game_over.ogg"))
		pass

func _play_new_record_sound():
	if _is_audio_manager_available():
		# AudioManager.play_ui_sfx(preload("res://audio/new_record.ogg"))
		pass

# =======================
#  INPUT FALLBACK
# =======================
func _unhandled_input(event):
	"""Fallback input si InputManager no está disponible"""
	if _is_input_manager_available():
		return
	
	# Solo procesar eventos de teclado
	if not event is InputEventKey or not event.pressed:
		return
	
	if event.keycode == KEY_ESCAPE:
		match current_state:
			GameState.PLAYING:
				pause_game()
				get_viewport().set_input_as_handled()
			GameState.PAUSED:
				resume_game()
				get_viewport().set_input_as_handled()

# =======================
#  UTILIDADES
# =======================
func reset_all_statistics():
	"""Resetea todas las estadísticas (¡PELIGROSO!)"""
	run_statistics = {
		"total_runs_completed": 0,
		"total_runs_failed": 0,
		"total_runs_started": 0,
		"current_streak": 0,
		"best_streak": 0,
		"total_time_played": 0.0,
		"fastest_completion": 0.0,
		"average_completion_time": 0.0
	}
	run_best_time = 0.0
	_save_persistent_data()
	statistics_updated.emit()
	print("GameStateManager: ⚠️ ALL STATISTICS RESET!")
	_log_to_debug("GameStateManager: ⚠️ ALL STATISTICS RESET!", "red")

# =======================
#  FUNCIONES DE DEBUG MEJORADAS
# =======================
func debug_info():
	"""Muestra información completa de debug"""
	print("=== 🎮 GAMESTATE MANAGER DEBUG ===")
	print("Current State: %s" % GameState.keys()[current_state])
	print("Previous State: %s" % GameState.keys()[previous_state])
	print("Initialized: %s" % is_initialized)
	print("Tree Paused: %s" % get_tree().paused)
	print("")
	print("=== 🏃 RUN INFO ===")
	print("Current Run: #%d" % current_run_number)
	print("Run Active: %s" % is_run_active)
	if is_run_active:
		print("Run Time: %s (precise: %s)" % [get_run_time_formatted_simple(), get_run_time_formatted()])
	print("Best Time: %s (%.3fs)" % [get_best_time_formatted_simple(), run_best_time])
	print("")
	print("=== 📊 STATISTICS ===")
	print("Completed: %d | Failed: %d | Started: %d" % [
		run_statistics.total_runs_completed,
		run_statistics.total_runs_failed, 
		run_statistics.total_runs_started
	])
	print("Current Streak: %d | Best Streak: %d" % [run_statistics.current_streak, run_statistics.best_streak])
	print("Completion Rate: %.1f%%" % (get_completion_rate() * 100))
	if run_statistics.total_runs_completed > 0:
		print("Average Time: %.3fs | Fastest: %.3fs" % [
			run_statistics.average_completion_time, 
			run_statistics.fastest_completion
		])
	print("Total Time Played: %.1fs (%.1f minutes)" % [
		run_statistics.total_time_played,
		run_statistics.total_time_played / 60.0
	])
	print("")
	print("=== 🔧 MANAGERS ===")
	print("InputManager: %s" % ("✅" if _is_input_manager_available() else "❌"))
	print("ConfigManager: %s" % ("✅" if _is_config_manager_available() else "❌"))
	print("AudioManager: %s" % ("✅" if _is_audio_manager_available() else "❌"))
	print("==============================")

func debug_complete_run():
	"""Debug: completa la run actual"""
	if is_run_active:
		complete_run()
		print("DEBUG: ✅ Completed current run")
		_log_to_debug("DEBUG: ✅ Completed current run", "green")
	else:
		print("DEBUG: ❌ No active run to complete")
		_log_to_debug("DEBUG: ❌ No active run to complete", "red")

func debug_fail_run():
	"""Debug: falla la run actual"""
	if is_run_active:
		fail_run()
		print("DEBUG: ❌ Failed current run")
		_log_to_debug("DEBUG: ❌ Failed current run", "orange")
	else:
		print("DEBUG: ❌ No active run to fail")
		_log_to_debug("DEBUG: ❌ No active run to fail", "red")

func debug_start_run():
	"""Debug: inicia nueva run"""
	if start_new_run():
		print("DEBUG: ✅ Started new run #%d" % current_run_number)
		_log_to_debug("DEBUG: ✅ Started new run #%d" % current_run_number, "green")
	else:
		print("DEBUG: ❌ Cannot start run (already active)")
		_log_to_debug("DEBUG: ❌ Cannot start run (already active)", "red")

func debug_force_state(state: GameState):
	"""Debug: fuerza un cambio de estado"""
	var old_state = current_state
	current_state = state
	var msg = "⚠️ FORCED state %s → %s" % [GameState.keys()[old_state], GameState.keys()[state]]
	print("DEBUG: %s" % msg)
	_log_to_debug("DEBUG: %s" % msg, "orange")

func debug_add_fake_stats(completed: int, failed: int):
	"""Debug: añade estadísticas falsas para testing"""
	run_statistics.total_runs_completed += completed
	run_statistics.total_runs_failed += failed
	run_statistics.total_runs_started += completed + failed
	_save_persistent_data()
	statistics_updated.emit()
	var msg = "Added %d completed, %d failed runs" % [completed, failed]
	print("DEBUG: %s" % msg)
	_log_to_debug("DEBUG: %s" % msg, "yellow")

func debug_set_fake_best_time(time: float):
	"""Debug: establece un mejor tiempo falso"""
	run_best_time = time
	_save_persistent_data()
	var msg = "Set fake best time to %.3fs" % time
	print("DEBUG: %s" % msg)
	_log_to_debug("DEBUG: %s" % msg, "yellow")

func get_debug_summary() -> Dictionary:
	"""Retorna resumen de debug"""
	return {
		"current_state": GameState.keys()[current_state],
		"previous_state": GameState.keys()[previous_state],
		"initialized": is_initialized,
		"run_active": is_run_active,
		"current_run": current_run_number,
		"current_time": get_run_time_formatted() if is_run_active else "N/A",
		"best_time": get_best_time_formatted(),
		"total_completed": run_statistics.total_runs_completed,
		"total_failed": run_statistics.total_runs_failed,
		"current_streak": run_statistics.current_streak,
		"completion_rate": "%.1f%%" % (get_completion_rate() * 100)
	}

# =======================
#  INTEGRACIÓN CON DEBUG
# =======================
func _log_to_debug(message: String, color: String = "white"):
	"""Envía mensaje al sistema de debug si está disponible"""
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager and debug_manager.has_method("log_to_console"):
		debug_manager.log_to_console(message, color)

# =======================
#  INTEGRACIÓN STATEMACHINE
# =======================
func _game_state_to_state_machine_name(game_state: GameState) -> String:
	"""Convierte GameState enum a nombre de estado del StateMachine"""
	match game_state:
		GameState.LOADING:
			return "LoadingState"
		GameState.MAIN_MENU:
			return "MainMenuState"
		GameState.PLAYING:
			return "GameplayState"
		GameState.PAUSED:
			return "PausedState"
		GameState.RUN_COMPLETE, GameState.RUN_FAILED, GameState.GAME_OVER, GameState.VICTORY:
			return "MainMenuState"  # Estos estados regresan al menú
		_:
			return "MainMenuState"  # Fallback

func _prepare_transition_data(game_state: GameState) -> Dictionary:
	"""Prepara datos para la transición del StateMachine"""
	var data = {}
	
	match game_state:
		GameState.PLAYING:
			data["run_number"] = current_run_number
			data["is_new_run"] = not is_run_active
		GameState.PAUSED:
			data["pause_reason"] = "user_input"
			data["run_time"] = get_current_run_time()
		GameState.RUN_COMPLETE:
			data["completion_time"] = get_current_run_time()
			data["run_number"] = current_run_number
		GameState.RUN_FAILED:
			data["failure_time"] = get_current_run_time()
			data["run_number"] = current_run_number
	
	return data

func get_state_machine() -> StateMachine:
	"""Obtiene referencia al StateMachine"""
	return state_machine

func start_state_machine():
	"""Inicia el StateMachine con el estado actual"""
	if state_machine:
		var state_name = _game_state_to_state_machine_name(current_state)
		var transition_data = _prepare_transition_data(current_state)
		state_machine.start(state_name, transition_data)
		print("GameStateManager: StateMachine started with %s" % state_name)

# =======================
#  CLEANUP
# =======================
func _exit_tree():
	# Guardar datos antes de salir
	_save_persistent_data()
	
	# Desconectar señales
	if _is_input_manager_available() and InputManager.input_action_pressed.is_connected(_on_input_action_pressed):
		InputManager.input_action_pressed.disconnect(_on_input_action_pressed)
	
	print("GameStateManager: 🔥 Cleanup complete")
	_log_to_debug("GameStateManager: 🔥 Cleanup complete", "green")
