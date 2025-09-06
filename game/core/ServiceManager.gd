extends Node

## Service Manager
## Coordinates all game services with professional lifecycle management
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  SERVICE REGISTRY
# ============================================================================

var services: Dictionary = {}
var service_load_order: Array[String] = []
var is_manager_ready: bool = false

# ============================================================================
#  LIFECYCLE
# ============================================================================

func _ready():
	print("ServiceManager: Starting service initialization...")
	await _initialize_services()
	is_manager_ready = true
	print("ServiceManager: All services initialized successfully")

func _initialize_services():
	"""Initialize all game services in correct order"""
	# Define service load order (dependencies first)
	service_load_order = [
		"ConfigService",
		"InputService", 
		"AudioService",
		"TransitionService"
	]
	
	# Load each service
	for service_name in service_load_order:
		await _load_service(service_name)

func _load_service(service_name: String):
	"""Load and initialize a specific service"""
	print("ServiceManager: Loading %s..." % service_name)
	
	var service_node = _create_service(service_name)
	if service_node:
		services[service_name] = service_node
		add_child(service_node)
		
		# Wait for service to be ready
		if service_node.has_method("start_service"):
			await service_node.start_service()
		
		print("ServiceManager: %s loaded successfully" % service_name)
	else:
		print("ServiceManager: Failed to create %s" % service_name)

func _create_service(service_name: String) -> Node:
	"""Create a service instance"""
	match service_name:
		"ConfigService":
			var script = load("res://game/core/services/ConfigService.gd")
			var service = script.new()
			service.service_name = "ConfigService"
			return service
		"InputService":
			var script = load("res://game/core/services/InputService.gd")
			var service = script.new()
			service.service_name = "InputService"
			return service
		"AudioService":
			var script = load("res://game/core/services/AudioService.gd")
			var service = script.new()
			service.service_name = "AudioService"
			return service
		"TransitionService":
			var script = load("res://game/ui/components/TransitionManager.gd")
			var service = script.new()
			service.service_name = "TransitionService"
			return service
		_:
			print("ServiceManager: Unknown service: %s" % service_name)
			return null

# ============================================================================
#  SERVICE ACCESS
# ============================================================================

func get_service(service_name: String) -> Node:
	"""Get a service by name"""
	return services.get(service_name, null)

func has_service(service_name: String) -> bool:
	"""Check if a service exists"""
	return services.has(service_name)

func is_service_ready(service_name: String) -> bool:
	"""Check if a service is ready"""
	var service = get_service(service_name)
	if not service:
		return false
	
	if service.has_method("is_service_available"):
		return service.is_service_available()
	
	return true

func are_services_ready() -> bool:
	"""Check if all services are ready"""
	if not is_manager_ready:
		return false
	
	for service_name in service_load_order:
		if not is_service_ready(service_name):
			return false
	
	return true

# ============================================================================
#  SERVICE MANAGEMENT
# ============================================================================

func restart_service(service_name: String):
	"""Restart a specific service"""
	var service = get_service(service_name)
	if service and service.has_method("stop_service"):
		service.stop_service()
		await service.start_service()

func stop_all_services():
	"""Stop all services"""
	for service in services.values():
		if service.has_method("stop_service"):
			service.stop_service()

# ============================================================================
#  STATUS AND DEBUGGING
# ============================================================================

func get_all_services_status() -> Dictionary:
	"""Get status of all services"""
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
	"""Print status of all services"""
	print("=== SERVICE MANAGER STATUS ===")
	print("Manager Ready: %s" % is_manager_ready)
	print("Services Loaded: %d" % services.size())
	print("")
	
	for service_name in service_load_order:
		var ready_status = "READY" if is_service_ready(service_name) else "NOT READY"
		print("%s: %s" % [service_name, ready_status])
	
	print("===============================")

# ============================================================================
#  CONVENIENCE METHODS
# ============================================================================

func get_config_service():
	"""Get ConfigService instance"""
	return get_service("ConfigService")

func get_input_service():
	"""Get InputService instance"""
	return get_service("InputService")

func get_audio_service():
	"""Get AudioService instance"""
	return get_service("AudioService")

func get_transition_service():
	"""Get TransitionService instance"""
	return get_service("TransitionService")

# ============================================================================
#  CLEANUP
# ============================================================================

func _exit_tree():
	stop_all_services()
	print("ServiceManager: Cleanup complete")
