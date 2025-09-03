extends Control
class_name MainMenuModular

# MainMenuModular.gd - Versión escalable con StateMachine
# Diseñado para fácil extensión y mantenimiento

# =======================
#  SEÑALES PARA STATEMACHINE
# =======================
signal start_game_requested
signal settings_requested
signal quit_requested
signal debug_mode_toggled(enabled: bool)

# Señales internas para mejor organización
signal menu_initialized
signal menu_button_focused(button_name: String)

# =======================
#  NODOS PRINCIPALES
# =======================
@export_group("Main UI Nodes")
@export var main_container: VBoxContainer
@export var start_button: Button
@export var settings_button: Button  
@export var quit_button: Button

@export_group("Sub Menus")
@export var settings_panel: Control

@export_group("Optional Elements")
@export var title_label: Label
@export var version_label: Label
@export var background_control: Control

# =======================
#  CONFIGURACIÓN
# =======================
@export_group("Menu Configuration")
@export var auto_focus_start: bool = true
@export var enable_keyboard_shortcuts: bool = true
@export var enable_debug_shortcuts: bool = true
@export var show_version_info: bool = true

# =======================
#  ESTADO INTERNO
# =======================
var is_initialized: bool = false
var current_focused_button: Button = null
var debug_mode: bool = false

# Cache de referencias para performance
var cached_buttons: Array[Button] = []
var button_actions: Dictionary = {}

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	_log_info("MainMenu: Starting modular initialization...")
	
	# Configurar propiedades básicas
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Esperar un frame para que todos los nodos estén listos
	await get_tree().process_frame
	
	# Inicializar componentes en orden
	_validate_node_structure()
	_cache_ui_elements()
	_setup_button_connections()
	_setup_ui_configuration()
	_setup_keyboard_shortcuts()
	_setup_initial_state()
	
	is_initialized = true
	menu_initialized.emit()
	
	_log_info("MainMenu: ✅ Modular initialization complete!")
	
	if enable_debug_shortcuts:
		_log_info("MainMenu: Press F1 for help, F12 for debug info")

func _validate_node_structure():
	"""Valida que la estructura de nodos sea correcta"""
	var missing_nodes: Array[String] = []
	
	# Validar nodos principales
	# Resolve exported references (NodePath saved in scene inspector) to actual nodes
	# This handles cases where the exported var stores a NodePath/string instead of a Node
	var raw_main = get("main_container")
	if typeof(raw_main) == TYPE_NODE_PATH or typeof(raw_main) == TYPE_STRING:
		var resolved_main = get_node_or_null(raw_main)
		if resolved_main:
			main_container = resolved_main
	elif not main_container:
		main_container = get_node_or_null("MainContainer")
		if not main_container:
			missing_nodes.append("MainContainer (VBoxContainer)")
	
	# start button
	var raw_start = get("start_button")
	if typeof(raw_start) == TYPE_NODE_PATH or typeof(raw_start) == TYPE_STRING:
		var resolved_start = get_node_or_null(raw_start)
		if resolved_start:
			start_button = resolved_start
	elif not start_button:
		var node_a = get_node_or_null("MainContainer/StartButton")
		var node_b = get_node_or_null("StartButton")
		start_button = node_a if node_a != null else node_b
		if not start_button:
			missing_nodes.append("StartButton")
	
	# settings button
	var raw_settings = get("settings_button")
	if typeof(raw_settings) == TYPE_NODE_PATH or typeof(raw_settings) == TYPE_STRING:
		var resolved_settings = get_node_or_null(raw_settings)
		if resolved_settings:
			settings_button = resolved_settings
	elif not settings_button:
		var node_a = get_node_or_null("MainContainer/SettingsButton")
		var node_b = get_node_or_null("SettingsButton")
		settings_button = node_a if node_a != null else node_b
		if not settings_button:
			missing_nodes.append("SettingsButton")
	
	# quit button
	var raw_quit = get("quit_button")
	if typeof(raw_quit) == TYPE_NODE_PATH or typeof(raw_quit) == TYPE_STRING:
		var resolved_quit = get_node_or_null(raw_quit)
		if resolved_quit:
			quit_button = resolved_quit
	elif not quit_button:
		var node_a = get_node_or_null("MainContainer/QuitButton")
		var node_b = get_node_or_null("QuitButton")
		quit_button = node_a if node_a != null else node_b
		if not quit_button:
			missing_nodes.append("QuitButton")
	
	# Nodos opcionales
	# settings panel (resolve exported NodePath/string)
	var raw_panel = get("settings_panel")
	if typeof(raw_panel) == TYPE_NODE_PATH or typeof(raw_panel) == TYPE_STRING:
		var resolved_panel = get_node_or_null(raw_panel)
		if resolved_panel:
			settings_panel = resolved_panel
	elif not settings_panel:
		settings_panel = get_node_or_null("SettingsPanel")
	
	# optional labels and background
	var raw_title = get("title_label")
	if typeof(raw_title) == TYPE_NODE_PATH or typeof(raw_title) == TYPE_STRING:
		var resolved_title = get_node_or_null(raw_title)
		if resolved_title:
			title_label = resolved_title
	elif not title_label:
		title_label = get_node_or_null("TitleLabel")

	var raw_version = get("version_label")
	if typeof(raw_version) == TYPE_NODE_PATH or typeof(raw_version) == TYPE_STRING:
		var resolved_version = get_node_or_null(raw_version)
		if resolved_version:
			version_label = resolved_version
	elif not version_label:
		version_label = get_node_or_null("VersionLabel")

	var raw_bg = get("background_control")
	if typeof(raw_bg) == TYPE_NODE_PATH or typeof(raw_bg) == TYPE_STRING:
		var resolved_bg = get_node_or_null(raw_bg)
		if resolved_bg:
			background_control = resolved_bg
	elif not background_control:
		background_control = get_node_or_null("Background")
	
	# Reportar nodos faltantes
	if missing_nodes.size() > 0:
		_log_error("MainMenu: Missing critical nodes: %s" % str(missing_nodes))
		_create_fallback_ui()
	else:
		_log_info("MainMenu: ✅ All required nodes found")

func _create_fallback_ui():
	"""Crea UI básica si faltan nodos críticos"""
	_log_info("MainMenu: Creating fallback UI structure...")
	
	# Crear container principal si no existe
	if not main_container:
		main_container = VBoxContainer.new()
		main_container.name = "MainContainer"
		main_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		add_child(main_container)
	
	# Crear botones si no existen
	if not start_button:
		start_button = Button.new()
		start_button.name = "StartButton"
		start_button.text = "Start Game"
		main_container.add_child(start_button)
	
	if not settings_button:
		settings_button = Button.new()
		settings_button.name = "SettingsButton"
		settings_button.text = "Settings"
		main_container.add_child(settings_button)
	
	if not quit_button:
		quit_button = Button.new()
		quit_button.name = "QuitButton"
		quit_button.text = "Quit Game"
		main_container.add_child(quit_button)

func _cache_ui_elements():
	"""Cachea elementos UI para mejor performance"""
	cached_buttons.clear()
	button_actions.clear()
	
	# Agregar botones al cache
	if start_button:
		cached_buttons.append(start_button)
		button_actions[start_button] = "start_game"
	
	if settings_button:
		cached_buttons.append(settings_button)
		button_actions[settings_button] = "settings"
	
	if quit_button:
		cached_buttons.append(quit_button)
		button_actions[quit_button] = "quit"
	
	_log_info("MainMenu: Cached %d buttons" % cached_buttons.size())

func _setup_button_connections():
	"""Configura las conexiones de botones"""
	# Conectar botones principales
	if start_button and not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)
		start_button.focus_entered.connect(_on_button_focused.bind("start"))
		_log_info("MainMenu: ✅ Start button connected")
	
	if settings_button and not settings_button.pressed.is_connected(_on_settings_button_pressed):
		settings_button.pressed.connect(_on_settings_button_pressed)
		settings_button.focus_entered.connect(_on_button_focused.bind("settings"))
		_log_info("MainMenu: ✅ Settings button connected")
	
	if quit_button and not quit_button.pressed.is_connected(_on_quit_button_pressed):
		quit_button.pressed.connect(_on_quit_button_pressed)
		quit_button.focus_entered.connect(_on_button_focused.bind("quit"))
		_log_info("MainMenu: ✅ Quit button connected")

func _setup_ui_configuration():
	"""Configura elementos UI opcionales"""
	# Configurar versión si está disponible
	if show_version_info and version_label:
		var version = ProjectSettings.get_setting("application/config/version", "1.0.0")
		version_label.text = "v%s" % version
	
	# Configurar panel de settings
	if settings_panel:
		settings_panel.visible = false
		# Configurar panel desde el main menu
		if settings_panel.has_method("setup_from_main_menu"):
			settings_panel.setup_from_main_menu(self)
		
		# Conectar señales del panel de settings
		if settings_panel.has_signal("back_to_main_requested"):
			if not settings_panel.back_to_main_requested.is_connected(_on_settings_panel_back):
				settings_panel.back_to_main_requested.connect(_on_settings_panel_back)
		
		if settings_panel.has_signal("setting_changed"):
			if not settings_panel.setting_changed.is_connected(_on_settings_panel_change):
				settings_panel.setting_changed.connect(_on_settings_panel_change)

func _setup_keyboard_shortcuts():
	"""Configura atajos de teclado personalizados"""
	if not enable_keyboard_shortcuts:
		return
	
	# Los inputs principales se manejan en _input()
	_log_info("MainMenu: ✅ Keyboard shortcuts enabled")

func _setup_initial_state():
	"""Configura el estado inicial del menú"""
	# Focus inicial
	if auto_focus_start and start_button:
		start_button.grab_focus()
		current_focused_button = start_button
	
	# Estado inicial de submenús
	_hide_all_submenus()

# =======================
#  INPUT HANDLING
# =======================
func _input(event):
	if not is_initialized or not enable_keyboard_shortcuts:
		return
	
	if event.is_action_pressed("ui_accept"):
		_handle_accept_input()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("ui_cancel"):
		_handle_cancel_input()
		get_viewport().set_input_as_handled()
	
	elif enable_debug_shortcuts:
		_handle_debug_input(event)

func _handle_accept_input():
	"""Maneja input de aceptar (Enter/Space)"""
	if current_focused_button:
		current_focused_button.pressed.emit()
	elif start_button:
		_on_start_button_pressed()

func _handle_cancel_input():
	"""Maneja input de cancelar (Escape)"""
	# Si hay submenú abierto, cerrarlo
	if settings_panel and settings_panel.visible:
		_hide_settings()
		return
	
	# Si no hay submenús, ir a quit
	_on_quit_button_pressed()

func _handle_debug_input(event):
	"""Maneja inputs de debug"""
	if not event is InputEventKey or not event.pressed:
		return
	
	match event.keycode:
		KEY_F1:
			_show_help_info()
		KEY_F12:
			_show_debug_info()
		KEY_F2:
			debug_mode = not debug_mode
			debug_mode_toggled.emit(debug_mode)
			_log_info("MainMenu: Debug mode %s" % ("ON" if debug_mode else "OFF"))

# =======================
#  BUTTON HANDLERS
# =======================
func _on_start_button_pressed():
	"""Handler del botón Start Game"""
	_log_info("MainMenu: 🎮 Start Game requested")
	
	# Validar si se puede iniciar el juego
	if not _can_start_game():
		_log_error("MainMenu: Cannot start game at this time")
		return
	
	# Emitir señal para StateMachine
	start_game_requested.emit()
	
	# Feedback opcional
	_play_button_sound("confirm")

func _on_settings_button_pressed():
	"""Handler del botón Settings"""
	_log_info("MainMenu: ⚙️ Settings requested")
	
	# Si hay panel integrado, mostrarlo
	if settings_panel:
		_show_settings()
	else:
		# Emitir señal para cambio de escena/estado
		settings_requested.emit()
	
	_play_button_sound("navigate")

func _on_quit_button_pressed():
	"""Handler del botón Quit"""
	_log_info("MainMenu: 👋 Quit requested")
	
	# Emitir señal para manejo de salida
	quit_requested.emit()
	
	_play_button_sound("confirm")

func _on_button_focused(button_name: String):
	"""Handler cuando un botón recibe focus"""
	menu_button_focused.emit(button_name)
	
	# Actualizar referencia del botón actual
	match button_name:
		"start":
			current_focused_button = start_button
		"settings":
			current_focused_button = settings_button
		"quit":
			current_focused_button = quit_button
	
	_play_button_sound("hover")

func _on_settings_panel_back():
	"""Handler cuando el panel de settings solicita volver"""
	_log_info("MainMenu: Settings panel requested back to main")
	_hide_settings()

func _on_settings_panel_change(setting_name: String, new_value):
	"""Handler cuando cambia un setting en el panel"""
	_log_info("MainMenu: Setting changed: %s = %s" % [setting_name, str(new_value)])

# =======================
#  SUBMENU MANAGEMENT
# =======================
func _show_settings():
	"""Muestra el panel de settings"""
	if not settings_panel:
		_log_error("MainMenu: Settings panel not available")
		return
	
	# Usar el método del panel modular
	if settings_panel.has_method("show_panel"):
		# Defer actual show to avoid calling into the panel before it's fully ready
		settings_panel.call_deferred("show_panel")
	else:
		# Fallback
		settings_panel.visible = true
		_hide_main_buttons()
	
	_log_info("MainMenu: Settings panel shown")

func _hide_settings():
	"""Oculta el panel de settings"""
	if settings_panel:
		# Usar método del panel modular
		if settings_panel.has_method("hide_panel"):
			# Defer hide to avoid immediate recursion / timing issues
			settings_panel.call_deferred("hide_panel")
		else:
			# Fallback
			settings_panel.visible = false
	
	_show_main_buttons()
	
	# Recuperar focus
	if start_button:
		start_button.grab_focus()
		current_focused_button = start_button
	
	_log_info("MainMenu: Settings panel hidden")

func _hide_all_submenus():
	"""Oculta todos los submenús"""
	if settings_panel:
		settings_panel.visible = false

func _show_main_buttons():
	"""Muestra los botones principales"""
	if main_container:
		main_container.visible = true

func _hide_main_buttons():
	"""Oculta los botones principales (para submenús fullscreen)"""
	# Solo ocultar si el submenú es fullscreen
	pass

# =======================
#  VALIDATION Y UTILITIES
# =======================
func _can_start_game() -> bool:
	"""Valida si se puede iniciar el juego"""
	# Verificar que GameStateManager esté listo (si está disponible)
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager:
		# Verificar que no haya run activa
		if game_state_manager.has_method("get_is_run_active") and game_state_manager.get_is_run_active():
			_log_error("MainMenu: Cannot start - run already active")
			return false
	
	return true

func _play_button_sound(sound_type: String):
	"""Reproduce sonidos de UI"""
	if not AudioManager:
		return
	
	# Implementar según tu sistema de audio
	match sound_type:
		"hover":
			# AudioManager.play_ui_sfx("button_hover")
			pass
		"navigate":
			# AudioManager.play_ui_sfx("button_navigate")
			pass
		"confirm":
			# AudioManager.play_ui_sfx("button_confirm")
			pass

# =======================
#  DEBUG Y INFORMACIÓN
# =======================
func _show_help_info():
	"""Muestra información de ayuda"""
	print("=== 🎮 MAIN MENU HELP ===")
	print("ENTER/SPACE: Start Game")
	print("TAB: Navigate buttons")
	print("ESC: Back/Quit")
	print("F1: This help")
	print("F12: Debug info")
	print("F2: Toggle debug mode")
	print("========================")

func _show_debug_info():
	"""Muestra información de debug detallada"""
	print("=== 🔧 MAIN MENU DEBUG ===")
	print("Initialized: %s" % is_initialized)
	var focused_name = "None"
	if current_focused_button:
		focused_name = current_focused_button.name
	print("Current focused: %s" % focused_name)
	print("Debug mode: %s" % debug_mode)
	print("Cached buttons: %d" % cached_buttons.size())
	
	print("\n--- UI Elements ---")
	print("Main container: %s" % (main_container != null))
	print("Start button: %s" % (start_button != null))
	print("Settings button: %s" % (settings_button != null))
	print("Quit button: %s" % (quit_button != null))
	print("Settings panel: %s" % (settings_panel != null))
	
	print("\n--- Configuration ---")
	print("Auto focus: %s" % auto_focus_start)
	print("Keyboard shortcuts: %s" % enable_keyboard_shortcuts)
	print("Debug shortcuts: %s" % enable_debug_shortcuts)
	print("Show version: %s" % show_version_info)
	
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager:
		print("\n--- Game State ---")
		if game_state_manager.has_method("is_ready"):
			print("GameStateManager ready: %s" % game_state_manager.is_ready())
		if game_state_manager.has_method("get_current_state"):
			print("Current state: %s" % game_state_manager.get_current_state())
		if game_state_manager.has_method("get_is_run_active"):
			print("Run active: %s" % game_state_manager.get_is_run_active())
	
	print("==========================")

# =======================
#  API PÚBLICA PARA EXTENSIÓN
# =======================
func add_custom_button(button_text: String, action_callback: Callable, insert_position: int = -1) -> Button:
	"""Agrega un botón personalizado al menú"""
	if not main_container:
		_log_error("MainMenu: Cannot add button - no main container")
		return null
	
	var new_button = Button.new()
	new_button.text = button_text
	new_button.pressed.connect(action_callback)
	
	if insert_position >= 0 and insert_position < main_container.get_child_count():
		main_container.add_child(new_button)
		main_container.move_child(new_button, insert_position)
	else:
		main_container.add_child(new_button)
	
	# Agregar al cache
	cached_buttons.append(new_button)
	
	_log_info("MainMenu: Added custom button '%s'" % button_text)
	return new_button

func remove_custom_button(button: Button) -> bool:
	"""Remueve un botón personalizado"""
	if button in cached_buttons:
		cached_buttons.erase(button)
	
	if button_actions.has(button):
		button_actions.erase(button)
	
	if button.get_parent():
		button.get_parent().remove_child(button)
		button.queue_free()
		return true
	
	return false

func set_button_enabled(button_name: String, enabled: bool):
	"""Habilita/deshabilita un botón específico"""
	var button: Button = null
	
	match button_name.to_lower():
		"start":
			button = start_button
		"settings":
			button = settings_button
		"quit":
			button = quit_button
	
	if button:
		button.disabled = not enabled
		_log_info("MainMenu: Button '%s' %s" % [button_name, "enabled" if enabled else "disabled"])

func get_button_reference(button_name: String) -> Button:
	"""Obtiene referencia a un botón específico"""
	match button_name.to_lower():
		"start":
			return start_button
		"settings":
			return settings_button
		"quit":
			return quit_button
		_:
			return null

# =======================
#  LOGGING UTILITIES
# =======================
func _log_info(message: String):
	"""Log de información"""
	print(message)
	if DebugManager and DebugManager.has_method("log_to_console"):
		DebugManager.log_to_console(message, "white")

func _log_error(message: String):
	"""Log de error"""
	print_rich("[color=red]%s[/color]" % message)
	if DebugManager and DebugManager.has_method("log_to_console"):
		DebugManager.log_to_console(message, "red")

# =======================
#  LIFECYCLE
# =======================
func _exit_tree():
	"""Cleanup al salir"""
	# Limpiar cache
	cached_buttons.clear()
	button_actions.clear()
	
	_log_info("MainMenu: 🔥 Cleanup complete")
