extends "res://game/core/services/BaseService.gd"

const GAME_SETTINGS_DATA_SCRIPT := preload("res://game/data/settings/GameSettingsData.gd")
const GAME_FLOW_DEFINITION_SCRIPT := preload("res://game/data/levels/GameFlowDefinition.gd")

const SETTINGS_RESOURCE_PATH := "res://game/data/settings/default_game_settings.tres"
const GAME_FLOW_RESOURCE_PATH := "res://game/data/levels/game_flow_definition.tres"

var _settings_defaults: Resource = null
var _game_flow_definition: Resource = null
var _resource_cache: Dictionary = {}

func _ready() -> void:
	super._ready()
	service_name = "DataService"

func start_service() -> void:
	super.start_service()
	_logger.log_info("Loading resources...")
	_resource_cache.clear()
	_load_settings_defaults()
	_game_flow_definition = null
	_logger.log_info("Service initialized with %d cached resources" % _resource_cache.size())

func stop_service() -> void:
	_logger.log_info("Shutting down, clearing cache")
	_resource_cache.clear()
	_settings_defaults = null
	_game_flow_definition = null
	super.stop_service()

func reload() -> void:
	_logger.log_info("Reloading resources")
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
	var status := super.get_service_status()
	status["cached_paths"] = _resource_cache.keys()
	status["settings_defaults"] = _settings_defaults != null
	status["game_flow_definition"] = _game_flow_definition != null
	return status

func _load_settings_defaults() -> void:
	var resource := _ensure_cached_resource(SETTINGS_RESOURCE_PATH)
	if not resource:
		_logger.log_error("Unable to load settings defaults at %s" % SETTINGS_RESOURCE_PATH)
		_settings_defaults = null
		return
	if not (resource is Resource):
		_logger.log_error("Resource at %s is not a valid Resource" % SETTINGS_RESOURCE_PATH)
		_settings_defaults = null
		return
	if not _resource_uses_script(resource, GAME_SETTINGS_DATA_SCRIPT):
		_logger.log_warn("Settings defaults loaded with unexpected script, continuing")
	_settings_defaults = resource
	_logger.log_info("Settings defaults ready")

func get_game_flow_definition() -> Resource:
	if _game_flow_definition:
		return _game_flow_definition

	var resource := _ensure_cached_resource(GAME_FLOW_RESOURCE_PATH)
	if resource and resource is Resource:
		if _resource_uses_script(resource, GAME_FLOW_DEFINITION_SCRIPT):
			_game_flow_definition = resource
			_logger.log_info("Game flow definition loaded from resource")
			return _game_flow_definition
		_logger.log_warn("Game flow definition script mismatch, using fallback")
	else:
		_logger.log_warn("Unable to load game flow definition resource, using fallback")

	_game_flow_definition = GAME_FLOW_DEFINITION_SCRIPT.new()
	_logger.log_info("Game flow definition fallback instantiated")
	return _game_flow_definition

func _ensure_cached_resource(path: String) -> Resource:
	if _resource_cache.has(path):
		return _resource_cache[path]

	var loaded := ResourceLoader.load(path)
	if not loaded:
		_logger.log_error("Failed to load resource at %s" % path)
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
