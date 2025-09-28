extends Node2D

class_name Lobby

# 🏛️ Lobby - Simple lobby with tileset platform

@export var lobby_name: String = "Simple Lobby"

# Node references
@onready var tilemap_layer: TileMapLayer = $TileMapLayer
@onready var player_spawn: Node2D = $PlayerSpawn
@onready var lobby_bounds: Area2D = $LobbyBounds

# Signals
signal player_entered_lobby(player: Node)
signal player_exited_lobby(player: Node)

func _ready():
	print("Lobby: Initialized - %s" % lobby_name)
	_setup_connections()

func _setup_connections():
	"""Setup signal connections"""
	if lobby_bounds:
		lobby_bounds.body_entered.connect(_on_lobby_bounds_body_entered)
		lobby_bounds.body_exited.connect(_on_lobby_bounds_body_exited)

func _on_lobby_bounds_body_entered(body: Node2D):
	"""Handle when a body enters the lobby"""
	if body.is_in_group("player"):
		print("Lobby: Player entered - %s" % lobby_name)
		player_entered_lobby.emit(body)

func _on_lobby_bounds_body_exited(body: Node2D):
	"""Handle when a body exits the lobby"""
	if body.is_in_group("player"):
		print("Lobby: Player exited - %s" % lobby_name)
		player_exited_lobby.emit(body)

func get_player_spawn_position() -> Vector2:
	"""Get the player spawn position"""
	if player_spawn:
		return player_spawn.global_position
	return global_position
