extends RefCounted
class_name SettingsModel

signal settings_loaded(data: Dictionary)
signal settings_changed(section: String, key: String, value)
signal settings_reset(data: Dictionary)
signal settings_applied(data: Dictionary)

var _config_service: Node = null
var _data_service: Node = null
var _current_settings: Dictionary = {}
var _default_settings: Dictionary = {}
var _dirty_map: Dictionary = {}

const GAME_SETTINGS_DATA_SCRIPT := preload("res://game/data/settings/GameSettingsData.gd")

func setup(config_service: Node, data_service: Node) -> void:
	_config_service = config_service
	_data_service = data_service
	_load_default_settings()
	_load_from_config()

func _load_default_settings() -> void:
	_default_settings = {}
	if _data_service and _data_service.has_method("get_settings_defaults_dict"):
		var defaults: Dictionary = _data_service.get_settings_defaults_dict()
		if not defaults.is_empty():
			_default_settings = defaults.duplicate(true)

	if _default_settings.is_empty():
		var fallback := GAME_SETTINGS_DATA_SCRIPT.new()
		_default_settings = fallback.to_dictionary()

func _load_from_config() -> void:
	if _config_service and _config_service.has_method("get_all_settings"):
		var loaded: Dictionary = _config_service.get_all_settings()
		_current_settings = _merge_defaults(_default_settings, loaded)
	else:
		_current_settings = _default_settings.duplicate(true)
	_dirty_map.clear()
	settings_loaded.emit(_current_settings.duplicate(true))

func get_all_settings() -> Dictionary:
	return _current_settings.duplicate(true)

func get_section(section: String) -> Dictionary:
	return _current_settings.get(section, {}).duplicate(true)

func get_value(section: String, key: String, default_value = null):
	if _current_settings.has(section) and _current_settings[section].has(key):
		return _current_settings[section][key]
	return default_value

func set_value(section: String, key: String, value) -> void:
	if not _current_settings.has(section):
		_current_settings[section] = {}

	if _current_settings[section].get(key) == value:
		return

	_current_settings[section][key] = value
	_mark_dirty(section, key)
	settings_changed.emit(section, key, value)

func reset_to_defaults() -> void:
	_current_settings = _default_settings.duplicate(true)
	_dirty_map.clear()
	settings_reset.emit(_current_settings.duplicate(true))

func is_dirty() -> bool:
	return not _dirty_map.is_empty()

func get_dirty_sections() -> Array:
	return _dirty_map.keys()

func apply_changes() -> void:
	if not _config_service:
		return

	for section in _current_settings.keys():
		for key in _current_settings[section].keys():
			if _config_service.has_method("set_value"):
				_config_service.set_value(section, key, _current_settings[section][key])

	if _config_service.has_method("save_config"):
		_config_service.save_config()

	_dirty_map.clear()
	settings_applied.emit(_current_settings.duplicate(true))

func reload() -> void:
	_load_from_config()

func get_defaults() -> Dictionary:
	return _default_settings.duplicate(true)

func _mark_dirty(section: String, key: String) -> void:
	if not _dirty_map.has(section):
		_dirty_map[section] = {}
	_dirty_map[section][key] = true

func _merge_defaults(defaults: Dictionary, overrides: Dictionary) -> Dictionary:
	var merged := defaults.duplicate(true)
	for section in overrides.keys():
		if not merged.has(section):
			merged[section] = {}
		for key in overrides[section].keys():
			merged[section][key] = overrides[section][key]
	return merged
