extends Node2D
class_name RoguelikeDebugVisualizer

# =======================
#  CONFIGURACIÓN DE DEBUG
# =======================
@export var enabled: bool = false
@export var show_room_bounds: bool = true
@export var show_room_connections: bool = true
@export var show_room_ids: bool = true
@export var show_grid: bool = false

# =======================
#  COLORES DE DEBUG
# =======================
var room_colors = {
	"START": Color.GREEN,
	"NORMAL": Color.WHITE,
	"TREASURE": Color.YELLOW,
	"BOSS": Color.RED,
	"SECRET": Color.PURPLE,
	"SHOP": Color.BLUE,
	"SPECIAL": Color.ORANGE
}

# =======================
#  REFERENCIAS
# =======================
var world_node
var dungeon_data: Dictionary = {}

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	# Encontrar el nodo World
	world_node = get_parent() as World
	if not world_node:
		world_node = get_node("../") as World
	
	if world_node:
		world_node.world_generated.connect(_on_world_generated)
		print("RoguelikeDebugVisualizer: Connected to World")

func _on_world_generated():
	"""Se llama cuando se genera un nuevo mundo"""
	if world_node:
		dungeon_data = world_node.current_dungeon_data
		queue_redraw()

# =======================
#  DRAWING
# =======================
func _draw():
	if not enabled or dungeon_data.is_empty():
		return
	
	var tile_size = 32  # Tamaño de cada tile en pixels
	
	# Dibujar grid si está habilitado
	if show_grid:
		_draw_grid(tile_size)
	
	# Dibujar rooms
	if show_room_bounds:
		_draw_room_bounds(tile_size)
	
	# Dibujar conexiones
	if show_room_connections:
		_draw_room_connections(tile_size)
	
	# Dibujar IDs de rooms
	if show_room_ids:
		_draw_room_ids(tile_size)

func _draw_grid(tile_size: int):
	"""Dibuja una grid de debug"""
	var map_size = dungeon_data.get("map_size", Vector2i(50, 50))
	var grid_color = Color(0.3, 0.3, 0.3, 0.5)
	
	# Líneas verticales
	for x in range(0, map_size.x + 1, 5):  # Cada 5 tiles
		var start_pos = Vector2(x * tile_size, 0)
		var end_pos = Vector2(x * tile_size, map_size.y * tile_size)
		draw_line(start_pos, end_pos, grid_color, 1)
	
	# Líneas horizontales
	for y in range(0, map_size.y + 1, 5):  # Cada 5 tiles
		var start_pos = Vector2(0, y * tile_size)
		var end_pos = Vector2(map_size.x * tile_size, y * tile_size)
		draw_line(start_pos, end_pos, grid_color, 1)

func _draw_room_bounds(tile_size: int):
	"""Dibuja los límites de las rooms"""
	var rooms = dungeon_data.get("rooms", [])
	
	for room in rooms:
		var room_type_key = str(room.type)
		var color = room_colors.get(room_type_key, Color.WHITE)
		color.a = 0.3  # Semi-transparente
		
		# Dibujar rectángulo de la room
		var rect_pos = Vector2(room.rect.position.x * tile_size, room.rect.position.y * tile_size)
		var rect_size = Vector2(room.rect.size.x * tile_size, room.rect.size.y * tile_size)
		
		draw_rect(Rect2(rect_pos, rect_size), color, false, 2)
		
		# Dibujar centro de la room
		var center_pos = Vector2(room.center.x * tile_size, room.center.y * tile_size)
		draw_circle(center_pos, 4, color)

func _draw_room_connections(tile_size: int):
	"""Dibuja las conexiones entre rooms"""
	var connections = dungeon_data.get("connections", [])
	var rooms = dungeon_data.get("rooms", [])
	
	for connection in connections:
		if connection.room_a < rooms.size() and connection.room_b < rooms.size():
			var room_a = rooms[connection.room_a]
			var room_b = rooms[connection.room_b]
			
			var start_pos = Vector2(room_a.center.x * tile_size, room_a.center.y * tile_size)
			var end_pos = Vector2(room_b.center.x * tile_size, room_b.center.y * tile_size)
			
			var color = Color.CYAN if connection.is_main_path else Color.GRAY
			draw_line(start_pos, end_pos, color, 2)

func _draw_room_ids(tile_size: int):
	"""Dibuja los IDs de las rooms"""
	var rooms = dungeon_data.get("rooms", [])
	
	for room in rooms:
		var center_pos = Vector2(room.center.x * tile_size, room.center.y * tile_size)
		var text = str(room.id)
		var color = Color.BLACK
		
		# Dibujar texto con font system
		var font = ThemeDB.fallback_font
		draw_string(font, center_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, color)

# =======================
#  CONTROLES DE DEBUG
# =======================
func toggle_debug():
	"""Alterna el debug visual"""
	enabled = !enabled
	queue_redraw()

func toggle_room_bounds():
	"""Alterna mostrar límites de rooms"""
	show_room_bounds = !show_room_bounds
	queue_redraw()

func toggle_connections():
	"""Alterna mostrar conexiones"""
	show_room_connections = !show_room_connections
	queue_redraw()

func toggle_room_ids():
	"""Alterna mostrar IDs de rooms"""
	show_room_ids = !show_room_ids
	queue_redraw()

func toggle_grid():
	"""Alterna mostrar grid"""
	show_grid = !show_grid
	queue_redraw()

# =======================
#  INPUT HANDLING
# =======================
func _input(event):
	if not enabled:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F2:
				toggle_room_bounds()
			KEY_F3:
				toggle_connections()
			KEY_F4:
				toggle_room_ids()
			KEY_F5:
				toggle_grid()
			KEY_F6:
				# Regenerar dungeon
				if world_node:
					world_node.regenerate_world()
