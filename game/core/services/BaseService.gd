class_name BaseService
extends Node
# BaseService - Clase base para todos los servicios del juego
#
# Proporciona funcionalidad común a todos los servicios:
# - Gestión de estado de inicialización
# - Interfaz estándar de ciclo de vida
# - Sistema de logging integrado
#
# Los servicios que hereden de BaseService deben:
# 1. Llamar a super.start_service() al inicio de su start_service()
# 2. Llamar a super.stop_service() al final de su stop_service()
# 3. Usar _logger para todos los mensajes de log

const LoggableBehavior := preload("res://game/core/utils/LoggableBehavior.gd")

var service_name: String = ""
var is_service_ready: bool = false

var _logger: LoggableBehavior

func _init() -> void:
	_logger = LoggableBehavior.new()

func _ready() -> void:
	# Configurar el logger con el nombre del servicio
	if not service_name.is_empty():
		_logger.set_context(service_name)

## Inicia el servicio. Los servicios hijos deben llamar a super.start_service()
func start_service() -> void:
	if is_service_ready:
		_logger.log_warn("Service already started, ignoring duplicate start_service() call")
		return

	is_service_ready = true

	# Actualizar el contexto del logger si el nombre cambió
	if not service_name.is_empty():
		_logger.set_context(service_name)

## Detiene el servicio. Los servicios hijos deben llamar a super.stop_service()
func stop_service() -> void:
	if not is_service_ready:
		_logger.log_warn("Service already stopped, ignoring duplicate stop_service() call")
		return

	is_service_ready = false

## Verifica si el servicio está disponible para uso
func is_service_available() -> bool:
	return is_service_ready

## Retorna el estado actual del servicio
func get_service_status() -> Dictionary:
	return {
		"name": service_name,
		"ready": is_service_ready,
		"available": is_service_available()
	}

## Reinicia el servicio (detiene y vuelve a iniciar)
func restart_service() -> void:
	_logger.log_info("Restarting service")
	stop_service()
	await get_tree().process_frame
	start_service()
