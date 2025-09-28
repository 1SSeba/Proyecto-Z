extends Control

signal settings_closed
signal back_pressed
signal settings_applied
signal settings_changed

const RESOLUTION_OPTIONS: Array[String] = [
	"1280x720",
	"1366x768",
	"1920x1080",
	"2560x1440",
	"3840x2160"
]

const WINDOW_MODE_OPTIONS: Array[String] = [
	"Windowed",
	"Fullscreen",
	"Windowed Borderless",
	"Exclusive Fullscreen"
]

const FPS_OPTIONS: Array[String] = [
	"30",
	"60",
	"90",
	"120",
	"144",
	"240",
	"Unlimited"
]

@onready var settings_content: VBoxContainer = $MainContainer/ContentContainer/SettingsContainer/SettingsContent
@onready var audio_tab: Button = $MainContainer/ContentContainer/TabContainer/AudioTab
@onready var video_tab: Button = $MainContainer/ContentContainer/TabContainer/VideoTab
@onready var controls_tab: Button = $MainContainer/ContentContainer/TabContainer/ControlsTab
@onready var audio_panel: Control = $MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings
@onready var video_panel: Control = $MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings
@onready var controls_panel: Control = $MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings
@onready var apply_button: Button = $MainContainer/ButtonContainer/ApplyButton
@onready var ok_button: Button = $MainContainer/ButtonContainer/OKButton
@onready var cancel_button: Button = $MainContainer/ButtonContainer/CancelButton
@onready var reset_button: Button = $MainContainer/ButtonContainer/ResetButton
@onready var close_button: Button = $MainContainer/HeaderContainer/CloseButton

var config_service: Node = null
var current_tab: String = "audio"
var current_settings: Dictionary = {}
var has_unsaved_changes: bool = false
var is_initialized: bool = false
var _tabs: Dictionary = {}

func _audio_settings() -> Dictionary:
	return current_settings.get("audio", {})

func _video_settings() -> Dictionary:
	return current_settings.get("video", {})

func _controls_settings() -> Dictionary:
	return current_settings.get("controls", {})

func _ready() -> void:
	await _initialize_settings()

func _input(event: InputEvent) -> void:
	if is_initialized and event.is_action_pressed("ui_cancel"):
		_on_cancel_button_pressed()
		get_viewport().set_input_as_handled()

func _initialize_settings() -> void:
	await _wait_for_services()

	config_service = ServiceManager.get_config_service()
	if not config_service:
		push_error("SettingsMenu: ConfigService not available")
		return

	_hide_unused_tabs()
	_setup_tabs()
	_connect_tab_buttons()
	_connect_controls()
	_load_settings()
	_refresh_ui()
	_switch_to_tab("audio")

	is_initialized = true

func _wait_for_services() -> void:
	var attempts := 0
	while not ServiceManager and attempts < 30:
		await get_tree().process_frame
		attempts += 1

func _hide_unused_tabs() -> void:
	for path in [
		"MainContainer/ContentContainer/TabContainer/GameplayTab",
		"MainContainer/ContentContainer/TabContainer/AccessibilityTab"
	]:
		var tab := get_node_or_null(path)
		if tab:
			tab.visible = false

	for path in [
		"MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings",
		"MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings"
	]:
		var panel := get_node_or_null(path)
		if panel:
			panel.visible = false

func _setup_tabs() -> void:
	_tabs = {
		"audio": {
			"button": audio_tab,
			"panel": audio_panel
		},
		"video": {
			"button": video_tab,
			"panel": video_panel
		},
		"controls": {
			"button": controls_tab,
			"panel": controls_panel
		}
	}

func _connect_tab_buttons() -> void:
	audio_tab.pressed.connect(_switch_to_tab.bind("audio"))
	video_tab.pressed.connect(_switch_to_tab.bind("video"))
	controls_tab.pressed.connect(_switch_to_tab.bind("controls"))

	apply_button.pressed.connect(_on_apply_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	ok_button.pressed.connect(_on_ok_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	close_button.pressed.connect(_on_cancel_button_pressed)

func _connect_controls() -> void:
	_connect_slider("AudioSettings/MasterVolumeContainer/MasterVolumeSlider", _on_master_volume_changed)
	_connect_slider("AudioSettings/MusicVolumeContainer/MusicVolumeSlider", _on_music_volume_changed)
	_connect_slider("AudioSettings/SFXVolumeContainer/SFXVolumeSlider", _on_sfx_volume_changed)

	_connect_checkbox("AudioSettings/SpatialAudioContainer/SpatialAudioCheck", _on_spatial_audio_toggled)
	_connect_checkbox("VideoSettings/VsyncContainer/VsyncCheck", _on_vsync_toggled)

	_connect_option_button("VideoSettings/ResolutionContainer/ResolutionOption", _on_resolution_item_selected)
	_connect_option_button("VideoSettings/WindowModeContainer/WindowModeOption", _on_window_mode_item_selected)
	_connect_option_button("VideoSettings/FPSLimitContainer/FPSLimitOption", _on_fps_limit_item_selected)

	_connect_slider("ControlsSettings/MouseSensitivityContainer/MouseSensitivitySlider", _on_mouse_sensitivity_changed)
	_connect_checkbox("ControlsSettings/MouseInvertContainer/MouseInvertXCheck", _on_mouse_invert_x_toggled)
	_connect_checkbox("ControlsSettings/MouseInvertYContainer/MouseInvertYCheck", _on_mouse_invert_y_toggled)

func _connect_slider(path: String, handler: Callable) -> void:
	var slider: Slider = settings_content.get_node_or_null(path)
	if slider and not slider.value_changed.is_connected(handler):
		if path.find("Volume") != -1:
			slider.min_value = 0.0
			slider.max_value = 1.0
			slider.step = 0.01
			slider.allow_greater = false
			slider.allow_lesser = false
		slider.value_changed.connect(handler)

func _connect_checkbox(path: String, handler: Callable) -> void:
	var checkbox: BaseButton = settings_content.get_node_or_null(path)
	if checkbox and not checkbox.toggled.is_connected(handler):
		checkbox.toggled.connect(handler)

func _connect_option_button(path: String, handler: Callable) -> void:
	var option_button: OptionButton = settings_content.get_node_or_null(path)
	if option_button and not option_button.item_selected.is_connected(handler):
		option_button.item_selected.connect(handler)

func _load_settings() -> void:
	current_settings = {
		"audio": {
			"master_volume": _clamp_unit(config_service.get_setting("audio", "master_volume", 0.8)),
			"music_volume": _clamp_unit(config_service.get_setting("audio", "music_volume", 0.8)),
			"sfx_volume": _clamp_unit(config_service.get_setting("audio", "sfx_volume", 0.9)),
			"spatial_audio": bool(config_service.get_setting("audio", "spatial_audio", false))
		},
		"video": {
			"resolution_index": int(config_service.get_setting("video", "resolution_index", 2)),
			"window_mode_index": int(config_service.get_setting("video", "window_mode_index", 0)),
			"fps_index": int(config_service.get_setting("video", "fps_index", 1)),
			"vsync": bool(config_service.get_setting("video", "vsync", true))
		},
		"controls": {
			"mouse_sensitivity": float(config_service.get_setting("controls", "mouse_sensitivity", 1.0)),
			"mouse_invert_x": bool(config_service.get_setting("controls", "mouse_invert_x", false)),
			"mouse_invert_y": bool(config_service.get_setting("controls", "mouse_invert_y", false))
		}
	}

	has_unsaved_changes = false

func _refresh_ui() -> void:
	var audio_settings := _audio_settings()
	_update_volume_slider("AudioSettings/MasterVolumeContainer/MasterVolumeSlider", audio_settings.get("master_volume", 0.8))
	_update_volume_slider("AudioSettings/MusicVolumeContainer/MusicVolumeSlider", audio_settings.get("music_volume", 0.8))
	_update_volume_slider("AudioSettings/SFXVolumeContainer/SFXVolumeSlider", audio_settings.get("sfx_volume", 0.9))
	_update_checkbox_state("AudioSettings/SpatialAudioContainer/SpatialAudioCheck", audio_settings.get("spatial_audio", false))

	var video_settings := _video_settings()
	_update_checkbox_state("VideoSettings/VsyncContainer/VsyncCheck", video_settings.get("vsync", true))
	_populate_option_button("VideoSettings/ResolutionContainer/ResolutionOption", RESOLUTION_OPTIONS, video_settings.get("resolution_index", 2))
	_populate_option_button("VideoSettings/WindowModeContainer/WindowModeOption", WINDOW_MODE_OPTIONS, video_settings.get("window_mode_index", 0))
	_populate_option_button("VideoSettings/FPSLimitContainer/FPSLimitOption", FPS_OPTIONS, video_settings.get("fps_index", 1))

	var controls_settings := _controls_settings()
	_update_mouse_sensitivity(controls_settings.get("mouse_sensitivity", 1.0))
	_update_checkbox_state("ControlsSettings/MouseInvertContainer/MouseInvertXCheck", controls_settings.get("mouse_invert_x", false))
	_update_checkbox_state("ControlsSettings/MouseInvertYContainer/MouseInvertYCheck", controls_settings.get("mouse_invert_y", false))

func _update_volume_slider(path: String, value: float) -> void:
	var clamped_value := _clamp_unit(value)
	var slider: Slider = settings_content.get_node_or_null(path)
	if slider:
		slider.value = clamped_value
	var label = settings_content.get_node_or_null(path.replace("Slider", "Value"))
	if label:
		label.text = str(int(round(clamped_value * 100.0))) + "%"

func _update_mouse_sensitivity(value: float) -> void:
	var slider: Slider = settings_content.get_node_or_null("ControlsSettings/MouseSensitivityContainer/MouseSensitivitySlider")
	if slider:
		slider.value = value
	var label = settings_content.get_node_or_null("ControlsSettings/MouseSensitivityContainer/MouseSensitivityValue")
	if label:
		label.text = str(round(value * 100.0) / 100.0) + "x"

func _update_checkbox_state(path: String, is_pressed: bool) -> void:
	var checkbox: BaseButton = settings_content.get_node_or_null(path)
	if checkbox:
		checkbox.button_pressed = is_pressed

func _populate_option_button(path: String, options: Array[String], selected_index: int) -> void:
	var option_button: OptionButton = settings_content.get_node_or_null(path)
	if option_button:
		if option_button.item_count != options.size():
			option_button.clear()
			for option in options:
				option_button.add_item(option)
		option_button.selected = clamp(selected_index, 0, options.size() - 1)

func _switch_to_tab(tab_name: String) -> void:
	if not _tabs.has(tab_name):
		return

	current_tab = tab_name
	for tab in _tabs.values():
		tab.panel.visible = false
		tab.button.button_pressed = false

	var current = _tabs[tab_name]
	current.panel.visible = true
	current.button.button_pressed = true

func _mark_unsaved_changes() -> void:
	if not has_unsaved_changes:
		has_unsaved_changes = true
		settings_changed.emit()

func _save_settings() -> void:
	for section in current_settings.keys():
		for key in current_settings[section].keys():
			config_service.set_value(section, key, current_settings[section][key])

	config_service.save_config()
	has_unsaved_changes = false
	settings_applied.emit()

func _on_apply_button_pressed() -> void:
	await _apply_settings()

func _on_ok_button_pressed() -> void:
	await _apply_settings()
	_close_settings()

func _on_cancel_button_pressed() -> void:
	if has_unsaved_changes:
		_load_settings()
		_refresh_ui()
	_close_settings()

func _on_reset_button_pressed() -> void:
	if not config_service:
		return
	config_service.reset_to_defaults()
	_load_settings()
	_refresh_ui()

func _close_settings() -> void:
	settings_closed.emit()
	back_pressed.emit()
	queue_free()

func _apply_settings() -> void:
	await _apply_video_settings()
	_save_settings()

func _apply_video_settings() -> void:
	var video_settings := _video_settings()
	var window_mode_index: int = clamp(video_settings.get("window_mode_index", 0), 0, WINDOW_MODE_OPTIONS.size() - 1)

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	match window_mode_index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			await get_tree().process_frame
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	await get_tree().process_frame

	var resolution_index: int = clamp(video_settings.get("resolution_index", 2), 0, RESOLUTION_OPTIONS.size() - 1)
	var resolution_string: String = RESOLUTION_OPTIONS[resolution_index]
	var parts := resolution_string.split("x")
	if parts.size() == 2:
		var width := parts[0].to_int()
		var height := parts[1].to_int()
		var new_size := Vector2i(width, height)
		DisplayServer.window_set_size(new_size)
		await get_tree().process_frame
		var screen_size := DisplayServer.screen_get_size()
		var window_pos := Vector2i((screen_size.x - new_size.x) / 2, (screen_size.y - new_size.y) / 2)
		DisplayServer.window_set_position(window_pos)

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if video_settings.get("vsync", true) else DisplayServer.VSYNC_DISABLED
	)

	var fps_index: int = clamp(video_settings.get("fps_index", 1), 0, FPS_OPTIONS.size() - 1)
	var fps_string: String = FPS_OPTIONS[fps_index]
	if fps_string == "Unlimited":
		Engine.max_fps = 0
	else:
		Engine.max_fps = fps_string.to_int()

func _on_master_volume_changed(value: float) -> void:
	var audio_settings := _audio_settings()
	audio_settings["master_volume"] = _clamp_unit(value)
	_update_volume_slider("AudioSettings/MasterVolumeContainer/MasterVolumeSlider", audio_settings["master_volume"])
	_mark_unsaved_changes()

func _on_music_volume_changed(value: float) -> void:
	var audio_settings := _audio_settings()
	audio_settings["music_volume"] = _clamp_unit(value)
	_update_volume_slider("AudioSettings/MusicVolumeContainer/MusicVolumeSlider", audio_settings["music_volume"])
	_mark_unsaved_changes()

func _on_sfx_volume_changed(value: float) -> void:
	var audio_settings := _audio_settings()
	audio_settings["sfx_volume"] = _clamp_unit(value)
	_update_volume_slider("AudioSettings/SFXVolumeContainer/SFXVolumeSlider", audio_settings["sfx_volume"])
	_mark_unsaved_changes()

func _on_spatial_audio_toggled(pressed: bool) -> void:
	var audio_settings := _audio_settings()
	audio_settings["spatial_audio"] = pressed
	_mark_unsaved_changes()

func _on_vsync_toggled(pressed: bool) -> void:
	var video_settings := _video_settings()
	video_settings["vsync"] = pressed
	_mark_unsaved_changes()

func _on_resolution_item_selected(index: int) -> void:
	var video_settings := _video_settings()
	video_settings["resolution_index"] = index
	_mark_unsaved_changes()

func _on_window_mode_item_selected(index: int) -> void:
	var video_settings := _video_settings()
	video_settings["window_mode_index"] = index
	_mark_unsaved_changes()

func _on_fps_limit_item_selected(index: int) -> void:
	var video_settings := _video_settings()
	video_settings["fps_index"] = index
	_mark_unsaved_changes()

func _on_mouse_sensitivity_changed(value: float) -> void:
	var controls_settings := _controls_settings()
	controls_settings["mouse_sensitivity"] = max(value, 0.1)
	_update_mouse_sensitivity(controls_settings["mouse_sensitivity"])
	_mark_unsaved_changes()

func _on_mouse_invert_x_toggled(pressed: bool) -> void:
	var controls_settings := _controls_settings()
	controls_settings["mouse_invert_x"] = pressed
	_mark_unsaved_changes()

func _on_mouse_invert_y_toggled(pressed: bool) -> void:
	var controls_settings := _controls_settings()
	controls_settings["mouse_invert_y"] = pressed
	_mark_unsaved_changes()

func _clamp_unit(value: float) -> float:
	return clamp(float(value), 0.0, 1.0)
