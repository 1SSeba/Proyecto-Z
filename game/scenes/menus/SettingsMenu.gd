extends Control

signal settings_closed
signal back_pressed
signal settings_applied
signal settings_changed

# Node references
@onready var settings_content: VBoxContainer = $MainContainer/ContentContainer/SettingsContainer/SettingsContent
@onready var tab_container: VBoxContainer = $MainContainer/ContentContainer/TabContainer
@onready var button_container: HBoxContainer = $MainContainer/ButtonContainer

@onready var audio_tab: Button = $MainContainer/ContentContainer/TabContainer/AudioTab
@onready var video_tab: Button = $MainContainer/ContentContainer/TabContainer/VideoTab
@onready var controls_tab: Button = $MainContainer/ContentContainer/TabContainer/ControlsTab
@onready var gameplay_tab: Button = $MainContainer/ContentContainer/TabContainer/GameplayTab
@onready var accessibility_tab: Button = $MainContainer/ContentContainer/TabContainer/AccessibilityTab

@onready var audio_panel: Control = $MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings
@onready var video_panel: Control = $MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings
@onready var controls_panel: Control = $MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings
@onready var gameplay_panel: Control = $MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings
@onready var accessibility_panel: Control = $MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings

@onready var apply_button: Button = $MainContainer/ButtonContainer/ApplyButton
@onready var ok_button: Button = $MainContainer/ButtonContainer/OKButton
@onready var cancel_button: Button = $MainContainer/ButtonContainer/CancelButton

#  CONFIGURATION DATA

var tabs_config: Dictionary = {
	"audio": {"button": null, "panel": null},
	"video": {"button": null, "panel": null},
	"controls": {"button": null, "panel": null},
	"gameplay": {"button": null, "panel": null},
	"accessibility": {"button": null, "panel": null}
}

var resolution_options: Array[String] = [
	"1280x720", "1366x768", "1920x1080", "2560x1440", "3840x2160"
]

var window_mode_options: Array[String] = [
	"Windowed", "Fullscreen", "Windowed Borderless", "Fullscreen Exclusive"
]

var fps_options: Array[String] = [
	"30", "60", "75", "90", "120", "144", "240", "Unlimited"
]

var quality_preset_options: Array[String] = [
	"Low", "Medium", "High", "Ultra"
]

var autosave_interval_options: Array[String] = [
	"1 minute", "2 minutes", "5 minutes", "10 minutes", "15 minutes", "30 minutes"
]

#  STATE VARIABLES

var current_tab: String = "audio"
var config_service: Node = null
var current_settings: Dictionary = {}
var has_unsaved_changes: bool = false
var is_initialized: bool = false

#  LIFECYCLE

func _ready():
	await _initialize_settings()

func _input(event: InputEvent):
	if is_initialized and event.is_action_pressed("ui_cancel"):
		_cancel_pressed()
		get_viewport().set_input_as_handled()

#  INITIALIZATION

func _initialize_settings():
	print("SettingsMenu: Inicializando...")

	await _wait_for_services()

	config_service = ServiceManager.get_config_service()
	if not config_service:
		push_error("SettingsMenu: ConfigService no disponible")
		return

	_setup_simple_references()
	_connect_simple_events()
	_setup_option_buttons()
	_load_settings()
	_update_ui()
	_switch_to_tab("audio")

	is_initialized = true
	print("SettingsMenu: Inicialización completada")

func _setup_simple_references():
	tabs_config.audio.button = audio_tab
	tabs_config.audio.panel = audio_panel
	tabs_config.video.button = video_tab
	tabs_config.video.panel = video_panel
	tabs_config.controls.button = controls_tab
	tabs_config.controls.panel = controls_panel
	tabs_config.gameplay.button = gameplay_tab
	tabs_config.gameplay.panel = gameplay_panel
	tabs_config.accessibility.button = accessibility_tab
	tabs_config.accessibility.panel = accessibility_panel

func _connect_simple_events():
	audio_tab.pressed.connect(_switch_to_tab.bind("audio"))
	video_tab.pressed.connect(_switch_to_tab.bind("video"))
	controls_tab.pressed.connect(_switch_to_tab.bind("controls"))
	gameplay_tab.pressed.connect(_switch_to_tab.bind("gameplay"))
	accessibility_tab.pressed.connect(_switch_to_tab.bind("accessibility"))

	# Connect top-level buttons (guard so we don't connect multiple times)
	var apply_callable = Callable(self, "_on_apply_button_pressed")
	if not apply_button.pressed.is_connected(apply_callable):
		apply_button.pressed.connect(apply_callable)

	var ok_callable = Callable(self, "_on_ok_button_pressed")
	if not ok_button.pressed.is_connected(ok_callable):
		ok_button.pressed.connect(ok_callable)

	var cancel_callable = Callable(self, "_on_cancel_button_pressed")
	if not cancel_button.pressed.is_connected(cancel_callable):
		cancel_button.pressed.connect(cancel_callable)

	# Connect audio controls
	var master_slider = settings_content.get_node_or_null("AudioSettings/MasterVolumeContainer/MasterVolumeSlider")
	if master_slider:
		var master_callable = Callable(self, "_on_master_volume_changed")
		if not master_slider.value_changed.is_connected(master_callable):
			master_slider.value_changed.connect(master_callable)

	var music_slider = settings_content.get_node_or_null("AudioSettings/MusicVolumeContainer/MusicVolumeSlider")
	if music_slider:
		var music_callable = Callable(self, "_on_music_volume_changed")
		if not music_slider.value_changed.is_connected(music_callable):
			music_slider.value_changed.connect(music_callable)

	var sfx_slider = settings_content.get_node_or_null("AudioSettings/SFXVolumeContainer/SFXVolumeSlider")
	if sfx_slider:
		var sfx_callable = Callable(self, "_on_sfx_volume_changed")
		if not sfx_slider.value_changed.is_connected(sfx_callable):
			sfx_slider.value_changed.connect(sfx_callable)

	var spatial_audio_check = settings_content.get_node_or_null("AudioSettings/SpatialAudioContainer/SpatialAudioCheck")
	if spatial_audio_check:
		var spatial_callable = Callable(self, "_on_spatial_audio_toggled")
		if not spatial_audio_check.toggled.is_connected(spatial_callable):
			spatial_audio_check.toggled.connect(spatial_callable)

	# Connect video controls
	var vsync_check = settings_content.get_node_or_null("VideoSettings/VsyncContainer/VsyncCheck")
	if vsync_check:
		var vsync_callable = Callable(self, "_on_vsync_toggled")
		if not vsync_check.toggled.is_connected(vsync_callable):
			vsync_check.toggled.connect(vsync_callable)

	# Connect controls
	var mouse_sens_slider = settings_content.get_node_or_null("ControlsSettings/MouseSensitivityContainer/MouseSensitivitySlider")
	if mouse_sens_slider:
		var mouse_sens_callable = Callable(self, "_on_mouse_sensitivity_changed")
		if not mouse_sens_slider.value_changed.is_connected(mouse_sens_callable):
			mouse_sens_slider.value_changed.connect(mouse_sens_callable)

	var mouse_invert_check = settings_content.get_node_or_null("ControlsSettings/MouseInvertContainer/MouseInvertXCheck")
	if mouse_invert_check:
		var mouse_invert_callable = Callable(self, "_on_mouse_invert_x_toggled")
		if not mouse_invert_check.toggled.is_connected(mouse_invert_callable):
			mouse_invert_check.toggled.connect(mouse_invert_callable)

	var gamepad_vibration_check = settings_content.get_node_or_null("ControlsSettings/GamepadVibrationContainer/GamepadVibrationCheck")
	if gamepad_vibration_check:
		var gamepad_vibration_callable = Callable(self, "_on_gamepad_vibration_toggled")
		if not gamepad_vibration_check.toggled.is_connected(gamepad_vibration_callable):
			gamepad_vibration_check.toggled.connect(gamepad_vibration_callable)

	# Connect gameplay controls
	var auto_save_check = settings_content.get_node_or_null("GameplaySettings/AutoSaveContainer/AutoSaveCheck")
	if auto_save_check:
		var auto_save_callable = Callable(self, "_on_auto_save_toggled")
		if not auto_save_check.toggled.is_connected(auto_save_callable):
			auto_save_check.toggled.connect(auto_save_callable)

	var tutorial_hints_check = settings_content.get_node_or_null("GameplaySettings/TutorialHintsContainer/TutorialHintsCheck")
	if tutorial_hints_check:
		var tutorial_hints_callable = Callable(self, "_on_tutorial_hints_toggled")
		if not tutorial_hints_check.toggled.is_connected(tutorial_hints_callable):
			tutorial_hints_check.toggled.connect(tutorial_hints_callable)

	# Connect accessibility controls
	var large_font_check = settings_content.get_node_or_null("AccessibilitySettings/LargeFontContainer/LargeFontCheck")
	if large_font_check:
		var large_font_callable = Callable(self, "_on_large_font_toggled")
		if not large_font_check.toggled.is_connected(large_font_callable):
			large_font_check.toggled.connect(large_font_callable)

	var high_contrast_check = settings_content.get_node_or_null("AccessibilitySettings/HighContrastContainer/HighContrastCheck")
	if high_contrast_check:
		var high_contrast_callable = Callable(self, "_on_high_contrast_toggled")
		if not high_contrast_check.toggled.is_connected(high_contrast_callable):
			high_contrast_check.toggled.connect(high_contrast_callable)

	var font_size_slider = settings_content.get_node_or_null("AccessibilitySettings/FontSizeContainer/FontSizeSlider")
	if font_size_slider:
		var font_size_callable = Callable(self, "_on_font_size_scale_changed")
		if not font_size_slider.value_changed.is_connected(font_size_callable):
			font_size_slider.value_changed.connect(font_size_callable)

func _setup_option_buttons():
	var resolution_button = settings_content.get_node_or_null("VideoSettings/ResolutionContainer/ResolutionOption")
	if resolution_button:
		resolution_button.clear()
		for option in resolution_options:
			resolution_button.add_item(option)
		resolution_button.item_selected.connect(_on_resolution_item_selected)

	var window_mode_button = settings_content.get_node_or_null("VideoSettings/WindowModeContainer/WindowModeOption")
	if window_mode_button:
		window_mode_button.clear()
		for option in window_mode_options:
			window_mode_button.add_item(option)
		window_mode_button.item_selected.connect(_on_window_mode_item_selected)

	var fps_button = settings_content.get_node_or_null("VideoSettings/FPSLimitContainer/FPSLimitOption")
	if fps_button:
		fps_button.clear()
		for option in fps_options:
			fps_button.add_item(option)
		fps_button.item_selected.connect(_on_fps_limit_item_selected)

	var quality_button = settings_content.get_node_or_null("VideoSettings/QualityPresetContainer/QualityPresetOption")
	if quality_button:
		quality_button.clear()
		for option in quality_preset_options:
			quality_button.add_item(option)
		quality_button.item_selected.connect(_on_quality_preset_item_selected)

	var autosave_button = settings_content.get_node_or_null("GameplaySettings/AutoSaveIntervalContainer/AutoSaveIntervalOption")
	if autosave_button:
		autosave_button.clear()
		for option in autosave_interval_options:
			autosave_button.add_item(option)
		autosave_button.item_selected.connect(_on_auto_save_interval_item_selected)

func _wait_for_services():
	var attempts = 0
	while not ServiceManager or attempts > 30:
		await get_tree().process_frame
		attempts += 1

	if attempts > 30:
		push_error("SettingsMenu: ServiceManager no encontrado")

#  TAB MANAGEMENT

func _switch_to_tab(tab_name: String):
	current_tab = tab_name

	for tab in tabs_config.values():
		if tab.panel:
			tab.panel.visible = false
		if tab.button:
			tab.button.button_pressed = false

	var current_config = tabs_config.get(tab_name)
	if current_config and current_config.panel:
		current_config.panel.visible = true
		current_config.button.button_pressed = true

	apply_button.visible = (tab_name == "video")
	print("SettingsMenu: Cambiado a tab: ", tab_name)

#  UI UPDATE FUNCTIONS

func _update_ui():
	if not current_settings:
		return

	print("SettingsMenu: Actualizando UI...")

	# Audio settings
	_update_slider("AudioSettings/MasterVolumeContainer/MasterVolumeSlider", "audio", "master_volume", 1.0)
	_update_slider("AudioSettings/MusicVolumeContainer/MusicVolumeSlider", "audio", "music_volume", 1.0)
	_update_slider("AudioSettings/SFXVolumeContainer/SFXVolumeSlider", "audio", "sfx_volume", 1.0)
	_update_checkbox("AudioSettings/SpatialAudioContainer/SpatialAudioCheck", "audio", "spatial_audio", false)

	# Video settings
	_update_checkbox("VideoSettings/VsyncContainer/VsyncCheck", "video", "vsync", true)
	_update_option_button("VideoSettings/FPSLimitContainer/FPSLimitOption", "video", "fps_limit", 1)
	_update_option_button("VideoSettings/ResolutionContainer/ResolutionOption", "video", "resolution", 2)
	_update_option_button("VideoSettings/WindowModeContainer/WindowModeOption", "video", "window_mode", 0)
	_update_option_button("VideoSettings/QualityPresetContainer/QualityPresetOption", "video", "quality_preset", 1)

	# Controls settings
	_update_slider("ControlsSettings/MouseSensitivityContainer/MouseSensitivitySlider", "controls", "mouse_sensitivity", 1.0)
	_update_checkbox("ControlsSettings/MouseInvertContainer/MouseInvertXCheck", "controls", "mouse_invert_x", false)
	_update_checkbox("ControlsSettings/GamepadVibrationContainer/GamepadVibrationCheck", "controls", "gamepad_vibration", true)

	# Gameplay settings
	_update_checkbox("GameplaySettings/AutoSaveContainer/AutoSaveCheck", "gameplay", "auto_save", true)
	_update_option_button("GameplaySettings/AutoSaveIntervalContainer/AutoSaveIntervalOption", "gameplay", "auto_save_interval", 2)
	_update_checkbox("GameplaySettings/TutorialHintsContainer/TutorialHintsCheck", "gameplay", "tutorial_hints", true)

	# Accessibility settings
	_update_checkbox("AccessibilitySettings/LargeFontContainer/LargeFontCheck", "accessibility", "large_font", false)
	_update_checkbox("AccessibilitySettings/HighContrastContainer/HighContrastCheck", "accessibility", "high_contrast", false)
	_update_slider("AccessibilitySettings/FontSizeContainer/FontSizeSlider", "accessibility", "font_size_scale", 1.0)

#  HELPER FUNCTIONS

func _update_slider(path: String, section: String, key: String, default_value: float):
	var slider = settings_content.get_node_or_null(path)
	if slider:
		var value = current_settings.get(section, {}).get(key, default_value)
		slider.value = value

		var label_path = path.replace("Slider", "Value")
		var label = settings_content.get_node_or_null(label_path)
		if label:
			if key == "font_size_scale":
				var percentage = int(value * 100)
				label.text = str(percentage) + "%"
			elif key.ends_with("_volume"):
				var percentage = int(value * 100)
				label.text = str(percentage) + "%"
			elif key == "mouse_sensitivity":
				label.text = str(value) + "x"
			else:
				label.text = str(value)

func _update_checkbox(path: String, section: String, key: String, default_value: bool):
	var checkbox = settings_content.get_node_or_null(path)
	if checkbox:
		var value = current_settings.get(section, {}).get(key, default_value)
		checkbox.button_pressed = value

func _update_option_button(path: String, section: String, key: String, default_value: int):
	var option_button = settings_content.get_node_or_null(path)
	if option_button:
		var value = current_settings.get(section, {}).get(key, default_value)
		option_button.selected = value

func _normalize_loaded_volume(value) -> float:
	# Accept either 0..1 or 0..100; return 0..1
	if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
		var v = float(value)
		if v > 1.0:
			v = clamp(v / 100.0, 0.0, 1.0)
		if v > 1.0:
			# assume percent
			return clamp(v / 100.0, 0.0, 1.0)
		return clamp(v, 0.0, 1.0)
	return 1.0

#  CONFIGURATION MANAGEMENT

func _load_settings():
	if not config_service:
		return

	current_settings = {
		"audio": {
			# Normalize volumes: config may store 0..100 (percent) or 0..1 (fraction).
			"master_volume": _normalize_loaded_volume(config_service.get_setting("audio", "master_volume", 80.0)),
			"music_volume": _normalize_loaded_volume(config_service.get_setting("audio", "music_volume", 80.0)),
			"sfx_volume": _normalize_loaded_volume(config_service.get_setting("audio", "sfx_volume", 90.0)),
			"spatial_audio": config_service.get_setting("audio", "spatial_audio", true)
		},
		"video": {
			"vsync": config_service.get_setting("video", "vsync", true),
			"fps_limit": config_service.get_setting("video", "fps_limit", 1),
			"resolution": config_service.get_setting("video", "resolution", 2),
			"window_mode": config_service.get_setting("video", "window_mode", 0),
			"quality_preset": config_service.get_setting("video", "quality_preset", 1)
		},
		"controls": {
			"mouse_sensitivity": config_service.get_setting("controls", "mouse_sensitivity", 1.0),
			"mouse_invert_x": config_service.get_setting("controls", "mouse_invert_x", false),
			"gamepad_vibration": config_service.get_setting("controls", "gamepad_vibration", true)
		},
		"gameplay": {
			"auto_save": config_service.get_setting("gameplay", "auto_save", true),
			"auto_save_interval": config_service.get_setting("gameplay", "auto_save_interval", 2),
			"tutorial_hints": config_service.get_setting("gameplay", "tutorial_hints", true)
		},
		"accessibility": {
			"large_font": config_service.get_setting("accessibility", "large_font", false),
			"high_contrast": config_service.get_setting("accessibility", "high_contrast", false),
			"font_size_scale": config_service.get_setting("accessibility", "font_size_scale", 1.0)
		}
	}

	print("SettingsMenu: Configuraciones cargadas")

func _save_settings():
	if not config_service:
		return

	for section_name in current_settings.keys():
		var section_data = current_settings[section_name]
		for key in section_data.keys():
			# If saving audio volumes, store as 0..100 percent to keep compatibility
			if section_name == "audio" and key.ends_with("_volume"):
				config_service.set_value(section_name, key, int(section_data[key] * 100))
			else:
				config_service.set_value(section_name, key, section_data[key])

	config_service.save_config()
	has_unsaved_changes = false
	settings_applied.emit()
	print("SettingsMenu: Configuraciones guardadas")

func _update_setting(section: String, key: String, value):
	if not current_settings.has(section):
		current_settings[section] = {}
	current_settings[section][key] = value
	has_unsaved_changes = true
	settings_changed.emit()

func _apply_video_settings():
	var video_settings = current_settings.get("video", {})

	# First, ensure we're in the correct window mode before changing resolution
	var window_mode_index = video_settings.get("window_mode", 0)

	# Reset any previous borderless state
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

	# Apply window mode
	match window_mode_index:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: # Windowed Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			await get_tree().process_frame # Wait a frame for mode change
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: # Fullscreen Exclusive
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	# Wait a frame for window mode to be applied
	await get_tree().process_frame

	# Apply resolution (only for windowed modes)
	if window_mode_index == 0 or window_mode_index == 2: # Windowed or Windowed Borderless
		var resolution_index = video_settings.get("resolution", 2)
		if resolution_index < resolution_options.size():
			var resolution_string = resolution_options[resolution_index]
			var parts = resolution_string.split("x")
			if parts.size() == 2:
				var width = parts[0].to_int()
				var height = parts[1].to_int()
				var new_size = Vector2i(width, height)

				# Set the size and center the window
				DisplayServer.window_set_size(new_size)
				await get_tree().process_frame # Wait for size change

				# Center the window on screen
				var screen_size = DisplayServer.screen_get_size()
				var window_pos = Vector2i(
					(screen_size.x - new_size.x) / 2,
					(screen_size.y - new_size.y) / 2
				)
				DisplayServer.window_set_position(window_pos)

	# Apply VSync
	var vsync = video_settings.get("vsync", true)
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	)

	# Apply FPS limit
	var fps_index = video_settings.get("fps_limit", 1)
	if fps_index < fps_options.size():
		var fps_string = fps_options[fps_index]
		if fps_string == "Unlimited":
			Engine.max_fps = 0
		else:
			Engine.max_fps = fps_string.to_int()

	print("SettingsMenu: Configuración de video aplicada - Resolución: ", resolution_options[video_settings.get("resolution", 2)], ", Modo: ", window_mode_options[window_mode_index])

#  BUTTON HANDLERS

func _apply_settings():
	await _apply_video_settings()
	_save_settings()
	print("SettingsMenu: Configuraciones aplicadas")

func _ok_pressed():
	await _apply_video_settings()
	_save_settings()
	_close_settings()

func _cancel_pressed():
	if has_unsaved_changes:
		_show_unsaved_dialog()
	else:
		_close_settings()

func _on_apply_button_pressed() -> void:
	await _apply_settings()

func _on_ok_button_pressed() -> void:
	await _ok_pressed()

func _on_cancel_button_pressed() -> void:
	_cancel_pressed()

func _close_settings():
	settings_closed.emit()
	queue_free()

func _show_unsaved_dialog():
	print("SettingsMenu: Cambios no guardados detectados")
	_close_settings()

#  EVENT HANDLERS

func _on_master_volume_changed(value: float):
	# Slider provides 0..1; ensure stored and applied as fraction
	var v = float(value)
	if v > 1.0:
		v = clamp(v / 100.0, 0.0, 1.0)
	_update_setting("audio", "master_volume", v)
	_apply_audio_volume_now("master_volume", v)

func _on_music_volume_changed(value: float):
	var v = float(value)
	if v > 1.0:
		v = clamp(v / 100.0, 0.0, 1.0)
	_update_setting("audio", "music_volume", v)
	_apply_audio_volume_now("music_volume", v)

func _on_sfx_volume_changed(value: float):
	var v = float(value)
	_update_setting("audio", "sfx_volume", v)
	_apply_audio_volume_now("sfx_volume", v)

func _apply_audio_volume_now(key: String, value: float):
	# Attempt to apply immediately via AudioService if available
	var audio_service = null
	if ServiceManager:
		audio_service = ServiceManager.get_audio_service()
	if audio_service:
		match key:
			"master_volume":
				audio_service.set_master_volume(value)
			"music_volume":
				audio_service.set_music_volume(value)
			"sfx_volume":
				audio_service.set_sfx_volume(value)

func _on_spatial_audio_toggled(button_pressed: bool):
	_update_setting("audio", "spatial_audio", button_pressed)

func _on_vsync_toggled(button_pressed: bool):
	_update_setting("video", "vsync", button_pressed)

func _on_fps_limit_item_selected(index: int):
	_update_setting("video", "fps_limit", index)

func _on_resolution_item_selected(index: int):
	_update_setting("video", "resolution", index)

func _on_window_mode_item_selected(index: int):
	_update_setting("video", "window_mode", index)

func _on_quality_preset_item_selected(index: int):
	_update_setting("video", "quality_preset", index)

func _on_mouse_sensitivity_changed(value: float):
	_update_setting("controls", "mouse_sensitivity", value)

func _on_mouse_invert_x_toggled(button_pressed: bool):
	_update_setting("controls", "mouse_invert_x", button_pressed)

func _on_gamepad_vibration_toggled(button_pressed: bool):
	_update_setting("controls", "gamepad_vibration", button_pressed)

func _on_auto_save_toggled(button_pressed: bool):
	_update_setting("gameplay", "auto_save", button_pressed)

func _on_auto_save_interval_item_selected(index: int):
	_update_setting("gameplay", "auto_save_interval", index)

func _on_tutorial_hints_toggled(button_pressed: bool):
	_update_setting("gameplay", "tutorial_hints", button_pressed)

func _on_large_font_toggled(button_pressed: bool):
	_update_setting("accessibility", "large_font", button_pressed)

func _on_high_contrast_toggled(button_pressed: bool):
	_update_setting("accessibility", "high_contrast", button_pressed)

func _on_font_size_scale_changed(value: float):
	_update_setting("accessibility", "font_size_scale", value)
