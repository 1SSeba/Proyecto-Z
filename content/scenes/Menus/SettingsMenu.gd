extends Control

# =======================
#  SEÑALES
# =======================
signal back_to_main  # Señal para notificar al main menu que vuelva

# -----------------------
#  NODOS PRINCIPALES
# -----------------------
@onready var main_panel: Control = $Panel
@onready var btn_audio: Button = $Panel/VBoxContainer/Audio
@onready var btn_video: Button = $Panel/VBoxContainer/Video
@onready var btn_controls: Button = $Panel/VBoxContainer/Controls
@onready var btn_back: Button = $Panel/VBoxContainer/Back

# =======================
#  SUBMENÚS
# =======================
@onready var audio_menu: Control = $Audio
@onready var video_menu: Control = $Video
@onready var controls_menu: Control = $Controls

# =======================
#  AUDIO MENU ELEMENTS
# =======================
@onready var master_slider: HSlider = get_node_or_null("Audio/AudioPanel/AudioOptions/MasterBox/MasterSlider")
@onready var master_label: Label = get_node_or_null("Audio/AudioPanel/AudioOptions/MasterBox/MasterLabel")
@onready var music_slider: HSlider = get_node_or_null("Audio/AudioPanel/AudioOptions/MusicBox/MusicSlider")
@onready var music_label: Label = get_node_or_null("Audio/AudioPanel/AudioOptions/MusicBox/MusicLabel")
@onready var sfx_slider: HSlider = get_node_or_null("Audio/AudioPanel/AudioOptions/EffectsBox/EffectsSlider")
@onready var sfx_label: Label = get_node_or_null("Audio/AudioPanel/AudioOptions/EffectsBox/EffectsLabel")
@onready var back_audiomenu: Button = get_node_or_null("Audio/AudioPanel/AudioOptions/Back")

# =======================
#  VIDEO MENU ELEMENTS
# =======================
@onready var screen_mode_btn: OptionButton = get_node_or_null("Video/VideoPanel/VideoOptions/ScreenModeBox/ScreenModeBtn")
@onready var resolution_btn: OptionButton = get_node_or_null("Video/VideoPanel/VideoOptions/ResolutionBox/ResolutionBtn")
@onready var vsync_checkbtn: CheckButton = get_node_or_null("Video/VideoPanel/VideoOptions/VSyncBox/VSyncBtn")
@onready var apply_btn: Button = get_node_or_null("Video/VideoPanel/VideoOptions/SaveBox/Apply")
@onready var reset_btn: Button = get_node_or_null("Video/VideoPanel/VideoOptions/SaveBox/Reset")
@onready var back_videomenu: Button = get_node_or_null("Video/VideoPanel/VideoOptions/Back")
@onready var status_label: Label = get_node_or_null("Video/VideoPanel/VideoOptions/StatusLabel")

# =======================
#  VARIABLES TEMPORALES PARA VIDEO
# =======================
var temp_screen_mode := 0
var temp_resolution := 0
var temp_vsync := true
var saved_screen_mode := 0
var saved_resolution := 0
var saved_vsync := true

# =======================
#  RESOLUCIONES DISPONIBLES
# =======================
var available_resolutions = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("SettingsMenu: Initializing...")
	_setup_connections()
	_init_video_options()
	_hide_all_menus()
	_load_all_settings()
	_show_main_menu()
	print("SettingsMenu: Ready")

func _setup_connections():
	"""Configurar conexiones de señales de forma segura"""
	# Botones principales
	_connect_button(btn_audio, _on_audio_pressed, "Audio")
	_connect_button(btn_video, _on_video_pressed, "Video")
	_connect_button(btn_controls, _on_controls_pressed, "Controls")
	_connect_button(btn_back, _on_back_pressed, "Back")
	
	# Botones de regreso en submenús
	_connect_button(back_audiomenu, _on_back_to_main_menu, "Back Audio")
	_connect_button(back_videomenu, _on_back_to_main_menu, "Back Video")
	
	# Audio sliders
	_connect_slider(master_slider, _on_master_volume_changed, "Master Volume")
	_connect_slider(music_slider, _on_music_volume_changed, "Music Volume")
	_connect_slider(sfx_slider, _on_sfx_volume_changed, "SFX Volume")
	
	# Video controls
	_connect_option_button(screen_mode_btn, _on_screen_mode_selected, "Screen Mode")
	_connect_option_button(resolution_btn, _on_resolution_selected, "Resolution")
	_connect_check_button(vsync_checkbtn, _on_vsync_toggled, "VSync")
	
	# Video buttons
	_connect_button(apply_btn, _on_apply_video_settings, "Apply")
	_connect_button(reset_btn, _on_reset_video_settings, "Reset")

func _connect_button(button: Button, method: Callable, button_name: String):
	"""Conecta un botón de forma segura"""
	if button:
		button.pressed.connect(method)
		print("SettingsMenu: Connected %s button" % button_name)
	else:
		print("SettingsMenu: %s button not found" % button_name)

func _connect_slider(slider: HSlider, method: Callable, slider_name: String):
	"""Conecta un slider de forma segura"""
	if slider:
		slider.value_changed.connect(method)
		print("SettingsMenu: Connected %s slider" % slider_name)
	else:
		print("SettingsMenu: %s slider not found" % slider_name)

func _connect_option_button(option_btn: OptionButton, method: Callable, option_name: String):
	"""Conecta un OptionButton de forma segura"""
	if option_btn:
		option_btn.item_selected.connect(method)
		print("SettingsMenu: Connected %s option button" % option_name)
	else:
		print("SettingsMenu: %s option button not found" % option_name)

func _connect_check_button(check_btn: CheckButton, method: Callable, check_name: String):
	"""Conecta un CheckButton de forma segura"""
	if check_btn:
		check_btn.toggled.connect(method)
		print("SettingsMenu: Connected %s check button" % check_name)
	else:
		print("SettingsMenu: %s check button not found" % check_name)

func _init_video_options():
	"""Inicializar opciones de video"""
	# Configurar opciones de pantalla
	if screen_mode_btn:
		screen_mode_btn.clear()
		screen_mode_btn.add_item("Windowed")
		screen_mode_btn.add_item("Fullscreen")
		screen_mode_btn.add_item("Borderless Fullscreen")
	
	# Configurar resoluciones
	if resolution_btn:
		resolution_btn.clear()
		for resolution in available_resolutions:
			resolution_btn.add_item("%dx%d" % [resolution.x, resolution.y])

# =======================
#  NAVEGACIÓN DE MENÚS
# =======================
func _hide_all_menus():
	"""Ocultar todos los menús"""
	_set_menu_visibility(main_panel, false)
	_set_menu_visibility(audio_menu, false)
	_set_menu_visibility(video_menu, false)
	_set_menu_visibility(controls_menu, false)

func _set_menu_visibility(menu: Control, show_menu: bool):
	"""Establecer visibilidad de menú de forma segura"""
	if menu and is_instance_valid(menu):
		menu.visible = show_menu

func _show_main_menu():
	"""Mostrar el menú principal"""
	_hide_all_menus()
	_set_menu_visibility(main_panel, true)

func _on_audio_pressed():
	"""Abrir menú de audio"""
	_hide_all_menus()
	_set_menu_visibility(audio_menu, true)
	_load_audio_settings()

func _on_video_pressed():
	"""Abrir menú de video"""
	_hide_all_menus()
	_set_menu_visibility(video_menu, true)
	_load_video_settings()

func _on_controls_pressed():
	"""Abrir menú de controles"""
	_hide_all_menus()
	_set_menu_visibility(controls_menu, true)
	# TODO: Implementar carga de controles

func _on_back_pressed():
	"""Volver al menú principal"""
	print("SettingsMenu: Returning to main menu...")
	
	# Asegurar que todas las configuraciones se guarden antes de salir
	_save_all_settings()
	
	# Si tenemos un parent que es el MainMenu, solo ocultarse y emitir señal
	var parent_node = get_parent()
	if parent_node and parent_node.name == "MainMenu":
		print("SettingsMenu: Embedded mode - hiding and notifying parent")
		back_to_main.emit()
		hide()
	else:
		# Si somos una escena independiente, cambiar de escena al menú modular
		print("SettingsMenu: Standalone mode - changing scene to MainMenuModular")
		get_tree().change_scene_to_file("res://content/scenes/Menus/MainMenuModular.tscn")

func _save_all_settings():
	"""Guardar todas las configuraciones pendientes"""
	if not _is_config_manager_available():
		print("SettingsMenu: ConfigManager not available for saving")
		return
	
	print("SettingsMenu: Saving all pending settings...")
	
	# Forzar guardado de configuraciones
	ConfigManager.save()
	print("SettingsMenu: All settings saved successfully")

func _on_back_to_main_menu():
	"""Volver al menú principal"""
	_show_main_menu()

# =======================
#  INPUT HANDLING
# =======================
func _unhandled_input(event):
	"""Manejar input no procesado"""
	if not visible:  # Solo procesar input si el settings menu está visible
		return
	
	# Solo procesar eventos de teclado presionados
	if not event is InputEventKey or not event.pressed:
		return
	
	# Manejo de tecla ESC para volver al main menu
	if event.keycode == KEY_ESCAPE:
		_on_back_pressed()
		get_viewport().set_input_as_handled()

# =======================
#  AUDIO SETTINGS
# =======================
func _load_audio_settings():
	"""Cargar configuración de audio"""
	print("SettingsMenu: Loading audio settings...")
	
	if not _is_config_manager_available():
		print("SettingsMenu: ConfigManager not available for audio")
		return
	
	var master_vol = ConfigManager.get_setting("audio", "master_volume", 0.8)
	var music_vol = ConfigManager.get_setting("audio", "music_volume", 0.7)
	var sfx_vol = ConfigManager.get_setting("audio", "sfx_volume", 0.8)
	
	_set_slider_value(master_slider, master_vol)
	_set_slider_value(music_slider, music_vol)
	_set_slider_value(sfx_slider, sfx_vol)
	
	_update_master_label(master_vol)
	_update_music_label(music_vol)
	_update_sfx_label(sfx_vol)

func _set_slider_value(slider: HSlider, value: float):
	"""Establecer valor de slider de forma segura"""
	if slider:
		slider.value = value

func _on_master_volume_changed(value: float):
	"""Cambio en volumen maestro"""
	_update_master_label(value)
	_apply_audio_setting("Master", value)
	if _is_config_manager_available():
		ConfigManager.set_setting("audio", "master_volume", value)
		ConfigManager.save()

func _on_music_volume_changed(value: float):
	"""Cambio en volumen de música"""
	_update_music_label(value)
	_apply_audio_setting("Music", value)
	if _is_config_manager_available():
		ConfigManager.set_setting("audio", "music_volume", value)
		ConfigManager.save()

func _on_sfx_volume_changed(value: float):
	"""Cambio en volumen de efectos"""
	_update_sfx_label(value)
	_apply_audio_setting("SFX", value)
	if _is_config_manager_available():
		ConfigManager.set_setting("audio", "sfx_volume", value)
		ConfigManager.save()

func _update_master_label(value: float):
	"""Actualizar etiqueta de volumen maestro"""
	if master_label and is_instance_valid(master_label):
		master_label.text = "Master: %d%%" % int(value * 100)

func _update_music_label(value: float):
	"""Actualizar etiqueta de volumen de música"""
	if music_label and is_instance_valid(music_label):
		music_label.text = "Music: %d%%" % int(value * 100)

func _update_sfx_label(value: float):
	"""Actualizar etiqueta de volumen de efectos"""
	if sfx_label and is_instance_valid(sfx_label):
		sfx_label.text = "SFX: %d%%" % int(value * 100)

func _apply_audio_setting(bus_name: String, value: float):
	"""Aplicar configuración de audio"""
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var db_value = linear_to_db(value) if value > 0.0 else -80.0
		AudioServer.set_bus_volume_db(bus_index, db_value)
		print("SettingsMenu: Set %s volume to %.1f dB (%.2f linear)" % [bus_name, db_value, value])
	else:
		print("SettingsMenu: Audio bus '%s' not found - trying to create..." % bus_name)
		# Intentar notificar al AudioManager para que recree los buses
		var audio_manager = get_node_or_null("/root/AudioManager")
		if audio_manager and audio_manager.has_method("_ensure_audio_buses_exist"):
			audio_manager._ensure_audio_buses_exist()
			# Reintentar
			bus_index = AudioServer.get_bus_index(bus_name)
			if bus_index != -1:
				var db_value = linear_to_db(value) if value > 0.0 else -80.0
				AudioServer.set_bus_volume_db(bus_index, db_value)
				print("SettingsMenu: Set %s volume to %.1f dB after bus creation" % [bus_name, db_value])

# =======================
#  VIDEO SETTINGS
# =======================
func _load_video_settings():
	"""Cargar configuración de video"""
	print("SettingsMenu: Loading video settings...")
	
	if not _is_config_manager_available():
		print("SettingsMenu: ConfigManager not available for video")
		_set_default_video_values()
		return
	
	# Cargar configuración guardada
	saved_screen_mode = ConfigManager.get_setting("video", "screen_mode", 0)
	saved_resolution = ConfigManager.get_setting("video", "resolution", 0)
	saved_vsync = ConfigManager.get_setting("video", "vsync", true)
	
	# Establecer valores temporales
	temp_screen_mode = saved_screen_mode
	temp_resolution = saved_resolution
	temp_vsync = saved_vsync
	
	# Actualizar UI
	_update_video_ui()
	_update_apply_button_state()

func _set_default_video_values():
	"""Establecer valores por defecto"""
	saved_screen_mode = 0
	saved_resolution = 0
	saved_vsync = true
	temp_screen_mode = saved_screen_mode
	temp_resolution = saved_resolution
	temp_vsync = saved_vsync
	_update_video_ui()

func _update_video_ui():
	"""Actualizar interfaz de video"""
	if screen_mode_btn:
		screen_mode_btn.selected = saved_screen_mode
	if resolution_btn:
		resolution_btn.selected = saved_resolution
	if vsync_checkbtn:
		vsync_checkbtn.button_pressed = saved_vsync

func _on_screen_mode_selected(index: int):
	"""Cambio en modo de pantalla"""
	temp_screen_mode = index
	_update_apply_button_state()

func _on_resolution_selected(index: int):
	"""Cambio en resolución"""
	temp_resolution = index
	_update_apply_button_state()

func _on_vsync_toggled(pressed: bool):
	"""Cambio en VSync"""
	temp_vsync = pressed
	_update_apply_button_state()

func _update_apply_button_state():
	"""Actualizar estado del botón aplicar"""
	var has_changes = (
		temp_screen_mode != saved_screen_mode or
		temp_resolution != saved_resolution or
		temp_vsync != saved_vsync
	)
	
	if apply_btn:
		apply_btn.disabled = not has_changes
	
	print("SettingsMenu: Apply button %s (changes: %s)" % ["enabled" if has_changes else "disabled", has_changes])

func _on_apply_video_settings():
	"""Aplicar configuración de video"""
	print("SettingsMenu: Applying video settings...")
	
	_update_status_label("Applying changes...")
	
	var changes_applied = false
	var in_editor = Engine.is_editor_hint() or OS.has_feature("editor")
	
	# Aplicar VSync
	if temp_vsync != saved_vsync:
		_apply_vsync(temp_vsync)
		changes_applied = true
	
	# Aplicar resolución
	if temp_resolution != saved_resolution:
		if not in_editor:
			_apply_resolution(temp_resolution)
			changes_applied = true
		else:
			print("SettingsMenu: Resolution change skipped (running in editor)")
			changes_applied = true  # Marcar como aplicado para guardar la configuración
	
	# Aplicar modo de pantalla
	if temp_screen_mode != saved_screen_mode:
		if not in_editor:
			await get_tree().process_frame
			_apply_screen_mode(temp_screen_mode)
			changes_applied = true
		else:
			print("SettingsMenu: Screen mode change skipped (running in editor)")
			changes_applied = true  # Marcar como aplicado para guardar la configuración
	
	if not changes_applied:
		_update_status_label("No changes to apply")
		return
	
	# Guardar configuración SIEMPRE, incluso en el editor
	if _is_config_manager_available():
		ConfigManager.set_setting("video", "screen_mode", temp_screen_mode)
		ConfigManager.set_setting("video", "resolution", temp_resolution)
		ConfigManager.set_setting("video", "vsync", temp_vsync)
		ConfigManager.save()
		print("SettingsMenu: Video settings saved to config")
	
	# Notificar cambios a DevTools si existe
	_notify_video_settings_changed()
	
	# Actualizar valores guardados
	saved_screen_mode = temp_screen_mode
	saved_resolution = temp_resolution
	saved_vsync = temp_vsync
	
	_update_apply_button_state()
	
	if in_editor:
		_update_status_label("Settings saved (will apply when exported)")
	else:
		_update_status_label("Changes applied successfully!")
	
	# Limpiar status después de 3 segundos
	get_tree().create_timer(3.0).timeout.connect(func(): _update_status_label(""))
	
	print("SettingsMenu: Video settings processing completed")

func _on_reset_video_settings():
	"""Resetear configuración de video"""
	print("SettingsMenu: Resetting video settings...")
	
	# Restaurar valores temporales
	temp_screen_mode = saved_screen_mode
	temp_resolution = saved_resolution
	temp_vsync = saved_vsync
	
	# Actualizar UI
	_update_video_ui()
	_update_apply_button_state()
	_update_status_label("Settings reset")

func _apply_screen_mode(mode: int):
	"""Aplicar modo de pantalla"""
	print("SettingsMenu: Setting screen mode to: %d" % mode)
	
	# Verificar si estamos en el editor (modo debug)
	if Engine.is_editor_hint() or OS.has_feature("editor"):
		print("SettingsMenu: Running in editor - screen mode changes limited")
		_update_status_label("Running in editor - screen mode limited")
		return
	
	# Verificar entorno headless
	if DisplayServer.get_name() == "headless":
		print("SettingsMenu: Skipping screen mode in headless environment")
		return
	
	match mode:
		0:  # Windowed
			print("SettingsMenu: Applying windowed mode")
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			# Asegurar que tenga decoraciones de ventana (no hay flag UNRESIZABLE en Godot 4.4)
		1:  # Fullscreen
			print("SettingsMenu: Applying fullscreen mode")
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:  # Borderless Fullscreen
			print("SettingsMenu: Applying borderless fullscreen mode")
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			var screen_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_size(screen_size)
			DisplayServer.window_set_position(Vector2i.ZERO)

func _apply_resolution(res_index: int):
	"""Aplicar resolución"""
	if res_index < 0 or res_index >= available_resolutions.size():
		print("SettingsMenu: Invalid resolution index: %d" % res_index)
		return
	
	var resolution = available_resolutions[res_index]
	print("SettingsMenu: Setting resolution to: %dx%d" % [resolution.x, resolution.y])
	
	# Verificar si estamos en el editor
	if Engine.is_editor_hint() or OS.has_feature("editor"):
		print("SettingsMenu: Running in editor - resolution changes limited")
		_update_status_label("Running in editor - resolution limited")
		return
	
	if DisplayServer.get_name() != "headless":
		# Solo cambiar resolución si no estamos en modo fullscreen
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_size(resolution)
			# Centrar la ventana
			var screen_size = DisplayServer.screen_get_size()
			var window_pos = (screen_size - resolution) / 2
			DisplayServer.window_set_position(window_pos)
			print("SettingsMenu: Resolution applied and window centered")
		else:
			print("SettingsMenu: Resolution setting saved for next windowed mode")

func _apply_vsync(enabled: bool):
	"""Aplicar VSync"""
	print("SettingsMenu: Setting VSync to: %s" % enabled)
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# =======================
#  UTILIDADES
# =======================
func _is_config_manager_available() -> bool:
	"""Verificar si ConfigManager está disponible"""
	return get_node_or_null("/root/ConfigManager") != null

func _notify_video_settings_changed():
	"""Notificar cambios en configuración de video"""
	var dev_tools = get_node_or_null("/root/DevTools")
	if dev_tools and dev_tools.has_method("notify_video_settings_changed"):
		dev_tools.notify_video_settings_changed()
		print("SettingsMenu: Notified DevTools of video settings change")

func _update_status_label(text: String):
	"""Actualizar etiqueta de estado"""
	if status_label and is_instance_valid(status_label):
		status_label.text = text

func _load_all_settings():
	"""Cargar todas las configuraciones"""
	_load_audio_settings()
	_load_video_settings()

# =======================
#  FUNCIONES DE DEBUG
# =======================
func debug_print_info():
	"""Información de debug del menú de configuración"""
	print("=== SETTINGS MENU DEBUG INFO ===")
	print("Main Panel: %s" % (main_panel != null))
	print("Audio Menu: %s" % (audio_menu != null))
	print("Video Menu: %s" % (video_menu != null))
	print("Current Resolution: %s" % str(DisplayServer.window_get_size()))
	print("Current Mode: %d" % DisplayServer.window_get_mode())
	print("ConfigManager Available: %s" % _is_config_manager_available())
	print("================================")

func debug_apply_changes():
	"""Debug: aplicar cambios forzadamente"""
	_on_apply_video_settings()

func debug_test_resolution_change():
	"""Debug: probar cambio de resolución"""
	temp_resolution = (temp_resolution + 1) % available_resolutions.size()
	_apply_resolution(temp_resolution)
	_update_apply_button_state()

# =======================
#  CLEANUP
# =======================
func _exit_tree():
	print("SettingsMenu: Cleanup complete")
