extends Control
# SettingsMenu.gd - Menú de configuraciones del juego

# Referencias a elementos UI
@onready var master_volume_slider: HSlider = $SettingsPanel/VBoxContainer/AudioSection/MasterVolumeContainer/MasterVolumeSlider
@onready var master_volume_value: Label = $SettingsPanel/VBoxContainer/AudioSection/MasterVolumeContainer/MasterVolumeValue
@onready var music_volume_slider: HSlider = $SettingsPanel/VBoxContainer/AudioSection/MusicVolumeContainer/MusicVolumeSlider
@onready var music_volume_value: Label = $SettingsPanel/VBoxContainer/AudioSection/MusicVolumeContainer/MusicVolumeValue
@onready var sfx_volume_slider: HSlider = $SettingsPanel/VBoxContainer/AudioSection/SfxVolumeContainer/SfxVolumeSlider
@onready var sfx_volume_value: Label = $SettingsPanel/VBoxContainer/AudioSection/SfxVolumeContainer/SfxVolumeValue
@onready var resolution_option: OptionButton = $SettingsPanel/VBoxContainer/VideoSection/ResolutionContainer/ResolutionOption
@onready var fullscreen_checkbox: CheckBox = $SettingsPanel/VBoxContainer/VideoSection/FullscreenContainer/FullscreenCheckbox
@onready var vsync_checkbox: CheckBox = $SettingsPanel/VBoxContainer/VideoSection/VSyncContainer/VSyncCheckbox
@onready var quality_option: OptionButton = $SettingsPanel/VBoxContainer/VideoSection/QualityContainer/QualityOption

# Configuraciones actuales
var current_settings: Dictionary = {
	"master_volume": 100.0,
	"music_volume": 80.0,
	"sfx_volume": 100.0,
	"resolution_index": 0,  # 1920x1080 por defecto
	"fullscreen": false,
	"vsync": true,
	"quality_level": 1  # Media por defecto
}

# Configuraciones temporales (antes de aplicar)
var temp_settings: Dictionary = {}

# Available resolutions
var available_resolutions: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1680, 1050),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
	Vector2i(1024, 768)
]

# Quality levels
var quality_names: Array[String] = ["Baja", "Media", "Alta"]

# Señales para comunicación
signal settings_closed
signal settings_applied(settings: Dictionary)
signal back_pressed  # For Observer pattern communication

func _ready():
	print("SettingsMenu: Initializing...")
	
	# Cargar configuraciones actuales
	_load_current_settings()
	
	# Aplicar configuraciones a la UI
	_update_ui_from_settings()
	
	# Configurar input handling
	set_process_input(true)
	
	print("SettingsMenu: Ready")

func _input(event):
	"""Handle input events - ESC to close settings"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_on_back_button_pressed()
				get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):  # Alternative ESC mapping
		_on_back_button_pressed()
		get_viewport().set_input_as_handled()

func _load_current_settings():
	"""Carga las configuraciones desde el ConfigService"""
	if ServiceManager and ServiceManager.has_service("ConfigService"):
		var config_service = ServiceManager.get_service("ConfigService")
		
		# Cargar configuraciones de audio
		current_settings.master_volume = config_service.get_value("audio", "master_volume", 100.0)
		current_settings.music_volume = config_service.get_value("audio", "music_volume", 80.0)
		current_settings.sfx_volume = config_service.get_value("audio", "sfx_volume", 100.0)
		
		# Cargar configuraciones de video
		var current_window_size = get_window().size
		var current_resolution_index = _find_resolution_index(current_window_size)
		
		current_settings.resolution_index = config_service.get_value("video", "resolution_index", current_resolution_index)
		current_settings.fullscreen = config_service.get_value("video", "fullscreen", false)
		current_settings.vsync = config_service.get_value("video", "vsync", true)
		current_settings.quality_level = config_service.get_value("video", "quality_level", 1)
		
		print("SettingsMenu: Settings loaded from ConfigService")
		print("  Current resolution index: ", current_settings.resolution_index)
		print("  Current window size: ", current_window_size)
	else:
		print("SettingsMenu: ConfigService not available, using defaults")
	
	# Copiar a configuraciones temporales
	temp_settings = current_settings.duplicate()

func _find_resolution_index(window_size: Vector2i) -> int:
	"""Encuentra el índice de resolución más cercano al tamaño de ventana actual"""
	for i in range(available_resolutions.size()):
		if available_resolutions[i] == window_size:
			return i
	
	# Si no encuentra exacta, devolver la más cercana o 0 por defecto
	return 0

func _update_ui_from_settings():
	"""Actualiza la UI con las configuraciones actuales"""
	# Audio sliders
	master_volume_slider.value = current_settings.master_volume
	music_volume_slider.value = current_settings.music_volume
	sfx_volume_slider.value = current_settings.sfx_volume
	
	# Video controls
	if resolution_option and current_settings.resolution_index < resolution_option.get_item_count():
		resolution_option.selected = current_settings.resolution_index
	
	fullscreen_checkbox.button_pressed = current_settings.fullscreen
	vsync_checkbox.button_pressed = current_settings.vsync
	
	if quality_option and current_settings.quality_level < quality_option.get_item_count():
		quality_option.selected = current_settings.quality_level
	
	# Actualizar labels de valores
	_update_volume_labels()
	
	print("SettingsMenu: UI updated with current settings")

func _update_volume_labels():
	"""Actualiza los labels de valores de volumen"""
	master_volume_value.text = "%d%%" % int(master_volume_slider.value)
	music_volume_value.text = "%d%%" % int(music_volume_slider.value)
	sfx_volume_value.text = "%d%%" % int(sfx_volume_slider.value)

func _apply_settings():
	"""Aplica las configuraciones temporales"""
	# Copiar configuraciones temporales a actuales
	current_settings = temp_settings.duplicate()
	
	# Aplicar a ConfigService
	if ServiceManager and ServiceManager.has_service("ConfigService"):
		var config_service = ServiceManager.get_service("ConfigService")
		
		# Guardar configuraciones de audio
		config_service.set_value("audio", "master_volume", current_settings.master_volume)
		config_service.set_value("audio", "music_volume", current_settings.music_volume)
		config_service.set_value("audio", "sfx_volume", current_settings.sfx_volume)
		
		# Guardar configuraciones de video
		config_service.set_value("video", "resolution_index", current_settings.resolution_index)
		config_service.set_value("video", "fullscreen", current_settings.fullscreen)
		config_service.set_value("video", "vsync", current_settings.vsync)
		config_service.set_value("video", "quality_level", current_settings.quality_level)
		
		# Guardar archivo de configuración
		config_service.save_config()
		
		print("SettingsMenu: Settings saved to ConfigService")
	
	# Aplicar configuraciones al sistema
	_apply_audio_settings()
	_apply_video_settings()
	
	# Emitir señal
	settings_applied.emit(current_settings)
	
	print("SettingsMenu: Settings applied successfully")

func _apply_audio_settings():
	"""Aplica configuraciones de audio al AudioService"""
	if ServiceManager and ServiceManager.has_service("AudioService"):
		var audio_service = ServiceManager.get_service("AudioService")
		
		# Aplicar volúmenes
		if audio_service.has_method("set_master_volume"):
			audio_service.set_master_volume(current_settings.master_volume / 100.0)
		if audio_service.has_method("set_music_volume"):
			audio_service.set_music_volume(current_settings.music_volume / 100.0)
		if audio_service.has_method("set_sfx_volume"):
			audio_service.set_sfx_volume(current_settings.sfx_volume / 100.0)
		
		print("SettingsMenu: Audio settings applied")

func _apply_video_settings():
	"""Aplica configuraciones de video al sistema con mejor manejo de ventana"""
	print("SettingsMenu: Applying video settings...")
	
	# Get current window
	var window = get_window()
	if not window:
		print("SettingsMenu: Warning - No window found")
		return
	
	# Aplicar resolución
	if current_settings.has("resolution_index") and current_settings.resolution_index < available_resolutions.size():
		var new_resolution = available_resolutions[current_settings.resolution_index]
		print("SettingsMenu: Setting resolution to ", new_resolution)
		
		# Si está en fullscreen, cambiar a windowed primero
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
			await get_tree().process_frame  # Wait for mode change
		
		# Aplicar nueva resolución
		window.size = new_resolution
		
		# Centrar ventana
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - new_resolution) / 2
		window.position = window_pos
		
		await get_tree().process_frame  # Wait for resize
	
	# Aplicar fullscreen después de cambiar resolución
	if current_settings.fullscreen:
		print("SettingsMenu: Enabling fullscreen")
		window.mode = Window.MODE_FULLSCREEN
	else:
		print("SettingsMenu: Setting windowed mode")
		window.mode = Window.MODE_WINDOWED
	
	# Aplicar VSync
	if current_settings.vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		print("SettingsMenu: VSync enabled")
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		print("SettingsMenu: VSync disabled")
	
	# Aplicar configuraciones de calidad gráfica
	_apply_quality_settings()
	
	print("SettingsMenu: Video settings applied successfully")

func _apply_quality_settings():
	"""Aplica configuraciones de calidad gráfica"""
	var viewport = get_viewport()
	if not viewport:
		return
		
	match current_settings.quality_level:
		0: # Baja
			viewport.scaling_3d_scale = 0.75
			viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		1: # Media
			viewport.scaling_3d_scale = 1.0
			viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		2: # Alta
			viewport.scaling_3d_scale = 1.0
			viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
	
	print("SettingsMenu: Quality level set to ", quality_names[current_settings.quality_level])

func _reset_to_defaults():
	"""Restablece configuraciones a valores por defecto"""
	temp_settings = {
		"master_volume": 100.0,
		"music_volume": 80.0,
		"sfx_volume": 100.0,
		"resolution_index": 0,
		"fullscreen": false,
		"vsync": true,
		"quality_level": 1
	}
	
	# Actualizar UI
	_update_ui_from_temp_settings()
	
	print("SettingsMenu: Settings reset to defaults")

func _update_ui_from_temp_settings():
	"""Actualiza la UI con las configuraciones temporales"""
	master_volume_slider.value = temp_settings.master_volume
	music_volume_slider.value = temp_settings.music_volume
	sfx_volume_slider.value = temp_settings.sfx_volume
	resolution_option.selected = temp_settings.resolution_index
	fullscreen_checkbox.button_pressed = temp_settings.fullscreen
	vsync_checkbox.button_pressed = temp_settings.vsync
	quality_option.selected = temp_settings.quality_level
	
	_update_volume_labels()

func show_menu():
	"""Muestra el menú de configuraciones"""
	visible = true
	
	# Recargar configuraciones actuales
	_load_current_settings()
	_update_ui_from_settings()

func hide_menu():
	"""Oculta el menú de configuraciones"""
	visible = false
	settings_closed.emit()

# =======================
#  CALLBACKS DE UI
# =======================

func _on_master_volume_changed(value: float):
	"""Maneja cambios en el volumen principal"""
	temp_settings.master_volume = value
	master_volume_value.text = "%d%%" % int(value)
	
	# Aplicar temporalmente para preview
	if ServiceManager and ServiceManager.has_service("AudioService"):
		var audio_service = ServiceManager.get_service("AudioService")
		if audio_service.has_method("set_master_volume"):
			audio_service.set_master_volume(value / 100.0)

func _on_music_volume_changed(value: float):
	"""Maneja cambios en el volumen de música"""
	temp_settings.music_volume = value
	music_volume_value.text = "%d%%" % int(value)
	
	# Aplicar temporalmente para preview
	if ServiceManager and ServiceManager.has_service("AudioService"):
		var audio_service = ServiceManager.get_service("AudioService")
		if audio_service.has_method("set_music_volume"):
			audio_service.set_music_volume(value / 100.0)

func _on_sfx_volume_changed(value: float):
	"""Maneja cambios en el volumen de efectos"""
	temp_settings.sfx_volume = value
	sfx_volume_value.text = "%d%%" % int(value)
	
	# Aplicar temporalmente para preview
	if ServiceManager and ServiceManager.has_service("AudioService"):
		var audio_service = ServiceManager.get_service("AudioService")
		if audio_service.has_method("set_sfx_volume"):
			audio_service.set_sfx_volume(value / 100.0)

func _on_resolution_selected(index: int):
	"""Maneja cambios en la resolución"""
	temp_settings.resolution_index = index
	print("SettingsMenu: Resolution selected: ", available_resolutions[index])

func _on_fullscreen_toggled(pressed: bool):
	"""Maneja cambios en fullscreen"""
	temp_settings.fullscreen = pressed

func _on_vsync_toggled(pressed: bool):
	"""Maneja cambios en VSync"""
	temp_settings.vsync = pressed

func _on_quality_selected(index: int):
	"""Maneja cambios en calidad gráfica"""
	temp_settings.quality_level = index
	print("SettingsMenu: Quality selected: ", quality_names[index])

func _on_reset_button_pressed():
	"""Maneja clic en botón Restablecer"""
	print("SettingsMenu: Reset button pressed")
	_reset_to_defaults()

func _on_apply_button_pressed():
	"""Maneja clic en botón Aplicar"""
	print("SettingsMenu: Apply button pressed")
	_apply_settings()

func _on_back_button_pressed():
	"""Maneja clic en botón Volver - Observer pattern"""
	print("SettingsMenu: Back button pressed")
	
	# Restaurar configuraciones originales (cancelar cambios temporales)
	temp_settings = current_settings.duplicate()
	_apply_audio_settings()  # Restaurar audio a valores originales
	
	# Emit signals for Observer pattern
	back_pressed.emit()
	settings_closed.emit()
	
	# Hide menu but don't manage state transitions (let observer handle it)
	hide_menu()

# =======================
#  UTILIDADES
# =======================

func get_current_settings() -> Dictionary:
	"""Obtiene las configuraciones actuales"""
	return current_settings.duplicate()

func has_unsaved_changes() -> bool:
	"""Verifica si hay cambios sin guardar"""
	return temp_settings != current_settings
