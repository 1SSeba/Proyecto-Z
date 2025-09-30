class_name LoggableBehavior
extends RefCounted
# LoggableBehavior - Sistema de logging unificado para todo el proyecto
#
# Esta clase elimina la duplicación de código de logging que estaba presente
# en múltiples servicios, controladores y entidades.
#
# Uso:
#   var _logger := LoggableBehavior.new("MiClase")
#   _logger.log_info("Mensaje informativo")
#   _logger.log_warn("Advertencia")
#   _logger.log_error("Error crítico")

const Log := preload("res://game/core/utils/Logger.gd")

var context_name: String = ""
var enable_push_warnings: bool = true
var enable_push_errors: bool = true

func _init(ctx_name: String = "", push_warnings: bool = true, push_errors: bool = true) -> void:
	context_name = ctx_name
	enable_push_warnings = push_warnings
	enable_push_errors = push_errors

## Registra un mensaje informativo
func log_info(message: String) -> void:
	var formatted := _format_message(message)
	Log.info(formatted)

## Registra una advertencia
func log_warn(message: String) -> void:
	var formatted := _format_message(message)
	Log.warn(formatted)
	if enable_push_warnings:
		push_warning(formatted)

## Registra un error
func log_error(message: String) -> void:
	var formatted := _format_message(message)
	Log.error(formatted)
	if enable_push_errors:
		push_error(formatted)

## Registra un mensaje genérico (log level bajo)
func log(message: String) -> void:
	var formatted := _format_message(message)
	Log.log(formatted)

## Formatea el mensaje con el contexto si está disponible
func _format_message(message: String) -> String:
	if context_name.is_empty():
		return message
	return "%s: %s" % [context_name, message]

## Cambia el contexto del logger
func set_context(new_context: String) -> void:
	context_name = new_context
