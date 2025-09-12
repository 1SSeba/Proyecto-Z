extends Node2D

class_name Room

# Stub Room entity: minimal implementation so scenes referencing it can load.
# Replace with full implementation from original assets when available.

var room_id: String = "stub_room"

func _ready():
    # Minimal initialization
    pass

func _on_room_bounds_body_entered(body):
    pass

func _on_room_bounds_body_exited(body):
    pass
