extends Control

# =======================
#  NODOS PRINCIPALES
# =======================
@onready var btn_start: Button = $BoxContainer/StartGame
@onready var btn_settings: Button = $BoxContainer/Settings
@onready var btn_quit: Button = $BoxContainer/Quit
@onready var settings_menu: Control = $SettingsMenu

# =======================
#  VARIABLES
# =======================
var is_initialized: bool = false
var settings_scene_path: String = "res://Scenes/Menus/SettingsMenu.tscn"

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("MainMenu: Initializing...")
	
	# Esperar un frame para que los nodos estén completamente listos
	await get_tree().process_frame
	
	# Configurar conexiones
	_setup_connections()
	
	# Configurar UI inicial
	_setup_initial_ui()
	
	# Conectar con managers si están disponibles
	_connect_with_managers()
	
	is_initialized = true
	print("MainMenu: Ready")

func _setup_connections():
	"""Configurar conexiones de señales de forma segura"""
	if btn_start:
		btn_start.pressed.connect(_on_start_pressed)
		print("MainMenu: Connected Start button")
	else:
		print("MainMenu: ERROR - Start button not found!")
	
	if btn_settings:
		btn_settings.pressed.connect(_on_settings_pressed)
		print("MainMenu: Connected Settings button")
	else:
		print("MainMenu: ERROR - Settings button not found!")
	
	if btn_quit:
		btn_quit.pressed.connect(_on_exit_pressed)
		print("MainMenu: Connected Quit button")
	else:
		print("MainMenu: ERROR - Quit button not found!")
	
	# Conectar el settings menu si está disponible
	if settings_menu:
		# Conectar la señal de volver al main menu
		settings_menu.back_to_main.connect(_on_settings_back)
		print("MainMenu: Settings menu found and connected")
	else:
		print("MainMenu: ERROR - Settings menu not found!")

func _setup_initial_ui():
	"""Configurar UI inicial"""
	# Verificar que la escena de settings exists
	if ResourceLoader.exists(settings_scene_path):
		print("MainMenu: Settings scene found at %s" % settings_scene_path)
	else:
		print("MainMenu: WARNING - Settings scene not found at %s" % settings_scene_path)
	
	# Asegurar que el menú principal sea visible y el de settings oculto
	show()
	
	# Ocultar settings menu al inicio
	if settings_menu:
		settings_menu.hide()
		print("MainMenu: Settings menu hidden initially")
	
	# Enfocar el botón de inicio
	if btn_start:
		btn_start.grab_focus()

func _connect_with_managers():
	"""Conectar con managers disponibles"""
	# Verificar GameStateManager
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager:
		print("MainMenu: GameStateManager found")
		# Podemos conectar señales específicas si es necesario
	else:
		print("MainMenu: GameStateManager not found")
	
	# Verificar AudioManager para música del menú
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager:
		print("MainMenu: AudioManager found")
		# Podemos reproducir música del menú aquí
		_play_menu_music()
	else:
		print("MainMenu: AudioManager not found")

func _play_menu_music():
	"""Reproducir música del menú si está disponible"""
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager and audio_manager.has_method("play_music"):
		# audio_manager.play_music("menu_theme")  # Descomenta cuando tengas música
		print("MainMenu: Menu music would play here")

# =======================
#  NAVEGACIÓN DEL MENÚ
# =======================
func _on_start_pressed():
	"""Iniciar el juego"""
	print("MainMenu: Start Game pressed")
	
	# Usar GameStateManager integrado para transición elegante
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager and game_state_manager.has_method("start_game"):
		print("MainMenu: Using GameStateManager to start game")
		game_state_manager.start_game(1)  # Iniciar run número 1
	elif game_state_manager and game_state_manager.has_method("change_state"):
		print("MainMenu: Using GameStateManager change_state")
		game_state_manager.change_state(game_state_manager.GameState.PLAYING)
	else:
		print("MainMenu: GameStateManager not available, using fallback")
		_change_to_game_scene()

func _change_to_game_scene():
	"""Cambiar a la escena del juego (fallback)"""
	var main_scene_path = "res://Scenes/Main.tscn"
	
	# Verificar que la escena existe
	if ResourceLoader.exists(main_scene_path):
		print("MainMenu: Changing to game scene: %s" % main_scene_path)
		get_tree().change_scene_to_file(main_scene_path)
	else:
		print("MainMenu: ERROR - Game scene not found: %s" % main_scene_path)
		_show_error("Game scene not found!")

func _on_settings_pressed():
	"""Abrir menú de configuración"""
	print("MainMenu: Settings pressed")
	
	# Usar el settings menu embebido en lugar de cambiar de escena
	if settings_menu:
		print("MainMenu: Showing embedded settings menu")
		settings_menu.show()
		# Ocultar los botones del menu principal mientras se muestran los settings
		_set_main_menu_visibility(false)
	else:
		# Fallback: cargar escena de settings (solo si no hay menu embebido)
		if ResourceLoader.exists(settings_scene_path):
			print("MainMenu: Loading settings scene as fallback...")
			get_tree().change_scene_to_file(settings_scene_path)
		else:
			print("MainMenu: ERROR - Settings scene not found!")
			_show_error("Settings scene not found!")

func _on_exit_pressed():
	"""Salir del juego"""
	print("MainMenu: Exit pressed")
	
	# Verificar si hay GameManager para limpiar antes de salir
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("cleanup_before_exit"):
		game_manager.cleanup_before_exit()
	
	# Verificar si hay ConfigManager para guardar configuración
	var config_manager = get_node_or_null("/root/ConfigManager")
	if config_manager and config_manager.has_method("save"):
		config_manager.save()
		print("MainMenu: Settings saved before exit")
	
	print("MainMenu: Exiting game...")
	get_tree().quit()

# =======================
#  INPUT HANDLING
# =======================
func _unhandled_input(event):
	"""Manejar input no procesado"""
	if not is_initialized:
		return
	
	# Solo procesar eventos de teclado presionados
	if not event is InputEventKey or not event.pressed:
		return
	
	# Manejo de teclas especiales del menú
	match event.keycode:
		KEY_ENTER, KEY_KP_ENTER:
			if btn_start and not btn_start.disabled:
				_on_start_pressed()
				get_viewport().set_input_as_handled()
		
		KEY_ESCAPE:
			# Si estamos en el main menu, cerrar el juego
			_on_exit_pressed()
			get_viewport().set_input_as_handled()
		
		KEY_S:
			if event.ctrl_pressed:  # Ctrl+S para settings
				_on_settings_pressed()
				get_viewport().set_input_as_handled()

# =======================
#  UTILIDADES
# =======================
func _show_error(message: String):
	"""Mostrar mensaje de error"""
	print("MainMenu: ERROR - %s" % message)
	
	# Enviar al debug system si está disponible
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager and debug_manager.has_method("log_error"):
		debug_manager.log_error("MainMenu: %s" % message)

func _is_manager_available(manager_name: String) -> bool:
	"""Verificar si un manager está disponible"""
	return get_node_or_null("/root/" + manager_name) != null

# =======================
#  ANIMACIONES Y EFECTOS
# =======================
func show_menu_with_fade():
	"""Mostrar menú con efecto de fade"""
	modulate = Color.TRANSPARENT
	show()
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)

func hide_menu_with_fade():
	"""Ocultar menú con efecto de fade"""
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(hide)

# =======================
#  CONFIGURACIÓN DEL MENÚ
# =======================
func set_button_states(start_enabled: bool = true, settings_enabled: bool = true, quit_enabled: bool = true):
	"""Configurar estados de los botones"""
	if btn_start:
		btn_start.disabled = not start_enabled
	if btn_settings:
		btn_settings.disabled = not settings_enabled
	if btn_quit:
		btn_quit.disabled = not quit_enabled
	
	print("MainMenu: Button states updated - Start: %s, Settings: %s, Quit: %s" % [start_enabled, settings_enabled, quit_enabled])

func focus_start_button():
	"""Enfocar el botón de inicio"""
	if btn_start:
		btn_start.grab_focus()

func _on_settings_back():
	"""Callback cuando se vuelve de settings al main menu"""
	print("MainMenu: Returning from settings")
	_set_main_menu_visibility(true)
	if settings_menu:
		settings_menu.hide()

func _set_main_menu_visibility(is_visible: bool):
	"""Mostrar/ocultar elementos del main menu"""
	if btn_start:
		btn_start.visible = is_visible
	if btn_settings:
		btn_settings.visible = is_visible
	if btn_quit:
		btn_quit.visible = is_visible
	
	# También actualizar otros elementos del menu principal si los hay
	var titulo = get_node_or_null("Titulo")
	if titulo:
		titulo.visible = is_visible

# =======================
#  FUNCIONES DE DEBUG
# =======================#
func debug_menu_info():
	"""Información de debug del menú"""
	print("=== MAIN MENU DEBUG INFO ===")
	print("Initialized: %s" % is_initialized)
	print("Start Button: %s" % (btn_start != null))
	print("Settings Button: %s" % (btn_settings != null))
	print("Quit Button: %s" % (btn_quit != null))
	print("Settings Scene Path: %s" % settings_scene_path)
	print("Settings Scene Exists: %s" % ResourceLoader.exists(settings_scene_path))
	print("Available Managers:")
	var managers = ["GameStateManager", "AudioManager", "GameManager", "ConfigManager"]
	for manager in managers:
		print("  %s: %s" % [manager, _is_manager_available(manager)])
	print("============================")

func debug_test_buttons():
	"""Test de botones para debug"""
	print("MainMenu: Testing button functionality...")
	
	if btn_start:
		print("  Start button: OK")
	else:
		print("  Start button: MISSING")
	
	if btn_settings:
		print("  Settings button: OK")
	else:
		print("  Settings button: MISSING")
	
	if btn_quit:
		print("  Quit button: OK")
	else:
		print("  Quit button: MISSING")

func debug_force_start():
	"""Debug: forzar inicio del juego"""
	_on_start_pressed()

func debug_toggle_settings():
	"""Debug: abrir menú de configuración"""
	print("MainMenu: Debug - Opening settings scene...")
	_on_settings_pressed()

# =======================
#  CLEANUP
# =======================
func _exit_tree():
	print("MainMenu: Cleanup complete")
