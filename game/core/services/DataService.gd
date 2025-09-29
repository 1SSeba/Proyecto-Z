extends Node

const GAME_SETTINGS_DATA_SCRIPT := preload("res://game/data/settings/GameSettingsData.gd")
const GAME_FLOW_DEFINITION_SCRIPT := preload("res://game/data/levels/GameFlowDefinition.gd")

const SETTINGS_RESOURCE_PATH := "res://game/data/settings/default_game_settings.tres"
const GAME_FLOW_RESOURCE_PATH := "res://game/data/levels/game_flow_definition.tres"

var service_name: String = "DataService"
var is_service_ready: bool = false

var _logger: Node = null
var _settings_defaults: Resource = null
var _game_flow_definition: Resource = null
var _resource_cache: Dictionary = {}

func start_service() -> void:
	_load_logger()
	_load_settings_defaults()
	is_service_ready = true
	_log_info("DataService: Service initialized")

func stop_service() -> void:
	_resource_cache.clear()
	_settings_defaults = null
	_game_flow_definition = null
	is_service_ready = false

func is_service_available() -> bool:
	return is_service_ready

func reload() -> void:
	_log_info("DataService: Reloading resources")
	_resource_cache.clear()
	_load_settings_defaults()
	_game_flow_definition = null

func get_settings_defaults() -> Resource:
	if _settings_defaults:
		if _settings_defaults.has_method("duplicate_settings"):
			return _settings_defaults.call("duplicate_settings")
		return _settings_defaults.duplicate(true)
	return null

func get_settings_defaults_dict() -> Dictionary:
	if _settings_defaults and _settings_defaults.has_method("to_dictionary"):
		return _settings_defaults.to_dictionary()
	return {}

func get_resource(path: String, duplicate_instance: bool = false):
	if not _resource_cache.has(path):
		var loaded := ResourceLoader.load(path)
		if loaded:
			_resource_cache[path] = loaded
		else:
			_log_error("DataService: Failed to load resource %s" % path)
			return null

	var resource = _resource_cache[path]
	if duplicate_instance and resource and resource is Resource:
		return resource.duplicate()
	return resource

func get_service_status() -> Dictionary:
	return {
		"ready": is_service_ready,
		"cached_paths": _resource_cache.keys(),
		"settings_defaults": _settings_defaults != null,
		"game_flow_definition": _game_flow_definition != null
	}

func _load_settings_defaults() -> void:
	var resource = get_resource(SETTINGS_RESOURCE_PATH, true)
	if resource and resource is Resource:
		if resource.get_script() != GAME_SETTINGS_DATA_SCRIPT:
			_log_warn("DataService: Settings defaults loaded with unexpected script, attempting to continue")
		_settings_defaults = resource
		_log_info("DataService: Settings defaults loaded")
	elif resource:
		_log_error("DataService: Resource at %s is not GameSettingsData" % SETTINGS_RESOURCE_PATH)
	else:
		_log_error("DataService: Unable to load settings defaults")

func get_game_flow_definition() -> Resource:
	if _game_flow_definition:
		return _game_flow_definition

	var resource = get_resource(GAME_FLOW_RESOURCE_PATH)
	if resource and resource is GAME_FLOW_DEFINITION_SCRIPT:
		_game_flow_definition = resource
		return _game_flow_definition

	_log_warn("DataService: Falling back to default GameFlowDefinition")
	_game_flow_definition = GAME_FLOW_DEFINITION_SCRIPT.new()
	return _game_flow_definition

func _load_logger() -> void:
	if _logger:
		return
	if ServiceManager and ServiceManager.has_service("DebugService"):
		_logger = ServiceManager.get_service("DebugService")

func _log_info(message: String) -> void:
	if _logger and _logger.has_method("info"):
		_logger.info(message)
	else:
		print("[DataService][INFO] %s" % message)

func _log_error(message: String) -> void:
	if _logger and _logger.has_method("error"):
		_logger.error(message)
	else:
		push_error("DataService: %s" % message)

func _log_warn(message: String) -> void:
	if _logger and _logger.has_method("warn"):
		_logger.warn(message)
	else:
		push_warning("DataService: %s" % message)
