extends Node

const SERVICE_DEFINITIONS: Array[Dictionary] = [
	{
		"name": "DebugService",
		"path": "res://game/core/services/DebugService.gd",
		"priority": - 100
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
		"name": "AudioService",
		"path": "res://game/core/services/AudioService.gd",
		"priority": - 20
	},
	{
		"name": "TransitionService",
		"path": "res://game/ui/components/TransitionManager.gd",
		"priority": - 10
	},
	{
		"name": "GameFlowController",
		"path": "res://game/core/systems/GameFlowController.gd"
	}
]

var services: Dictionary = {}
var service_load_order: Array[String] = []
var is_manager_ready: bool = false
var _logger: Node = null

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

	if service_name == "DebugService":
		_logger = service_node

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

func get_audio_service():
	return get_service("AudioService")

func get_transition_service():
	return get_service("TransitionService")

func get_resource_library():
	return get_service("ResourceLibrary")

func get_game_flow_controller():
	return get_service("GameFlowController")

func get_scene_controller():
	return get_service("SceneController")

#  CLEANUP

func _exit_tree():
	stop_all_services()
	_log_info("ServiceManager: Cleanup complete")

#  LOGGING HELPERS

func _ensure_logger():
	if _logger:
		return
	_logger = get_service("DebugService")

func _log_info(message: String):
	_ensure_logger()
	if _logger and _logger.has_method("info"):
		_logger.info(message)
	else:
		print("[ServiceManager][INFO] %s" % message)

func _log_error(message: String):
	_ensure_logger()
	if _logger and _logger.has_method("error"):
		_logger.error(message)
	else:
		push_error("ServiceManager: %s" % message)
