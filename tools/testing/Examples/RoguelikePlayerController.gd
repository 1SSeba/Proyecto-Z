extends CharacterBody2D
class_name RoguelikePlayerController

# =======================
#  REFERENCIAS AL MUNDO
# =======================
@export var world_node_path: NodePath = "../World"
var world
var current_room_id: int = -1
var last_room_type

# =======================
#  CONFIGURACIÓN DE MOVIMIENTO
# =======================
@export var speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 800.0

# =======================
#  TILE COLLISION
# =======================
var tile_size: int = 32

# =======================
#  INICIALIZACIÓN
# =======================

func _ready():
	# Encontrar el World node (no forzamos el tipo concreto para evitar errores del analizador)
	world = get_node(world_node_path)
	if not world:
		push_error("RoguelikePlayerController: World node not found at path: %s" % world_node_path)
		return
	
	# Conectar a eventos del mundo
	world.world_generated.connect(_on_world_generated)
	world.room_entered.connect(_on_room_entered)
	
	print("RoguelikePlayerController: Connected to World system")

func _on_world_generated():
	"""Se ejecuta cuando se genera un nuevo mundo"""
	print("RoguelikePlayerController: New world generated, moving to spawn")
	
	# Mover jugador al spawn point
	var spawn_pos = world.get_player_spawn_position()
	global_position = Vector2(spawn_pos.x * tile_size, spawn_pos.y * tile_size)
	
	# Actualizar room actual
	_update_current_room()


func _on_room_entered(room_id: int, room_type):
	"""Se ejecuta cuando el jugador entra a una nueva room"""
	# Evitar dependencias de enums externas: mostrar el valor crudo
	var type_name = str(room_type)
	print("Player entered %s room (ID: %d)" % [type_name, room_id])
	
	# Handler genérico: por ahora llamamos a un handler que no depende de enums concretos
	_on_enter_room_generic(room_id, room_type)

func _on_enter_room_generic(room_id, room_type):
	"""Manejador genérico de entrada a room. Actualmente solo loggea;
	Puedes extenderlo para llamar a handlers concretos basados en room_type."""
	print("_on_enter_room_generic: room_id=%s, room_type=%s" % [str(room_id), str(room_type)])

# =======================
#  MOVIMIENTO
# =======================
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	# Input de movimiento
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	
	input_vector = input_vector.normalized()
	
	# Aplicar movimiento
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Verificar colisiones con paredes
	var old_position = global_position
	move_and_slide()
	
	# Verificar si cambió de room
	if global_position != old_position:
		_update_current_room()

func _update_current_room():
	"""Actualiza la room actual basada en la posición del jugador"""
	if not world:
		return
	
	# Convertir posición del jugador a coordenadas de tile
	var tile_pos = Vector2i(global_position / tile_size)
	
	# Obtener room en esa posición
	var room = world.get_room_at_position(tile_pos)
	if room and room.id != current_room_id:
		current_room_id = room.id
		last_room_type = room.type
		world.player_entered_room(tile_pos)

func can_move_to_position(new_position: Vector2) -> bool:
	"""Verifica si el jugador puede moverse a una posición"""
	if not world:
		return true
	
	var tile_pos = Vector2i(new_position / tile_size)
	return world.is_position_walkable(tile_pos)

# =======================
#  EVENTOS DE ROOM
# =======================
func _on_enter_start_room():
	"""Acciones al entrar a la room de inicio"""
	print("🏠 Welcome to the dungeon!")
	# Aquí puedes añadir: tutorial, healing, save point, etc.

func _on_enter_treasure_room():
	"""Acciones al entrar a room de tesoro"""
	print("💰 Treasure room discovered!")
	# Tocar sonido de tesoro (si el AudioManager expone una API segura)
	if AudioManager and AudioManager.has_method("play_sfx"):
		var sfx = null
		if AudioManager.has_method("get_sfx_stream"):
			sfx = AudioManager.get_sfx_stream("treasure_discovered")
		if sfx:
			AudioManager.play_sfx(sfx)
	
	# Mostrar notificación
	# UI.show_notification("Treasure Room!")

func _on_enter_boss_room():
	"""Acciones al entrar a room del boss"""
	print("👹 Boss room entered!")
	# Cambiar música
	if AudioManager and AudioManager.has_method("play_music"):
		var music = null
		if AudioManager.has_method("get_music_stream"):
			music = AudioManager.get_music_stream("boss_battle")
		if music:
			AudioManager.play_music(music)
	
	# Cerrar puertas (futuro)
	# _lock_room_doors()
	
	# Spawn del boss
	# _spawn_boss()

func _on_enter_secret_room():
	"""Acciones al entrar a room secreta"""
	print("🔍 Secret room found!")
	# Logro/achievement
	# GameManager.unlock_achievement("secret_finder")
	
	# Sonido especial
	if AudioManager and AudioManager.has_method("play_sfx"):
		var sfx2 = null
		if AudioManager.has_method("get_sfx_stream"):
			sfx2 = AudioManager.get_sfx_stream("secret_found")
		if sfx2:
			AudioManager.play_sfx(sfx2)

func _on_enter_normal_room():
	"""Acciones al entrar a room normal"""
	print("⚔️ Exploring dungeon...")
	# Música ambiente
	if AudioManager and AudioManager.has_method("play_music"):
		var current = null
		if AudioManager.has_property("current_music"):
			current = AudioManager.current_music
		if current != "dungeon_ambient":
			var ambient = null
			if AudioManager.has_method("get_music_stream"):
				ambient = AudioManager.get_music_stream("dungeon_ambient")
			if ambient:
				AudioManager.play_music(ambient)

# =======================
#  UTILIDADES
# =======================
func get_current_room():
	"""Obtiene la room actual del jugador (sin anotar el tipo para evitar dependencias)"""
	if not world:
		return null

	var tile_pos = Vector2i(global_position / tile_size)
	return world.get_room_at_position(tile_pos)

func is_in_room_type(room_type) -> bool:
	"""Verifica si el jugador está en un tipo específico de room (room_type puede ser int)."""
	return last_room_type == room_type

func get_distance_to_room_center() -> float:
	"""Obtiene la distancia al centro de la room actual"""
	var current_room = get_current_room()
	if not current_room:
		return 0.0
	
	var room_center = Vector2(current_room.center.x * tile_size, current_room.center.y * tile_size)
	return global_position.distance_to(room_center)

# =======================
#  DEBUG
# =======================
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				# Regenerar mundo y mover jugador al nuevo spawn
				if world:
					world.regenerate_world()
			KEY_T:
				# Teleport al centro de la room actual
				var current_room = get_current_room()
				if current_room:
					global_position = Vector2(current_room.center.x * tile_size, current_room.center.y * tile_size)
			KEY_I:
				# Info de la room actual
				print_current_room_info()

func print_current_room_info():
	"""Imprime información de la room actual"""
	var current_room = get_current_room()
	if current_room:
		var type_name = str(current_room.type)
		print("=== CURRENT ROOM INFO ===")
		print("ID: %d" % current_room.id)
		print("Type: %s" % type_name)
		print("Bounds: %s" % current_room.rect)
		print("Center: %s" % current_room.center)
		print("Connections: %d" % current_room.connections.size())
		print("Distance from start: %d" % current_room.distance_from_start)
		print("Player distance to center: %.1f" % get_distance_to_room_center())
		print("========================")
	else:
		print("Player is not in any room")
