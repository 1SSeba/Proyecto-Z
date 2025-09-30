class_name AudioUtils
# AudioUtils - Utilidades para manejo de audio
#
# Proporciona funciones estáticas para conversiones comunes de audio
# y otras operaciones relacionadas con AudioServer.

## Convierte un valor lineal (0.0 a 1.0) a decibelios
##
## @param linear: Valor lineal de volumen (0.0 = silencio, 1.0 = máximo)
## @return: Valor en decibelios (-80.0 a 0.0)
static func linear_to_db(linear: float) -> float:
	linear = clampf(linear, 0.0, 1.0)

	# Valores muy bajos se consideran silencio
	if linear <= 0.0001:
		return -80.0

	# Fórmula: dB = 20 * log10(linear)
	return 20.0 * (log(linear) / log(10.0))

## Convierte un valor en decibelios a lineal (0.0 a 1.0)
##
## @param db: Valor en decibelios (típicamente -80.0 a 0.0)
## @return: Valor lineal de volumen (0.0 a 1.0)
static func db_to_linear(db: float) -> float:
	# Fórmula: linear = 10^(dB/20)
	var linear := pow(10.0, db / 20.0)
	return clampf(linear, 0.0, 1.0)

## Normaliza un valor de volumen que puede venir en formato 0-1 o 0-100
##
## @param value: Valor a normalizar (puede ser float o int)
## @return: Valor normalizado en rango 0.0 a 1.0
static func normalize_volume(value) -> float:
	if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
		var v := float(value)
		# Si el valor es mayor a 1, asumimos que está en escala 0-100
		if v > 1.0:
			v = clampf(v / 100.0, 0.0, 1.0)
		else:
			v = clampf(v, 0.0, 1.0)
		return v

	# Si no es un número, retornar volumen máximo por defecto
	return 1.0

## Obtiene el índice de un bus de audio por nombre
##
## @param bus_name: Nombre del bus a buscar
## @return: Índice del bus, o -1 si no se encuentra
static func get_bus_index(bus_name: String) -> int:
	# Búsqueda exacta primero
	for i in range(AudioServer.get_bus_count()):
		if AudioServer.get_bus_name(i) == bus_name:
			return i

	# Fallback: búsqueda case-insensitive
	var lower_name := bus_name.to_lower()
	for i in range(AudioServer.get_bus_count()):
		if AudioServer.get_bus_name(i).to_lower() == lower_name:
			return i

	return -1

## Aplica un volumen lineal a un bus de audio específico
##
## @param bus_name: Nombre del bus
## @param linear_volume: Volumen lineal (0.0 a 1.0)
## @return: true si se aplicó correctamente, false si el bus no existe
static func set_bus_volume(bus_name: String, linear_volume: float) -> bool:
	var bus_index := get_bus_index(bus_name)
	if bus_index < 0:
		return false

	var db := linear_to_db(linear_volume)
	AudioServer.set_bus_volume_db(bus_index, db)
	return true

## Obtiene el volumen lineal actual de un bus de audio
##
## @param bus_name: Nombre del bus
## @return: Volumen lineal (0.0 a 1.0), o -1.0 si el bus no existe
static func get_bus_volume(bus_name: String) -> float:
	var bus_index := get_bus_index(bus_name)
	if bus_index < 0:
		return -1.0

	var db := AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)
