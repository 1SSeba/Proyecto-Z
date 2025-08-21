class_name GameEvent
extends RefCounted
# Sistema de eventos tipados para comunicación entre componentes

# Tipos de eventos del juego
enum Type {
	# Game Flow Events
	GAME_STARTED,
	GAME_PAUSED,
	GAME_RESUMED,
	GAME_ENDED,
	LEVEL_STARTED,
	LEVEL_COMPLETED,
	LEVEL_FAILED,
	
	# Player Events
	PLAYER_SPAWNED,
	PLAYER_DIED,
	PLAYER_DAMAGED,
	PLAYER_HEALED,
	PLAYER_LEVEL_UP,
	PLAYER_MOVED,
	PLAYER_STATE_CHANGED,
	
	# Combat Events
	ENEMY_SPAWNED,
	ENEMY_DIED,
	WEAPON_FIRED,
	PROJECTILE_HIT,
	DAMAGE_DEALT,
	
	# World Events
	DOOR_OPENED,
	ITEM_COLLECTED,
	ROOM_ENTERED,
	ROOM_CLEARED,
	CHECKPOINT_REACHED,
	
	# UI Events
	MENU_OPENED,
	MENU_CLOSED,
	BUTTON_PRESSED,
	SETTING_CHANGED,
	
	# System Events
	SAVE_GAME,
	LOAD_GAME,
	CONFIG_CHANGED,
	ACHIEVEMENT_UNLOCKED,
	
	# Custom Events
	CUSTOM
}

# Propiedades del evento
var type: Type
var source: Node
var data: Dictionary = {}
var timestamp: float
var processed: bool = false
var cancelled: bool = false

# Constructor
func _init(event_type: Type, event_source: Node = null, event_data: Dictionary = {}):
	type = event_type
	source = event_source
	data = event_data
	timestamp = Time.get_unix_time_from_system()

# Métodos de utilidad
func get_type_name() -> String:
	return Type.keys()[type]

func is_type(event_type: Type) -> bool:
	return type == event_type

func has_data(key: String) -> bool:
	return key in data

func get_data(key: String, default_value = null):
	return data.get(key, default_value)

func set_data(key: String, value):
	data[key] = value

func cancel():
	"""Cancela el evento (evita que se procese más)"""
	cancelled = true

func mark_processed():
	"""Marca el evento como procesado"""
	processed = true

func clone() -> GameEvent:
	"""Crea una copia del evento"""
	var cloned = GameEvent.new(type, source, data.duplicate())
	cloned.timestamp = timestamp
	return cloned

func _to_string() -> String:
	var source_name = "null"
	if source:
		source_name = source.name
	return "GameEvent[%s] from %s at %.3f" % [
		get_type_name(),
		source_name,
		timestamp
	]

# Factory methods para eventos comunes
static func player_died(player: Node) -> GameEvent:
	return GameEvent.new(Type.PLAYER_DIED, player)

static func player_damaged(player: Node, damage: float, damage_source: Node = null) -> GameEvent:
	return GameEvent.new(Type.PLAYER_DAMAGED, player, {
		"damage": damage,
		"damage_source": damage_source
	})

static func level_completed(level_number: int, completion_time: float) -> GameEvent:
	return GameEvent.new(Type.LEVEL_COMPLETED, null, {
		"level": level_number,
		"time": completion_time
	})

static func setting_changed(setting_name: String, old_value, new_value) -> GameEvent:
	return GameEvent.new(Type.SETTING_CHANGED, null, {
		"setting": setting_name,
		"old_value": old_value,
		"new_value": new_value
	})
