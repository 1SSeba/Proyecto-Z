extends Node

# Sistema de eventos simple y funcional
# Bus global para comunicación entre componentes

# Listeners organizados por tipo de evento
var listeners: Dictionary = {}

# Configuración
var debug_mode: bool = false
var max_events_history: int = 100

# Historial de eventos (para debugging)
var event_history: Array = []

# Señales principales
signal event_dispatched(event_type: String, data: Dictionary)

func _ready():
	if debug_mode:
		print("📡 EventBus initialized")

# Suscribirse a un tipo de evento
func subscribe(event_type: String, listener: Callable) -> bool:
	if not listeners.has(event_type):
		listeners[event_type] = []
	
	# Evitar duplicados
	if listener in listeners[event_type]:
		if debug_mode:
			push_warning("EventBus: Listener already subscribed to %s" % event_type)
		return false
	
	listeners[event_type].append(listener)
	
	if debug_mode:
		print("📋 EventBus: Subscribed to %s" % event_type)
	
	return true

# Desuscribirse de un tipo de evento
func unsubscribe(event_type: String, listener: Callable) -> bool:
	if not listeners.has(event_type):
		return false
	
	if listener in listeners[event_type]:
		listeners[event_type].erase(listener)
		
		# Limpiar si no hay más listeners
		if listeners[event_type].is_empty():
			listeners.erase(event_type)
		
		if debug_mode:
			print("🗑️ EventBus: Unsubscribed from %s" % event_type)
		
		return true
	
	return false

# Publicar un evento
func publish(event_type: String, data: Dictionary = {}) -> bool:
	# Añadir al historial
	_add_to_history(event_type, data)
	
	# Emitir señal principal
	event_dispatched.emit(event_type, data)
	
	# Notificar a listeners específicos
	if listeners.has(event_type):
		for listener in listeners[event_type]:
			if listener.is_valid():
				listener.call(data)
			else:
				if debug_mode:
					push_warning("EventBus: Invalid listener found for %s" % event_type)
	
	if debug_mode:
		print("📤 EventBus: Published %s with %d listeners" % [event_type, listeners.get(event_type, []).size()])
	
	return true

# Métodos de conveniencia para eventos comunes
func publish_game_started(data: Dictionary = {}):
	publish("game_started", data)

func publish_game_paused(data: Dictionary = {}):
	publish("game_paused", data)

func publish_game_resumed(data: Dictionary = {}):
	publish("game_resumed", data)

func publish_player_died(data: Dictionary = {}):
	publish("player_died", data)

func publish_player_health_changed(health: float, max_health: float = 100.0):
	publish("player_health_changed", {"health": health, "max_health": max_health})

func publish_state_changed(from_state: String, to_state: String):
	publish("state_changed", {"from": from_state, "to": to_state})

func publish_level_completed(level_name: String = ""):
	publish("level_completed", {"level": level_name})

# Historial y debugging
func _add_to_history(event_type: String, data: Dictionary):
	var event_record = {
		"type": event_type,
		"data": data,
		"timestamp": Time.get_time_dict_from_system()
	}
	
	event_history.append(event_record)
	
	# Mantener solo los últimos eventos
	if event_history.size() > max_events_history:
		event_history.pop_front()

func get_recent_events(count: int = 10) -> Array:
	"""Obtiene los eventos más recientes"""
	var recent = event_history.duplicate()
	recent.reverse()
	return recent.slice(0, count)

func clear_history():
	"""Limpia el historial de eventos"""
	event_history.clear()
	if debug_mode:
		print("🧹 EventBus: History cleared")

func get_listener_count(event_type: String = "") -> int:
	"""Obtiene el número de listeners para un evento específico o total"""
	if event_type.is_empty():
		var total = 0
		for type in listeners.keys():
			total += listeners[type].size()
		return total
	else:
		return listeners.get(event_type, []).size()

func get_active_event_types() -> Array:
	"""Obtiene todos los tipos de eventos activos"""
	return listeners.keys()

# Debug y utilidades
func enable_debug(enabled: bool = true):
	"""Habilita/deshabilita debug"""
	debug_mode = enabled
	print("🐛 EventBus debug: %s" % ("enabled" if enabled else "disabled"))

func print_debug_info():
	"""Imprime información de debug"""
	if not debug_mode:
		return
	
	print("🔍 EventBus Debug Info:")
	print("  Active event types: %s" % str(get_active_event_types()))
	print("  Total listeners: %d" % get_listener_count())
	print("  Recent events: %d" % event_history.size())
	
	for event_type in listeners.keys():
		print("    %s: %d listeners" % [event_type, listeners[event_type].size()])

func _to_string() -> String:
	return "EventBus[%d types, %d listeners]" % [listeners.size(), get_listener_count()]
