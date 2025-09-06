# Generador de Habitaciones para Roguelike
extends RefCounted
class_name RoomGenerator

# =======================
#  CONFIGURACIÓN
# =======================
enum RoomShape {
	RECTANGLE,    # Habitación rectangular básica
	L_SHAPE,      # Habitación en forma de L
	CROSS,        # Habitación en forma de cruz
	CIRCLE,       # Habitación circular/ovalada
	IRREGULAR     # Habitación irregular
}

enum RoomFeature {
	NONE,
	PILLARS,      # Columnas en la habitación
	WATER_POOL,   # Charco de agua
	RAISED_AREA,  # Área elevada
	PIT,          # Foso
	ALTAR         # Altar central
}

# =======================
#  TEMPLATE DE HABITACIÓN
# =======================
class RoomTemplate extends RefCounted:
	var shape: RoomShape = RoomShape.RECTANGLE
	var features: Array = []  # Sin tipado específico para evitar errores
	var min_size: Vector2i = Vector2i(6, 6)
	var max_size: Vector2i = Vector2i(12, 10)
	var spawn_points: Array = []
	var decoration_points: Array = []
	
	func _init(p_shape: RoomShape = RoomShape.RECTANGLE, p_min: Vector2i = Vector2i(6, 6), p_max: Vector2i = Vector2i(12, 10)):
		shape = p_shape
		min_size = p_min
		max_size = p_max
		features = []
		spawn_points = []
		decoration_points = []

# =======================
#  VARIABLES
# =======================
var room_templates: Dictionary = {}
var rng: RandomNumberGenerator

# =======================
#  INICIALIZACIÓN
# =======================
func _init():
	rng = RandomNumberGenerator.new()
	_setup_room_templates()

func _setup_room_templates():
	"""Configura las plantillas de habitaciones"""
	print("RoomGenerator: Setting up room templates...")
	
	# Habitación rectangular básica
	var basic_rect = RoomTemplate.new(RoomShape.RECTANGLE, Vector2i(6, 6), Vector2i(12, 10))
	room_templates[RoomsSystem.RoomType.NORMAL] = [basic_rect]
	
	# Habitación de inicio (más grande y simple)
	var start_room = RoomTemplate.new(RoomShape.RECTANGLE, Vector2i(8, 8), Vector2i(12, 12))
	room_templates[RoomsSystem.RoomType.START] = [start_room]
	
	# Habitación de tesoro (más pequeña, puede tener features)
	var treasure_room = RoomTemplate.new(RoomShape.RECTANGLE, Vector2i(6, 6), Vector2i(10, 8))
	treasure_room.features.append(RoomFeature.ALTAR)
	treasure_room.features.append(RoomFeature.RAISED_AREA)
	room_templates[RoomsSystem.RoomType.TREASURE] = [treasure_room]
	
	# Habitación del boss (grande y especial)
	var boss_room = RoomTemplate.new(RoomShape.CROSS, Vector2i(12, 12), Vector2i(16, 16))
	boss_room.features.append(RoomFeature.PILLARS)
	boss_room.features.append(RoomFeature.RAISED_AREA)
	room_templates[RoomsSystem.RoomType.BOSS] = [boss_room]
	
	# Habitación secreta (irregular)
	var secret_room = RoomTemplate.new(RoomShape.IRREGULAR, Vector2i(5, 5), Vector2i(8, 8))
	secret_room.features.append(RoomFeature.PIT)
	secret_room.features.append(RoomFeature.WATER_POOL)
	room_templates[RoomsSystem.RoomType.SECRET] = [secret_room]
	
	# Habitación de tienda (forma L)
	var shop_room = RoomTemplate.new(RoomShape.L_SHAPE, Vector2i(8, 8), Vector2i(12, 10))
	room_templates[RoomsSystem.RoomType.SHOP] = [shop_room]
	
	print("RoomGenerator: Room templates configured successfully")

# =======================
#  GENERACIÓN DE HABITACIONES
# =======================
func generate_room_layout(room, tilemap_layer) -> bool:
	"""Genera el layout interno de una habitación"""
	if not tilemap_layer:
		print("RoomGenerator: TileMapLayer not found")
		return false
	
	if not tilemap_layer.tile_set:
		print("RoomGenerator: TileSet not configured in TileMapLayer")
		return false
	
	# Obtener template para el tipo de habitación
	var template = _get_template_for_room(room)
	if not template:
		print("RoomGenerator: No template found for room type %s" % RoomsSystem.RoomType.keys()[room.type])
		return false
	
	print("RoomGenerator: Generating layout for room %d (type: %s)" % [room.id, RoomsSystem.RoomType.keys()[room.type]])
	
	# Generar la forma básica
	_generate_room_shape(room, template, tilemap_layer)
	
	# Agregar características especiales
	_add_room_features(room, template, tilemap_layer)
	
	# Configurar puntos de spawn
	_setup_spawn_points(room, template)
	
	return true

func _get_template_for_room(room) -> RoomTemplate:
	"""Obtiene un template apropiado para el tipo de habitación"""
	if not room_templates.has(room.type):
		# Usar template básico como fallback
		if room_templates.has(RoomsSystem.RoomType.NORMAL):
			return room_templates[RoomsSystem.RoomType.NORMAL][0]
		else:
			# Crear template básico si no existe
			return RoomTemplate.new()
	
	var templates = room_templates[room.type]
	return templates[rng.randi() % templates.size()]

func _generate_room_shape(room, template: RoomTemplate, tilemap_layer):
	"""Genera la forma básica de la habitación"""
	match template.shape:
		RoomShape.RECTANGLE:
			_generate_rectangle_room(room, tilemap_layer)
		RoomShape.L_SHAPE:
			_generate_l_shape_room(room, tilemap_layer)
		RoomShape.CROSS:
			_generate_cross_room(room, tilemap_layer)
		RoomShape.CIRCLE:
			_generate_circle_room(room, tilemap_layer)
		RoomShape.IRREGULAR:
			_generate_irregular_room(room, tilemap_layer)

func _generate_rectangle_room(room, tilemap_layer):
	"""Genera una habitación rectangular básica"""
	# Limpiar área y llenar con suelo
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			tilemap_layer.set_cell(Vector2i(x, y), 0, Vector2i(1, 1))  # Suelo
	
	# Paredes exteriores
	for x in range(room.position.x, room.position.x + room.size.x):
		tilemap_layer.set_cell(Vector2i(x, room.position.y), 0, Vector2i(0, 0))  # Pared superior
		tilemap_layer.set_cell(Vector2i(x, room.position.y + room.size.y - 1), 0, Vector2i(0, 0))  # Pared inferior
	
	for y in range(room.position.y, room.position.y + room.size.y):
		tilemap_layer.set_cell(Vector2i(room.position.x, y), 0, Vector2i(0, 0))  # Pared izquierda
		tilemap_layer.set_cell(Vector2i(room.position.x + room.size.x - 1, y), 0, Vector2i(0, 0))  # Pared derecha

func _generate_l_shape_room(room, tilemap_layer):
	"""Genera una habitación en forma de L"""
	# Dividir en dos rectángulos
	var rect1_size = Vector2i(room.size.x * 2 / 3, room.size.y * 2 / 3)
	var rect2_size = Vector2i(room.size.x / 3, room.size.y / 3)
	var rect2_pos = room.position + Vector2i(rect1_size.x, rect1_size.y)
	
	# Generar primer rectángulo
	_fill_rectangle(tilemap_layer, room.position, rect1_size)
	
	# Generar segundo rectángulo
	_fill_rectangle(tilemap_layer, rect2_pos, rect2_size)
	
	# Agregar paredes básicas
	_add_walls_around_area(tilemap_layer, room.position, room.size)

func _generate_cross_room(room, tilemap_layer):
	"""Genera una habitación en forma de cruz"""
	var center = room.center
	var arm_length = min(room.size.x, room.size.y) / 4
	
	# Brazo horizontal
	_fill_rectangle(tilemap_layer, 
		Vector2i(center.x - room.size.x / 2, center.y - arm_length),
		Vector2i(room.size.x, arm_length * 2)
	)
	
	# Brazo vertical
	_fill_rectangle(tilemap_layer,
		Vector2i(center.x - arm_length, center.y - room.size.y / 2),
		Vector2i(arm_length * 2, room.size.y)
	)
	
	_add_walls_around_area(tilemap_layer, room.position, room.size)

func _generate_circle_room(room, tilemap_layer):
	"""Genera una habitación circular"""
	var center = room.center
	var radius = min(room.size.x, room.size.y) / 2 - 1
	
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			var distance = Vector2(x, y).distance_to(Vector2(center))
			
			if distance <= radius - 1:
				tilemap_layer.set_cell(Vector2i(x, y), 0, Vector2i(1, 1))  # Suelo interior
			elif distance <= radius:
				tilemap_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))  # Pared

func _generate_irregular_room(room, tilemap_layer):
	"""Genera una habitación irregular usando ruido"""
	# Generar forma base rectangular
	_generate_rectangle_room(room, tilemap_layer)
	
	# Para evitar complejidad, mantener forma rectangular por ahora
	# Se puede expandir después con FastNoiseLite si es necesario

# =======================
#  CARACTERÍSTICAS ESPECIALES
# =======================
func _add_room_features(room, template: RoomTemplate, tilemap_layer):
	"""Agrega características especiales a la habitación"""
	for feature in template.features:
		match feature:
			RoomFeature.PILLARS:
				_add_pillars(room, tilemap_layer)
			RoomFeature.WATER_POOL:
				_add_water_pool(room, tilemap_layer)
			RoomFeature.RAISED_AREA:
				_add_raised_area(room, tilemap_layer)
			RoomFeature.PIT:
				_add_pit(room, tilemap_layer)
			RoomFeature.ALTAR:
				_add_altar(room, tilemap_layer)

func _add_pillars(room, tilemap_layer):
	"""Agrega columnas a la habitación"""
	var pillar_positions = [
		room.position + Vector2i(room.size.x / 4, room.size.y / 4),
		room.position + Vector2i(room.size.x * 3 / 4, room.size.y / 4),
		room.position + Vector2i(room.size.x / 4, room.size.y * 3 / 4),
		room.position + Vector2i(room.size.x * 3 / 4, room.size.y * 3 / 4)
	]
	
	for pos in pillar_positions:
		if _is_position_valid_for_feature(room, pos):
			tilemap_layer.set_cell(pos, 0, Vector2i(3, 0))  # Tile de columna

func _add_water_pool(room, tilemap_layer):
	"""Agrega un charco de agua"""
	var pool_center = room.center
	var pool_radius = 2
	
	for x in range(pool_center.x - pool_radius, pool_center.x + pool_radius + 1):
		for y in range(pool_center.y - pool_radius, pool_center.y + pool_radius + 1):
			var distance = Vector2(x, y).distance_to(Vector2(pool_center))
			if distance <= pool_radius and _is_position_valid_for_feature(room, Vector2i(x, y)):
				tilemap_layer.set_cell(Vector2i(x, y), 0, Vector2i(2, 1))  # Tile de agua

func _add_raised_area(room, tilemap_layer):
	"""Agrega un área elevada en el centro"""
	var raised_size = Vector2i(room.size.x / 3, room.size.y / 3)
	var raised_pos = room.center - raised_size / 2
	
	_fill_rectangle(tilemap_layer, raised_pos, raised_size, Vector2i(1, 2))  # Tile elevado

func _add_pit(room, tilemap_layer):
	"""Agrega un foso"""
	var pit_size = Vector2i(3, 3)
	var pit_pos = room.center - pit_size / 2
	
	_fill_rectangle(tilemap_layer, pit_pos, pit_size, Vector2i(0, 2))  # Tile de foso

func _add_altar(room, tilemap_layer):
	"""Agrega un altar en el centro"""
	var altar_pos = room.center
	if _is_position_valid_for_feature(room, altar_pos):
		tilemap_layer.set_cell(altar_pos, 0, Vector2i(4, 0))  # Tile de altar

# =======================
#  UTILIDADES
# =======================
func _fill_rectangle(tilemap_layer, pos: Vector2i, size: Vector2i, tile_coords: Vector2i = Vector2i(1, 1)):
	"""Llena un rectángulo con un tile específico"""
	for x in range(pos.x, pos.x + size.x):
		for y in range(pos.y, pos.y + size.y):
			tilemap_layer.set_cell(Vector2i(x, y), 0, tile_coords)

func _add_walls_around_area(tilemap_layer, pos: Vector2i, size: Vector2i):
	"""Agrega paredes alrededor de un área"""
	# Paredes horizontales
	for x in range(pos.x, pos.x + size.x):
		tilemap_layer.set_cell(Vector2i(x, pos.y), 0, Vector2i(0, 0))  # Pared superior
		tilemap_layer.set_cell(Vector2i(x, pos.y + size.y - 1), 0, Vector2i(0, 0))  # Pared inferior
	
	# Paredes verticales
	for y in range(pos.y, pos.y + size.y):
		tilemap_layer.set_cell(Vector2i(pos.x, y), 0, Vector2i(0, 0))  # Pared izquierda
		tilemap_layer.set_cell(Vector2i(pos.x + size.x - 1, y), 0, Vector2i(0, 0))  # Pared derecha

func _is_position_valid_for_feature(room, pos: Vector2i) -> bool:
	"""Verifica si una posición es válida para colocar una característica"""
	# Verificar que esté dentro de la habitación
	if not room.bounds.has_point(pos):
		return false
	
	# Verificar que no esté muy cerca de las paredes
	var distance_to_edge = min(
		min(pos.x - room.position.x, room.position.x + room.size.x - pos.x),
		min(pos.y - room.position.y, room.position.y + room.size.y - pos.y)
	)
	
	return distance_to_edge >= 2

func _setup_spawn_points(room, template: RoomTemplate):
	"""Configura puntos de spawn para la habitación"""
	template.spawn_points.clear()
	
	# Agregar puntos de spawn seguros (alejados de paredes y características)
	var spawn_candidates = []
	
	for x in range(room.position.x + 2, room.position.x + room.size.x - 2):
		for y in range(room.position.y + 2, room.position.y + room.size.y - 2):
			var pos = Vector2i(x, y)
			if _is_position_valid_for_feature(room, pos):
				spawn_candidates.append(pos)
	
	# Seleccionar algunos puntos de spawn
	var spawn_count = min(8, spawn_candidates.size())
	for i in range(spawn_count):
		if spawn_candidates.size() == 0:
			break
		var index = rng.randi() % spawn_candidates.size()
		template.spawn_points.append(spawn_candidates[index])
		spawn_candidates.remove_at(index)

# =======================
#  API PÚBLICA
# =======================
func get_spawn_points_for_room(room) -> Array:
	"""Obtiene puntos de spawn válidos para una habitación"""
	var template = _get_template_for_room(room)
	if template and template.spawn_points.size() > 0:
		return template.spawn_points
	
	# Fallback: generar puntos básicos
	var points = []
	points.append(room.center)
	points.append(room.center + Vector2i(-2, -2))
	points.append(room.center + Vector2i(2, 2))
	points.append(room.center + Vector2i(-2, 2))
	points.append(room.center + Vector2i(2, -2))
	
	return points

func set_seed(new_seed: int):
	"""Configura la semilla del generador"""
	rng.seed = new_seed

# =======================
#  DEBUG
# =======================
func debug_room_info(room):
	"""Muestra información de debug de una habitación"""
	print("=== ROOM GENERATOR DEBUG ===")
	print("Room ID: %d" % room.id)
	print("Type: %s" % RoomsSystem.RoomType.keys()[room.type])
	print("Position: %s" % room.position)
	print("Size: %s" % room.size)
	print("Center: %s" % room.center)
	print("Connections: %d" % room.connections.size())
	print("Doors: %d" % room.doors.size())
	print("=============================")

func debug_template_info():
	"""Muestra información de debug de las plantillas"""
	print("=== ROOM TEMPLATES DEBUG ===")
	for room_type in room_templates.keys():
		var templates = room_templates[room_type]
		print("Type %s: %d templates" % [RoomsSystem.RoomType.keys()[room_type], templates.size()])
	print("==============================")
