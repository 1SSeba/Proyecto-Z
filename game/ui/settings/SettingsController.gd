extends RefCounted
class_name SettingsController

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

var view: Control
var model
var config_service
var current_tab: String = "audio"

var _settings_content: VBoxContainer
var _audio_tab: Button
var _video_tab: Button
var _controls_tab: Button
var _audio_panel: Control
var _video_panel: Control
var _controls_panel: Control
var _apply_button: Button
var _ok_button: Button
var _cancel_button: Button
var _reset_button: Button
var _close_button: Button
var _tabs: Dictionary = {}

func setup(view_ref: Control, model_ref, config_ref) -> void:
	view = view_ref
	model = model_ref
	config_service = config_ref

	_cache_view_nodes()
	_hide_unused_tabs()
	_setup_tabs()
	_connect_tab_buttons()
	_connect_controls()
	_connect_model_signals()
	model.reload()
	_refresh_ui()
	_switch_to_tab("audio")

func is_dirty() -> bool:
	return model.is_dirty()

func apply_changes() -> void:
	await _apply_video_settings()
	model.apply_changes()

func reset_to_defaults() -> void:
	model.reset_to_defaults()

func reload_from_config() -> void:
	model.reload()

func get_settings_snapshot() -> Dictionary:
	return model.get_all_settings()

func _cache_view_nodes() -> void:
	_settings_content = view.get_node("MainContainer/ContentContainer/SettingsContainer/SettingsContent")
	_audio_tab = view.get_node("MainContainer/ContentContainer/TabContainer/AudioTab")
	_video_tab = view.get_node("MainContainer/ContentContainer/TabContainer/VideoTab")
	_controls_tab = view.get_node("MainContainer/ContentContainer/TabContainer/ControlsTab")
	_audio_panel = view.get_node("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings")
	_video_panel = view.get_node("MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings")
	_controls_panel = view.get_node("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings")
	_apply_button = view.get_node("MainContainer/ButtonContainer/ApplyButton")
	_ok_button = view.get_node("MainContainer/ButtonContainer/OKButton")
	_cancel_button = view.get_node("MainContainer/ButtonContainer/CancelButton")
	_reset_button = view.get_node("MainContainer/ButtonContainer/ResetButton")
	_close_button = view.get_node("MainContainer/HeaderContainer/CloseButton")

func _hide_unused_tabs() -> void:
	for path in [
		"MainContainer/ContentContainer/TabContainer/GameplayTab",
		"MainContainer/ContentContainer/TabContainer/AccessibilityTab"
	]:
		var tab = view.get_node_or_null(path)
		if tab:
			tab.visible = false

	for path in [
		"MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings",
		"MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings"
	]:
		var panel = view.get_node_or_null(path)
		if panel:
			panel.visible = false

func _setup_tabs() -> void:
	_tabs = {
		"audio": {
			"button": _audio_tab,
			"panel": _audio_panel
		},
		"video": {
			"button": _video_tab,
			"panel": _video_panel
		},
		"controls": {
			"button": _controls_tab,
			"panel": _controls_panel
		}
	}

func _connect_tab_buttons() -> void:
	_audio_tab.pressed.connect(_switch_to_tab.bind("audio"))
	_video_tab.pressed.connect(_switch_to_tab.bind("video"))
	_controls_tab.pressed.connect(_switch_to_tab.bind("controls"))

	_apply_button.pressed.connect(_on_apply_button_pressed)
	_cancel_button.pressed.connect(_on_cancel_button_pressed)
	_ok_button.pressed.connect(_on_ok_button_pressed)
	_reset_button.pressed.connect(_on_reset_button_pressed)
	_close_button.pressed.connect(_on_cancel_button_pressed)

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
	_connect_checkbox("ControlsSettings/MouseInvertContainer/MouseInvertYCheck", _on_mouse_invert_y_toggled)

func _connect_slider(path: String, handler: Callable) -> void:
	var slider: Slider = _settings_content.get_node_or_null(path)
	if slider and not slider.value_changed.is_connected(handler):
		slider.value_changed.connect(handler)

func _connect_checkbox(path: String, handler: Callable) -> void:
	var checkbox: BaseButton = _settings_content.get_node_or_null(path)
	if checkbox and not checkbox.toggled.is_connected(handler):
		checkbox.toggled.connect(handler)

func _connect_option_button(path: String, handler: Callable) -> void:
	var option_button: OptionButton = _settings_content.get_node_or_null(path)
	if option_button and not option_button.item_selected.is_connected(handler):
		option_button.item_selected.connect(handler)

func _connect_model_signals() -> void:
	model.settings_loaded.connect(_on_model_loaded)
	model.settings_reset.connect(_on_model_reset)

func _on_model_loaded(_data: Dictionary) -> void:
	_refresh_ui()

func _on_model_reset(_data: Dictionary) -> void:
	_refresh_ui()

func _refresh_ui() -> void:
	_update_audio_ui()
	_update_video_ui()
	_update_controls_ui()

func _update_audio_ui() -> void:
	_update_volume_slider("AudioSettings/MasterVolumeContainer/MasterVolumeSlider", model.get_value("audio", "master_volume", 0.8))
	_update_volume_slider("AudioSettings/MusicVolumeContainer/MusicVolumeSlider", model.get_value("audio", "music_volume", 0.8))
	_update_volume_slider("AudioSettings/SFXVolumeContainer/SFXVolumeSlider", model.get_value("audio", "sfx_volume", 0.9))
	_update_checkbox_state("AudioSettings/SpatialAudioContainer/SpatialAudioCheck", model.get_value("audio", "spatial_audio", false))

func _update_video_ui() -> void:
	_update_checkbox_state("VideoSettings/VsyncContainer/VsyncCheck", model.get_value("video", "vsync", true))
	_populate_option_button("VideoSettings/ResolutionContainer/ResolutionOption", RESOLUTION_OPTIONS, model.get_value("video", "resolution_index", 2))
	_populate_option_button("VideoSettings/WindowModeContainer/WindowModeOption", WINDOW_MODE_OPTIONS, model.get_value("video", "window_mode_index", 0))
	_populate_option_button("VideoSettings/FPSLimitContainer/FPSLimitOption", FPS_OPTIONS, model.get_value("video", "fps_index", 1))

func _update_controls_ui() -> void:
	_update_mouse_sensitivity(model.get_value("controls", "mouse_sensitivity", 1.0))
	_update_checkbox_state("ControlsSettings/MouseInvertContainer/MouseInvertXCheck", model.get_value("controls", "mouse_invert_x", false))
	_update_checkbox_state("ControlsSettings/MouseInvertContainer/MouseInvertYCheck", model.get_value("controls", "mouse_invert_y", false))

func _update_volume_slider(path: String, value: float) -> void:
	var clamped_value: float = clamp(value, 0.0, 1.0)
	var slider: Slider = _settings_content.get_node_or_null(path)
	if slider:
		slider.value = clamped_value
	var label = _settings_content.get_node_or_null(path.replace("Slider", "Value"))
	if label:
		label.text = str(int(round(clamped_value * 100.0))) + "%"

func _update_mouse_sensitivity(value: float) -> void:
	var slider: Slider = _settings_content.get_node_or_null("ControlsSettings/MouseSensitivityContainer/MouseSensitivitySlider")
	if slider:
		slider.value = value
	var label = _settings_content.get_node_or_null("ControlsSettings/MouseSensitivityContainer/MouseSensitivityValue")
	if label:
		label.text = str(round(value * 100.0) / 100.0) + "x"

func _update_checkbox_state(path: String, is_pressed: bool) -> void:
	var checkbox: BaseButton = _settings_content.get_node_or_null(path)
	if checkbox:
		checkbox.button_pressed = is_pressed

func _populate_option_button(path: String, options: Array[String], selected_index: int) -> void:
	var option_button: OptionButton = _settings_content.get_node_or_null(path)
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

func _on_apply_button_pressed() -> void:
	await apply_changes()

func _on_ok_button_pressed() -> void:
	await apply_changes()
	view.emit_signal("settings_closed")
	view.emit_signal("back_pressed")
	view.queue_free()

func _on_cancel_button_pressed() -> void:
	if model.is_dirty():
		reload_from_config()
	_refresh_ui()
	view.emit_signal("settings_closed")
	view.emit_signal("back_pressed")
	view.queue_free()

func _on_reset_button_pressed() -> void:
	reset_to_defaults()

func _on_master_volume_changed(value: float) -> void:
	model.set_value("audio", "master_volume", clamp(value, 0.0, 1.0))
	_update_volume_slider("AudioSettings/MasterVolumeContainer/MasterVolumeSlider", model.get_value("audio", "master_volume", 0.8))

func _on_music_volume_changed(value: float) -> void:
	model.set_value("audio", "music_volume", clamp(value, 0.0, 1.0))
	_update_volume_slider("AudioSettings/MusicVolumeContainer/MusicVolumeSlider", model.get_value("audio", "music_volume", 0.8))

func _on_sfx_volume_changed(value: float) -> void:
	model.set_value("audio", "sfx_volume", clamp(value, 0.0, 1.0))
	_update_volume_slider("AudioSettings/SFXVolumeContainer/SFXVolumeSlider", model.get_value("audio", "sfx_volume", 0.9))

func _on_spatial_audio_toggled(pressed: bool) -> void:
	model.set_value("audio", "spatial_audio", pressed)

func _on_vsync_toggled(pressed: bool) -> void:
	model.set_value("video", "vsync", pressed)

func _on_resolution_item_selected(index: int) -> void:
	model.set_value("video", "resolution_index", index)

func _on_window_mode_item_selected(index: int) -> void:
	model.set_value("video", "window_mode_index", index)

func _on_fps_limit_item_selected(index: int) -> void:
	model.set_value("video", "fps_index", index)

func _on_mouse_sensitivity_changed(value: float) -> void:
	var clamped: float = max(value, 0.1)
	model.set_value("controls", "mouse_sensitivity", clamped)
	_update_mouse_sensitivity(model.get_value("controls", "mouse_sensitivity", 1.0))

func _on_mouse_invert_x_toggled(pressed: bool) -> void:
	model.set_value("controls", "mouse_invert_x", pressed)

func _on_mouse_invert_y_toggled(pressed: bool) -> void:
	model.set_value("controls", "mouse_invert_y", pressed)

func _apply_video_settings() -> void:
	var video_settings: Dictionary = model.get_section("video")
	var window_mode_index: int = clamp(video_settings.get("window_mode_index", 0), 0, WINDOW_MODE_OPTIONS.size() - 1)

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	match window_mode_index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			await view.get_tree().process_frame
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	await view.get_tree().process_frame

	var resolution_index: int = clamp(video_settings.get("resolution_index", 2), 0, RESOLUTION_OPTIONS.size() - 1)
	var resolution_string: String = RESOLUTION_OPTIONS[resolution_index]
	var parts: PackedStringArray = resolution_string.split("x")
	if parts.size() == 2:
		var width: int = parts[0].to_int()
		var height: int = parts[1].to_int()
		var new_size: Vector2i = Vector2i(width, height)
		DisplayServer.window_set_size(new_size)
		await view.get_tree().process_frame
		var screen_size: Vector2i = DisplayServer.screen_get_size()
		var window_pos: Vector2i = Vector2i((screen_size.x - new_size.x) / 2, (screen_size.y - new_size.y) / 2)
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

func request_cancel() -> void:
	_on_cancel_button_pressed()

func request_apply() -> void:
	_on_apply_button_pressed()

func request_reset() -> void:
	_on_reset_button_pressed()
