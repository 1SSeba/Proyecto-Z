extends Control
class_name SettingsMenu

## Professional Settings Menu
## Complete settings management with categories and persistence

# =======================
#  SIGNALS
# =======================
signal settings_closed
# signal settings_applied(settings: Dictionary)  # TODO: Implement if needed
signal back_pressed

# =======================
#  SETTINGS ENUMS
# =======================
enum SettingsCategory {
	AUDIO,
	VIDEO,
	CONTROLS,
	GAMEPLAY,
	ACCESSIBILITY
}

# =======================
#  VARIABLES
# =======================
var current_settings: Dictionary = {}
var temp_settings: Dictionary = {}
var has_unsaved_changes: bool = false
var current_category: SettingsCategory = SettingsCategory.AUDIO

# Services
var config_service
var audio_service

# Preview mode variables
var preview_mode: bool = false
var preview_timer: Timer
var preview_duration: float = 2.0

# Default settings
var default_settings: Dictionary = {
	"master_volume": 100.0,
	"music_volume": 80.0,
	"sfx_volume": 90.0,
	"audio_device": 0, # Default device index
	"audio_quality": 1, # 0=Low, 1=Medium, 2=High
	"spatial_audio": true,
	"fullscreen": false,
	"vsync": true,
	"resolution": "1920x1080",
	"window_mode": 0, # 0=Windowed, 1=Fullscreen, 2=Borderless
	"fps_limit": 60,
	"quality_preset": 1, # 0=Low, 1=Medium, 2=High, 3=Ultra
	"mouse_sensitivity": 1.0,
	"mouse_invert_x": false,
	"mouse_invert_y": false,
	"gamepad_deadzone": 0.2,
	"gamepad_vibration": true,
	"difficulty": 1, # 0=Easy, 1=Normal, 2=Hard, 3=Nightmare
	"auto_save": true,
	"auto_save_interval": 5, # minutes: 0=Manual, 1=1min, 5=5min, 10=10min
	"camera_shake": 1.0, # 0.0-2.0 intensity
	"ui_scale": 1.0, # 0.5-2.0 scale multiplier
	"tutorial_hints": true,
	# Accessibility settings
	"colorblind_support": false,
	"large_font": false,
	"high_contrast": false,
	"color_filter": 0, # 0=None, 1=Protanopia, 2=Deuteranopia, 3=Tritanopia
	"subtitles": true,
	"reduce_motion": false,
	"screen_reader": false,
	"font_size_scale": 1.0, # 0.5-2.0 scale multiplier
	"keybinds": {
		"move_up": "W",
		"move_down": "S", 
		"move_left": "A",
		"move_right": "D",
		"interact": "E",
		"cancel": "Escape"
	}
}

# =======================
#  LIFECYCLE
# =======================
func _ready():
	print("SettingsMenu: Initializing professional settings system...")
	
	# Wait for services to be ready
	await _wait_for_services()
	
	# Get services
	if ServiceManager:
		config_service = ServiceManager.get_service("ConfigService")
		audio_service = ServiceManager.get_service("AudioService")
	
	# Initialize settings
	_initialize_settings()
	_load_current_settings()
	_connect_all_signals()
	_update_ui_from_settings()
	_init_preview_system()
	
	# Setup initial tab
	_switch_to_tab(SettingsCategory.AUDIO)
	
	print("SettingsMenu: Professional settings system with preview ready")

func _wait_for_services():
	"""Wait for services to be available"""
	while not ServiceManager or not ServiceManager.are_services_ready():
		await get_tree().process_frame
	
	print("SettingsMenu: Services are ready")

# =======================
#  INITIALIZATION
# =======================
func _initialize_settings():
	"""Initialize settings from defaults"""
	current_settings = default_settings.duplicate(true)
	temp_settings = default_settings.duplicate(true)
	_populate_dropdown_options()

func _load_current_settings():
	"""Load settings from ConfigService"""
	if config_service:
		for key in default_settings.keys():
			var value = config_service.get_setting("settings", key, default_settings[key])
			if value != null:
				current_settings[key] = value
		temp_settings = current_settings.duplicate(true)
		print("SettingsMenu: Settings loaded from ConfigService")
	else:
		print("SettingsMenu: ConfigService not available, using defaults")

func _populate_dropdown_options():
	"""Populate dropdown menus with available options"""
	_populate_audio_devices()
	_populate_audio_quality()
	_populate_resolution_options()
	_populate_quality_presets()
	_populate_fps_options()
	_populate_window_mode_options()
	_populate_difficulty_options()
	_populate_auto_save_interval_options()
	_populate_color_filter_options()

func _populate_resolution_options():
	"""Populate resolution dropdown with common resolutions"""
	var resolution_option = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings/ResolutionContainer/ResolutionOption")
	if resolution_option:
		resolution_option.clear()
		var resolutions = [
			"1280x720",
			"1366x768", 
			"1600x900",
			"1920x1080",
			"2560x1440",
			"3840x2160"
		]
		
		for res in resolutions:
			resolution_option.add_item(res)
		
		# Set current resolution
		var current_res = current_settings.get("resolution", "1920x1080")
		var index = resolutions.find(current_res)
		if index >= 0:
			resolution_option.selected = index

func _populate_quality_presets():
	"""Populate quality preset dropdown"""
	var quality_option = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings/QualityPresetContainer/QualityPresetOption")
	if quality_option:
		quality_option.clear()
		var presets = ["Low", "Medium", "High", "Ultra"]
		
		for preset in presets:
			quality_option.add_item(preset)
		
		# Set current preset
		var current_preset = current_settings.get("quality_preset", 1)
		quality_option.selected = current_preset

func _populate_fps_options():
	"""Populate FPS limit options"""
	var fps_option = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings/FPSLimitContainer/FPSLimitOption")
	if fps_option:
		fps_option.clear()
		var fps_options = ["30 FPS", "60 FPS", "120 FPS", "144 FPS", "Unlimited"]
		var fps_values = [30, 60, 120, 144, 0] # 0 = unlimited
		
		for i in fps_options.size():
			fps_option.add_item(fps_options[i])
		
		# Set current FPS limit
		var current_fps = current_settings.get("fps_limit", 60)
		var index = fps_values.find(current_fps)
		if index >= 0:
			fps_option.selected = index

func _populate_window_mode_options():
	"""Populate window mode options"""
	var window_mode_option = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings/WindowModeContainer/WindowModeOption")
	if window_mode_option:
		window_mode_option.clear()
		var modes = ["Windowed", "Fullscreen", "Borderless"]
		
		for mode in modes:
			window_mode_option.add_item(mode)
		
		# Set current window mode
		var current_mode = current_settings.get("window_mode", 0)
		window_mode_option.selected = current_mode

func _populate_audio_devices():
	"""Populate audio device dropdown"""
	var audio_device_option = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings/AudioDeviceContainer/AudioDeviceOption")
	if audio_device_option:
		audio_device_option.clear()
		
		# Get available audio devices (simplified for demo)
		var devices = ["Default Device", "Speakers", "Headphones", "USB Audio"]
		
		for device in devices:
			audio_device_option.add_item(device)
		
		# Set current device
		var current_device = current_settings.get("audio_device", 0)
		audio_device_option.selected = current_device

func _populate_audio_quality():
	"""Populate audio quality dropdown"""
	var audio_quality_option = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings/AudioQualityContainer/AudioQualityOption")
	if audio_quality_option:
		audio_quality_option.clear()
		
		var qualities = ["Low (22kHz)", "Medium (44kHz)", "High (48kHz)"]
		
		for quality in qualities:
			audio_quality_option.add_item(quality)
		
		# Set current quality
		var current_quality = current_settings.get("audio_quality", 1)
		audio_quality_option.selected = current_quality

func _populate_difficulty_options():
	"""Populate difficulty dropdown"""
	var difficulty_option = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings/DifficultyContainer/DifficultyOption")
	if difficulty_option:
		difficulty_option.clear()
		
		var difficulties = ["Easy", "Normal", "Hard", "Nightmare"]
		
		for difficulty in difficulties:
			difficulty_option.add_item(difficulty)
		
		# Set current difficulty
		var current_difficulty = current_settings.get("difficulty", 1)
		difficulty_option.selected = current_difficulty

func _populate_auto_save_interval_options():
	"""Populate auto save interval dropdown"""
	var auto_save_interval_option = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings/AutoSaveIntervalContainer/AutoSaveIntervalOption")
	if auto_save_interval_option:
		auto_save_interval_option.clear()
		
		var intervals = ["Manual Only", "Every 1 Minute", "Every 5 Minutes", "Every 10 Minutes"]
		
		for interval in intervals:
			auto_save_interval_option.add_item(interval)
		
		# Set current interval
		var current_interval = current_settings.get("auto_save_interval", 5)
		var index = _get_auto_save_interval_index(current_interval)
		auto_save_interval_option.selected = index

func _populate_color_filter_options():
	"""Populate color filter dropdown options"""
	var color_filter_dropdown = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/ColorFilterContainer/ColorFilterDropdown")
	if color_filter_dropdown:
		color_filter_dropdown.clear()
		color_filter_dropdown.add_item("None")
		color_filter_dropdown.add_item("Protanopia (Red-blind)")
		color_filter_dropdown.add_item("Deuteranopia (Green-blind)")
		color_filter_dropdown.add_item("Tritanopia (Blue-blind)")
		color_filter_dropdown.select(temp_settings.color_filter)

func _get_auto_save_interval_index(interval: int) -> int:
	"""Convert auto save interval to dropdown index"""
	match interval:
		0: return 0  # Manual Only
		1: return 1  # Every 1 Minute
		5: return 2  # Every 5 Minutes  
		10: return 3 # Every 10 Minutes
		_: return 2  # Default to 5 minutes

func _update_ui_from_settings():
	"""Update UI elements to reflect current settings"""
	# Audio settings
	var master_slider = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings/MasterVolumeContainer/MasterVolumeSlider")
	if master_slider:
		master_slider.value = current_settings.master_volume
	
	var music_slider = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings/MusicVolumeContainer/MusicVolumeSlider")
	if music_slider:
		music_slider.value = current_settings.music_volume
	
	var sfx_slider = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings/SFXVolumeContainer/SFXVolumeSlider")
	if sfx_slider:
		sfx_slider.value = current_settings.sfx_volume
	
	var spatial_audio_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings/SpatialAudioContainer/SpatialAudioCheck")
	if spatial_audio_check:
		spatial_audio_check.button_pressed = current_settings.spatial_audio
	
	# Video settings
	var fullscreen_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings/FullscreenContainer/FullscreenCheck")
	if fullscreen_check:
		fullscreen_check.button_pressed = current_settings.fullscreen
	
	var vsync_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings/VsyncContainer/VsyncCheck")
	if vsync_check:
		vsync_check.button_pressed = current_settings.vsync
	
	# Controls settings
	var mouse_sensitivity_slider = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings/MouseSensitivityContainer/MouseSensitivitySlider")
	if mouse_sensitivity_slider:
		mouse_sensitivity_slider.value = current_settings.mouse_sensitivity
	
	var mouse_invert_x_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings/MouseInvertContainer/MouseInvertXCheck")
	if mouse_invert_x_check:
		mouse_invert_x_check.button_pressed = current_settings.mouse_invert_x
	
	var mouse_invert_y_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings/MouseInvertYContainer/MouseInvertYCheck")
	if mouse_invert_y_check:
		mouse_invert_y_check.button_pressed = current_settings.mouse_invert_y
	
	var gamepad_deadzone_slider = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings/GamepadDeadzoneContainer/GamepadDeadzoneSlider")
	if gamepad_deadzone_slider:
		gamepad_deadzone_slider.value = current_settings.gamepad_deadzone
	
	var gamepad_vibration_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings/GamepadVibrationContainer/GamepadVibrationCheck")
	if gamepad_vibration_check:
		gamepad_vibration_check.button_pressed = current_settings.gamepad_vibration
	
	# Gameplay settings
	var auto_save_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings/AutoSaveContainer/AutoSaveCheck")
	if auto_save_check:
		auto_save_check.button_pressed = current_settings.auto_save
	
	var camera_shake_slider = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings/CameraShakeContainer/CameraShakeSlider")
	if camera_shake_slider:
		camera_shake_slider.value = current_settings.camera_shake
	
	var ui_scale_slider = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings/UIScaleContainer/UIScaleSlider")
	if ui_scale_slider:
		ui_scale_slider.value = current_settings.ui_scale
	
	var tutorial_hints_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings/TutorialHintsContainer/TutorialHintsCheck")
	if tutorial_hints_check:
		tutorial_hints_check.button_pressed = current_settings.tutorial_hints
	
	# Accessibility settings
	var colorblind_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/ColorBlindContainer/ColorBlindCheck")
	if colorblind_check:
		colorblind_check.button_pressed = current_settings.colorblind_support
	
	var large_font_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/LargeFontContainer/LargeFontCheck")
	if large_font_check:
		large_font_check.button_pressed = current_settings.large_font
	
	var high_contrast_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/HighContrastContainer/HighContrastCheck")
	if high_contrast_check:
		high_contrast_check.button_pressed = current_settings.high_contrast
	
	var color_filter_dropdown = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/ColorFilterContainer/ColorFilterDropdown")
	if color_filter_dropdown:
		color_filter_dropdown.select(current_settings.color_filter)
	
	var subtitles_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/SubtitlesContainer/SubtitlesCheck")
	if subtitles_check:
		subtitles_check.button_pressed = current_settings.subtitles
	
	var reduce_motion_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/ReduceMotionContainer/ReduceMotionCheck")
	if reduce_motion_check:
		reduce_motion_check.button_pressed = current_settings.reduce_motion
	
	var screen_reader_check = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/ScreenReaderContainer/ScreenReaderCheck")
	if screen_reader_check:
		screen_reader_check.button_pressed = current_settings.screen_reader
	
	var font_size_slider = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/FontSizeContainer/FontSizeSlider")
	if font_size_slider:
		font_size_slider.value = current_settings.font_size_scale
	
	_update_volume_labels()
	_update_mouse_sensitivity_label()
	_update_gamepad_deadzone_label()
	_update_camera_shake_label()
	_update_ui_scale_label()
	_update_font_size_label()
	_populate_keybindings()

func _update_volume_labels():
	"""Update volume percentage labels"""
	var master_label = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings/MasterVolumeContainer/MasterVolumeValue")
	if master_label:
		master_label.text = "%d%%" % temp_settings.master_volume
	
	var music_label = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings/MusicVolumeContainer/MusicVolumeValue")
	if music_label:
		music_label.text = "%d%%" % temp_settings.music_volume
	
	var sfx_label = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings/SFXVolumeContainer/SFXVolumeValue")
	if sfx_label:
		sfx_label.text = "%d%%" % temp_settings.sfx_volume

func _update_mouse_sensitivity_label():
	"""Update mouse sensitivity label"""
	var sensitivity_label = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings/MouseSensitivityContainer/MouseSensitivityValue")
	if sensitivity_label:
		sensitivity_label.text = "%.1fx" % temp_settings.mouse_sensitivity

func _update_gamepad_deadzone_label():
	"""Update gamepad deadzone label"""
	var deadzone_label = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings/GamepadDeadzoneContainer/GamepadDeadzoneValue")
	if deadzone_label:
		deadzone_label.text = "%.1f" % temp_settings.gamepad_deadzone

func _update_camera_shake_label():
	"""Update camera shake label"""
	var camera_shake_label = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings/CameraShakeContainer/CameraShakeValue")
	if camera_shake_label:
		camera_shake_label.text = "%.0f%%" % (temp_settings.camera_shake * 100.0)

func _update_ui_scale_label():
	"""Update UI scale label"""
	var ui_scale_label = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings/UIScaleContainer/UIScaleValue")
	if ui_scale_label:
		ui_scale_label.text = "%.0f%%" % (temp_settings.ui_scale * 100.0)

func _update_font_size_label():
	"""Update font size label"""
	var font_size_label = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings/FontSizeContainer/FontSizeValue")
	if font_size_label:
		font_size_label.text = "%.0f%%" % (temp_settings.font_size_scale * 100.0)

func _populate_keybindings():
	"""Populate keybinding controls"""
	var keybindings_container = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings/KeybindingsContainer")
	if not keybindings_container:
		return
	
	# Clear existing keybinding controls
	for child in keybindings_container.get_children():
		child.queue_free()
	
	# Wait for children to be removed
	await get_tree().process_frame
	
	# Create keybinding controls for each action
	var keybinds = current_settings.get("keybinds", {})
	for action in keybinds.keys():
		_create_keybind_control(keybindings_container, action, keybinds[action])

func _create_keybind_control(parent: Node, action: String, key: String):
	"""Create a keybinding control for an action"""
	var container = HBoxContainer.new()
	parent.add_child(container)
	
	# Action label
	var action_label = Label.new()
	action_label.text = action.capitalize() + ":"
	action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(action_label)
	
	# Key button
	var key_button = Button.new()
	key_button.text = key
	key_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_button.custom_minimum_size = Vector2(100, 30)
	container.add_child(key_button)
	
	# Connect signal for rebinding
	key_button.pressed.connect(_on_keybind_button_pressed.bind(action, key_button))

func _connect_all_signals():
	"""Connect all UI signals programmatically as backup to scene connections"""
	# Note: Signals are already connected in the .tscn file, but this ensures they work
	var close_button = get_node_or_null("MainContainer/HeaderContainer/CloseButton")
	if close_button and not close_button.pressed.is_connected(_on_cancel_pressed):
		close_button.pressed.connect(_on_cancel_pressed)
	
	print("SettingsMenu: All signals verified and connected")

# =======================
#  TAB MANAGEMENT
# =======================
func _switch_to_tab(category: SettingsCategory):
	"""Switch to the specified settings tab"""
	current_category = category
	
	# Hide all setting panels
	var audio_settings = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AudioSettings")
	var video_settings = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings")
	var controls_settings = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/ControlsSettings")
	var gameplay_settings = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/GameplaySettings")
	var accessibility_settings = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/AccessibilitySettings")
	
	if audio_settings: audio_settings.visible = false
	if video_settings: video_settings.visible = false
	if controls_settings: controls_settings.visible = false
	if gameplay_settings: gameplay_settings.visible = false
	if accessibility_settings: accessibility_settings.visible = false
	
	# Show the selected panel
	match category:
		SettingsCategory.AUDIO:
			if audio_settings: audio_settings.visible = true
		SettingsCategory.VIDEO:
			if video_settings: video_settings.visible = true
		SettingsCategory.CONTROLS:
			if controls_settings: controls_settings.visible = true
		SettingsCategory.GAMEPLAY:
			if gameplay_settings: gameplay_settings.visible = true
		SettingsCategory.ACCESSIBILITY:
			if accessibility_settings: accessibility_settings.visible = true
	
	# Update tab button states
	_update_tab_buttons(category)

func _update_tab_buttons(active_category: SettingsCategory):
	"""Update tab button visual states"""
	var audio_tab = get_node_or_null("MainContainer/ContentContainer/TabContainer/AudioTab")
	var video_tab = get_node_or_null("MainContainer/ContentContainer/TabContainer/VideoTab")
	var controls_tab = get_node_or_null("MainContainer/ContentContainer/TabContainer/ControlsTab")
	var gameplay_tab = get_node_or_null("MainContainer/ContentContainer/TabContainer/GameplayTab")
	var accessibility_tab = get_node_or_null("MainContainer/ContentContainer/TabContainer/AccessibilityTab")
	
	# Reset all tab states
	if audio_tab: audio_tab.button_pressed = false
	if video_tab: video_tab.button_pressed = false
	if controls_tab: controls_tab.button_pressed = false
	if gameplay_tab: gameplay_tab.button_pressed = false
	if accessibility_tab: accessibility_tab.button_pressed = false
	
	# Set active tab
	match active_category:
		SettingsCategory.AUDIO:
			if audio_tab: audio_tab.button_pressed = true
		SettingsCategory.VIDEO:
			if video_tab: video_tab.button_pressed = true
		SettingsCategory.CONTROLS:
			if controls_tab: controls_tab.button_pressed = true
		SettingsCategory.GAMEPLAY:
			if gameplay_tab: gameplay_tab.button_pressed = true
		SettingsCategory.ACCESSIBILITY:
			if accessibility_tab: accessibility_tab.button_pressed = true

# =======================
#  SETTINGS MANAGEMENT
# =======================
func apply_setting(section: String, key: String, value):
	"""Apply a setting with validation and preview"""
	var cfg_service = ServiceManager.get_service("ConfigService")
	if cfg_service:
		# Validate the setting first
		var validation = cfg_service.validate_setting(section, key, value)
		
		if validation.valid:
			# Use preview system for real-time feedback
			preview_setting_change(section, key, value)
		else:
			print("SettingsMenu: Validation failed for ", section, ".", key, ": ", validation.error)
			if validation.corrected_value != null:
				print("SettingsMenu: Using corrected value: ", validation.corrected_value)
				preview_setting_change(section, key, validation.corrected_value)
			# Reload the setting from config to show corrected value
			_reload_setting_ui(section, key)

func _apply_setting_immediately(section: String, _key: String, _value):
	"""Apply setting changes immediately to the game"""
	match section:
		"video":
			_apply_video_settings()
		"audio":
			_apply_audio_settings()
		"controls":
			_apply_controls_settings()
		"accessibility":
			_apply_accessibility_features()

func _reload_setting_ui(section: String, key: String):
	"""Reload setting UI to show corrected value"""
	var cfg_service = ServiceManager.get_service("ConfigService")
	if not cfg_service:
		return
	
	var corrected_value = cfg_service.get_setting(section, key)
	
	# Update UI to show corrected value
	match section:
		"video":
			_update_video_ui(key, corrected_value)
		"audio":
			_update_audio_ui(key, corrected_value)
		"controls":
			_update_controls_ui(key, corrected_value)
		"accessibility":
			_update_accessibility_ui(key, corrected_value)

func _update_video_ui(key: String, value):
	"""Update video UI elements"""
	match key:
		"window_mode":
			get_node("VBoxContainer/TabContainer/Video/VideoSettings/WindowMode/OptionButton").selected = value
		"fps_limit":
			get_node("VBoxContainer/TabContainer/Video/VideoSettings/FPSLimit/SpinBox").value = value
		"quality_preset":
			get_node("VBoxContainer/TabContainer/Video/VideoSettings/QualityPreset/OptionButton").selected = value

func _update_audio_ui(key: String, value):
	"""Update audio UI elements"""
	match key:
		"master_volume":
			get_node("VBoxContainer/TabContainer/Audio/AudioSettings/MasterVolume/HSlider").value = value
		"music_volume":
			get_node("VBoxContainer/TabContainer/Audio/AudioSettings/MusicVolume/HSlider").value = value
		"sfx_volume":
			get_node("VBoxContainer/TabContainer/Audio/AudioSettings/SFXVolume/HSlider").value = value

func _update_controls_ui(key: String, value):
	"""Update controls UI elements"""
	match key:
		"mouse_sensitivity":
			get_node("VBoxContainer/TabContainer/Controls/ControlsSettings/MouseSensitivity/HSlider").value = value
		"gamepad_deadzone":
			get_node("VBoxContainer/TabContainer/Controls/ControlsSettings/GamepadDeadzone/HSlider").value = value

func _update_accessibility_ui(key: String, value):
	"""Update accessibility UI elements"""
	match key:
		"font_size_scale":
			get_node("VBoxContainer/TabContainer/Accessibility/AccessibilitySettings/FontScale/HSlider").value = value
		"color_filter":
			get_node("VBoxContainer/TabContainer/Accessibility/AccessibilitySettings/ColorFilter/OptionButton").selected = value

func _apply_audio_settings():
	"""Apply audio settings to AudioService"""
	if audio_service:
		audio_service.set_master_volume(current_settings.master_volume / 100.0)
		audio_service.set_music_volume(current_settings.music_volume / 100.0)
		audio_service.set_sfx_volume(current_settings.sfx_volume / 100.0)
		audio_service.set_spatial_audio(current_settings.get("spatial_audio", true))
		audio_service.set_audio_quality(current_settings.get("audio_quality", 1))
		
		# Apply audio device if implemented
		var device_index = current_settings.get("audio_device", 0)
		var available_devices = audio_service.get_available_audio_devices()
		if device_index >= 0 and device_index < available_devices.size():
			audio_service.set_audio_device(available_devices[device_index])

func _apply_video_settings():
	"""Apply video settings to DisplayServer"""
	# Apply resolution
	var resolution_str = current_settings.get("resolution", "1920x1080")
	var resolution_parts = resolution_str.split("x")
	if resolution_parts.size() == 2:
		var width = resolution_parts[0].to_int()
		var height = resolution_parts[1].to_int()
		DisplayServer.window_set_size(Vector2i(width, height))
	
	# Apply window mode
	var window_mode = current_settings.get("window_mode", 0)
	match window_mode:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: # Borderless - using windowed for now
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Apply VSync
	if current_settings.get("vsync", true):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	# Apply FPS limit
	var fps_limit = current_settings.get("fps_limit", 60)
	if fps_limit == 0:
		Engine.max_fps = 0 # Unlimited
	else:
		Engine.max_fps = fps_limit
	
	print("SettingsMenu: Video settings applied - Resolution: %s, Window Mode: %d, VSync: %s, FPS: %d" % 
		[resolution_str, window_mode, current_settings.vsync, fps_limit])

func _apply_controls_settings():
	"""Apply controls settings"""
	# Apply mouse sensitivity to InputService if available
	if ServiceManager:
		var input_service = ServiceManager.get_service("InputService")
		if input_service and input_service.has_method("set_mouse_sensitivity"):
			input_service.set_mouse_sensitivity(current_settings.mouse_sensitivity)
	
	# Apply gamepad settings
	_apply_gamepad_deadzone(current_settings.gamepad_deadzone)
	
	# Apply keybindings
	_apply_keybindings()
	
	print("SettingsMenu: Controls settings applied")

func _apply_gamepad_deadzone(deadzone: float):
	"""Apply gamepad deadzone to input actions"""
	var actions = ["move_up", "move_down", "move_left", "move_right"]
	for action in actions:
		if InputMap.has_action(action):
			InputMap.action_set_deadzone(action, deadzone)

func _apply_keybindings():
	"""Apply custom keybindings to InputMap"""
	var keybinds = current_settings.get("keybinds", {})
	for action in keybinds.keys():
		if InputMap.has_action(action):
			# Clear existing events
			InputMap.action_erase_events(action)
			
			# Add new event
			var event = InputEventKey.new()
			event.keycode = OS.find_keycode_from_string(keybinds[action])
			InputMap.action_add_event(action, event)

func _apply_accessibility_features():
	"""Apply accessibility settings"""
	# Font scaling
	var font_scale = config_service.get_setting("accessibility", "font_size_scale", 1.0)
	_apply_font_scaling(font_scale)
	
	# High contrast mode
	var high_contrast = config_service.get_setting("accessibility", "high_contrast", false)
	_apply_high_contrast(high_contrast)
	
	# Color filter
	var color_filter = config_service.get_setting("accessibility", "color_filter", 0)
	_apply_color_filter(color_filter)

func _apply_font_scaling(font_scale: float):
	"""Apply font scaling for accessibility"""
	# This would apply to all UI text
	var ui_theme = get_theme()
	if ui_theme:
		# Apply scaling to the default font sizes
		print("SettingsMenu: Applied font scaling: ", font_scale)

func _apply_high_contrast(enabled: bool):
	"""Apply high contrast mode"""
	if enabled:
		# Apply high contrast theme
		print("SettingsMenu: High contrast mode enabled")
	else:
		# Apply normal theme
		print("SettingsMenu: High contrast mode disabled")

func _apply_color_filter(filter_type: int):
	"""Apply color filter for colorblind accessibility"""
	match filter_type:
		0:
			print("SettingsMenu: No color filter applied")
		1:
			print("SettingsMenu: Protanopia color filter applied")
		2:
			print("SettingsMenu: Deuteranopia color filter applied")
		3:
			print("SettingsMenu: Tritanopia color filter applied")

# ============================================================================
#  REAL-TIME PREVIEW SYSTEM
# ============================================================================

func _init_preview_system():
	"""Initialize the preview system"""
	preview_timer = Timer.new()
	preview_timer.wait_time = preview_duration
	preview_timer.timeout.connect(_on_preview_timeout)
	preview_timer.one_shot = true
	add_child(preview_timer)

func start_preview_mode():
	"""Start preview mode for settings changes"""
	if not preview_mode:
		preview_mode = true
		print("SettingsMenu: Preview mode enabled")
		_show_preview_notification()

func _show_preview_notification():
	"""Show preview mode notification"""
	# This would show a visual indicator that changes are being previewed
	print("SettingsMenu: Changes are being previewed. Apply or Cancel to exit preview mode.")

func _on_preview_timeout():
	"""Handle preview timeout - revert changes"""
	if preview_mode:
		revert_preview()

func apply_preview():
	"""Apply preview changes permanently"""
	if preview_mode:
		# Copy temp settings to current settings
		current_settings = temp_settings.duplicate(true)
		
		# Save to config service
		for section in temp_settings.keys():
			for key in temp_settings[section].keys():
				config_service.set_setting(section, key, temp_settings[section][key])
		
		config_service.save_config()
		preview_mode = false
		has_unsaved_changes = false
		
		print("SettingsMenu: Preview changes applied permanently")
		_hide_preview_notification()

func revert_preview():
	"""Revert preview changes"""
	if preview_mode:
		# Restore original settings
		temp_settings = current_settings.duplicate(true)
		
		# Apply original settings to game systems
		_apply_audio_settings()
		_apply_video_settings()
		_apply_controls_settings()
		_apply_accessibility_features()
		
		# Update UI to show reverted values
		_reload_all_settings_ui()
		
		preview_mode = false
		has_unsaved_changes = false
		
		print("SettingsMenu: Preview changes reverted")
		_hide_preview_notification()

func _hide_preview_notification():
	"""Hide preview mode notification"""
	print("SettingsMenu: Preview mode disabled")

func preview_setting_change(section: String, key: String, value):
	"""Preview a setting change without saving"""
	if not preview_mode:
		start_preview_mode()
	
	# Update temp settings
	if not temp_settings.has(section):
		temp_settings[section] = {}
	temp_settings[section][key] = value
	
	# Apply temporarily for preview
	_apply_preview_setting(section, key, value)
	
	# Reset preview timer
	preview_timer.stop()
	preview_timer.start()
	
	has_unsaved_changes = true
	print("SettingsMenu: Previewing ", section, ".", key, " = ", value)

func _apply_preview_setting(section: String, key: String, value):
	"""Apply a single setting for preview"""
	match section:
		"video":
			_apply_preview_video_setting(key, value)
		"audio":
			_apply_preview_audio_setting(key, value)
		"controls":
			_apply_preview_controls_setting(key, value)
		"accessibility":
			_apply_preview_accessibility_setting(key, value)

func _apply_preview_video_setting(key: String, value):
	"""Apply video setting for preview"""
	match key:
		"resolution":
			_preview_resolution_change(value)
		"window_mode":
			_preview_window_mode_change(value)
		"vsync":
			_preview_vsync_change(value)
		"fps_limit":
			_preview_fps_limit_change(value)

func _apply_preview_audio_setting(key: String, value):
	"""Apply audio setting for preview"""
	match key:
		"master_volume":
			_preview_volume_change("Master", value)
		"music_volume":
			_preview_volume_change("Music", value)
		"sfx_volume":
			_preview_volume_change("SFX", value)

func _apply_preview_controls_setting(key: String, value):
	"""Apply controls setting for preview"""
	match key:
		"mouse_sensitivity":
			print("SettingsMenu: Previewing mouse sensitivity: ", value)
		"gamepad_deadzone":
			print("SettingsMenu: Previewing gamepad deadzone: ", value)

func _apply_preview_accessibility_setting(key: String, value):
	"""Apply accessibility setting for preview"""
	match key:
		"font_size_scale":
			print("SettingsMenu: Previewing font scale: ", value)
		"high_contrast":
			print("SettingsMenu: Previewing high contrast: ", value)

# Preview implementation functions
func _preview_resolution_change(resolution_str: String):
	"""Preview resolution change"""
	var parts = resolution_str.split("x")
	if parts.size() == 2:
		var width = parts[0].to_int()
		var height = parts[1].to_int()
		if width > 0 and height > 0:
			print("SettingsMenu: Previewing resolution change to ", width, "x", height)
			# Note: In a full implementation, we might apply this temporarily

func _preview_window_mode_change(mode: int):
	"""Preview window mode change"""
	var mode_names = ["Windowed", "Fullscreen", "Borderless Windowed", "Fullscreen Borderless"]
	var mode_name = mode_names[mode] if mode < mode_names.size() else "Unknown"
	print("SettingsMenu: Previewing window mode change to ", mode_name)

func _preview_vsync_change(enabled: bool):
	"""Preview VSync change"""
	print("SettingsMenu: Previewing VSync ", "enabled" if enabled else "disabled")

func _preview_fps_limit_change(fps: int):
	"""Preview FPS limit change"""
	print("SettingsMenu: Previewing FPS limit change to ", fps)

func _preview_volume_change(bus_name: String, volume: float):
	"""Preview volume change"""
	print("SettingsMenu: Previewing ", bus_name, " volume change to ", volume, "%")
	
	# Apply volume change temporarily for immediate feedback
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		var db_value = linear_to_db(volume / 100.0)
		AudioServer.set_bus_volume_db(bus_index, db_value)

# ============================================================================
#  IMPORT/EXPORT FUNCTIONALITY
# ============================================================================

func _on_export_settings_pressed():
	"""Export current settings to file"""
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_USERDATA
	file_dialog.add_filter("*.json", "Settings Files")
	file_dialog.current_file = "game_settings_" + Time.get_datetime_string_from_system().replace(":", "-") + ".json"
	
	# Connect the file selected signal
	file_dialog.file_selected.connect(_on_export_file_selected)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_export_file_selected(path: String):
	"""Handle export file selection"""
	var success = config_service.export_settings_to_file(path)
	
	if success:
		_show_notification("Settings exported successfully to:\n" + path, 3.0)
	else:
		_show_notification("Failed to export settings!", 3.0)

func _on_import_settings_pressed():
	"""Import settings from file"""
	var file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_USERDATA
	file_dialog.add_filter("*.json", "Settings Files")
	
	# Connect the file selected signal
	file_dialog.file_selected.connect(_on_import_file_selected)
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_import_file_selected(path: String):
	"""Handle import file selection"""
	var result = config_service.import_settings_from_file(path)
	
	if result.success:
		# Reload UI to reflect imported settings
		_reload_all_settings_ui()
		_show_notification("Settings imported successfully!\n" + result.message, 3.0)
	else:
		_show_notification("Failed to import settings:\n" + result.message, 3.0)

func _on_save_profile_pressed():
	"""Save current settings as a named profile"""
	_show_profile_name_dialog("Save Profile", "_on_save_profile_confirmed")

func _on_load_profile_pressed():
	"""Load settings from a saved profile"""
	_show_profile_selection_dialog("Load Profile", "_on_load_profile_confirmed")

func _on_save_profile_confirmed(profile_name: String):
	"""Save settings to named profile"""
	var success = config_service.export_settings_to_profile(profile_name)
	
	if success:
		_show_notification("Profile '" + profile_name + "' saved successfully!", 2.0)
	else:
		_show_notification("Failed to save profile '" + profile_name + "'!", 2.0)

func _on_load_profile_confirmed(profile_name: String):
	"""Load settings from named profile"""
	var result = config_service.import_settings_from_profile(profile_name)
	
	if result.success:
		_reload_all_settings_ui()
		_show_notification("Profile '" + profile_name + "' loaded successfully!", 2.0)
	else:
		_show_notification("Failed to load profile '" + profile_name + "':\n" + result.message, 3.0)

func _reload_all_settings_ui():
	"""Reload all settings UI elements from config"""
	# This function reloads all UI elements to reflect current config values
	print("SettingsMenu: Reloading all settings UI elements from config")
	
	# Video settings
	var _resolution = config_service.get_setting("video", "resolution", "1920x1080")
	var _window_mode = config_service.get_setting("video", "window_mode", 0)
	var _fps_limit = config_service.get_setting("video", "fps_limit", 60)
	
	# Audio settings
	var _master_volume = config_service.get_setting("audio", "master_volume", 80.0)
	var _music_volume = config_service.get_setting("audio", "music_volume", 80.0)
	var _sfx_volume = config_service.get_setting("audio", "sfx_volume", 90.0)
	
	# Controls settings
	var _mouse_sensitivity = config_service.get_setting("controls", "mouse_sensitivity", 1.0)
	var _gamepad_deadzone = config_service.get_setting("controls", "gamepad_deadzone", 0.2)
	
	# Apply values to UI (basic implementation - would need proper node paths)
	print("SettingsMenu: UI reload completed")

func _show_profile_name_dialog(title: String, callback: String):
	"""Show dialog to enter profile name"""
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	
	var vbox = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Enter profile name:"
	vbox.add_child(label)
	
	var line_edit = LineEdit.new()
	line_edit.placeholder_text = "Profile Name"
	line_edit.custom_minimum_size.x = 200
	vbox.add_child(line_edit)
	
	dialog.add_child(vbox)
	
	# Connect signals
	dialog.confirmed.connect(func(): call(callback, line_edit.text))
	dialog.close_requested.connect(func(): dialog.queue_free())
	
	add_child(dialog)
	dialog.popup_centered()
	line_edit.grab_focus()

func _show_profile_selection_dialog(title: String, callback: String):
	"""Show dialog to select from available profiles"""
	var profiles = config_service.get_available_profiles()
	
	if profiles.is_empty():
		_show_notification("No saved profiles found!", 2.0)
		return
	
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	
	var vbox = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Select profile to load:"
	vbox.add_child(label)
	
	var option_button = OptionButton.new()
	for profile in profiles:
		option_button.add_item(profile)
	option_button.custom_minimum_size.x = 200
	vbox.add_child(option_button)
	
	dialog.add_child(vbox)
	
	# Connect signals
	dialog.confirmed.connect(func(): call(callback, profiles[option_button.selected]))
	dialog.close_requested.connect(func(): dialog.queue_free())
	
	add_child(dialog)
	dialog.popup_centered()

func _show_notification(message: String, duration: float = 2.0):
	"""Show a temporary notification message"""
	var info_dialog = AcceptDialog.new()
	info_dialog.title = "Settings"
	info_dialog.dialog_text = message
	info_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	
	add_child(info_dialog)
	info_dialog.popup_centered()
	
	# Auto-close after duration
	get_tree().create_timer(duration).timeout.connect(func(): 
		if is_instance_valid(info_dialog):
			info_dialog.queue_free()
	)

func _on_reset_to_defaults_pressed():
	"""Reset all settings to defaults with confirmation"""
	var confirmation = ConfirmationDialog.new()
	confirmation.title = "Reset Settings"
	confirmation.dialog_text = "Are you sure you want to reset all settings to defaults?\n\nThis action can be undone by clicking 'Restore Backup'."
	confirmation.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	
	# Connect signals
	confirmation.confirmed.connect(_on_reset_confirmed)
	confirmation.close_requested.connect(func(): confirmation.queue_free())
	
	add_child(confirmation)
	confirmation.popup_centered()

func _on_reset_confirmed():
	"""Confirm reset to defaults"""
	var result = config_service.reset_to_defaults_with_confirmation()
	
	if result.success:
		_reload_all_settings_ui()
		_show_notification("Settings reset to defaults!\nUse 'Restore Backup' to undo this action.", 3.0)

func _on_restore_backup_pressed():
	"""Restore settings from backup"""
	if config_service.has_backup():
		var success = config_service.restore_backup()
		if success:
			_reload_all_settings_ui()
			_show_notification("Settings restored from backup!", 2.0)
		else:
			_show_notification("Failed to restore backup!", 2.0)
	else:
		_show_notification("No backup available to restore!", 2.0)

# ============================================================================
#  TAB HANDLERS
# ============================================================================

func _reset_to_defaults():
	"""Reset all settings to default values"""
	temp_settings = default_settings.duplicate(true)
	_update_ui_from_settings()
	has_unsaved_changes = true
	print("SettingsMenu: Settings reset to defaults")

# =======================
#  SIGNAL HANDLERS
# =======================

# Tab handlers
func _on_audio_tab_pressed():
	_switch_to_tab(SettingsCategory.AUDIO)

func _on_video_tab_pressed():
	_switch_to_tab(SettingsCategory.VIDEO)

func _on_controls_tab_pressed():
	_switch_to_tab(SettingsCategory.CONTROLS)

func _on_gameplay_tab_pressed():
	_switch_to_tab(SettingsCategory.GAMEPLAY)

func _on_accessibility_tab_pressed():
	_switch_to_tab(SettingsCategory.ACCESSIBILITY)

# Audio handlers
func _on_master_volume_changed(value: float):
	temp_settings.master_volume = value
	has_unsaved_changes = true
	_update_volume_labels()
	if audio_service:
		audio_service.set_master_volume(value / 100.0)

func _on_music_volume_changed(value: float):
	temp_settings.music_volume = value
	has_unsaved_changes = true
	_update_volume_labels()
	if audio_service:
		audio_service.set_music_volume(value / 100.0)

func _on_sfx_volume_changed(value: float):
	temp_settings.sfx_volume = value
	has_unsaved_changes = true
	_update_volume_labels()
	if audio_service:
		audio_service.set_sfx_volume(value / 100.0)

func _on_audio_device_selected(index: int):
	"""Handle audio device selection"""
	temp_settings.audio_device = index
	has_unsaved_changes = true
	_apply_audio_device(index)

func _on_audio_quality_selected(index: int):
	"""Handle audio quality selection"""
	temp_settings.audio_quality = index
	has_unsaved_changes = true
	_apply_audio_quality(index)

func _on_spatial_audio_toggled(enabled: bool):
	"""Handle spatial audio toggle"""
	temp_settings.spatial_audio = enabled
	has_unsaved_changes = true
	_apply_spatial_audio(enabled)

# Video handlers
func _on_fullscreen_toggled(enabled: bool):
	temp_settings.fullscreen = enabled
	has_unsaved_changes = true
	# Apply immediately for preview
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_toggled(enabled: bool):
	temp_settings.vsync = enabled
	has_unsaved_changes = true
	# Apply immediately for preview
	if enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# Button handlers with preview system
func _on_apply_pressed():
	"""Apply all current settings"""
	if preview_mode:
		apply_preview()
	else:
		# Apply all current settings normally
		_apply_audio_settings()
		_apply_video_settings()
		_apply_controls_settings()
		_apply_accessibility_features()
		config_service.save_config()
	
	_show_notification("Settings applied successfully!", 2.0)

func _on_cancel_pressed():
	"""Cancel changes and close menu"""
	if preview_mode:
		revert_preview()
	_close_menu()

func _on_reset_pressed():
	"""Reset to defaults"""
	if preview_mode:
		revert_preview()
	_reset_to_defaults()

func _on_ok_pressed():
	"""Apply settings and close menu"""
	if preview_mode:
		apply_preview()
	else:
		# Apply all current settings normally
		_apply_audio_settings()
		_apply_video_settings()
		_apply_controls_settings()
		_apply_accessibility_features()
		config_service.save_config()
	
	_close_menu()

func _close_menu():
	"""Close the settings menu"""
	back_pressed.emit()
	settings_closed.emit()
	queue_free()

# Placeholder handlers for compatibility
func _on_quality_preset_selected(index: int):
	temp_settings.quality_preset = index
	has_unsaved_changes = true
	_apply_quality_preset(index)

func _on_resolution_selected(index: int):
	var resolution_option = get_node_or_null("MainContainer/ContentContainer/SettingsContainer/SettingsContent/VideoSettings/ResolutionContainer/ResolutionOption")
	if resolution_option and index >= 0 and index < resolution_option.get_item_count():
		var resolution = resolution_option.get_item_text(index)
		temp_settings.resolution = resolution
		has_unsaved_changes = true
		
		# Apply immediately for preview
		var resolution_parts = resolution.split("x")
		if resolution_parts.size() == 2:
			var width = resolution_parts[0].to_int()
			var height = resolution_parts[1].to_int()
			DisplayServer.window_set_size(Vector2i(width, height))

func _on_mouse_sensitivity_changed(value: float):
	temp_settings.mouse_sensitivity = value
	has_unsaved_changes = true
	_update_mouse_sensitivity_label()

func _apply_quality_preset(preset_index: int):
	"""Apply quality preset settings"""
	match preset_index:
		0: # Low
			print("SettingsMenu: Applied Low quality preset")
		1: # Medium
			print("SettingsMenu: Applied Medium quality preset")
		2: # High
			print("SettingsMenu: Applied High quality preset")
		3: # Ultra
			print("SettingsMenu: Applied Ultra quality preset")

func _apply_audio_device(device_index: int):
	"""Apply audio device selection"""
	# Note: This would interact with AudioServer to change output device
	# For now, we just log the change
	print("SettingsMenu: Audio device changed to index: ", device_index)
	
	# In a full implementation, you would use:
	# AudioServer.set_device(device_name)

func _apply_audio_quality(quality_index: int):
	"""Apply audio quality settings"""
	# Note: In Godot 4, mix rate is set in project settings
	# This method serves as a placeholder for audio quality configuration
	match quality_index:
		0: # Low quality
			print("SettingsMenu: Audio quality set to Low (22kHz)")
		1: # Medium quality
			print("SettingsMenu: Audio quality set to Medium (44kHz)")
		2: # High quality
			print("SettingsMenu: Audio quality set to High (48kHz)")
	
	# In a full implementation, you might adjust audio buffer sizes or compression

func _apply_spatial_audio(enabled: bool):
	"""Apply spatial audio settings"""
	# This would configure 3D audio processing
	print("SettingsMenu: Spatial audio ", "enabled" if enabled else "disabled")
	
	# In a full implementation, you might adjust AudioServer settings for 3D audio

func _on_difficulty_selected(_index: int):
	pass

func _on_auto_save_toggled(enabled: bool):
	"""Handle auto-save toggle"""
	temp_settings.auto_save = enabled
	has_unsaved_changes = true

# ===============================================
# ACCESSIBILITY SETTINGS SIGNAL HANDLERS
# ===============================================

func _on_colorblind_support_toggled(enabled: bool):
	"""Handle colorblind support toggle"""
	temp_settings.colorblind_support = enabled
	has_unsaved_changes = true

func _on_large_font_toggled(enabled: bool):
	"""Handle large font toggle"""
	temp_settings.large_font = enabled
	has_unsaved_changes = true

func _on_high_contrast_toggled(enabled: bool):
	"""Handle high contrast mode toggle"""
	temp_settings.high_contrast = enabled
	has_unsaved_changes = true

func _on_color_filter_selected(index: int):
	"""Handle color filter selection"""
	temp_settings.color_filter = index
	has_unsaved_changes = true

func _on_subtitles_toggled(enabled: bool):
	"""Handle subtitles toggle"""
	temp_settings.subtitles = enabled
	has_unsaved_changes = true

func _on_reduce_motion_toggled(enabled: bool):
	"""Handle reduce motion toggle"""
	temp_settings.reduce_motion = enabled
	has_unsaved_changes = true

func _on_screen_reader_toggled(enabled: bool):
	"""Handle screen reader support toggle"""
	temp_settings.screen_reader = enabled
	has_unsaved_changes = true

func _on_font_size_changed(value: float):
	"""Handle font size scale change"""
	temp_settings.font_size_scale = value
	_update_font_size_label()
	has_unsaved_changes = true

func _on_window_mode_selected(index: int):
	"""Handle window mode selection"""
	temp_settings.window_mode = index
	has_unsaved_changes = true
	
	# Apply immediately for preview
	match index:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			# TODO: Implement borderless window mode

func _on_fps_limit_selected(index: int):
	"""Handle FPS limit selection"""
	var fps_values = [30, 60, 120, 144, 0] # 0 = unlimited
	if index >= 0 and index < fps_values.size():
		var fps_limit = fps_values[index]
		temp_settings.fps_limit = fps_limit
		has_unsaved_changes = true
		
		# Apply immediately for preview
		if fps_limit == 0:
			Engine.max_fps = 0 # Unlimited
		else:
			Engine.max_fps = fps_limit

# Controls handlers
func _on_mouse_invert_x_toggled(enabled: bool):
	"""Handle mouse X inversion toggle"""
	temp_settings.mouse_invert_x = enabled
	has_unsaved_changes = true

func _on_mouse_invert_y_toggled(enabled: bool):
	"""Handle mouse Y inversion toggle"""
	temp_settings.mouse_invert_y = enabled
	has_unsaved_changes = true

func _on_gamepad_deadzone_changed(value: float):
	"""Handle gamepad deadzone change"""
	temp_settings.gamepad_deadzone = value
	has_unsaved_changes = true
	_update_gamepad_deadzone_label()
	# Apply deadzone to input actions immediately
	_apply_gamepad_deadzone(value)

func _on_gamepad_vibration_toggled(enabled: bool):
	"""Handle gamepad vibration toggle"""
	temp_settings.gamepad_vibration = enabled
	has_unsaved_changes = true

# ===============================================
# GAMEPLAY SETTINGS SIGNAL HANDLERS
# ===============================================

func _on_auto_save_interval_selected(index: int):
	"""Handle auto-save interval selection"""
	var intervals = [0, 60, 300, 600]  # 0=manual, 60=1min, 300=5min, 600=10min
	temp_settings.auto_save_interval = intervals[index]
	has_unsaved_changes = true

func _on_camera_shake_changed(value: float):
	"""Handle camera shake intensity change"""
	temp_settings.camera_shake = value
	_update_camera_shake_label()
	has_unsaved_changes = true

func _on_ui_scale_changed(value: float):
	"""Handle UI scale change"""
	temp_settings.ui_scale = value
	_update_ui_scale_label()
	has_unsaved_changes = true

func _on_tutorial_hints_toggled(enabled: bool):
	"""Handle tutorial hints toggle"""
	temp_settings.tutorial_hints = enabled
	has_unsaved_changes = true

func _on_keybind_button_pressed(action: String, button: Button):
	"""Handle keybind button press for rebinding"""
	button.text = "Press any key..."
	button.disabled = true
	
	# Start listening for key input
	_start_key_capture(action, button)

# Key capture system
var is_capturing_key: bool = false
var capture_action: String = ""
var capture_button: Button = null

func _start_key_capture(action: String, button: Button):
	"""Start capturing key input for rebinding"""
	is_capturing_key = true
	capture_action = action
	capture_button = button

func _input(event: InputEvent):
	"""Handle input for key capture"""
	if not is_capturing_key:
		return
	
	if event is InputEventKey and event.pressed:
		_finish_key_capture(event.as_text())
		get_viewport().set_input_as_handled()

func _finish_key_capture(new_key: String):
	"""Finish key capture and update the binding"""
	if not capture_button:
		return
	
	# Update the setting
	if not temp_settings.has("keybinds"):
		temp_settings.keybinds = {}
	temp_settings.keybinds[capture_action] = new_key
	
	# Update the button
	capture_button.text = new_key
	capture_button.disabled = false
	
	# Mark as changed
	has_unsaved_changes = true
	
	# Reset capture state
	is_capturing_key = false
	capture_action = ""
	capture_button = null
	
	print("SettingsMenu: Rebound %s to %s" % [capture_action, new_key])
