extends Node
class_name BaseService
# BaseService.gd - Clase base para todos los servicios del juego

# Propiedades del servicio
var service_name: String = ""
var is_initialized: bool = false

# Señales
signal service_started
signal service_stopped
# signal service_error(error: String) # TODO: Implementar cuando sea necesario

func _ready():
	pass
	print("BaseService: Service %s ready" % service_name)

func start_service():
	pass
	print("BaseService: Starting service %s" % service_name)
	is_initialized = true
	service_started.emit()

func stop_service():
	pass
	print("BaseService: Stopping service %s" % service_name)
	is_initialized = false
	service_stopped.emit()

func restart_service():
	pass
	print("BaseService: Restarting service %s" % service_name)
	stop_service()
	await get_tree().process_frame
	start_service()

func get_service_name() -> String:
	pass
	return service_name

func is_service_ready() -> bool:
	pass
	return is_initialized
