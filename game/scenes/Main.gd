extends Node2D

const PLAYER_PATH := NodePath("GameWorld/Player")

func get_player() -> CharacterBody2D:
    return get_node_or_null(PLAYER_PATH)

# Minimal Main scene script — keep simple so the scene loads correctly.
func _ready():
    if not get_player():
        push_warning("Main.gd: Player node not found; HUD won't receive health updates")
