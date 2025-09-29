extends Node

const GAME_SETTINGS_DATA_SCRIPT := preload("res://game/data/settings/GameSettingsData.gd")
const GAME_FLOW_DEFINITION_SCRIPT := preload("res://game/data/levels/GameFlowDefinition.gd")
const Log := preload("res://game/core/utils/Logger.gd")

const SETTINGS_RESOURCE_PATH := "res://game/data/settings/default_game_settings.tres"
const GAME_FLOW_RESOURCE_PATH := "res://game/data/levels/game_flow_definition.tres"

var service_name: String = "DataService"
var is_service_ready: bool = false

var _settings_defaults: Resource = null
var _game_flow_definition: Resource = null
var _resource_cache: Dictionary = {}

func start_service() -> void:
	_log_info("DataService: Loading resources")
	_resource_cache.clear()
	_load_settings_defaults()
	_game_flow_definition = null
	is_service_ready = true
	_log_info("DataService: Service initialized")

func stop_service() -> void:
	_log_info("DataService: Shutting down")
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
			var duplicated = _settings_defaults.call("duplicate_settings")
			if duplicated:
				return duplicated
		return _settings_defaults.duplicate(true)
	return null

func get_settings_defaults_dict() -> Dictionary:
	if _settings_defaults and _settings_defaults.has_method("to_dictionary"):
		return _settings_defaults.to_dictionary()
	return {}

func get_resource(path: String, duplicate_instance: bool = false) -> Resource:
	var resource := _ensure_cached_resource(path)
	if not resource:
		return null
	if duplicate_instance and resource is Resource:
		return resource.duplicate(true)
	return resource

func get_service_status() -> Dictionary:
	return {
		"ready": is_service_ready,
		"cached_paths": _resource_cache.keys(),
		"settings_defaults": _settings_defaults != null,
		"game_flow_definition": _game_flow_definition != null
	}

func _load_settings_defaults() -> void:
	var resource := _ensure_cached_resource(SETTINGS_RESOURCE_PATH)
	if not resource:
		_log_error("DataService: Unable to load settings defaults at %s" % SETTINGS_RESOURCE_PATH)
		_settings_defaults = null
		return
	if not (resource is Resource):
		_log_error("DataService: Resource at %s is not a valid Resource" % SETTINGS_RESOURCE_PATH)
		_settings_defaults = null
		return
	if not _resource_uses_script(resource, GAME_SETTINGS_DATA_SCRIPT):
		_log_warn("DataService: Settings defaults loaded with unexpected script, continuing with loaded resource")
	_settings_defaults = resource
	_log_info("DataService: Settings defaults ready")

func get_game_flow_definition() -> Resource:
	if _game_flow_definition:
		return _game_flow_definition

	var resource := _ensure_cached_resource(GAME_FLOW_RESOURCE_PATH)
	if resource and resource is Resource:
		if _resource_uses_script(resource, GAME_FLOW_DEFINITION_SCRIPT):
			_game_flow_definition = resource
			_log_info("DataService: Game flow definition loaded from resource")
			return _game_flow_definition
		_log_warn("DataService: Game flow definition script mismatch, using fallback")
	else:
		_log_warn("DataService: Unable to load game flow definition resource, using fallback")

	_game_flow_definition = GAME_FLOW_DEFINITION_SCRIPT.new()
	_log_info("DataService: Game flow definition fallback instantiated")
	return _game_flow_definition

func _ensure_cached_resource(path: String) -> Resource:
	if _resource_cache.has(path):
		return _resource_cache[path]

	var loaded := ResourceLoader.load(path)
	if not loaded:
		_log_error("DataService: Failed to load resource at %s" % path)
		return null

	_resource_cache[path] = loaded
	return loaded

func _resource_uses_script(resource: Resource, expected_script: Script) -> bool:
	if not resource:
		return false

	var script: Script = resource.get_script()
	if not script:
		return false

	if script == expected_script:
		return true

	if script.resource_path != "" and script.resource_path == expected_script.resource_path:
		return true

	return false

func _log_info(message: String) -> void:
	Log.info(message)

func _log_error(message: String) -> void:
	Log.error(message)
	push_error(message)

func _log_warn(message: String) -> void:
	Log.warn(message)
