extends Control
class_name SettingsPanelModular

# SettingsPanelModular.gd - Panel de settings integrado en MainMenuModular
# Diseñado para ser escalable y fácil de extender

# =======================
#  SEÑALES
# =======================
signal back_to_main_requested
signal setting_changed(setting_name: String, new_value)
signal panel_shown
signal panel_hidden

# =======================
#  NODOS
# =======================
@export_group("Settings Buttons")
@export var audio_button: Button
@export var video_button: Button
@export var controls_button: Button
@export var back_button: Button

@export_group("Optional Elements")
@export var settings_title: Label
@export var settings_container: VBoxContainer

# =======================
#  CONFIGURACIÓN
# =======================
@export_group("Panel Configuration")
@export var auto_hide_on_back: bool = true
@export var enable_keyboard_navigation: bool = true
@export var show_advanced_settings: bool = false

# =======================
#  ESTADO INTERNO
# =======================
var main_menu_parent: Node = null
var is_initialized: bool = false
var current_focused_button: Button = null

# Cache de settings para evitar accesos constantes a ConfigManager
var cached_settings: Dictionary = {}
var settings_cache_dirty: bool = true

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	_log_info("SettingsPanel: Initializing...")
	
	# Configurar nodo
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false  # Oculto por defecto
	
	# Esperar un frame
	await get_tree().process_frame
	
	# Inicializar componentes
	_validate_nodes()
	_setup_button_connections()
	_setup_initial_configuration()
	_cache_current_settings()
	
	is_initialized = true
	_log_info("SettingsPanel: ✅ Initialized")

func setup_from_main_menu(main_menu: Node):
	"""Configurar desde el MainMenu parent"""
	main_menu_parent = main_menu
	_log_info("SettingsPanel: Connected to MainMenu: %s" % main_menu.name)

func _validate_nodes():
	"""Valida que los nodos necesarios existan"""
	# Buscar nodos automáticamente si no están asignados
	if not settings_container:
		settings_container = get_node_or_null("SettingsContainer")
	
	if not audio_button:
		audio_button = get_node_or_null("SettingsContainer/AudioButton")
	
	if not video_button:
		video_button = get_node_or_null("SettingsContainer/VideoButton")
	
	if not controls_button:
		controls_button = get_node_or_null("SettingsContainer/ControlsButton")
	
	if not back_button:
		back_button = get_node_or_null("SettingsContainer/BackButton")
	
	if not settings_title:
		settings_title = get_node_or_null("SettingsContainer/SettingsTitle")
	
	# Crear botones básicos si no existen
	_create_fallback_buttons()

func _create_fallback_buttons():
	"""Crea botones básicos si no existen"""
	if not settings_container:
		settings_container = VBoxContainer.new()
		settings_container.name = "SettingsContainer"
		add_child(settings_container)
	
	if not back_button:
		back_button = Button.new()
		back_button.name = "BackButton"
		back_button.text = "Back to Main Menu"
		settings_container.add_child(back_button)

func _setup_button_connections():
	"""Configura las conexiones de botones"""
	if audio_button and not audio_button.pressed.is_connected(_on_audio_button_pressed):
		audio_button.pressed.connect(_on_audio_button_pressed)
		audio_button.focus_entered.connect(_on_button_focused.bind("audio"))
	
	if video_button and not video_button.pressed.is_connected(_on_video_button_pressed):
		video_button.pressed.connect(_on_video_button_pressed)
		video_button.focus_entered.connect(_on_button_focused.bind("video"))
	
	if controls_button and not controls_button.pressed.is_connected(_on_controls_button_pressed):
		controls_button.pressed.connect(_on_controls_button_pressed)
		controls_button.focus_entered.connect(_on_button_focused.bind("controls"))
	
	if back_button and not back_button.pressed.is_connected(_on_back_button_pressed):
		back_button.pressed.connect(_on_back_button_pressed)
		back_button.focus_entered.connect(_on_button_focused.bind("back"))

func _setup_initial_configuration():
	"""Configuración inicial del panel"""
	# Configurar título si existe
	if settings_title:
		settings_title.text = "SETTINGS"

# =======================
#  MOSTRAR/OCULTAR PANEL
# =======================
func show_panel():
	"""Muestra el panel de settings"""
	if not is_initialized:
		await _ready()
	
	visible = true
	_refresh_settings_display()
	grab_initial_focus()
	panel_shown.emit()
	_log_info("SettingsPanel: Panel shown")

func hide_panel():
	"""Oculta el panel de settings"""
	visible = false
	panel_hidden.emit()
	_log_info("SettingsPanel: Panel hidden")
	
	# Notificar al main menu si está conectado
	if main_menu_parent and main_menu_parent.has_method("_hide_settings"):
		main_menu_parent._hide_settings()

func grab_initial_focus():
	"""Establece el focus inicial"""
	if audio_button:
		audio_button.grab_focus()
		current_focused_button = audio_button
	elif back_button:
		back_button.grab_focus()
		current_focused_button = back_button

# =======================
#  MANEJO DE SETTINGS
# =======================
func _cache_current_settings():
	"""Cachea settings actuales para mejor performance"""
	if not ConfigManager:
		return
	
	# Cachear settings principales
	cached_settings = {
		"master_volume": ConfigManager.get_setting("audio", "master_volume", 1.0),
		"sfx_volume": ConfigManager.get_setting("audio", "sfx_volume", 1.0),
		"music_volume": ConfigManager.get_setting("audio", "music_volume", 1.0),
		"fullscreen": ConfigManager.get_setting("video", "fullscreen", false),
		"vsync": ConfigManager.get_setting("video", "vsync", true),
		"resolution": ConfigManager.get_setting("video", "resolution", "1920x1080")
	}
	
	settings_cache_dirty = false

func _refresh_settings_display():
	"""Refresca la visualización de settings"""
	if settings_cache_dirty:
		_cache_current_settings()
	
	# Actualizar textos de botones con valores actuales
	_update_button_displays()

func _update_button_displays():
	"""Actualiza el texto de los botones con valores actuales"""
	if audio_button:
		var master_vol = int(cached_settings.get("master_volume", 1.0) * 100)
		audio_button.text = "Audio Settings (%d%%)" % master_vol
	
	if video_button:
		var resolution = cached_settings.get("resolution", "1920x1080")
		var fullscreen_text = "Fullscreen" if cached_settings.get("fullscreen", false) else "Windowed"
		video_button.text = "Video Settings (%s - %s)" % [resolution, fullscreen_text]

# =======================
#  BUTTON HANDLERS
# =======================
func _on_audio_button_pressed():
	"""Handler del botón de audio"""
	_log_info("SettingsPanel: Audio settings requested")
	
	# Aquí podrías abrir un submenú de audio o cambiar escena
	# Por ahora, mostrar opciones básicas
	_show_audio_options()

func _on_video_button_pressed():
	"""Handler del botón de video"""
	_log_info("SettingsPanel: Video settings requested")
	
	# Aquí podrías abrir un submenú de video
	_show_video_options()

func _on_controls_button_pressed():
	"""Handler del botón de controles"""
	_log_info("SettingsPanel: Controls settings requested")
	
	# Aquí podrías abrir configuración de controles
	_show_controls_options()

func _on_back_button_pressed():
	"""Handler del botón de volver"""
	_log_info("SettingsPanel: Back to main menu requested")
	
	if auto_hide_on_back:
		hide_panel()
	
	back_to_main_requested.emit()

func _on_button_focused(button_name: String):
	"""Handler cuando un botón recibe focus"""
	match button_name:
		"audio":
			current_focused_button = audio_button
		"video":
			current_focused_button = video_button
		"controls":
			current_focused_button = controls_button
		"back":
			current_focused_button = back_button

# =======================
#  OPTIONS HANDLERS (PLACEHOLDER)
# =======================
func _show_audio_options():
	"""Muestra opciones de audio básicas"""
	# Por ahora, solo toggle de volumen master
	var current_volume = cached_settings.get("master_volume", 1.0)
	var new_volume = 0.5 if current_volume > 0.5 else 1.0
	
	_change_setting("audio", "master_volume", new_volume)
	
	print("SettingsPanel: Master volume changed to %.1f" % new_volume)

func _show_video_options():
	"""Muestra opciones de video básicas"""
	# Toggle fullscreen
	var current_fullscreen = cached_settings.get("fullscreen", false)
	var new_fullscreen = not current_fullscreen
	
	_change_setting("video", "fullscreen", new_fullscreen)
	
	# Aplicar inmediatamente
	if new_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	print("SettingsPanel: Fullscreen changed to %s" % new_fullscreen)

func _show_controls_options():
	"""Muestra opciones de controles"""
	print("SettingsPanel: Controls configuration not implemented yet")

# =======================
#  SETTING MANAGEMENT
# =======================
func _change_setting(section: String, key: String, value):
	"""Cambia un setting y actualiza cache"""
	if ConfigManager:
		ConfigManager.set_setting(section, key, value)
		
		# Actualizar cache
		var cache_key = key
		if section != "":
			cache_key = "%s_%s" % [section, key]
		cached_settings[cache_key] = value
		
		# Emitir señal
		setting_changed.emit("%s.%s" % [section, key], value)
		
		# Marcar para refresco de display
		settings_cache_dirty = true

# =======================
#  INPUT HANDLING
# =======================
func _input(event):
	if not visible or not enable_keyboard_navigation:
		return
	
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("ui_accept"):
		if current_focused_button:
			current_focused_button.pressed.emit()
		get_viewport().set_input_as_handled()

# =======================
#  API PÚBLICA
# =======================
func add_custom_setting_button(text: String, callback: Callable) -> Button:
	"""Agrega un botón personalizado de setting"""
	if not settings_container:
		_log_error("SettingsPanel: Cannot add button - no container")
		return null
	
	var new_button = Button.new()
	new_button.text = text
	new_button.pressed.connect(callback)
	
	# Insertar antes del botón Back
	if back_button:
		var back_index = back_button.get_index()
		settings_container.add_child(new_button)
		settings_container.move_child(new_button, back_index)
	else:
		settings_container.add_child(new_button)
	
	_log_info("SettingsPanel: Added custom button '%s'" % text)
	return new_button

func get_cached_setting(section: String, key: String, default_value = null):
	"""Obtiene un setting del cache"""
	var cache_key = "%s_%s" % [section, key]
	return cached_settings.get(cache_key, default_value)

func refresh_all_settings():
	"""Fuerza una actualización completa de settings"""
	settings_cache_dirty = true
	_cache_current_settings()
	_refresh_settings_display()

# =======================
#  UTILITIES
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
	cached_settings.clear()
	main_menu_parent = null
