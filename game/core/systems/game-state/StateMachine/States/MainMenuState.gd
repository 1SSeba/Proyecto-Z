extends "res://game/systems/game-state/StateMachine/State.gd"

# MainMenuState - Estado del menú principal
# Versión simplificada que funciona con MainMenu

var main_menu_scene: Node = null
var is_menu_connected: bool = false

func enter(_previous_state: State = null) -> void:
	print("🏠 Entering MainMenuState")
	
	# Asegurar que la escena del menú principal esté activa
	await _ensure_main_menu_scene()
	
	# Configurar contexto de input
	_setup_input_context()
	
	# Notificar a otros sistemas
	_notify_menu_entered()
	
	# Conectar señales del menú si no están conectadas
	_connect_menu_signals()
	
	# Configuraciones adicionales
	_setup_menu_configuration()
	
	print("MainMenuState: ✅ Ready and active")

func exit(_next_state: State = null) -> void:
	print("🏠 Exiting MainMenuState")
	
	# Desconectar señales del menú
	_disconnect_menu_signals()
	# Notificar salida del menú: keep this minimal to avoid calling globals during teardown.
	# Projects with an EventBus can override _notify_menu_exited if they need custom behavior.
	_notify_menu_exited()


func _notify_menu_exited():
	# Default no-op notification hook. Override in a subclass if needed.
	return


func _setup_input_context():
	Default no-op implementation provided so the analyzer and other code can call
	this method without requiring a project-specific implementation.


func _notify_menu_entered():
	Default implementation is a no-op; projects can extend this state to notify
	other systems (EventBus, telemetry, etc.).


func _setup_menu_configuration():
	No-op by default; override in subsclasses for custom menu configuration.

func _ensure_main_menu_scene():
	
	var current_scene = get_tree().current_scene
	
	# Si ya estamos en MainMenu, usar la escena actual
	if current_scene and current_scene.has_signal("start_game_requested"):
		main_menu_scene = current_scene
		print("MainMenuState: Using current MainMenu scene")
		return
	
	# Si no, cargar la escena del menú principal
	var main_menu_path = "res://game/ui/MainMenu.tscn"
	if ResourceLoader.exists(main_menu_path):
		print("MainMenuState: Loading MainMenu scene")
		get_tree().change_scene_to_file(main_menu_path)
		# Esperar un frame para que la escena se cargue
		await get_tree().process_frame
		main_menu_scene = get_tree().current_scene
	else:
		print("MainMenuState: ERROR - MainMenu scene not found at: " + main_menu_path)

func _connect_menu_signals():
	
	if not main_menu_scene:
		main_menu_scene = get_tree().current_scene
	
	if main_menu_scene and main_menu_scene.has_signal("start_game_requested"):
		var cb_start = Callable(self, "_on_start_game_requested")
		if not main_menu_scene.is_connected("start_game_requested", cb_start):
			main_menu_scene.connect("start_game_requested", cb_start)

		var cb_settings = Callable(self, "_on_settings_requested")
		if not main_menu_scene.is_connected("settings_requested", cb_settings):
			main_menu_scene.connect("settings_requested", cb_settings)

		var cb_quit = Callable(self, "_on_quit_requested")
		if not main_menu_scene.is_connected("quit_requested", cb_quit):
			main_menu_scene.connect("quit_requested", cb_quit)
		
		print("MainMenuState: Connected to menu signals")

func _disconnect_menu_signals():
	
	if main_menu_scene and main_menu_scene.has_signal("start_game_requested"):
		var cb_start = Callable(self, "_on_start_game_requested")
		if main_menu_scene.is_connected("start_game_requested", cb_start):
			main_menu_scene.disconnect("start_game_requested", cb_start)

		var cb_settings = Callable(self, "_on_settings_requested")
		if main_menu_scene.is_connected("settings_requested", cb_settings):
			main_menu_scene.disconnect("settings_requested", cb_settings)

		var cb_quit = Callable(self, "_on_quit_requested")
		if main_menu_scene.is_connected("quit_requested", cb_quit):
			main_menu_scene.disconnect("quit_requested", cb_quit)

# =======================
#  MANEJADORES DE SEÑALES DEL MENÚ
# =======================
func _on_start_game_requested():
	
	print("MainMenuState: Start game requested")
	
	# Transición a estado de carga
	if state_machine:
		state_machine.change_state("LoadingState")

func _on_settings_requested():
	
	print("MainMenuState: Settings requested")
	
	# Transición a estado de settings
	if state_machine:
		state_machine.change_state("SettingsState")

func _on_quit_requested():
	
	print("MainMenuState: Quit requested")
	
	# Confirmar y salir
	get_tree().quit()

# =======================
#  UTILIDADES
# =======================
func get_state_name() -> String:
	return "MainMenuState"

func handle_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# En el menú principal, ESC no debería cerrar el juego inmediatamente
				# Solo ignorar o mostrar diálogo de confirmación
				if state_machine and state_machine.debug_mode:
					print("🏠 ESC pressed in MainMenu - ignoring")
			KEY_ENTER, KEY_SPACE:
				# Iniciar juego
				_start_game()
			KEY_Q:
				# Ctrl+Q para cerrar el juego (estándar en Linux)
				if event.ctrl_pressed:
					if state_machine and state_machine.debug_mode:
						print("👋 Ctrl+Q pressed - closing game")
					_quit_game()
			KEY_F4:
				# Alt+F4 para cerrar el juego (estándar en Windows)
				if event.alt_pressed:
					if state_machine and state_machine.debug_mode:
						print("👋 Alt+F4 pressed - closing game")
					_quit_game()
			KEY_S:
				# Abrir configuración
				_open_settings()

func _start_game():
	
	if state_machine and state_machine.debug_mode:
		print("🎮 Starting game via GameStateManager...")
	
	# Usar GameStateManager para iniciar el juego
	if has_node("/root/GameStateManager"):
		var gsm = get_node("/root/GameStateManager")
		if gsm.has_method("start_game"):
			gsm.start_game(1)  # Iniciar run 1
		else:
			gsm.change_state(gsm.GameState.PLAYING)
	else:
		# Fallback al StateMachine básico
		transition_to("GameplayState", {"level": 1})

func _open_settings():
	
	if state_machine and state_machine.debug_mode:
		print("⚙️ Opening settings...")
	
	# Primero intentar usar el main menu integrado
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name == "MainMenu":
		# Si estamos en la escena del main menu, buscar settings embebidos
		var main_menu_script = current_scene.get_script()
		if main_menu_script and current_scene.has_method("_on_settings_pressed"):
			print("MainMenuState: Using embedded settings menu")
			current_scene._on_settings_pressed()
			return
	
	# Usar GameStateManager si está disponible
	if has_node("/root/GameStateManager"):
		var gsm = get_node("/root/GameStateManager")
		if gsm.has_method("open_settings"):
			gsm.open_settings("MainMenu")
		else:
			# Cambiar a escena de settings
			get_tree().change_scene_to_file("res://game/scenes/menus/SettingsMenu.tscn")
	else:
		transition_to("SettingsState")

func _quit_game():
	
	if state_machine and state_machine.debug_mode:
		print("👋 Quitting game...")
	
	# Notificar al GameStateManager para cleanup
	if has_node("/root/GameStateManager"):
		var gsm = get_node("/root/GameStateManager")
		if gsm.has_method("_save_persistent_data"):
			gsm._save_persistent_data()
	
	get_tree().quit()

# (exit already defined earlier with a _next_state argument)
