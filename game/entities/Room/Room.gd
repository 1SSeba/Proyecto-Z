extends Node2D

class_name Room

# 🏠 Room - Simple room with tileset platform

@export var room_id: String = "simple_room"
@export var room_name: String = "Simple Room"

# Node references
@onready var tilemap_layer: TileMapLayer = $TileMapLayer
@onready var player_spawn: Node2D = $PlayerSpawn
@onready var room_bounds: Area2D = $RoomBounds

# Signals
signal room_entered(player: Node)
signal room_exited(player: Node)

func _ready():
	print("Room: Initialized - %s" % room_name)
	_setup_connections()

func _setup_connections():
	"""Setup signal connections"""
	if room_bounds:
		room_bounds.body_entered.connect(_on_room_bounds_body_entered)
		room_bounds.body_exited.connect(_on_room_bounds_body_exited)

func _on_room_bounds_body_entered(body: Node2D):
	"""Handle when a body enters the room bounds"""
	if body.is_in_group("player"):
		print("Room: Player entered - %s" % room_name)
		room_entered.emit(body)

func _on_room_bounds_body_exited(body: Node2D):
	"""Handle when a body exits the room bounds"""
	if body.is_in_group("player"):
		print("Room: Player exited - %s" % room_name)
		room_exited.emit(body)

func get_player_spawn_position() -> Vector2:
	"""Get the player spawn position"""
	if player_spawn:
		return player_spawn.global_position
	return global_position
