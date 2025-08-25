extends "res://Core/StateMachine/State.gd"
class_name MainMenuState
# Estado del menú principal - integrado con GameStateManager

func enter(_previous_state: State = null) -> void:
	if state_machine and state_machine.debug_mode:
		print("🏠 Entering MainMenuState")
	
	# Notificar al GameStateManager que estamos en el menú
	if has_node("/root/GameStateManager"):
		var gsm = get_node("/root/GameStateManager")
		if gsm.current_state != gsm.GameState.MAIN_MENU:
			print("MainMenuState: Syncing GameStateManager to MAIN_MENU")
	
	# Notificar que entramos al menú principal
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("menu_entered", {"menu": "main"})
	
	# Configurar input context
	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		if input_manager.has_method("set_context"):
			input_manager.set_context("UI_MENU")
	
	# Cargar la escena del menú principal si no está cargada
	_ensure_main_menu_scene()

func _ensure_main_menu_scene():
	"""Asegura que la escena del menú principal esté cargada"""
	var current_scene = get_tree().current_scene
	
	# Si no estamos en MainMenu.tscn, cargarla
	if not current_scene or current_scene.scene_file_path != "res://Scenes/Menus/MainMenu.tscn":
		print("MainMenuState: Loading MainMenu scene...")
		get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")

func handle_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# Salir del juego desde el menú principal
				_quit_game()
			KEY_ENTER, KEY_SPACE:
				# Iniciar juego
				_start_game()
			KEY_S:
				# Abrir configuración
				_open_settings()

func _start_game():
	"""Inicia el juego usando GameStateManager"""
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
	"""Abre configuración"""
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
			# Fallback a cambio de escena directo
			get_tree().change_scene_to_file("res://Scenes/Menus/SettingsMenu.tscn")
	else:
		transition_to("SettingsState")

func _quit_game():
	"""Cierra el juego"""
	if state_machine and state_machine.debug_mode:
		print("👋 Quitting game...")
	
	# Notificar al GameStateManager para cleanup
	if has_node("/root/GameStateManager"):
		var gsm = get_node("/root/GameStateManager")
		if gsm.has_method("_save_persistent_data"):
			gsm._save_persistent_data()
	
	get_tree().quit()

func exit() -> void:
	if state_machine and state_machine.debug_mode:
		print("🏠 Exiting MainMenuState")
	
	# Notificar que salimos del menú
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("menu_exited", {"menu": "main"})
