@tool
extends RefCounted
class_name WizardRoomGenerator

# Clase básica para evitar errores de compilación
enum RoomType {
	ENTRANCE = 0,
	NORMAL = 1,
	TREASURE = 2,
	BOSS = 3,
	SPECIAL = 4,
	SECRET = 5
}

class WizardRoom:
	var position: Vector2i
	var size: Vector2i
	var type: RoomType
	var connections: Array[Vector2i] = []
	
	func _init(pos: Vector2i, sz: Vector2i, room_type: RoomType):
		position = pos
		size = sz
		type = room_type

var generated_rooms: Array[WizardRoom] = []

func generate_dungeon(p_seed: int = 0, p_room_count: int = 12) -> Array[WizardRoom]:
	# Generación básica para evitar errores
	generated_rooms.clear()
	
	# Usar el seed si se proporciona
	if p_seed != 0:
		print("Using seed: ", p_seed)
	
	# Crear habitaciones según la cantidad solicitada
	for i in range(max(1, p_room_count)):
		var room_type = RoomType.ENTRANCE if i == 0 else RoomType.NORMAL
		var room = WizardRoom.new(Vector2i(10 + i * 12, 10), Vector2i(8, 8), room_type)
		generated_rooms.append(room)
	
	return generated_rooms

func get_rooms() -> Array[WizardRoom]:
	return generated_rooms
