extends "res://src/systems/StateMachine/State.gd"

# MainMenuState - Estado del menú principal mejorado y escalable
# Diseñado para trabajar con MainMenuModular.gd

var main_menu_scene: Node = null
var is_menu_connected: bool = false

func enter(_previous_state: State = null) -> void:
	print("🏠 Entering MainMenuState (Modular Version)")
	
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

func exit() -> void:
	print("🏠 Exiting MainMenuState")
	
	# Desconectar señales del menú
	_disconnect_menu_signals()
	
	# Notificar salida del menú
	_notify_menu_exited()
	
	# Limpiar referencias
	is_menu_connected = false

# =======================
#  CONFIGURACIÓN DE ESCENA
# =======================
func _ensure_main_menu_scene() -> void:
	"""Asegurar que la escena del menú principal esté cargada y activa"""
	var current_scene = get_tree().current_scene
	
	# Si ya estamos en MainMenu compatible, usar la escena actual
	if current_scene and _is_compatible_main_menu(current_scene):
		main_menu_scene = current_scene
		print("MainMenuState: Using current MainMenu scene")
		return
	
	# Cargar la escena del menú principal modular (ahora es la única canonical)
	var main_menu_path = "res://content/scenes/Menus/MainMenuModular.tscn"
	if ResourceLoader.exists(main_menu_path):
		print("MainMenuState: Loading MainMenuModular scene")
		get_tree().change_scene_to_file(main_menu_path)
		# Esperar un frame para que la escena se cargue
		await get_tree().process_frame
		main_menu_scene = get_tree().current_scene
	else:
		print("MainMenuState: ERROR - MainMenuModular.tscn not found. Please add it to the project.")

func _is_compatible_main_menu(scene: Node) -> bool:
	"""Verifica si la escena es un menú principal compatible"""
	# Verificar si tiene las señales necesarias
	return (scene.has_signal("start_game_requested") and 
			scene.has_signal("settings_requested") and 
			scene.has_signal("quit_requested"))

# =======================
#  CONFIGURACIÓN DE SISTEMAS
# =======================
func _setup_input_context():
	"""Configura el contexto de input"""
	var input_manager = get_node_or_null("/root/InputManager")
	if input_manager and input_manager.has_method("set_context"):
		input_manager.set_context("UI_MENU")
	elif input_manager and input_manager.has_method("set_input_context"):
		# Usar enum si está disponible, sino usar string como fallback
		if input_manager.has_method("get_input_context_enum"):
			var ui_menu_context = input_manager.get_input_context_enum("UI_MENU")
			if ui_menu_context != null:
				input_manager.set_input_context(ui_menu_context)
		# Si no hay enum disponible, intentar con valor 0 (común para UI)
		else:
			input_manager.set_input_context(0)

func _notify_menu_entered():
	"""Notifica que se entró al menú"""
	if EventBus and EventBus.has_method("publish"):
		EventBus.publish("menu_entered", {"menu": "main", "state": "MainMenuState"})

func _notify_menu_exited():
	"""Notifica que se salió del menú"""
	if EventBus and EventBus.has_method("publish"):
		EventBus.publish("menu_exited", {"menu": "main", "state": "MainMenuState"})

func _setup_menu_configuration():
	"""Configura el menú según el estado del juego"""
	if not main_menu_scene:
		return
	
	# Si el menú tiene método de configuración, usarlo
	if main_menu_scene.has_method("set_button_enabled"):
		# Ejemplo: deshabilitar botón si hay una run activa
		var game_state_manager = get_node_or_null("/root/GameStateManager")
		if game_state_manager and game_state_manager.has_method("get_is_run_active") and game_state_manager.get_is_run_active():
			main_menu_scene.set_button_enabled("start", false)
		else:
			main_menu_scene.set_button_enabled("start", true)

# =======================
#  MANEJO DE SEÑALES
# =======================
func _connect_menu_signals():
	"""Conectar señales del menú principal"""
	if not main_menu_scene or is_menu_connected:
		return
	
	# Verificar que el menú tenga las señales necesarias
	if not _is_compatible_main_menu(main_menu_scene):
		print("MainMenuState: WARNING - Menu scene is not compatible")
		return
	
	# Conectar señales principales
	if not main_menu_scene.start_game_requested.is_connected(_on_start_game_requested):
		main_menu_scene.start_game_requested.connect(_on_start_game_requested)
	
	if not main_menu_scene.settings_requested.is_connected(_on_settings_requested):
		main_menu_scene.settings_requested.connect(_on_settings_requested)
	
	if not main_menu_scene.quit_requested.is_connected(_on_quit_requested):
		main_menu_scene.quit_requested.connect(_on_quit_requested)
	
	# Conectar señales adicionales si existen (para MainMenuModular)
	if main_menu_scene.has_signal("debug_mode_toggled"):
		if not main_menu_scene.debug_mode_toggled.is_connected(_on_debug_mode_toggled):
			main_menu_scene.debug_mode_toggled.connect(_on_debug_mode_toggled)
	
	if main_menu_scene.has_signal("menu_initialized"):
		if not main_menu_scene.menu_initialized.is_connected(_on_menu_initialized):
			main_menu_scene.menu_initialized.connect(_on_menu_initialized)
	
	is_menu_connected = true
	print("MainMenuState: ✅ Connected to menu signals")

func _disconnect_menu_signals():
	"""Desconectar señales del menú principal"""
	if not main_menu_scene or not is_menu_connected:
		return
	
	# Desconectar señales principales
	if main_menu_scene.start_game_requested.is_connected(_on_start_game_requested):
		main_menu_scene.start_game_requested.disconnect(_on_start_game_requested)
	
	if main_menu_scene.settings_requested.is_connected(_on_settings_requested):
		main_menu_scene.settings_requested.disconnect(_on_settings_requested)
	
	if main_menu_scene.quit_requested.is_connected(_on_quit_requested):
		main_menu_scene.quit_requested.disconnect(_on_quit_requested)
	
	# Desconectar señales adicionales
	if main_menu_scene.has_signal("debug_mode_toggled"):
		if main_menu_scene.debug_mode_toggled.is_connected(_on_debug_mode_toggled):
			main_menu_scene.debug_mode_toggled.disconnect(_on_debug_mode_toggled)
	
	if main_menu_scene.has_signal("menu_initialized"):
		if main_menu_scene.menu_initialized.is_connected(_on_menu_initialized):
			main_menu_scene.menu_initialized.disconnect(_on_menu_initialized)

# =======================
#  MANEJADORES DE SEÑALES DEL MENÚ
# =======================
func _on_start_game_requested():
	"""Manejar solicitud de inicio de juego"""
	print("MainMenuState: 🎮 Start game requested")
	
	# Verificar que se puede iniciar el juego
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager and game_state_manager.has_method("get_is_run_active") and game_state_manager.get_is_run_active():
		print("MainMenuState: Cannot start - run already active")
		return
	
	# Transición a estado de carga o gameplay
	if state_machine and state_machine.has_state("GameplayState"):
		transition_to("GameplayState", {"new_run": true})
	elif state_machine and state_machine.has_state("LoadingState"):
		transition_to("LoadingState", {"target": "gameplay"})
	else:
		# Fallback usando GameStateManager
		if game_state_manager and game_state_manager.has_method("start_new_run"):
			game_state_manager.start_new_run()

func _on_settings_requested():
	"""Manejar solicitud de settings"""
	print("MainMenuState: ⚙️ Settings requested")
	
	# Si hay SettingsState, transicionar a él
	if state_machine and state_machine.has_state("SettingsState"):
		transition_to("SettingsState", {"return_to": "MainMenuState"})
	else:
		# Si el menú tiene panel integrado, pedirle que lo muestre (fallback)
		if main_menu_scene and main_menu_scene.has_method("_show_settings"):
			# Defer to avoid timing issues
			main_menu_scene.call_deferred("_show_settings")
		else:
			print("MainMenuState: Using integrated settings panel (no direct method available)")

func _on_quit_requested():
	"""Manejar solicitud de salir"""
	print("MainMenuState: 👋 Quit requested")
	
	# Guardar datos persistentes antes de salir
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager and game_state_manager.has_method("_save_persistent_data"):
		game_state_manager._save_persistent_data()
	
	# Salir del juego
	get_tree().quit()

func _on_debug_mode_toggled(enabled: bool):
	"""Manejar cambio de modo debug"""
	print("MainMenuState: Debug mode %s" % ("enabled" if enabled else "disabled"))
	
	# Notificar a otros sistemas
	if DebugManager and DebugManager.has_method("set_debug_mode"):
		DebugManager.set_debug_mode(enabled)

func _on_menu_initialized():
	"""Manejar cuando el menú termina de inicializarse"""
	print("MainMenuState: Menu fully initialized")
	
	# Configuraciones post-inicialización
	_setup_menu_configuration()

# =======================
#  INPUT HANDLING
# =======================
func handle_input(event: InputEvent) -> void:
	"""Manejar input específico del estado del menú principal"""
	
	# Debug toggle
	if event.is_action_pressed("debug_toggle"):
		_handle_debug_toggle()
		return
	
	# Quick actions con teclado
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				_show_help()
			KEY_F5:
				_quick_start_game()
			KEY_Q:
				if event.ctrl_pressed:
					_on_quit_requested()

func _handle_debug_toggle():
	"""Maneja el toggle de debug"""
	if main_menu_scene and main_menu_scene.has_method("_show_debug_info"):
		main_menu_scene._show_debug_info()
	else:
		_show_state_debug_info()

func _show_help():
	"""Muestra ayuda del menú"""
	if main_menu_scene and main_menu_scene.has_method("_show_help_info"):
		main_menu_scene._show_help_info()

func _quick_start_game():
	"""Inicio rápido del juego"""
	_on_start_game_requested()

func _show_state_debug_info():
	"""Muestra información de debug del estado"""
	print("=== 🏠 MAIN MENU STATE DEBUG ===")
	var scene_name = "None"
	if main_menu_scene:
		scene_name = main_menu_scene.name
	print("Menu scene: %s" % scene_name)
	print("Menu connected: %s" % is_menu_connected)
	print("Menu compatible: %s" % (_is_compatible_main_menu(main_menu_scene) if main_menu_scene else false))
	
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager:
		if game_state_manager.has_method("get_current_state"):
			print("Game state: %s" % game_state_manager.get_current_state())
		if game_state_manager.has_method("get_is_run_active"):
			print("Run active: %s" % game_state_manager.get_is_run_active())
	
	if state_machine:
		print("StateMachine: %s" % state_machine.get_current_state_name())
	
	print("==============================")

# =======================
#  UTILIDADES Y API PÚBLICA
# =======================
func get_state_name() -> String:
	return "MainMenuState"

func is_menu_ready() -> bool:
	"""Verifica si el menú está listo"""
	return main_menu_scene != null and is_menu_connected

func get_menu_scene() -> Node:
	"""Obtiene referencia a la escena del menú"""
	return main_menu_scene

func force_menu_refresh():
	"""Fuerza una actualización del menú"""
	if main_menu_scene and main_menu_scene.has_method("_setup_initial_state"):
		main_menu_scene._setup_initial_state()
	
	_setup_menu_configuration()

func get_menu_debug_info() -> Dictionary:
	"""Obtiene información de debug del menú"""
	var scene_name = "None"
	if main_menu_scene:
		scene_name = main_menu_scene.name
	
	return {
		"scene_name": scene_name,
		"is_connected": is_menu_connected,
		"is_compatible": _is_compatible_main_menu(main_menu_scene) if main_menu_scene else false,
		"state_name": get_state_name()
	}
