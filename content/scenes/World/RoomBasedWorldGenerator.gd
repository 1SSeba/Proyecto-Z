extends RefCounted
class_name RoomBasedWorldGenerator

# =======================
#  CONFIGURACIÓN DE DUNGEONS
# =======================
enum DungeonSize {
	SMALL,     # 8-12 rooms
	MEDIUM,    # 15-25 rooms  
	LARGE      # 30-50 rooms
}

enum RoomType {
	START,        # Habitación inicial
	NORMAL,       # Habitación normal
	TREASURE,     # Habitación con tesoro
	BOSS,         # Habitación del boss
	SECRET,       # Habitación secreta
	SHOP,         # Tienda
	SPECIAL       # Habitación especial/evento
}

# Configuración de tamaños de dungeon
var dungeon_configs = {
	DungeonSize.SMALL: {
		"min_rooms": 8,
		"max_rooms": 12,
		"map_size": Vector2i(40, 40),
		"room_size_min": Vector2i(6, 6),
		"room_size_max": Vector2i(12, 12),
		"corridor_width": 3
	},
	DungeonSize.MEDIUM: {
		"min_rooms": 15,
		"max_rooms": 25,
		"map_size": Vector2i(60, 60),
		"room_size_min": Vector2i(8, 8),
		"room_size_max": Vector2i(16, 16),
		"corridor_width": 3
	},
	DungeonSize.LARGE: {
		"min_rooms": 30,
		"max_rooms": 50,
		"map_size": Vector2i(80, 80),
		"room_size_min": Vector2i(10, 10),
		"room_size_max": Vector2i(20, 20),
		"corridor_width": 4
	}
}

# =======================
#  VARIABLES DE GENERACIÓN
# =======================
var seed_value: int
var rng: RandomNumberGenerator
var current_dungeon_size: DungeonSize = DungeonSize.MEDIUM
var generated_rooms: Array = []
var room_connections: Array = []
var dungeon_grid: Array = []  # Grid 2D para el mapa
var map_size: Vector2i

# Clases internas para rooms y conexiones
class Room:
	var id
	var type
	var rect
	var center
	var connections: Array = []  # IDs de rooms conectadas
	var is_main_path = false
	var distance_from_start = 0

	func _init(p_id: int, p_rect: Rect2i, p_type = RoomType.NORMAL):
		id = p_id
		rect = p_rect
		type = p_type
		center = Vector2i(rect.position.x + int(floor(rect.size.x / 2.0)), rect.position.y + int(floor(rect.size.y / 2.0)))

class Connection:
	var room_a: int
	var room_b: int
	var path: Array = []
	var is_main_path: bool = false

	func _init(p_room_a: int, p_room_b: int):
		room_a = p_room_a
		room_b = p_room_b

# =======================
#  INICIALIZACIÓN
# =======================
func _init(p_seed: int = 0, p_size: DungeonSize = DungeonSize.MEDIUM):
	seed_value = p_seed if p_seed != 0 else randi()
	current_dungeon_size = p_size
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Configurar tamaño del mapa
	var config = dungeon_configs[current_dungeon_size]
	map_size = config.map_size
	
	# Inicializar grid
	_initialize_grid()
	
	print("RoomBasedWorldGenerator: Initialized with seed %d, size %s" % [seed_value, DungeonSize.keys()[current_dungeon_size]])

func _initialize_grid():
	"""Inicializa el grid del dungeon"""
	dungeon_grid = []
	for y in range(map_size.y):
		var row = []
		for x in range(map_size.x):
			row.append(0)  # 0 = vacío, 1 = pared, 2 = piso, 3 = corredor
		dungeon_grid.append(row)

# =======================
#  GENERACIÓN PRINCIPAL
# =======================
func generate_dungeon() -> Dictionary:
	"""Genera un dungeon completo y retorna la información"""
	print("Generating dungeon...")
	
	# Paso 1: Generar rooms
	_generate_rooms()
	
	# Paso 2: Conectar rooms
	_connect_rooms()
	
	# Paso 3: Asignar tipos especiales
	_assign_special_rooms()
	
	# Paso 4: Generar corredores
	_generate_corridors()
	
	# Paso 5: Aplicar al grid
	_apply_rooms_to_grid()
	
	print("Dungeon generated: %d rooms, %d connections" % [generated_rooms.size(), room_connections.size()])
	
	return {
		"rooms": generated_rooms,
		"connections": room_connections,
		"grid": dungeon_grid,
		"map_size": map_size,
		"seed": seed_value
	}

func _generate_rooms():
	"""Genera las rooms del dungeon"""
	var config = dungeon_configs[current_dungeon_size]
	var room_count = rng.randi_range(config.min_rooms, config.max_rooms)
	
	generated_rooms.clear()
	var attempts = 0
	var max_attempts = room_count * 10
	
	while generated_rooms.size() < room_count and attempts < max_attempts:
		attempts += 1
		
		# Generar tamaño de room
		var room_width = rng.randi_range(config.room_size_min.x, config.room_size_max.x)
		var room_height = rng.randi_range(config.room_size_min.y, config.room_size_max.y)
		
		# Generar posición
		var room_x = rng.randi_range(2, map_size.x - room_width - 2)
		var room_y = rng.randi_range(2, map_size.y - room_height - 2)
		
		var new_rect = Rect2i(room_x, room_y, room_width, room_height)
		
		# Verificar que no se solape con rooms existentes
		if _is_room_valid(new_rect):
			var room = Room.new(generated_rooms.size(), new_rect)
			generated_rooms.append(room)
			print("Generated room %d: %s" % [room.id, new_rect])

func _is_room_valid(rect: Rect2i) -> bool:
	"""Verifica si una room puede ser colocada sin solaparse"""
	var margin = 2  # Margen mínimo entre rooms
	
	for room in generated_rooms:
		var expanded_rect = Rect2i(
			room.rect.position.x - margin,
			room.rect.position.y - margin,
			room.rect.size.x + margin * 2,
			room.rect.size.y + margin * 2
		)
		
		if expanded_rect.intersects(rect):
			return false
	
	return true

func _connect_rooms():
	"""Conecta las rooms usando Minimum Spanning Tree"""
	if generated_rooms.size() < 2:
		return
	
	room_connections.clear()
	var connected_rooms = [0]  # Empezar con room 0
	var unconnected_rooms = []
	
	# Añadir todas las demás rooms a unconnected
	for i in range(1, generated_rooms.size()):
		unconnected_rooms.append(i)
	
	# Conectar usando MST modificado
	while unconnected_rooms.size() > 0:
		var best_connection = null
		var min_distance = INF
		
		# Encontrar la conexión más corta desde rooms conectadas
		for connected_id in connected_rooms:
			for unconnected_id in unconnected_rooms:
				var distance = generated_rooms[connected_id].center.distance_to(generated_rooms[unconnected_id].center)
				if distance < min_distance:
					min_distance = distance
					best_connection = {"from": connected_id, "to": unconnected_id}
		
		if best_connection:
			# Crear conexión
			var connection = Connection.new(best_connection.from, best_connection.to)
			room_connections.append(connection)
			
			# Actualizar lists
			connected_rooms.append(best_connection.to)
			unconnected_rooms.erase(best_connection.to)
			
			# Marcar conexiones en rooms
			generated_rooms[best_connection.from].connections.append(best_connection.to)
			generated_rooms[best_connection.to].connections.append(best_connection.from)
	
	# Añadir algunas conexiones extras para crear loops (opcional)
	_add_extra_connections()

func _add_extra_connections():
	"""Añade conexiones extra para crear ciclos en el dungeon"""
	var extra_connections = rng.randi_range(1, max(1, int(floor(generated_rooms.size() / 8.0))))
	
	for i in range(extra_connections):
		var room_a = rng.randi_range(0, generated_rooms.size() - 1)
		var room_b = rng.randi_range(0, generated_rooms.size() - 1)
			
		if room_a != room_b and not _rooms_connected(room_a, room_b):
			var connection = Connection.new(room_a, room_b)
			room_connections.append(connection)
			generated_rooms[room_a].connections.append(room_b)
			generated_rooms[room_b].connections.append(room_a)

func _rooms_connected(room_a: int, room_b: int) -> bool:
	"""Verifica si dos rooms ya están conectadas"""
	return generated_rooms[room_a].connections.has(room_b)

func _assign_special_rooms():
	"""Asigna tipos especiales a las rooms"""
	if generated_rooms.size() == 0:
		return
	
	# Room de inicio (siempre la primera)
	generated_rooms[0].type = RoomType.START
	
	# Calcular distancias desde el inicio
	_calculate_distances_from_start()
	
	# Room del boss (la más lejana del inicio)
	var boss_room_id = _find_furthest_room()
	if boss_room_id >= 0:
		generated_rooms[boss_room_id].type = RoomType.BOSS
	
	# Rooms de tesoro (algunas rooms aleatorias)
	var treasure_count = max(1, int(floor(generated_rooms.size() / 8.0)))
	for i in range(treasure_count):
		var room_id = rng.randi_range(1, generated_rooms.size() - 1)
		if generated_rooms[room_id].type == RoomType.NORMAL:
			generated_rooms[room_id].type = RoomType.TREASURE
	
	# Room secreta (1-2 rooms)
	if rng.randf() < 0.7:  # 70% chance
		var room_id = rng.randi_range(1, generated_rooms.size() - 1)
		if generated_rooms[room_id].type == RoomType.NORMAL:
			generated_rooms[room_id].type = RoomType.SECRET

func _calculate_distances_from_start():
	"""Calcula distancias desde la room de inicio usando BFS"""
	var visited = {}
	var queue = [0]  # Empezar desde room 0
	generated_rooms[0].distance_from_start = 0
	visited[0] = true
	
	while queue.size() > 0:
		var current_room_id = queue.pop_front()
		var current_distance = generated_rooms[current_room_id].distance_from_start
		
		for connected_id in generated_rooms[current_room_id].connections:
			if not visited.has(connected_id):
				visited[connected_id] = true
				generated_rooms[connected_id].distance_from_start = current_distance + 1
				queue.append(connected_id)

func _find_furthest_room() -> int:
	"""Encuentra la room más lejana del inicio"""
	var max_distance = -1
	var furthest_room = -1
	
	for room in generated_rooms:
		if room.distance_from_start > max_distance and room.type == RoomType.NORMAL:
			max_distance = room.distance_from_start
			furthest_room = room.id
	
	return furthest_room

func _generate_corridors():
	"""Genera los paths de corredores entre rooms"""
	for connection in room_connections:
		var room_a = generated_rooms[connection.room_a]
		var room_b = generated_rooms[connection.room_b]
		
		# Generar path simple entre centros
		connection.path = _generate_l_shaped_path(room_a.center, room_b.center)

func _generate_l_shaped_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	"""Genera un path en forma de L entre dos puntos"""
	var path = []
	
	# Decidir si ir horizontal primero o vertical primero
	var horizontal_first = rng.randf() < 0.5
	
	if horizontal_first:
		# Horizontal primero
		var current_y = start.y
		for current_x in range(min(start.x, end.x), max(start.x, end.x) + 1):
			path.append(Vector2i(current_x, current_y))
		
		# Luego vertical
		var fixed_x = end.x
		for next_y in range(min(start.y, end.y), max(start.y, end.y) + 1):
			if not path.has(Vector2i(fixed_x, next_y)):
				path.append(Vector2i(fixed_x, next_y))
	else:
		# Vertical primero
		var fixed_x = start.x
		for current_y in range(min(start.y, end.y), max(start.y, end.y) + 1):
			path.append(Vector2i(fixed_x, current_y))
		
		# Luego horizontal
		var fixed_y = end.y
		for next_x in range(min(start.x, end.x), max(start.x, end.x) + 1):
			if not path.has(Vector2i(next_x, fixed_y)):
				path.append(Vector2i(next_x, fixed_y))
	
	return path

func _apply_rooms_to_grid():
	"""Aplica las rooms y corredores al grid"""
	# Limpiar grid
	for y in range(map_size.y):
		for x in range(map_size.x):
			dungeon_grid[y][x] = 1  # Todo es pared inicialmente
	
	# Aplicar rooms
	for room in generated_rooms:
		for y in range(room.rect.position.y, room.rect.position.y + room.rect.size.y):
			for x in range(room.rect.position.x, room.rect.position.x + room.rect.size.x):
				if x >= 0 and x < map_size.x and y >= 0 and y < map_size.y:
					dungeon_grid[y][x] = 2  # Piso de room
	
	# Aplicar corredores
	var config = dungeon_configs[current_dungeon_size]
	var corridor_width = config.corridor_width
	
	for connection in room_connections:
		for path_point in connection.path:
			# Aplicar ancho del corredor
			var half = int(floor(corridor_width / 2.0))
			for dy in range(-half, half + 1):
				for dx in range(-half, half + 1):
					var x = path_point.x + dx
					var y = path_point.y + dy
					if x >= 0 and x < map_size.x and y >= 0 and y < map_size.y:
						if dungeon_grid[y][x] == 1:  # Solo cambiar paredes
							dungeon_grid[y][x] = 3  # Corredor

# =======================
#  UTILIDADES Y GETTERS
# =======================
func get_room_by_type(type: RoomType) -> Room:
	"""Obtiene la primera room del tipo especificado"""
	for room in generated_rooms:
		if room.type == type:
			return room
	return null

func get_spawn_position() -> Vector2i:
	"""Obtiene la posición de spawn (centro de la room de inicio)"""
	var start_room = get_room_by_type(RoomType.START)
	if start_room:
		return start_room.center
	return Vector2i(int(floor(map_size.x / 2.0)), int(floor(map_size.y / 2.0)))

func get_dungeon_info() -> Dictionary:
	"""Retorna información del dungeon generado"""
	return {
		"size": DungeonSize.keys()[current_dungeon_size],
		"room_count": generated_rooms.size(),
		"connection_count": room_connections.size(),
		"map_size": map_size,
		"seed": seed_value,
		"room_types": _count_room_types()
	}

func _count_room_types() -> Dictionary:
	"""Cuenta cuántas rooms hay de cada tipo"""
	var counts = {}
	for type in RoomType.values():
		counts[RoomType.keys()[type]] = 0
	
	for room in generated_rooms:
		var type_name = RoomType.keys()[room.type]
		counts[type_name] += 1
	
	return counts
