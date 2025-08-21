extends Control

# -----------------------
#  NODOS PRINCIPALES
# -----------------------
@onready var main_panel: Control = $Panel
@onready var btn_audio: Button = $Panel/VBoxContainer/Audio
@onready var btn_video: Button = $Panel/VBoxContainer/Video
@onready var btn_controls: Button = $Panel/VBoxContainer/Controls
@onready var btn_back: Button = $Panel/VBoxContainer/Back

# -----------------------
#  SUBMENÚS
# -----------------------
@onready var audio_menu: Control = $Audio
@onready var video_menu: Control = $Video
@onready var controls_menu: Control = $Controls

# -----------------------
#  AUDIO MENU ELEMENTS (Optional - may not exist in scene)
# -----------------------
@onready var master_slider: HSlider = get_node_or_null("Audio/AudioPanel/AudioOptions/MasterBox/MasterSlider")
@onready var master_label: Label = get_node_or_null("Audio/AudioPanel/AudioOptions/MasterBox/MasterLabel")
@onready var music_slider: HSlider = get_node_or_null("Audio/AudioPanel/AudioOptions/MusicBox/MusicSlider")
@onready var music_label: Label = get_node_or_null("Audio/AudioPanel/AudioOptions/MusicBox/MusicLabel")
@onready var sfx_slider: HSlider = get_node_or_null("Audio/AudioPanel/AudioOptions/EffectsBox/EffectsSlider")
@onready var sfx_label: Label = get_node_or_null("Audio/AudioPanel/AudioOptions/EffectsBox/EffectsLabel")
@onready var back_audiomenu: Button = get_node_or_null("Audio/AudioPanel/AudioOptions/Back")

# -----------------------
#  VIDEO MENU ELEMENTS (Optional - may not exist in scene)
# -----------------------
@onready var screen_mode_btn: OptionButton = get_node_or_null("Video/VideoPanel/VideoOptions/ScreenModeBox/ScreenModeBtn")
@onready var resolution_btn: OptionButton = get_node_or_null("Video/VideoPanel/VideoOptions/ResolutionBox/ResolutionBtn")
@onready var vsync_checkbtn: CheckButton = get_node_or_null("Video/VideoPanel/VideoOptions/VSyncBox/VSyncBtn")
@onready var apply_btn: Button = get_node_or_null("Video/VideoPanel/VideoOptions/SaveBox/Apply")
@onready var reset_btn: Button = get_node_or_null("Video/VideoPanel/VideoOptions/SaveBox/Reset")
@onready var back_videomenu: Button = get_node_or_null("Video/VideoPanel/VideoOptions/Back")

# Labels de estado (opcional - crear solo si existen en tu escena)
@onready var status_label: Label = get_node_or_null("Video/VideoPanel/VideoOptions/StatusLabel")

# -----------------------
#  VARIABLES TEMPORALES PARA VIDEO
# -----------------------
var temp_screen_mode := 0
var temp_resolution := 0
var temp_vsync := true
var saved_screen_mode := 0  # Renombrado para evitar shadowing
var saved_resolution := 0   # Renombrado para evitar shadowing
var saved_vsync := true     # Renombrado para evitar shadowing

# -----------------------
#  RESOLUCIONES DISPONIBLES
# -----------------------
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
	_setup_connections()
	_init_video_options()
	_hide_all_menus()
	_load_all_settings()
	_show_main_menu()

func _setup_connections():
	# Validar y conectar botones principales
	if btn_audio:
		btn_audio.pressed.connect(_on_audio_pressed)
	else:
		print("ERROR: btn_audio not found!")
		
	if btn_video:
		btn_video.pressed.connect(_on_video_pressed)
	else:
		print("ERROR: btn_video not found!")
		
	if btn_controls:
		btn_controls.pressed.connect(_on_controls_pressed)
	else:
		print("ERROR: btn_controls not found!")
		
	if btn_back:
		btn_back.pressed.connect(_on_back_pressed)
	else:
		print("ERROR: btn_back not found!")
	
	# Validar y conectar botones de regreso en submenús
	if back_audiomenu:
		back_audiomenu.pressed.connect(_on_back_to_main_menu)
	else:
		print("ERROR: back_audiomenu not found!")
		
	if back_videomenu:
		back_videomenu.pressed.connect(_on_back_to_main_menu)
	else:
		print("ERROR: back_videomenu not found!")
	
	# Validar y conectar audio sliders
	if master_slider:
		master_slider.value_changed.connect(_on_master_volume_changed)
	else:
		print("ERROR: master_slider not found!")
		
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
	else:
		print("ERROR: music_slider not found!")
		
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	else:
		print("ERROR: sfx_slider not found!")
	
	# Validar y conectar controles de video
	if screen_mode_btn:
		screen_mode_btn.item_selected.connect(_on_screen_mode_selected)
	else:
		print("ERROR: screen_mode_btn not found!")
		
	if resolution_btn:
		resolution_btn.item_selected.connect(_on_resolution_selected)
	else:
		print("ERROR: resolution_btn not found!")
		
	if vsync_checkbtn:
		vsync_checkbtn.toggled.connect(_on_vsync_toggled)
	else:
		print("ERROR: vsync_checkbtn not found!")
	
	# Validar y conectar botones de aplicar/resetear
	if apply_btn:
		apply_btn.pressed.connect(_on_apply_video_settings)
	else:
		print("ERROR: apply_btn not found!")
		
	if reset_btn:
		reset_btn.pressed.connect(_on_reset_video_settings)
	else:
		print("ERROR: reset_btn not found!")

func _init_video_options():
	# Configurar opciones de pantalla
	if screen_mode_btn:
		screen_mode_btn.clear()
		screen_mode_btn.add_item("Windowed")
		screen_mode_btn.add_item("Fullscreen")
		screen_mode_btn.add_item("Borderless")
	
	# Configurar resoluciones
	if resolution_btn:
		resolution_btn.clear()
		for i in range(available_resolutions.size()):
			var res = available_resolutions[i]
			resolution_btn.add_item("%dx%d" % [res.x, res.y])

# =======================
#  NAVEGACIÓN DE MENÚS
# =======================
func _hide_all_menus():
	if main_panel:
		main_panel.hide()
	if audio_menu:
		audio_menu.hide()
	if video_menu:
		video_menu.hide()
	if controls_menu:
		controls_menu.hide()

func _show_main_menu():
	_hide_all_menus()
	if main_panel:
		main_panel.show()

func _on_audio_pressed():
	_hide_all_menus()
	if audio_menu:
		audio_menu.show()
		_load_audio_settings()

func _on_video_pressed():
	_hide_all_menus()
	if video_menu:
		video_menu.show()
		_load_video_settings()

func _on_controls_pressed():
	_hide_all_menus()
	if controls_menu:
		controls_menu.show()
	# TODO: Implementar carga de controles

func _on_back_pressed():
	hide()

func _on_back_to_main_menu():
	_show_main_menu()

# =======================
#  AUDIO SETTINGS
# =======================
func _load_audio_settings():
	if not _is_config_manager_available():
		return
		
	var master_vol = ConfigManager.get_setting("audio", "master_volume")
	var music_vol = ConfigManager.get_setting("audio", "music_volume")
	var sfx_vol = ConfigManager.get_setting("audio", "sfx_volume")
	
	if master_vol != null and master_slider:
		master_slider.value = master_vol
		_update_master_label(master_vol)
	if music_vol != null and music_slider:
		music_slider.value = music_vol
		_update_music_label(music_vol)
	if sfx_vol != null and sfx_slider:
		sfx_slider.value = sfx_vol
		_update_sfx_label(sfx_vol)

func _on_master_volume_changed(value: float):
	_update_master_label(value)
	_apply_audio_setting("Master", value)
	if _is_config_manager_available():
		ConfigManager.set_setting("audio", "master_volume", value)

func _on_music_volume_changed(value: float):
	_update_music_label(value)
	_apply_audio_setting("Music", value)
	if _is_config_manager_available():
		ConfigManager.set_setting("audio", "music_volume", value)

func _on_sfx_volume_changed(value: float):
	_update_sfx_label(value)
	_apply_audio_setting("SFX", value)
	if _is_config_manager_available():
		ConfigManager.set_setting("audio", "sfx_volume", value)

func _update_master_label(value: float):
	if master_label:
		master_label.text = "Master: %d%%" % int(value)

func _update_music_label(value: float):
	if music_label:
		music_label.text = "Music: %d%%" % int(value)

func _update_sfx_label(value: float):
	if sfx_label:
		sfx_label.text = "SFX: %d%%" % int(value)

func _apply_audio_setting(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var db_value = linear_to_db(value / 100.0)
		AudioServer.set_bus_volume_db(bus_index, db_value)
		print("Applied %s volume: %.2f%% (%.2f dB)" % [bus_name, value, db_value])

# =======================
#  VIDEO SETTINGS
# =======================
func _load_video_settings():
	if not _is_config_manager_available():
		print("ConfigManager not available for video settings")
		return
		
	# Cargar configuración actual
	saved_screen_mode = ConfigManager.get_setting("video", "screen_mode")
	saved_resolution = ConfigManager.get_setting("video", "resolution")
	saved_vsync = ConfigManager.get_setting("video", "vsync")
	
	# Valores por defecto si es null
	if saved_screen_mode == null:
		saved_screen_mode = 0
	if saved_resolution == null:
		saved_resolution = 0
	if saved_vsync == null:
		saved_vsync = true
	
	# Actualizar variables temporales
	temp_screen_mode = saved_screen_mode
	temp_resolution = saved_resolution
	temp_vsync = saved_vsync
	
	print("Loaded video settings - Screen: %d, Resolution: %d, VSync: %s" % [saved_screen_mode, saved_resolution, saved_vsync])
	
	# Actualizar UI
	if screen_mode_btn:
		screen_mode_btn.selected = saved_screen_mode
	if resolution_btn:
		resolution_btn.selected = saved_resolution
	if vsync_checkbtn:
		vsync_checkbtn.button_pressed = saved_vsync
	
	_update_apply_button_state()

func _on_screen_mode_selected(index: int):
	temp_screen_mode = index
	_update_apply_button_state()

func _on_resolution_selected(index: int):
	temp_resolution = index
	_update_apply_button_state()

func _on_vsync_toggled(pressed: bool):
	temp_vsync = pressed
	_update_apply_button_state()

func _update_apply_button_state():
	var has_changes = (
		temp_screen_mode != saved_screen_mode or
		temp_resolution != saved_resolution or
		temp_vsync != saved_vsync
	)
	if apply_btn:
		apply_btn.disabled = not has_changes
		# Cambiar texto del botón para indicar estado
		if has_changes:
			apply_btn.text = "Apply Changes"
			apply_btn.modulate = Color.YELLOW
		else:
			apply_btn.text = "No Changes"
			apply_btn.modulate = Color.GRAY
	
	print("Apply button state: %s (changes: %s)" % ["enabled" if has_changes else "disabled", has_changes])

func _on_apply_video_settings():
	print("========== APPLYING VIDEO SETTINGS ==========")
	
	# Verificar si estamos en editor
	if OS.has_feature("editor"):
		print("INFO: Running in Godot editor - Limited video settings available")
		_handle_editor_mode_settings()
		return
	
	print("Current settings:")
	print("  Screen Mode: %d -> %d" % [saved_screen_mode, temp_screen_mode])
	print("  Resolution: %d -> %d" % [saved_resolution, temp_resolution])
	print("  VSync: %s -> %s" % [saved_vsync, temp_vsync])
	
	_update_status_label("Applying changes...")
	
	# Solo aplicar si hay cambios reales
	var changes_applied = false
	
	# ORDEN IMPORTANTE: Aplicar resolución ANTES del modo de pantalla
	
	# 1. Aplicar VSync primero (es independiente)
	if temp_vsync != saved_vsync:
		print("Applying VSync change...")
		_apply_vsync(temp_vsync)
		changes_applied = true
		await get_tree().process_frame  # Esperar un frame
	
	# 2. Aplicar resolución
	if temp_resolution != saved_resolution:
		print("Applying resolution change...")
		await _apply_resolution(temp_resolution)
		changes_applied = true
		await get_tree().process_frame  # Esperar un frame
	
	# 3. Aplicar modo de pantalla al final
	if temp_screen_mode != saved_screen_mode:
		print("Applying screen mode change...")
		await _apply_screen_mode(temp_screen_mode)
		changes_applied = true
		await get_tree().process_frame  # Esperar un frame
	if temp_resolution != saved_resolution:
		print("Applying resolution change...")
		_apply_resolution(temp_resolution)
		changes_applied = true
	
	# Aplicar VSync
	if temp_vsync != saved_vsync:
		print("Applying VSync change...")
		_apply_vsync(temp_vsync)
		changes_applied = true
	
	if not changes_applied:
		print("No changes detected to apply")
		_update_status_label("No changes to apply")
		return
	
	# Guardar configuración
	if _is_config_manager_available():
		ConfigManager.set_setting("video", "screen_mode", temp_screen_mode)
		ConfigManager.set_setting("video", "resolution", temp_resolution)
		ConfigManager.set_setting("video", "vsync", temp_vsync)
		print("Settings saved to ConfigManager")
	else:
		print("WARNING: ConfigManager not available - settings not saved!")
	
	# Actualizar configuración guardada
	saved_screen_mode = temp_screen_mode
	saved_resolution = temp_resolution
	saved_vsync = temp_vsync
	
	_update_apply_button_state()
	_update_status_label("Changes applied successfully!")
	
	# Limpiar status después de 3 segundos
	get_tree().create_timer(3.0).timeout.connect(func(): _update_status_label(""))
	
	print("============= SETTINGS APPLIED =============")
	_print_current_display_info()

func _on_reset_video_settings():
	print("Resetting video settings...")
	
	# Restaurar valores temporales
	temp_screen_mode = saved_screen_mode
	temp_resolution = saved_resolution
	temp_vsync = saved_vsync
	
	# Actualizar UI
	if screen_mode_btn:
		screen_mode_btn.selected = saved_screen_mode
	if resolution_btn:
		resolution_btn.selected = saved_resolution
	if vsync_checkbtn:
		vsync_checkbtn.button_pressed = saved_vsync
	
	_update_apply_button_state()

func _apply_screen_mode(mode: int):
	print("Setting screen mode to: %d" % mode)
	
	# Solo saltar si estamos en el editor Y es headless
	if DisplayServer.get_name() == "headless":
		print("  -> Skipping: Running in headless mode")
		return
	
	# Advertir si estamos en editor pero continuar
	if OS.has_feature("editor"):
		print("  -> Warning: Running in editor - limited functionality")
		# En editor, algunas funciones no trabajarán completamente
		# pero intentamos aplicar lo que podemos
	
	# Esperar un frame para asegurar que otros cambios se aplicaron
	await get_tree().process_frame
	
	match mode:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			print("  -> Applied: Windowed mode")
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			print("  -> Applied: Fullscreen mode")
		2: # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			print("  -> Applied: Borderless mode")
	
	# Verificar que se aplicó
	await get_tree().process_frame  # Esperar un frame
	var current_mode = DisplayServer.window_get_mode()
	var is_borderless = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	print("  -> Verification: Mode = %d, Borderless = %s" % [current_mode, is_borderless])

func _apply_resolution(res_index: int):
	print("=== APPLYING RESOLUTION ===")
	print("Resolution index: %d" % res_index)
	print("Available resolutions count: %d" % available_resolutions.size())
	
	if res_index >= 0 and res_index < available_resolutions.size():
		var resolution = available_resolutions[res_index]
		print("Target resolution: %dx%d" % [resolution.x, resolution.y])
		print("Current resolution: %s" % str(DisplayServer.window_get_size()))
		
		# Solo saltar si estamos en headless
		if DisplayServer.get_name() == "headless":
			print("  -> Skipping: Running in headless mode")
			return
		
		# Si estamos en editor, advertir pero intentar aplicar
		if OS.has_feature("editor"):
			print("  -> WARNING: Running in embedded editor window")
			print("  -> May not work fully - export for complete testing")
		
		# Aplicar la resolución
		var current_mode = DisplayServer.window_get_mode()
		
		# Si estamos en ventana, cambiar tamaño directamente
		if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_size(resolution)
			# Centrar la ventana
			var screen_size = DisplayServer.screen_get_size()
			var window_pos = (screen_size - resolution) / 2
			DisplayServer.window_set_position(window_pos)
			print("  -> Applied windowed resolution: %dx%d" % [resolution.x, resolution.y])
		else:
			# Para fullscreen, primero cambiar a ventana, redimensionar, luego volver
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			await get_tree().process_frame
			DisplayServer.window_set_size(resolution)
			await get_tree().process_frame
			DisplayServer.window_set_mode(current_mode)
			print("  -> Applied fullscreen resolution: %dx%d" % [resolution.x, resolution.y])
		
		# Verificar que se aplicó
		await get_tree().process_frame
		var final_size = DisplayServer.window_get_size()
		print("  -> Final size: %dx%d" % [final_size.x, final_size.y])
		var current_size = DisplayServer.window_get_size()
		print("  -> Target: %dx%d" % [resolution.x, resolution.y])
		print("  -> Actual: %dx%d" % [current_size.x, current_size.y])
		
		var success = (current_size.x == resolution.x and current_size.y == resolution.y)
		print("  -> Resolution change successful: %s" % success)
		
		if not success:
			print("  -> WARNING: Resolution change may not have been applied")
			print("  -> This can happen in windowed mode or due to system constraints")
	else:
		print("ERROR: Invalid resolution index: %d" % res_index)

func _apply_vsync(enabled: bool):
	print("Setting VSync to: %s" % ("enabled" if enabled else "disabled"))
	var vsync_mode = DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsync_mode)
	
	# Verificar que se aplicó
	await get_tree().process_frame  # Esperar un frame
	var current_vsync = DisplayServer.window_get_vsync_mode()
	print("  -> Applied VSync: %s" % ("enabled" if enabled else "disabled"))
	print("  -> Verification: Current VSync mode = %d" % current_vsync)

# =======================
#  CARGA INICIAL DE CONFIGURACIÓN
# =======================
func _load_all_settings():
	_apply_initial_video_settings()
	_apply_initial_audio_settings()

func _apply_initial_video_settings():
	if not _is_config_manager_available():
		return
		
	var screen_mode = ConfigManager.get_setting("video", "screen_mode")
	var resolution = ConfigManager.get_setting("video", "resolution")
	var vsync = ConfigManager.get_setting("video", "vsync")
	
	print("Applying initial video settings - Screen: %s, Resolution: %s, VSync: %s" % [screen_mode, resolution, vsync])
	
	if screen_mode != null:
		_apply_screen_mode(screen_mode)
	if resolution != null:
		_apply_resolution(resolution)
	if vsync != null:
		_apply_vsync(vsync)

func _apply_initial_audio_settings():
	var master_vol = ConfigManager.get_setting("audio", "master_volume")
	var music_vol = ConfigManager.get_setting("audio", "music_volume")
	var sfx_vol = ConfigManager.get_setting("audio", "sfx_volume")
	
	if master_vol != null:
		_apply_audio_setting("Master", master_vol)
	if music_vol != null:
		_apply_audio_setting("Music", music_vol)
	if sfx_vol != null:
		_apply_audio_setting("SFX", sfx_vol)

# =======================
#  FUNCIONES DE UTILIDAD
# =======================
func _is_config_manager_available() -> bool:
	return get_node_or_null("/root/ConfigManager") != null

# Función específica para manejar configuraciones en modo editor
func _handle_editor_mode_settings():
	# En modo editor, aplicamos solo las configuraciones que funcionan
	_apply_vsync(temp_vsync)
	
	# Guardar configuraciones usando el ConfigManager
	if _is_config_manager_available():
		ConfigManager.set_setting("video", "screen_mode", temp_screen_mode)
		ConfigManager.set_setting("video", "resolution", temp_resolution)
		ConfigManager.set_setting("video", "vsync", temp_vsync)
		ConfigManager.save()  # Usar save() en lugar de save_config()
		
		# Actualizar valores guardados
		saved_screen_mode = temp_screen_mode
		saved_resolution = temp_resolution
		saved_vsync = temp_vsync
	
	# Notificar cambios a DevTools
	if get_node_or_null("/root/DevTools"):
		if temp_screen_mode != saved_screen_mode:
			DevTools.notify_video_settings_changed("Screen Mode", saved_screen_mode, temp_screen_mode)
		if temp_resolution != saved_resolution:
			DevTools.notify_video_settings_changed("Resolution", saved_resolution, temp_resolution)
	
	# Crear un mensaje más informativo y útil
	var dev_message = "🔧 DEVELOPMENT MODE ACTIVE\n"
	dev_message += "✅ VSync: Applied successfully\n"
	
	if temp_screen_mode != saved_screen_mode:
		dev_message += "⚠️ Screen Mode: Will apply on export\n"
	
	if temp_resolution != saved_resolution:
		dev_message += "⚠️ Resolution: Will apply on export\n"
	
	dev_message += "\n💡 SHORTCUTS:\n"
	dev_message += "  F6: Quick export to test settings\n"
	dev_message += "  F7: Basic fullscreen toggle\n"
	dev_message += "  Ctrl+Shift+P: Run Quick Export task"
	
	_update_status_label(dev_message)
	print(dev_message)
	
	# Auto-ocultar el mensaje después de unos segundos
	await get_tree().create_timer(6.0).timeout
	_update_status_label("")

func _update_status_label(text: String):
	if status_label:
		status_label.text = text
		if text != "":
			status_label.modulate = Color.WHITE
	print("Status: %s" % text)

func _print_current_display_info():
	print("========== CURRENT DISPLAY INFO ==========")
	print("Window Mode: %d" % DisplayServer.window_get_mode())
	print("Window Size: %s" % str(DisplayServer.window_get_size()))
	print("Borderless: %s" % DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))
	print("VSync Mode: %d" % DisplayServer.window_get_vsync_mode())
	print("===========================================")

# =======================
#  FUNCIONES DE DEBUG
# =======================
func _print_current_settings():
	print("=== CURRENT SETTINGS ===")
	if _is_config_manager_available():
		print("Audio - Master: %s, Music: %s, SFX: %s" % [
			ConfigManager.get_setting("audio", "master_volume"),
			ConfigManager.get_setting("audio", "music_volume"),
			ConfigManager.get_setting("audio", "sfx_volume")
		])
		print("Video - Screen: %s, Resolution: %s, VSync: %s" % [
			ConfigManager.get_setting("video", "screen_mode"),
			ConfigManager.get_setting("video", "resolution"),
			ConfigManager.get_setting("video", "vsync")
		])
	else:
		print("ConfigManager not available!")
	print("=========================")

# Función para debuggear desde el inspector
func debug_apply_changes():
	print("DEBUG: Forcing apply video changes")
	_on_apply_video_settings()

func debug_print_info():
	print("DEBUG: Printing all info")
	_print_current_settings()
	_print_current_display_info()

func debug_test_resolution_change():
	print("DEBUG: Testing resolution change manually")
	print("Current resolution: %s" % str(DisplayServer.window_get_size()))
	
	# Intentar cambiar a 1920x1080
	var test_resolution = Vector2i(1920, 1080)
	print("Trying to set resolution to: %s" % str(test_resolution))
	
	DisplayServer.window_set_size(test_resolution)
	await get_tree().process_frame
	
	var new_size = DisplayServer.window_get_size()
	print("New resolution: %s" % str(new_size))
	print("Change successful: %s" % (new_size == test_resolution))

func debug_force_resolution(width: int, height: int):
	print("DEBUG: Force setting resolution to %dx%d" % [width, height])
	var target_resolution = Vector2i(width, height)
	DisplayServer.window_set_size(target_resolution)
	await get_tree().process_frame
	var actual_resolution = DisplayServer.window_get_size()
	print("Target: %s, Actual: %s" % [str(target_resolution), str(actual_resolution)])
