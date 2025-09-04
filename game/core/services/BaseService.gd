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
	"""Inicialización base del servicio"""
	print("BaseService: Service %s ready" % service_name)

func start_service():
	"""Inicia el servicio - debe ser implementado por las clases hijas"""
	print("BaseService: Starting service %s" % service_name)
	is_initialized = true
	service_started.emit()

func stop_service():
	"""Detiene el servicio - debe ser implementado por las clases hijas"""
	print("BaseService: Stopping service %s" % service_name)
	is_initialized = false
	service_stopped.emit()

func restart_service():
	"""Reinicia el servicio"""
	print("BaseService: Restarting service %s" % service_name)
	stop_service()
	await get_tree().process_frame
	start_service()

func get_service_name() -> String:
	"""Obtiene el nombre del servicio"""
	return service_name

func is_service_ready() -> bool:
	"""Verifica si el servicio está listo"""
	return is_initialized
