## SettingsController - Professional Refactored Version
##
## Manages the Settings Menu UI and coordinates between the view and model.
## Follows MVC pattern with clear separation of concerns.
##
## @author: Professional Refactor
## @version: 2.0

extends RefCounted

# ============================================================================
# PRELOADS
# ============================================================================

const SettingsValidator := preload("res://game/ui/settings/SettingsValidator.gd")

# ============================================================================
# CONSTANTS & ENUMS
# ============================================================================

## Available video resolutions
const RESOLUTION_OPTIONS: Array[String] = [
	"1280x720", # HD
	"1366x768", # WXGA
	"1920x1080", # Full HD
	"2560x1440", # 2K
	"3840x2160" # 4K
]

## Window display modes
enum WindowMode {
	WINDOWED = 0,
	FULLSCREEN = 1,
	BORDERLESS = 2,
	EXCLUSIVE_FULLSCREEN = 3
}

const WINDOW_MODE_OPTIONS: Array[String] = [
	"Windowed",
	"Fullscreen",
	"Windowed Borderless",
	"Exclusive Fullscreen"
]

## FPS limit options
const FPS_OPTIONS: Array[String] = [
	"30", "60", "90", "120", "144", "240", "Unlimited"
]

## Settings tabs
enum TabType {
	AUDIO,
	VIDEO,
	CONTROLS
}

# ============================================================================
# DEPENDENCIES
# ============================================================================

var view: Control = null
var model = null
var config_service = null

# ============================================================================
# STATE
# ============================================================================

var current_tab: TabType = TabType.AUDIO
var _is_initialized: bool = false

# ============================================================================
# CACHED NODES
# ============================================================================

var _settings_content: VBoxContainer
var _tabs: Dictionary = {}
var _buttons: Dictionary = {}

# ============================================================================
# INITIALIZATION
# ============================================================================

## Setup the controller with required dependencies
func setup(view_ref: Control, model_ref, config_ref) -> void:
	assert(view_ref != null, "View reference cannot be null")
	assert(model_ref != null, "Model reference cannot be null")
	assert(config_ref != null, "Config service reference cannot be null")

	view = view_ref
	model = model_ref
	config_service = config_ref

	_initialize()

## Initialize the controller
func _initialize() -> void:
	if _is_initialized:
		push_warning("SettingsController: Already initialized")
		return

	_cache_ui_nodes()
	_setup_tabs()
	_connect_signals()
	_populate_option_buttons()

	# Load current settings
	model.reload()
	refresh_ui()

	# Show default tab
	switch_to_tab(TabType.AUDIO)

	_is_initialized = true

# ============================================================================
# UI NODE CACHING
# ============================================================================

## Cache all UI nodes for performance
func _cache_ui_nodes() -> void:
	var main = view.get_node("MainContainer")
	_settings_content = main.get_node("ContentContainer/SettingsContainer/SettingsContent")

	# Cache tab buttons
	var tab_container = main.get_node("ContentContainer/TabContainer")
	_tabs[TabType.AUDIO] = {
		"button": tab_container.get_node("AudioTab"),
		"panel": _settings_content.get_node("AudioSettings")
	}
	_tabs[TabType.VIDEO] = {
		"button": tab_container.get_node("VideoTab"),
		"panel": _settings_content.get_node("VideoSettings")
	}
	_tabs[TabType.CONTROLS] = {
		"button": tab_container.get_node("ControlsTab"),
		"panel": _settings_content.get_node("ControlsSettings")
	}

	# Cache action buttons
	var button_container = main.get_node("ButtonContainer")
	_buttons.apply = button_container.get_node("ApplyButton")
	_buttons.ok = button_container.get_node("OKButton")
	_buttons.cancel = button_container.get_node("CancelButton")
	_buttons.reset = button_container.get_node("ResetButton")
	_buttons.close = main.get_node("HeaderContainer/CloseButton")

	_hide_unused_ui_elements()

## Hide tabs and panels that aren't implemented yet
func _hide_unused_ui_elements() -> void:
	var unused_tabs := ["GameplayTab", "AccessibilityTab"]
	var unused_panels := ["GameplaySettings", "AccessibilitySettings"]

	for tab_name in unused_tabs:
		var tab = view.get_node_or_null("MainContainer/ContentContainer/TabContainer/" + tab_name)
		if tab:
			tab.visible = false

	for panel_name in unused_panels:
		var panel = _settings_content.get_node_or_null(panel_name)
		if panel:
			panel.visible = false

# ============================================================================
# TAB SYSTEM
# ============================================================================

## Setup tab navigation
func _setup_tabs() -> void:
	for tab_type in _tabs.keys():
		var tab_data = _tabs[tab_type]
		if tab_data.button:
			tab_data.button.pressed.connect(switch_to_tab.bind(tab_type))

## Switch to a specific tab
func switch_to_tab(tab_type: TabType) -> void:
	if not _tabs.has(tab_type):
		push_warning("SettingsController: Invalid tab type: %d" % tab_type)
		return

	current_tab = tab_type

	# Hide all panels and deselect all buttons
	for tab_data in _tabs.values():
		tab_data.panel.visible = false
		tab_data.button.button_pressed = false

	# Show selected panel and button
	var selected = _tabs[tab_type]
	selected.panel.visible = true
	selected.button.button_pressed = true

# ============================================================================
# SIGNAL CONNECTIONS
# ============================================================================

## Connect all UI signals
func _connect_signals() -> void:
	_connect_action_buttons()
	_connect_audio_controls()
	_connect_video_controls()
	_connect_controls_settings()
	_connect_model_signals()

## Connect main action buttons
func _connect_action_buttons() -> void:
	_buttons.apply.pressed.connect(_on_apply_pressed)
	_buttons.ok.pressed.connect(_on_ok_pressed)
	_buttons.cancel.pressed.connect(_on_cancel_pressed)
	_buttons.reset.pressed.connect(_on_reset_pressed)
	_buttons.close.pressed.connect(_on_cancel_pressed)

## Connect audio controls
func _connect_audio_controls() -> void:
	var base_path = "AudioSettings"

	_safe_connect_slider(base_path + "/MasterVolumeContainer/MasterVolumeSlider",
		_on_master_volume_changed)
	_safe_connect_slider(base_path + "/MusicVolumeContainer/MusicVolumeSlider",
		_on_music_volume_changed)
	_safe_connect_slider(base_path + "/SFXVolumeContainer/SFXVolumeSlider",
		_on_sfx_volume_changed)
	_safe_connect_checkbox(base_path + "/SpatialAudioContainer/SpatialAudioCheck",
		_on_spatial_audio_toggled)

## Connect video controls
func _connect_video_controls() -> void:
	var base_path = "VideoSettings"

	_safe_connect_checkbox(base_path + "/VsyncContainer/VsyncCheck",
		_on_vsync_toggled)
	_safe_connect_option_button(base_path + "/ResolutionContainer/ResolutionOption",
		_on_resolution_selected)
	_safe_connect_option_button(base_path + "/WindowModeContainer/WindowModeOption",
		_on_window_mode_selected)
	_safe_connect_option_button(base_path + "/FPSLimitContainer/FPSLimitOption",
		_on_fps_limit_selected)

## Connect controls settings
func _connect_controls_settings() -> void:
	var base_path = "ControlsSettings"

	_safe_connect_slider(base_path + "/MouseSensitivityContainer/MouseSensitivitySlider",
		_on_mouse_sensitivity_changed)
	_safe_connect_checkbox(base_path + "/MouseInvertContainer/MouseInvertXCheck",
		_on_mouse_invert_x_toggled)
	_safe_connect_checkbox(base_path + "/MouseInvertYContainer/MouseInvertYCheck",
		_on_mouse_invert_y_toggled)

## Connect model signals
func _connect_model_signals() -> void:
	if model.has_signal("settings_loaded"):
		model.settings_loaded.connect(_on_settings_loaded)
	if model.has_signal("settings_reset"):
		model.settings_reset.connect(_on_settings_reset)

# ============================================================================
# SAFE CONNECTION HELPERS
# ============================================================================

## Safely connect a slider with error handling
func _safe_connect_slider(path: String, handler: Callable) -> void:
	var slider: Slider = _settings_content.get_node_or_null(path)
	if slider and not slider.value_changed.is_connected(handler):
		slider.value_changed.connect(handler)
	elif not slider:
		push_warning("SettingsController: Slider not found at path: %s" % path)

## Safely connect a checkbox with error handling
func _safe_connect_checkbox(path: String, handler: Callable) -> void:
	var checkbox: BaseButton = _settings_content.get_node_or_null(path)
	if checkbox and not checkbox.toggled.is_connected(handler):
		checkbox.toggled.connect(handler)
	elif not checkbox:
		push_warning("SettingsController: Checkbox not found at path: %s" % path)

## Safely connect an option button with error handling
func _safe_connect_option_button(path: String, handler: Callable) -> void:
	var option_button: OptionButton = _settings_content.get_node_or_null(path)
	if option_button and not option_button.item_selected.is_connected(handler):
		option_button.item_selected.connect(handler)
	elif not option_button:
		push_warning("SettingsController: OptionButton not found at path: %s" % path)

# ============================================================================
# UI UPDATE METHODS
# ============================================================================

## Refresh all UI elements with current model data
func refresh_ui() -> void:
	_update_audio_ui()
	_update_video_ui()
	_update_controls_ui()

## Update audio UI elements
func _update_audio_ui() -> void:
	_set_volume_slider("AudioSettings/MasterVolumeContainer/MasterVolumeSlider",
		model.get_value("audio", "master_volume", 0.8))
	_set_volume_slider("AudioSettings/MusicVolumeContainer/MusicVolumeSlider",
		model.get_value("audio", "music_volume", 0.8))
	_set_volume_slider("AudioSettings/SFXVolumeContainer/SFXVolumeSlider",
		model.get_value("audio", "sfx_volume", 0.9))
	_set_checkbox("AudioSettings/SpatialAudioContainer/SpatialAudioCheck",
		model.get_value("audio", "spatial_audio", false))

## Update video UI elements
func _update_video_ui() -> void:
	_set_checkbox("VideoSettings/VsyncContainer/VsyncCheck",
		model.get_value("video", "vsync", true))
	_set_option_button("VideoSettings/ResolutionContainer/ResolutionOption",
		model.get_value("video", "resolution_index", 2))
	_set_option_button("VideoSettings/WindowModeContainer/WindowModeOption",
		model.get_value("video", "window_mode_index", 0))
	_set_option_button("VideoSettings/FPSLimitContainer/FPSLimitOption",
		model.get_value("video", "fps_index", 1))

## Update controls UI elements
func _update_controls_ui() -> void:
	_set_mouse_sensitivity(model.get_value("controls", "mouse_sensitivity", 1.0))
	_set_checkbox("ControlsSettings/MouseInvertContainer/MouseInvertXCheck",
		model.get_value("controls", "mouse_invert_x", false))
	_set_checkbox("ControlsSettings/MouseInvertYContainer/MouseInvertYCheck",
		model.get_value("controls", "mouse_invert_y", false))

# ============================================================================
# UI SETTER HELPERS
# ============================================================================

## Set volume slider value and update label
func _set_volume_slider(path: String, value: float) -> void:
	var clamped_value: float = clampf(value, 0.0, 1.0)

	var slider: Slider = _settings_content.get_node_or_null(path)
	if slider:
		slider.value = clamped_value

	var label_path = path.replace("Slider", "Value")
	var label = _settings_content.get_node_or_null(label_path)
	if label:
		label.text = "%d%%" % int(round(clamped_value * 100.0))

## Set mouse sensitivity slider and label
func _set_mouse_sensitivity(value: float) -> void:
	var slider: Slider = _settings_content.get_node_or_null(
		"ControlsSettings/MouseSensitivityContainer/MouseSensitivitySlider")
	if slider:
		slider.value = value

	var label = _settings_content.get_node_or_null(
		"ControlsSettings/MouseSensitivityContainer/MouseSensitivityValue")
	if label:
		label.text = "%.2fx" % value

## Set checkbox state
func _set_checkbox(path: String, is_pressed: bool) -> void:
	var checkbox: BaseButton = _settings_content.get_node_or_null(path)
	if checkbox:
		checkbox.button_pressed = is_pressed

## Set option button selected index
func _set_option_button(path: String, selected_index: int) -> void:
	var option_button: OptionButton = _settings_content.get_node_or_null(path)
	if option_button:
		var clamped_index = clampi(selected_index, 0, option_button.item_count - 1)
		option_button.selected = clamped_index

# ============================================================================
# OPTION BUTTON POPULATION
# ============================================================================

## Populate all option buttons with their values
func _populate_option_buttons() -> void:
	_populate_option_items("VideoSettings/ResolutionContainer/ResolutionOption", RESOLUTION_OPTIONS)
	_populate_option_items("VideoSettings/WindowModeContainer/WindowModeOption", WINDOW_MODE_OPTIONS)
	_populate_option_items("VideoSettings/FPSLimitContainer/FPSLimitOption", FPS_OPTIONS)

## Populate an option button with items
func _populate_option_items(path: String, items: Array[String]) -> void:
	var option_button: OptionButton = _settings_content.get_node_or_null(path)
	if not option_button:
		push_warning("SettingsController: OptionButton not found at: %s" % path)
		return

	# Only populate if empty or count doesn't match
	if option_button.item_count != items.size():
		option_button.clear()
		for item in items:
			option_button.add_item(item)

# ============================================================================
# EVENT HANDLERS - Action Buttons
# ============================================================================

func _on_apply_pressed() -> void:
	await apply_settings()

func _on_ok_pressed() -> void:
	await apply_settings()
	_close_menu()

func _on_cancel_pressed() -> void:
	if model.is_dirty():
		model.reload()
		refresh_ui()
	_close_menu()

func _on_reset_pressed() -> void:
	model.reset_to_defaults()

# ============================================================================
# EVENT HANDLERS - Audio
# ============================================================================

func _on_master_volume_changed(value: float) -> void:
	var validated: float = SettingsValidator.clamp_value("audio", "master_volume", value)
	model.set_value("audio", "master_volume", validated)
	_set_volume_slider("AudioSettings/MasterVolumeContainer/MasterVolumeSlider", validated)

func _on_music_volume_changed(value: float) -> void:
	var validated: float = SettingsValidator.clamp_value("audio", "music_volume", value)
	model.set_value("audio", "music_volume", validated)
	_set_volume_slider("AudioSettings/MusicVolumeContainer/MusicVolumeSlider", validated)

func _on_sfx_volume_changed(value: float) -> void:
	var validated: float = SettingsValidator.clamp_value("audio", "sfx_volume", value)
	model.set_value("audio", "sfx_volume", validated)
	_set_volume_slider("AudioSettings/SFXVolumeContainer/SFXVolumeSlider", validated)

func _on_spatial_audio_toggled(pressed: bool) -> void:
	var error := SettingsValidator.validate_value("audio", "spatial_audio", pressed)
	if not error.is_empty():
		push_warning("SettingsController: %s" % error)
		return
	model.set_value("audio", "spatial_audio", pressed)

# ============================================================================
# EVENT HANDLERS - Video
# ============================================================================

func _on_vsync_toggled(pressed: bool) -> void:
	var error := SettingsValidator.validate_value("video", "vsync", pressed)
	if not error.is_empty():
		push_warning("SettingsController: %s" % error)
		return
	model.set_value("video", "vsync", pressed)

func _on_resolution_selected(index: int) -> void:
	var validated: int = SettingsValidator.clamp_value("video", "resolution_index", index)
	model.set_value("video", "resolution_index", validated)

func _on_window_mode_selected(index: int) -> void:
	var validated: int = SettingsValidator.clamp_value("video", "window_mode_index", index)
	model.set_value("video", "window_mode_index", validated)

func _on_fps_limit_selected(index: int) -> void:
	var validated: int = SettingsValidator.clamp_value("video", "fps_index", index)
	model.set_value("video", "fps_index", validated)

# ============================================================================
# EVENT HANDLERS - Controls
# ============================================================================

func _on_mouse_sensitivity_changed(value: float) -> void:
	var validated: float = SettingsValidator.clamp_value("controls", "mouse_sensitivity", value)
	model.set_value("controls", "mouse_sensitivity", validated)
	_set_mouse_sensitivity(validated)

func _on_mouse_invert_x_toggled(pressed: bool) -> void:
	var error := SettingsValidator.validate_value("controls", "mouse_invert_x", pressed)
	if not error.is_empty():
		push_warning("SettingsController: %s" % error)
		return
	model.set_value("controls", "mouse_invert_x", pressed)

func _on_mouse_invert_y_toggled(pressed: bool) -> void:
	var error := SettingsValidator.validate_value("controls", "mouse_invert_y", pressed)
	if not error.is_empty():
		push_warning("SettingsController: %s" % error)
		return
	model.set_value("controls", "mouse_invert_y", pressed)

# ============================================================================
# EVENT HANDLERS - Model
# ============================================================================

func _on_settings_loaded(_data: Dictionary) -> void:
	refresh_ui()

func _on_settings_reset(_data: Dictionary) -> void:
	refresh_ui()

# ============================================================================
# SETTINGS APPLICATION
# ============================================================================

## Apply all pending changes
func apply_settings() -> void:
	await _apply_video_settings()
	model.apply_changes()

## Apply video settings to the display
func _apply_video_settings() -> void:
	var video_settings: Dictionary = model.get_section("video")

	await _apply_window_mode(video_settings)
	await _apply_resolution(video_settings)
	_apply_vsync(video_settings)
	_apply_fps_limit(video_settings)

## Apply window mode setting
func _apply_window_mode(settings: Dictionary) -> void:
	var mode_index: int = clampi(settings.get("window_mode_index", 0), 0, WindowMode.size() - 1)

	# Reset borderless flag first
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

	match mode_index:
		WindowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		WindowMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			await view.get_tree().process_frame
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		WindowMode.EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	await view.get_tree().process_frame

## Apply resolution setting
func _apply_resolution(settings: Dictionary) -> void:
	var res_index: int = clampi(settings.get("resolution_index", 2), 0, RESOLUTION_OPTIONS.size() - 1)
	var resolution_string: String = RESOLUTION_OPTIONS[res_index]
	var parts: PackedStringArray = resolution_string.split("x")

	if parts.size() != 2:
		push_error("SettingsController: Invalid resolution format: %s" % resolution_string)
		return

	var width: int = parts[0].to_int()
	var height: int = parts[1].to_int()
	var new_size := Vector2i(width, height)

	DisplayServer.window_set_size(new_size)
	await view.get_tree().process_frame

	# Center window
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var window_pos := Vector2i(
		int((screen_size.x - new_size.x) / 2.0),
		int((screen_size.y - new_size.y) / 2.0)
	)
	DisplayServer.window_set_position(window_pos)

## Apply VSync setting
func _apply_vsync(settings: Dictionary) -> void:
	var vsync_enabled: bool = settings.get("vsync", true)
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED
	)

## Apply FPS limit setting
func _apply_fps_limit(settings: Dictionary) -> void:
	var fps_index: int = clampi(settings.get("fps_index", 1), 0, FPS_OPTIONS.size() - 1)
	var fps_string: String = FPS_OPTIONS[fps_index]

	if fps_string == "Unlimited":
		Engine.max_fps = 0
	else:
		Engine.max_fps = fps_string.to_int()

# ============================================================================
# PUBLIC API
# ============================================================================

## Check if settings have unsaved changes
func is_dirty() -> bool:
	return model.is_dirty()

## Get a snapshot of all current settings
func get_settings_snapshot() -> Dictionary:
	return model.get_all_settings()

## Request cancel (called externally)
func request_cancel() -> void:
	_on_cancel_pressed()

## Request apply (called externally)
func request_apply() -> void:
	await _on_apply_pressed()

## Request reset (called externally)
func request_reset() -> void:
	_on_reset_pressed()

# ============================================================================
# INTERNAL HELPERS
# ============================================================================

## Close the settings menu
func _close_menu() -> void:
	view.emit_signal("settings_closed")
	view.emit_signal("back_pressed")
	view.queue_free()
