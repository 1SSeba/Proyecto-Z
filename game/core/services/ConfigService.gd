extends "res://game/core/services/BaseService.gd"
class_name ConfigService

const GAME_SETTINGS_DATA_SCRIPT := preload("res://game/data/settings/GameSettingsData.gd")

const CONFIG_PATH: String = "user://settings.cfg"
const SETTINGS_RESOURCE_PATH: String = "res://game/data/settings/default_game_settings.tres"

var _config_data: Dictionary = {}
var _default_config: Dictionary = {}
var _default_source: String = "hardcoded"

func _ready() -> void:
	super._ready()
	service_name = "ConfigService"

func start_service() -> void:
	super.start_service()
	_load_default_settings()
	_load_config()
	_logger.log_info("Service initialized with %d sections" % _config_data.size())

func stop_service() -> void:
	save_config()
	super.stop_service()

func _load_config() -> void:
	_config_data = _default_config.duplicate(true)

	var file := ConfigFile.new()
	var result := file.load(CONFIG_PATH)

	if result != OK:
		_logger.log_info("Using default configuration")
		save_config()
		return

	for section in file.get_sections():
		if not _config_data.has(section):
			_config_data[section] = {}

		for key in file.get_section_keys(section):
			_config_data[section][key] = file.get_value(section, key)

	_logger.log_info("Configuration loaded from %s" % CONFIG_PATH)

func save_config() -> void:
	var file := ConfigFile.new()

	for section in _config_data.keys():
		for key in _config_data[section].keys():
			file.set_value(section, key, _config_data[section][key])

	var result := file.save(CONFIG_PATH)
	if result != OK:
		_logger.log_error("Failed to save settings to %s" % CONFIG_PATH)
	else:
		_logger.log_info("Configuration saved")

func reset_to_defaults() -> void:
	_load_default_settings()
	_config_data = _default_config.duplicate(true)
	save_config()

func get_all_settings() -> Dictionary:
	return _config_data.duplicate(true)

func get_setting(section: String, key: String, default_value = null):
	if _config_data.has(section) and _config_data[section].has(key):
		return _config_data[section][key]
	return default_value

func set_setting(section: String, key: String, value) -> void:
	if not _config_data.has(section):
		_config_data[section] = {}
	_config_data[section][key] = value

func get_value(section: String, key: String, default_value = null):
	return get_setting(section, key, default_value)

func set_value(section: String, key: String, value) -> void:
	set_setting(section, key, value)

func get_audio_setting(key: String, default_value = null):
	return get_setting("audio", key, default_value)

func set_audio_setting(key: String, value) -> void:
	set_setting("audio", key, value)

func get_video_setting(key: String, default_value = null):
	return get_setting("video", key, default_value)

func set_video_setting(key: String, value) -> void:
	set_setting("video", key, value)

func get_controls_setting(key: String, default_value = null):
	return get_setting("controls", key, default_value)

func set_controls_setting(key: String, value) -> void:
	set_setting("controls", key, value)

func get_service_status() -> Dictionary:
	var status := super.get_service_status()
	status["config_path"] = CONFIG_PATH
	status["sections"] = _config_data.keys()
	status["default_source"] = _default_source
	return status

func _load_default_settings() -> void:
	var source := "hardcoded"
	var defaults := _get_defaults_from_data_service()
	if defaults.is_empty():
		defaults = _get_defaults_from_resource()
		if defaults.is_empty():
			defaults = _get_hardcoded_defaults()
		else:
			source = "resource"
	else:
		source = "service"

	_default_config = defaults
	_default_source = source

func _get_defaults_from_data_service() -> Dictionary:
	if not ServiceManager:
		return {}

	var data_service = ServiceManager.get_data_service()
	if not data_service or not data_service.has_method("get_settings_defaults_dict"):
		return {}

	var defaults: Dictionary = data_service.get_settings_defaults_dict()
	return defaults.duplicate(true)

func _get_defaults_from_resource() -> Dictionary:
	var resource = ResourceLoader.load(SETTINGS_RESOURCE_PATH)
	if resource and resource is Resource:
		if resource.get_script() == GAME_SETTINGS_DATA_SCRIPT and resource.has_method("to_dictionary"):
			return resource.call("to_dictionary")

	return {}

func _get_hardcoded_defaults() -> Dictionary:
	return {
		"audio": {
			"master_volume": 0.8,
			"music_volume": 0.8,
			"sfx_volume": 0.9,
			"spatial_audio": false
		},
		"video": {
			"resolution_index": 2,
			"window_mode_index": 0,
			"fps_index": 1,
			"vsync": true
		},
		"controls": {
			"mouse_sensitivity": 1.0,
			"mouse_invert_x": false,
			"mouse_invert_y": false
		}
	}
