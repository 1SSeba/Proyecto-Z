extends Node

var service_name: String = "ConfigService"
var is_service_ready: bool = false

var config_data: Dictionary = {}
var config_file_path: String = "user://game_config.cfg"
var config_file: ConfigFile = ConfigFile.new()

var default_config: Dictionary = {
	"video": {
		"resolution": "1920x1080",
		"window_mode": 0,
		"fullscreen": false,
		"vsync": true,
		"fps_limit": 60,
		"quality_preset": 1
	},
	"audio": {
		"master_volume": 80.0,
		"music_volume": 80.0,
		"sfx_volume": 90.0,
		"audio_device": 0,
		"audio_quality": 1,
		"spatial_audio": true
	},
	"controls": {
		"mouse_sensitivity": 1.0,
		"mouse_invert_x": false,
		"mouse_invert_y": false,
		"gamepad_deadzone": 0.2,
		"gamepad_vibration": true,
		"keybinds": {
			"move_up": "W",
			"move_down": "S",
			"move_left": "A",
			"move_right": "D",
			"interact": "E",
			"cancel": "Escape"
		}
	},
	"gameplay": {
		"difficulty": 1,
		"auto_save": true,
		"auto_save_interval": 5,
		"camera_shake": 1.0,
		"ui_scale": 1.0,
		"tutorial_hints": true
	},
	"accessibility": {
		"colorblind_support": false,
		"large_font": false,
		"high_contrast": false,
		"color_filter": 0,
		"subtitles": true,
		"reduce_motion": false,
		"screen_reader": false,
		"font_size_scale": 1.0
	},
	"system": {
		"first_run": true,
		"config_version": "1.0",
		"last_played": "",
		"total_playtime": 0
	}
}

#  SERVICE LIFECYCLE

func _start():
	service_name = "ConfigService"
	load_config()
	is_service_ready = true
	print("ConfigService: Service initialized successfully")

func start_service():
	
	_start()

#  CONFIGURATION MANAGEMENT

func load_config():
	
	config_data = default_config.duplicate(true)

	if config_file.load(config_file_path) == OK:
		_merge_loaded_config()
		print("ConfigService: Config file loaded from: ", config_file_path)
		print("ConfigService: Configuration loaded successfully")
	else:
		print("ConfigService: No config file found, using defaults")
		save_config()

func _merge_loaded_config():
	
	for section in config_file.get_sections():
		if not config_data.has(section):
			config_data[section] = {}

		for key in config_file.get_section_keys(section):
			config_data[section][key] = config_file.get_value(section, key)

func save_config():
	
	config_file = ConfigFile.new()

	for section in config_data.keys():
		for key in config_data[section].keys():
			config_file.set_value(section, key, config_data[section][key])

	if config_file.save(config_file_path) == OK:
		print("ConfigService: Configuration saved to: ", config_file_path)
	else:
		print("ConfigService: Failed to save configuration")

func save_settings():
	
	save_config()

#  CONFIG ACCESS METHODS

func get_setting(section: String, key: String, default_value = null):
	
	if config_data.has(section) and config_data[section].has(key):
		return config_data[section][key]
	return default_value

func set_setting(section: String, key: String, value):
	
	if not config_data.has(section):
		config_data[section] = {}

	config_data[section][key] = value

func get_value(section: String, key: String, default_value = null):
	
	return get_setting(section, key, default_value)

func set_value(section: String, key: String, value):
	
	set_setting(section, key, value)

#  CONVENIENCE METHODS

func get_audio_setting(key: String, default_value = null):
	
	return get_setting("audio", key, default_value)

func set_audio_setting(key: String, value):
	
	set_setting("audio", key, value)

func get_video_setting(key: String, default_value = null):
	
	return get_setting("video", key, default_value)

func set_video_setting(key: String, value):
	
	set_setting("video", key, value)

func get_graphics_setting(key: String, default_value = null):
	
	return get_setting("video", key, default_value)

func set_graphics_setting(key: String, value):
	
	set_setting("video", key, value)

func get_gameplay_setting(key: String, default_value = null):
	
	return get_setting("gameplay", key, default_value)

func set_gameplay_setting(key: String, value):
	
	set_setting("gameplay", key, value)

#  SETTINGS VALIDATION SYSTEM

func validate_setting(section: String, key: String, value) -> Dictionary:
	
	var result = {"valid": false, "error": "", "corrected_value": null}

	match section:
		"video":
			result = _validate_video_setting(key, value)
		"audio":
			result = _validate_audio_setting(key, value)
		"controls":
			result = _validate_controls_setting(key, value)
		"gameplay":
			result = _validate_gameplay_setting(key, value)
		"accessibility":
			result = _validate_accessibility_setting(key, value)
		"system":
			result = _validate_system_setting(key, value)
		_:
			result.error = "Unknown section: " + section

	return result

func _validate_video_setting(key: String, value) -> Dictionary:
	
	var result = {"valid": true, "error": "", "corrected_value": null}

	match key:
		"resolution":
			if not _is_valid_resolution(value):
				result.valid = false
				result.error = "Invalid resolution format. Use 'WIDTHxHEIGHT'"
				result.corrected_value = "1920x1080"
		"window_mode":
			if not value is int or value < 0 or value > 4:
				result.valid = false
				result.error = "Window mode must be 0-4"
				result.corrected_value = 0
		"fps_limit":
			if not value is int or value < 30 or value > 240:
				result.valid = false
				result.error = "FPS limit must be between 30-240"
				result.corrected_value = 60
		"quality_preset":
			if not value is int or value < 0 or value > 3:
				result.valid = false
				result.error = "Quality preset must be 0-3"
				result.corrected_value = 1

	return result

func _validate_audio_setting(key: String, value) -> Dictionary:
	
	var result = {"valid": true, "error": "", "corrected_value": null}

	match key:
		"master_volume", "music_volume", "sfx_volume":
			if not value is float or value < 0.0 or value > 100.0:
				result.valid = false
				result.error = "Volume must be between 0.0-100.0"
				result.corrected_value = 80.0
		"audio_device":
			if not value is int or value < 0:
				result.valid = false
				result.error = "Audio device index must be >= 0"
				result.corrected_value = 0
		"audio_quality":
			if not value is int or value < 0 or value > 2:
				result.valid = false
				result.error = "Audio quality must be 0-2"
				result.corrected_value = 1

	return result

func _validate_controls_setting(key: String, value) -> Dictionary:
	
	var result = {"valid": true, "error": "", "corrected_value": null}

	match key:
		"mouse_sensitivity":
			if not value is float or value < 0.1 or value > 5.0:
				result.valid = false
				result.error = "Mouse sensitivity must be between 0.1-5.0"
				result.corrected_value = 1.0
		"gamepad_deadzone":
			if not value is float or value < 0.0 or value > 1.0:
				result.valid = false
				result.error = "Gamepad deadzone must be between 0.0-1.0"
				result.corrected_value = 0.2

	return result

func _validate_gameplay_setting(key: String, value) -> Dictionary:
	
	var result = {"valid": true, "error": "", "corrected_value": null}

	match key:
		"difficulty":
			if not value is int or value < 0 or value > 3:
				result.valid = false
				result.error = "Difficulty must be 0-3"
				result.corrected_value = 1
		"auto_save_interval":
			if not value is int or value < 1 or value > 60:
				result.valid = false
				result.error = "Auto-save interval must be 1-60 minutes"
				result.corrected_value = 5
		"camera_shake", "ui_scale":
			if not value is float or value < 0.0 or value > 2.0:
				result.valid = false
				result.error = "Value must be between 0.0-2.0"
				result.corrected_value = 1.0

	return result

func _validate_accessibility_setting(key: String, value) -> Dictionary:
	
	var result = {"valid": true, "error": "", "corrected_value": null}

	match key:
		"color_filter":
			if not value is int or value < 0 or value > 3:
				result.valid = false
				result.error = "Color filter must be 0-3"
				result.corrected_value = 0
		"font_size_scale":
			if not value is float or value < 0.5 or value > 2.0:
				result.valid = false
				result.error = "Font size scale must be between 0.5-2.0"
				result.corrected_value = 1.0

	return result

func _validate_system_setting(key: String, value) -> Dictionary:
	
	var result = {"valid": true, "error": "", "corrected_value": null}

	match key:
		"total_playtime":
			if not value is int or value < 0:
				result.valid = false
				result.error = "Playtime must be >= 0"
				result.corrected_value = 0

	return result

func _is_valid_resolution(resolution_string: String) -> bool:
	
	var parts = resolution_string.split("x")
	if parts.size() != 2:
		return false

	var width = parts[0].to_int()
	var height = parts[1].to_int()
	return width > 0 and height > 0 and width >= 640 and height >= 480

func set_setting_validated(section: String, key: String, value) -> bool:
	
	var validation = validate_setting(section, key, value)

	if validation.valid:
		set_setting(section, key, value)
		return true
	else:
		print("ConfigService: Validation failed for ", section, ".", key, ": ", validation.error)
		if validation.corrected_value != null:
			print("ConfigService: Using corrected value: ", validation.corrected_value)
			set_setting(section, key, validation.corrected_value)
		return false

func validate_all_settings() -> Dictionary:
	
	var issues = {}

	for section in config_data.keys():
		for key in config_data[section].keys():
			var validation = validate_setting(section, key, config_data[section][key])
			if not validation.valid:
				if not issues.has(section):
					issues[section] = {}
				issues[section][key] = validation.error

	return issues

#  BACKUP AND RESTORE SYSTEM

var backup_config: Dictionary = {}

func create_backup():
	
	backup_config = config_data.duplicate(true)
	print("ConfigService: Configuration backup created")

func restore_backup() -> bool:
	
	if backup_config.is_empty():
		print("ConfigService: No backup available to restore")
		return false

	config_data = backup_config.duplicate(true)
	save_config()
	print("ConfigService: Configuration restored from backup")
	return true

func has_backup() -> bool:
	
	return not backup_config.is_empty()

#  IMPORT/EXPORT FUNCTIONALITY

func export_settings_to_file(file_path: String) -> bool:
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("ConfigService: Failed to create export file: ", file_path)
		return false

	var export_data = {
		"metadata": {
			"exported_at": Time.get_datetime_string_from_system(),
			"config_version": config_data.get("system", {}).get("config_version", "1.0"),
			"game_version": ProjectSettings.get_setting("application/config/version", "1.0")
		},
		"settings": config_data.duplicate(true)
	}

	var json_string = JSON.stringify(export_data, "\t")
	file.store_string(json_string)
	file.close()

	print("ConfigService: Settings exported to: ", file_path)
	return true

func import_settings_from_file(file_path: String) -> Dictionary:
	
	var result = {"success": false, "message": "", "imported_settings": {}}

	if not FileAccess.file_exists(file_path):
		result.message = "Import file not found: " + file_path
		return result

	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		result.message = "Failed to open import file: " + file_path
		return result

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		result.message = "Invalid JSON format in import file"
		return result

	var import_data = json.data
	if not import_data.has("settings"):
		result.message = "Import file missing 'settings' section"
		return result

	# Create backup before importing
	create_backup()

	# Validate and import settings
	var imported_settings = import_data.settings
	var validation_success = import_settings(imported_settings)

	result.success = true
	result.imported_settings = imported_settings
	result.message = "Settings imported successfully"

	if not validation_success:
		result.message += " (with validation corrections)"

	if import_data.has("metadata"):
		var metadata = import_data.metadata
		print("ConfigService: Imported settings from ", metadata.get("exported_at", "unknown date"))
		print("ConfigService: Import config version: ", metadata.get("config_version", "unknown"))

	return result

func export_settings_to_profile(profile_name: String) -> bool:
	
	var profiles_dir = "user://settings_profiles/"
	DirAccess.make_dir_recursive_absolute(profiles_dir)

	var file_path = profiles_dir + profile_name + ".json"
	return export_settings_to_file(file_path)

func import_settings_from_profile(profile_name: String) -> Dictionary:
	
	var profiles_dir = "user://settings_profiles/"
	var file_path = profiles_dir + profile_name + ".json"
	return import_settings_from_file(file_path)

func get_available_profiles() -> Array:
	
	var profiles = []
	var profiles_dir = "user://settings_profiles/"

	var dir = DirAccess.open(profiles_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name.ends_with(".json"):
				var profile_name = file_name.get_basename()
				profiles.append(profile_name)
			file_name = dir.get_next()

	return profiles

func delete_profile(profile_name: String) -> bool:
	
	var profiles_dir = "user://settings_profiles/"
	var file_path = profiles_dir + profile_name + ".json"

	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		print("ConfigService: Deleted profile: ", profile_name)
		return true
	else:
		print("ConfigService: Profile not found: ", profile_name)
		return false

func reset_to_defaults_with_confirmation() -> Dictionary:
	
	var current_config = config_data.duplicate(true)

	# Create backup
	create_backup()

	# Reset to defaults
	config_data = default_config.duplicate(true)
	save_config()

	return {
		"success": true,
		"message": "Settings reset to defaults. Use restore_backup() to undo.",
		"previous_config": current_config
	}

#  BULK OPERATIONS

func reset_to_defaults():
	
	create_backup()
	config_data = default_config.duplicate(true)
	save_config()
	print("ConfigService: Reset to default configuration")

func get_all_settings() -> Dictionary:
	
	return config_data.duplicate(true)

func import_settings(settings: Dictionary) -> bool:
	
	create_backup()
	var temp_config = settings.duplicate(true)
	var validation_issues = {}

	# Validate all imported settings
	for section in temp_config.keys():
		for key in temp_config[section].keys():
			var validation = validate_setting(section, key, temp_config[section][key])
			if not validation.valid:
				if not validation_issues.has(section):
					validation_issues[section] = {}
				validation_issues[section][key] = validation.error

				# Use corrected value if available
				if validation.corrected_value != null:
					temp_config[section][key] = validation.corrected_value

	if not validation_issues.is_empty():
		print("ConfigService: Import had validation issues: ", validation_issues)
		print("ConfigService: Corrected values were used where possible")

	config_data = temp_config
	save_config()
	print("ConfigService: Imported configuration with validation")
	return validation_issues.is_empty()

func get_config_status() -> Dictionary:
	
	return {
		"config_file_exists": FileAccess.file_exists(config_file_path),
		"config_file_path": config_file_path,
		"sections_count": config_data.size(),
		"total_settings": _count_total_settings(),
		"has_backup": has_backup(),
		"validation_issues": validate_all_settings(),
		"available_profiles": get_available_profiles()
	}

func _count_total_settings() -> int:
	
	var count = 0
	for section in config_data.values():
		count += section.size()
	return count
