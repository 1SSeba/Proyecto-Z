extends Node

const GAME_SETTINGS_DATA_SCRIPT := preload("res://game/data/settings/GameSettingsData.gd")

var service_name: String = "ConfigService"
var is_service_ready: bool = false
var _logger: Node = null

const CONFIG_PATH: String = "user://settings.cfg"
const SETTINGS_RESOURCE_PATH: String = "res://game/data/settings/default_game_settings.tres"

var _config_data: Dictionary = {}
var _default_config: Dictionary = {}
var _default_source: String = "hardcoded"

func start_service() -> void:
	_load_logger()
	_load_default_settings()
	_load_config()
	is_service_ready = true
	_log_info("ConfigService: Service initialized")

func stop_service() -> void:
	save_config()
	is_service_ready = false

func is_service_available() -> bool:
	return is_service_ready

func _load_config() -> void:
	_config_data = _default_config.duplicate(true)

	var file := ConfigFile.new()
	var result := file.load(CONFIG_PATH)

	if result != OK:
		_log_info("ConfigService: Using default configuration")
		save_config()
		return

	for section in file.get_sections():
		if not _config_data.has(section):
			_config_data[section] = {}

		for key in file.get_section_keys(section):
			_config_data[section][key] = file.get_value(section, key)

	_log_info("ConfigService: Configuration loaded from %s" % CONFIG_PATH)

func save_config() -> void:
	var file := ConfigFile.new()

	for section in _config_data.keys():
		for key in _config_data[section].keys():
			file.set_value(section, key, _config_data[section][key])

	var result := file.save(CONFIG_PATH)
	if result != OK:
		_log_error("ConfigService: Failed to save settings (%s)" % CONFIG_PATH)
	else:
		_log_info("ConfigService: Configuration saved")

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
	return {
		"config_path": CONFIG_PATH,
		"sections": _config_data.keys(),
		"ready": is_service_ready,
		"default_source": _default_source
	}

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

func _load_logger() -> void:
	if _logger:
		return
	if ServiceManager and ServiceManager.has_service("DebugService"):
		_logger = ServiceManager.get_service("DebugService")

func _log_info(message: String) -> void:
	if _logger and _logger.has_method("info"):
		_logger.info(message)
	else:
		print("[ConfigService][INFO] %s" % message)

func _log_error(message: String) -> void:
	if _logger and _logger.has_method("error"):
		_logger.error(message)
	else:
		push_error("ConfigService: %s" % message)
