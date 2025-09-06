# Generador de Conexiones y Corredores
extends RefCounted
class_name CorridorGenerator

# =======================
#  CONFIGURACIÓN
# =======================
enum CorridorType {
	STRAIGHT,     # Corredor directo
	L_SHAPED,     # Corredor en forma de L
	ZIGZAG,       # Corredor en zigzag
	CURVED        # Corredor curvo
}

enum CorridorFeature {
	NONE,
	DOORS,        # Puertas en los extremos
	PILLARS,      # Columnas decorativas
	TRAPS,        # Trampas en el corredor
	LIGHTING,     # Antorchas/luces
	DECORATION    # Elementos decorativos
}

# =======================
#  CONFIGURACIÓN DE GENERACIÓN
# =======================
class CorridorConfig extends RefCounted:
	var width: int = 3                    # Ancho del corredor
	var min_length: int = 5               # Longitud mínima
	var max_length: int = 20              # Longitud máxima
	var allow_diagonal: bool = false      # Permitir conexiones diagonales
	var prefer_straight: bool = true      # Preferir corredores rectos
	var features: Array[CorridorFeature] = []  # Características a incluir
	
	func _init():
		features = [CorridorFeature.DOORS]

# =======================
#  VARIABLES
# =======================
var config: CorridorConfig
var rng: RandomNumberGenerator
var pathfinding: AStar2D

# =======================
#  INICIALIZACIÓN
# =======================
func _init(corridor_config: CorridorConfig = null):
	config = corridor_config if corridor_config else CorridorConfig.new()
	rng = RandomNumberGenerator.new()
	pathfinding = AStar2D.new()

# =======================
#  GENERACIÓN DE CONEXIONES
# =======================
func generate_connections(rooms: Array, tilemap) -> Array:
	"""Genera conexiones entre habitaciones usando algoritmo de minimum spanning tree"""
	if rooms.size() < 2:
		print("CorridorGenerator: Need at least 2 rooms to generate connections")
		return []
	
	var corridors: Array = []
	
	# Crear grafo de conexiones posibles
	var connections = _calculate_room_connections(rooms)
	
	# Generar minimum spanning tree
	var mst_connections = _generate_minimum_spanning_tree(connections)
	
	# Agregar algunas conexiones adicionales para ciclos (opcional)
	if rng.randf() > 0.3:  # 70% de probabilidad de agregar conexiones extra
		var extra_connections = _add_extra_connections(connections, mst_connections)
		mst_connections.append_array(extra_connections)
	
	# Generar corredores para cada conexión
	for connection in mst_connections:
		var corridor = _generate_corridor_between_rooms(connection.room_a, connection.room_b, tilemap)
		if corridor:
			corridors.append(corridor)
			connection.room_a.connections.append(connection.room_b.id)
			connection.room_b.connections.append(connection.room_a.id)
	
	return corridors

func _calculate_room_connections(rooms: Array) -> Array:
	"""Calcula todas las conexiones posibles entre habitaciones"""
	var connections = []
	
	for i in range(rooms.size()):
		for j in range(i + 1, rooms.size()):
			var room_a = rooms[i]
			var room_b = rooms[j]
			var distance = room_a.center.distance_to(room_b.center)
			
			connections.append({
				"room_a": room_a,
				"room_b": room_b,
				"distance": distance,
				"weight": _calculate_connection_weight(room_a, room_b)
			})
	
	# Ordenar por peso (distancia principalmente)
	connections.sort_custom(func(a, b): return a.weight < b.weight)
	
	return connections

func _calculate_connection_weight(room_a, room_b) -> float:
	"""Calcula el peso de una conexión entre dos habitaciones"""
	var base_distance = room_a.center.distance_to(room_b.center)
	
	# Factores que afectan el peso
	var weight = base_distance
	
	# Preferir conectar habitación de inicio con normales
	if room_a.type == RoomsSystem.RoomType.START or room_b.type == RoomsSystem.RoomType.START:
		weight *= 0.8  # Reducir peso para priorizar
	
	# Penalizar conexiones con habitaciones especiales
	if room_a.type == RoomsSystem.RoomType.BOSS or room_b.type == RoomsSystem.RoomType.BOSS:
		weight *= 1.5  # Aumentar peso para que sea menos probable
	
	if room_a.type == RoomsSystem.RoomType.SECRET or room_b.type == RoomsSystem.RoomType.SECRET:
		weight *= 1.3
	
	return weight

func _generate_minimum_spanning_tree(connections: Array) -> Array:
	"""Genera un minimum spanning tree usando algoritmo de Kruskal"""
	var mst_connections = []
	var room_sets = {}  # Union-Find para detectar ciclos
	
	# Inicializar conjuntos (cada habitación en su propio conjunto)
	for connection in connections:
		var room_a_id = connection.room_a.id
		var room_b_id = connection.room_b.id
		
		if not room_sets.has(room_a_id):
			room_sets[room_a_id] = room_a_id
		if not room_sets.has(room_b_id):
			room_sets[room_b_id] = room_b_id
	
	# Procesar conexiones en orden de peso
	for connection in connections:
		var set_a = _find_set(room_sets, connection.room_a.id)
		var set_b = _find_set(room_sets, connection.room_b.id)
		
		# Si no están en el mismo conjunto, agregar conexión
		if set_a != set_b:
			mst_connections.append(connection)
			_union_sets(room_sets, set_a, set_b)
	
	return mst_connections

func _add_extra_connections(all_connections: Array, mst_connections: Array) -> Array:
	"""Agrega conexiones adicionales para crear ciclos opcionales"""
	var extra_connections = []
	var used_connections = []
	
	# Crear conjunto de conexiones ya usadas
	for connection in mst_connections:
		used_connections.append([connection.room_a.id, connection.room_b.id])
	
	# Buscar conexiones cortas no utilizadas
	for connection in all_connections:
		if extra_connections.size() >= 2:  # Máximo 2 conexiones extra
			break
		
		var conn_key = [connection.room_a.id, connection.room_b.id]
		var reverse_key = [connection.room_b.id, connection.room_a.id]
		
		if not used_connections.has(conn_key) and not used_connections.has(reverse_key):
			if connection.distance < 15 and rng.randf() > 0.5:  # 50% probabilidad para conexiones cortas
				extra_connections.append(connection)
				used_connections.append(conn_key)
	
	return extra_connections

# =======================
#  GENERACIÓN DE CORREDORES
# =======================
func _generate_corridor_between_rooms(room_a, room_b, tilemap):
	"""Genera un corredor entre dos habitaciones"""
	# Encontrar mejores puntos de conexión
	var start_point = _find_best_connection_point(room_a, room_b.center)
	var end_point = _find_best_connection_point(room_b, room_a.center)
	
	# Generar el camino
	var path = _generate_corridor_path(start_point, end_point)
	if path.is_empty():
		print("CorridorGenerator: Failed to generate path between rooms %d and %d" % [room_a.id, room_b.id])
		return null
	
	# Crear corredor
	var corridor = RoomsSystem.Corridor.new()
	corridor.id = rng.randi()
	corridor.room_a_id = room_a.id
	corridor.room_b_id = room_b.id
	corridor.path = path
	corridor.width = config.width
	
	# Dibujar corredor en el tilemap
	_draw_corridor_on_tilemap(corridor, tilemap)
	
	# Agregar características
	_add_corridor_features(corridor, tilemap)
	
	# Crear puertas
	_create_doors(corridor, room_a, room_b)
	
	return corridor

func _find_best_connection_point(room, target) -> Vector2i:
	"""Encuentra el mejor punto de conexión en una habitación hacia un objetivo"""
	var best_point = room.center
	var min_distance = INF
	
	# Probar puntos en los bordes de la habitación
	var border_points = _get_room_border_points(room)
	
	for point in border_points:
		var distance = point.distance_to(target)
		if distance < min_distance:
			min_distance = distance
			best_point = point
	
	return best_point

func _get_room_border_points(room) -> Array:
	"""Obtiene puntos válidos en el borde de una habitación para conexiones"""
	var points: Array[Vector2i] = []
	
	# Puntos en las paredes (evitando esquinas)
	# Pared superior
	for x in range(room.position.x + 2, room.position.x + room.size.x - 2):
		points.append(Vector2i(x, room.position.y))
	
	# Pared inferior
	for x in range(room.position.x + 2, room.position.x + room.size.x - 2):
		points.append(Vector2i(x, room.position.y + room.size.y - 1))
	
	# Pared izquierda
	for y in range(room.position.y + 2, room.position.y + room.size.y - 2):
		points.append(Vector2i(room.position.x, y))
	
	# Pared derecha
	for y in range(room.position.y + 2, room.position.y + room.size.y - 2):
		points.append(Vector2i(room.position.x + room.size.x - 1, y))
	
	return points

func _generate_corridor_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	"""Genera el camino del corredor usando A*"""
	var path: Array[Vector2i] = []
	
	if config.prefer_straight and _can_make_straight_path(start, end):
		path = _generate_straight_path(start, end)
	else:
		path = _generate_l_shaped_path(start, end)
	
	return path

func _can_make_straight_path(start: Vector2i, end: Vector2i) -> bool:
	"""Verifica si se puede hacer un camino recto entre dos puntos"""
	# Por simplicidad, asumimos que siempre podemos hacer caminos rectos
	# En una implementación más compleja, verificaríamos colisiones
	return abs(start.x - end.x) < 5 or abs(start.y - end.y) < 5

func _generate_straight_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	"""Genera un camino recto (horizontal o vertical)"""
	var path: Array[Vector2i] = []
	
	if abs(start.x - end.x) >= abs(start.y - end.y):
		# Camino principalmente horizontal
		path = _create_horizontal_then_vertical_path(start, end)
	else:
		# Camino principalmente vertical
		path = _create_vertical_then_horizontal_path(start, end)
	
	return path

func _generate_l_shaped_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	"""Genera un camino en forma de L"""
	var path: Array[Vector2i] = []
	
	if rng.randf() > 0.5:
		# Horizontal primero, luego vertical
		path = _create_horizontal_then_vertical_path(start, end)
	else:
		# Vertical primero, luego horizontal
		path = _create_vertical_then_horizontal_path(start, end)
	
	return path

func _create_horizontal_then_vertical_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	"""Crea un camino horizontal primero, luego vertical"""
	var path: Array[Vector2i] = []
	
	# Segmento horizontal
	var step_x = 1 if end.x > start.x else -1
	for x in range(start.x, end.x + step_x, step_x):
		path.append(Vector2i(x, start.y))
	
	# Segmento vertical
	var step_y = 1 if end.y > start.y else -1
	for y in range(start.y + step_y, end.y + step_y, step_y):
		path.append(Vector2i(end.x, y))
	
	return path

func _create_vertical_then_horizontal_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	"""Crea un camino vertical primero, luego horizontal"""
	var path: Array[Vector2i] = []
	
	# Segmento vertical
	var step_y = 1 if end.y > start.y else -1
	for y in range(start.y, end.y + step_y, step_y):
		path.append(Vector2i(start.x, y))
	
	# Segmento horizontal
	var step_x = 1 if end.x > start.x else -1
	for x in range(start.x + step_x, end.x + step_x, step_x):
		path.append(Vector2i(x, end.y))
	
	return path

func _draw_corridor_on_tilemap(corridor, tilemap):
	"""Dibuja el corredor en el tilemap"""
	if not tilemap or not tilemap.tile_set:
		print("CorridorGenerator: TileMap not configured")
		return
	
	var half_width = int(floor(corridor.width / 2))
	
	for point in corridor.path:
		# Dibujar el corredor con el ancho especificado
		for dx in range(-half_width, half_width + 1):
			for dy in range(-half_width, half_width + 1):
				var tile_pos = point + Vector2i(dx, dy)
				tilemap.set_cell(tile_pos, 0, Vector2i(1, 1))  # Suelo de corredor
		
		# Agregar paredes en los lados
		_add_corridor_walls(point, corridor.width, tilemap)

func _add_corridor_walls(center: Vector2i, width: int, tilemap):
	"""Agrega paredes a los lados del corredor"""
	var half_width = int(floor(float(width) / 2.0))
	
	# Paredes laterales (simplificado - necesitaría lógica más compleja para corredores curvos)
	for offset in [-half_width - 1, half_width + 1]:
		tilemap.set_cell(center + Vector2i(offset, 0), 0, Vector2i(0, 0))  # Pared horizontal
		tilemap.set_cell(center + Vector2i(0, offset), 0, Vector2i(0, 0))  # Pared vertical

# =======================
#  CARACTERÍSTICAS DEL CORREDOR
# =======================
func _add_corridor_features(corridor, tilemap):
	"""Agrega características especiales al corredor"""
	for feature in config.features:
		match feature:
			CorridorFeature.DOORS:
				_add_doors_to_corridor(corridor)
			CorridorFeature.PILLARS:
				_add_pillars_to_corridor(corridor, tilemap)
			CorridorFeature.TRAPS:
				_add_traps_to_corridor(corridor, tilemap)
			CorridorFeature.LIGHTING:
				_add_lighting_to_corridor(corridor, tilemap)
			CorridorFeature.DECORATION:
				_add_decoration_to_corridor(corridor, tilemap)

func _add_doors_to_corridor(_corridor):
	"""Agrega puertas al corredor"""
	# Las puertas se manejan en _create_doors
	pass

func _add_pillars_to_corridor(corridor, tilemap):
	"""Agrega columnas decorativas al corredor"""
	if corridor.path.size() < 8:  # Solo en corredores largos
		return
	
	var pillar_spacing = 6
	for i in range(pillar_spacing, corridor.path.size(), pillar_spacing):
		var pos = corridor.path[i]
		# Agregar columnas a los lados si hay espacio
		tilemap.set_cell(pos + Vector2i(2, 0), 0, Vector2i(3, 0))
		tilemap.set_cell(pos + Vector2i(-2, 0), 0, Vector2i(3, 0))

func _add_traps_to_corridor(corridor, tilemap):
	"""Agrega trampas al corredor"""
	var trap_count = int(floor(corridor.path.size() / 10))  # Una trampa cada 10 tiles
	
	for i in range(trap_count):
		var random_index = rng.randi() % corridor.path.size()
		var trap_pos = corridor.path[random_index]
		# Tile de trampa (oculta)
		tilemap.set_cell(trap_pos, 0, Vector2i(5, 2))

func _add_lighting_to_corridor(corridor, tilemap):
	"""Agrega iluminación al corredor"""
	var light_spacing = 8
	for i in range(light_spacing, corridor.path.size(), light_spacing):
		var pos = corridor.path[i]
		# Antorcha en la pared
		tilemap.set_cell(pos + Vector2i(1, 0), 0, Vector2i(4, 1))

func _add_decoration_to_corridor(corridor, tilemap):
	"""Agrega elementos decorativos al corredor"""
	# Decoraciones aleatorias ocasionales
	for i in range(0, corridor.path.size(), 5):
		if rng.randf() > 0.7:  # 30% de probabilidad
			var pos = corridor.path[i]
			tilemap.set_cell(pos + Vector2i(1, 0), 0, Vector2i(6, 1))  # Decoración

func _create_doors(corridor, room_a, room_b):
	"""Crea puertas en los extremos del corredor"""
	if corridor.path.size() < 2:
		return
	
	# Puerta en el inicio (usar constructor con parámetros requeridos)
	var door_a_id = rng.randi()
	var door_a = RoomsSystem.Door.new(door_a_id, corridor.path[0], Vector2i.ZERO)
	door_a.room_id = room_a.id
	door_a.corridor_id = corridor.id
	door_a.is_open = false
	corridor.doors.append(door_a)
	room_a.doors.append(door_a)
	
	# Puerta en el final (usar constructor con parámetros requeridos)
	var door_b_id = rng.randi()
	var door_b = RoomsSystem.Door.new(door_b_id, corridor.path[-1], Vector2i.ZERO)
	door_b.room_id = room_b.id
	door_b.corridor_id = corridor.id
	door_b.is_open = false
	corridor.doors.append(door_b)
	room_b.doors.append(door_b)

# =======================
#  UTILIDADES UNION-FIND
# =======================
func _find_set(sets: Dictionary, element: int) -> int:
	"""Encuentra el representante del conjunto (con compresión de camino)"""
	if sets[element] != element:
		sets[element] = _find_set(sets, sets[element])
	return sets[element]

func _union_sets(sets: Dictionary, set_a: int, set_b: int):
	"""Une dos conjuntos"""
	var root_a = _find_set(sets, set_a)
	var root_b = _find_set(sets, set_b)
	
	if root_a != root_b:
		sets[root_b] = root_a

# =======================
#  API PÚBLICA
# =======================
func set_seed(new_seed: int):
	"""Configura la semilla del generador"""
	rng.seed = new_seed

func set_config(new_config: CorridorConfig):
	"""Configura los parámetros del generador"""
	config = new_config

# =======================
#  DEBUG
# =======================
func debug_corridor_info(corridor):
	"""Muestra información de debug de un corredor"""
	print("=== CORRIDOR GENERATOR DEBUG ===")
	print("Corridor ID: %d" % corridor.id)
	print("Connecting rooms: %d -> %d" % [corridor.room_a_id, corridor.room_b_id])
	print("Path length: %d tiles" % corridor.path.size())
	print("Width: %d" % corridor.width)
	print("Doors: %d" % corridor.doors.size())
	print("Path preview: %s ... %s" % [corridor.path[0] if corridor.path.size() > 0 else "None", corridor.path[-1] if corridor.path.size() > 0 else "None"])
	print("=================================")
