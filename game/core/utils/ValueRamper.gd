class_name ValueRamper
extends RefCounted
# ValueRamper - Sistema de interpolación suave de valores
#
# Permite hacer transiciones suaves (rampas) entre valores actuales y objetivos.
# Útil para volúmenes de audio, opacidades, posiciones, etc.
#
# Uso:
#   var ramper := ValueRamper.new()
#   ramper.set_target("volume", 0.8, 2.0)  # Llegar a 0.8 en 2 segundos
#   ramper.set_current("volume", 0.0)      # Valor inicial
#
#   func _process(delta):
#       var changes := ramper.process(delta)
#       for key in changes:
#           apply_value(key, changes[key])

var _targets: Dictionary = {} # key -> target_value
var _speeds: Dictionary = {} # key -> seconds_to_reach
var _current_values: Dictionary = {} # key -> current_value

## Establece un valor objetivo para una clave con una velocidad de transición
##
## @param key: Identificador único del valor
## @param target: Valor objetivo a alcanzar
## @param speed_seconds: Tiempo en segundos para alcanzar el objetivo
func set_target(key: String, target: float, speed_seconds: float = 0.0) -> void:
	_targets[key] = target
	_speeds[key] = max(0.0, speed_seconds)

	# Si no hay valor actual, usar el objetivo como inicial
	if not _current_values.has(key):
		_current_values[key] = target

## Establece el valor actual de una clave
##
## @param key: Identificador único del valor
## @param current: Valor actual
func set_current(key: String, current: float) -> void:
	_current_values[key] = current

## Obtiene el valor actual de una clave
##
## @param key: Identificador único del valor
## @return: Valor actual, o null si no existe
func get_current(key: String):
	return _current_values.get(key, null)

## Obtiene el valor objetivo de una clave
##
## @param key: Identificador único del valor
## @return: Valor objetivo, o null si no existe
func get_target(key: String):
	return _targets.get(key, null)

## Verifica si una clave tiene un objetivo pendiente
##
## @param key: Identificador único del valor
## @return: true si hay un objetivo activo
func has_target(key: String) -> bool:
	return _targets.has(key)

## Cancela la transición de una clave
##
## @param key: Identificador único del valor
func cancel(key: String) -> void:
	_targets.erase(key)
	_speeds.erase(key)

## Cancela todas las transiciones activas
func cancel_all() -> void:
	_targets.clear()
	_speeds.clear()

## Procesa las transiciones por un frame
##
## @param delta: Tiempo transcurrido desde el último frame
## @return: Dictionary con las claves que cambiaron y sus nuevos valores
func process(delta: float) -> Dictionary:
	var changed := {}
	var to_remove := []

	for key in _targets.keys():
		var target := float(_targets[key])
		var speed := float(_speeds.get(key, 0.0))
		var current := float(_current_values.get(key, target))

		# Calcular el factor de interpolación
		var t := 0.0
		if speed > 0.0:
			t = minf(1.0, delta / speed)
		else:
			t = 1.0 # Cambio instantáneo

		# Interpolar hacia el objetivo
		var next_val := lerpf(current, target, t)

		# Actualizar valor actual
		_current_values[key] = next_val
		changed[key] = next_val

		# Si llegamos al objetivo (con un pequeño margen), remover
		if absf(next_val - target) < 0.001:
			_current_values[key] = target
			changed[key] = target
			to_remove.append(key)

	# Limpiar objetivos alcanzados
	for k in to_remove:
		_targets.erase(k)
		_speeds.erase(k)

	return changed

## Obtiene el número de transiciones activas
##
## @return: Cantidad de claves con objetivos activos
func get_active_count() -> int:
	return _targets.size()

## Verifica si hay alguna transición activa
##
## @return: true si hay al menos una transición en curso
func is_active() -> bool:
	return _targets.size() > 0

## Reinicia el ramper, eliminando todos los valores y objetivos
func reset() -> void:
	_targets.clear()
	_speeds.clear()
	_current_values.clear()
