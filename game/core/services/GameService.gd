extends Node
# GameService.gd - Servicio central del juego

## Base Game Service Class
## Professional service architecture for indie/roguelike games
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  SERVICE BASE INTERFACE
# ============================================================================

signal service_ready()
# Variables principales
var game_state: String = "idle"
var current_level: String = ""

# Señales
# TODO: Implementar cuando sean necesarias
# signal game_started
# signal game_paused  
# signal game_resumed
# signal service_error(error: String)

# ============================================================================
#  CORE PROPERTIES
# ============================================================================

@export var service_name: String = ""
@export var auto_start: bool = true

var is_service_ready: bool = false
var service_dependencies: Array[Node] = []

# ============================================================================
#  LIFECYCLE
# ============================================================================

func _ready():
	if auto_start:
		await start_service()

func start_service():
	"""Start this service - Override in child classes"""
	if is_service_ready:
		return
	
	# Wait for dependencies
	await _wait_for_service_dependencies()
	
	# Service-specific initialization
	await _start()
	
	is_service_ready = true
	service_ready.emit()

func _start():
	"""Service-specific initialization - Override in child classes"""
	pass

func stop_service():
	"""Stop this service"""
	_stop()
	is_service_ready = false

func _stop():
	"""Service-specific cleanup - Override in child classes"""
	pass

# ============================================================================
#  DEPENDENCY MANAGEMENT
# ============================================================================

func add_service_dependency(service: Node):
	"""Add a service dependency"""
	if service and service not in service_dependencies:
		service_dependencies.append(service)

func _wait_for_service_dependencies():
	"""Wait for all service dependencies to be ready"""
	for dependency in service_dependencies:
		if dependency and not dependency.is_service_ready:
			await dependency.service_ready

# ============================================================================
#  SERVICE STATE
# ============================================================================

func get_service_status() -> Dictionary:
	"""Get service status information"""
	return {
		"name": service_name,
		"ready": is_service_ready,
		"dependencies_count": service_dependencies.size()
	}

func is_service_available() -> bool:
	"""Check if service is available for use"""
	return is_service_ready
