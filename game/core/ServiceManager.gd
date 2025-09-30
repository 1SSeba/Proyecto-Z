extends Node

const Log := preload("res://game/core/utils/Logger.gd")

const SERVICE_DEFINITIONS: Array[Dictionary] = [
	{
		"name": "DebugService",
		"path": "res://game/core/services/DebugService.gd",
		"priority": - 100
	},
	{
		"name": "DataService",
		"path": "res://game/core/services/DataService.gd",
		"priority": - 75
	},
	{
		"name": "ConfigService",
		"path": "res://game/core/services/ConfigService.gd",
		"priority": - 50
	},
	{
		"name": "ResourceLibrary",
		"path": "res://game/core/services/ResourceLibrary.gd",
		"priority": - 40
	},
	{
		"name": "InputService",
		"path": "res://game/core/services/InputService.gd",
		"priority": - 30
	},
	{
		"name": "GameFlowController",
		"path": "res://game/core/systems/GameFlowController.gd"
	}
]

const DEFAULT_WAIT_FRAMES := 240

var services: Dictionary = {}
var service_load_order: Array[String] = []
var is_manager_ready: bool = false

signal services_initialized

func _ready():
	_log_info("ServiceManager: Starting service initialization...")
	await _initialize_services()
	is_manager_ready = true
	_log_info("ServiceManager: All services initialized successfully")

func _initialize_services():
	var ordered_definitions := SERVICE_DEFINITIONS.duplicate()
	ordered_definitions.sort_custom(Callable(self, "_compare_services"))

	service_load_order.clear()

	for definition in ordered_definitions:
		var service_name: String = String(definition.get("name", ""))
		var loaded := await _load_service(definition)
		if loaded:
			service_load_order.append(service_name)

	services_initialized.emit()

func _compare_services(a: Dictionary, b: Dictionary) -> bool:
	var priority_a: int = int(a.get("priority", 0))
	var priority_b: int = int(b.get("priority", 0))
	if priority_a == priority_b:
		return String(a.get("name", "")) < String(b.get("name", ""))
	return priority_a < priority_b

func _load_service(definition: Dictionary) -> bool:
	var service_name: String = String(definition.get("name", ""))
	_log_info("Loading %s..." % service_name)

	var service_node = _create_service(definition)
	if not service_node:
		_log_error("Failed to create %s" % service_name)
		return false

	services[service_name] = service_node
	add_child(service_node)

	if service_node.has_method("start_service"):
		await service_node.start_service()

	_log_info("%s loaded successfully" % service_name)
	return true

func _create_service(definition: Dictionary) -> Node:
	var service_name: String = String(definition.get("name", ""))
	if not definition.has("path"):
		_log_error("Service definition for %s is missing path" % service_name)
		return null

	var script: Script = load(definition.get("path", ""))
	if not script:
		_log_error("Unable to load script for service %s from %s" % [service_name, definition.get("path", "")])
		return null

	var instance = script.new()

	if instance is Node:
		if "service_name" in instance:
			instance.service_name = service_name
		instance.name = service_name
	else:
		_log_error("Service %s does not extend Node" % service_name)
		return null

	return instance

#  SERVICE ACCESS

func get_service(service_name: String) -> Node:
	return services.get(service_name, null)

func has_service(service_name: String) -> bool:
	return services.has(service_name)

func is_service_ready(service_name: String) -> bool:
	var service = get_service(service_name)
	if not service:
		return false

	if service.has_method("is_service_available"):
		return service.is_service_available()

	return true

func are_services_ready() -> bool:
	if not is_manager_ready:
		return false

	for service_name in service_load_order:
		if not is_service_ready(service_name):
			return false

	return true

#  SERVICE WAIT HELPERS

func wait_for_service(service_name: StringName, timeout_frames: int = DEFAULT_WAIT_FRAMES) -> Node:
	var frames_elapsed := 0
	var service_key := String(service_name)
	while frames_elapsed < timeout_frames:
		var service := get_service(service_key)
		if service and is_service_ready(service_key):
			return service
		await get_tree().process_frame
		frames_elapsed += 1

	var fallback := get_service(service_key)
	if fallback:
		if not is_service_ready(service_key):
			_log_warn("ServiceManager: wait_for_service(%s) timed out before service reported ready" % service_name)
		return fallback

	_log_warn("ServiceManager: wait_for_service(%s) timed out and service was not found" % service_name)
	return null

func wait_for_services(service_names: Array, timeout_frames: int = DEFAULT_WAIT_FRAMES) -> Dictionary:
	var normalized: Array[String] = []
	for service_name in service_names:
		normalized.append(String(service_name))

	var resolved: Dictionary = {}
	var frames_elapsed := 0
	while frames_elapsed < timeout_frames and resolved.size() < normalized.size():
		for service_name in normalized:
			if resolved.has(service_name):
				continue
			var service := get_service(service_name)
			if service and is_service_ready(service_name):
				resolved[service_name] = service
		await get_tree().process_frame
		frames_elapsed += 1

	for service_name in normalized:
		if resolved.has(service_name):
			continue
		var service := get_service(service_name)
		if service:
			resolved[service_name] = service
			if not is_service_ready(service_name):
				_log_warn("ServiceManager: wait_for_services timed out waiting for %s to report ready" % service_name)
		else:
			_log_warn("ServiceManager: wait_for_services could not locate %s" % service_name)

	return resolved

func wait_until_ready(timeout_frames: int = DEFAULT_WAIT_FRAMES) -> bool:
	var frames_elapsed := 0
	while frames_elapsed < timeout_frames:
		if are_services_ready():
			return true
		await get_tree().process_frame
		frames_elapsed += 1

	if not are_services_ready():
		_log_warn("ServiceManager: wait_until_ready timed out with pending services")
	return are_services_ready()

#  SERVICE MANAGEMENT

func restart_service(service_name: String):
	var service = get_service(service_name)
	if service and service.has_method("stop_service"):
		service.stop_service()
		await service.start_service()

func stop_all_services():
	for service in services.values():
		if service.has_method("stop_service"):
			service.stop_service()

#  STATUS AND DEBUGGING

func get_all_services_status() -> Dictionary:
	var status = {}

	for service_name in services.keys():
		var service = services[service_name]
		status[service_name] = {
			"exists": service != null,
			"ready": is_service_ready(service_name)
		}

		if service and service.has_method("get_service_status"):
			status[service_name]["details"] = service.get_service_status()

	return status

func print_services_status():
	_log_info("=== SERVICE MANAGER STATUS ===")
	_log_info("Manager Ready: %s" % is_manager_ready)
	_log_info("Services Loaded: %d" % services.size())

	for service_name in service_load_order:
		var ready_status = "READY" if is_service_ready(service_name) else "NOT READY"
		_log_info("%s: %s" % [service_name, ready_status])

	_log_info("===============================")

#  CONVENIENCE METHODS

func get_config_service():
	return get_service("ConfigService")

func get_input_service():
	return get_service("InputService")

func get_game_flow_controller():
	return get_service("GameFlowController")

func get_data_service():
	return get_service("DataService")

#  CLEANUP

func _exit_tree():
	stop_all_services()
	_log_info("ServiceManager: Cleanup complete")

#  LOGGING HELPERS
func _log_info(message: String):
	Log.info(message)

func _log_warn(message: String):
	Log.warn(message)
	push_warning(message)

func _log_error(message: String):
	Log.error(message)
	push_error(message)
