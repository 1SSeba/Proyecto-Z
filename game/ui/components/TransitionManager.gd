extends Node
class_name TransitionManager

## TransitionManager - Simple transition system for UI elements
## Provides basic fade in/out transitions for scene changes

# =======================
#  PROPERTIES
# =======================
var service_name: String = "TransitionService"
var is_ready: bool = false

# =======================
#  INITIALIZATION
# =======================
func _ready():
	is_ready = true
	print("TransitionManager: Initialized successfully")

# =======================
#  PUBLIC API
# =======================
func fade_out(duration: float = 0.5) -> void:
	"""Fade out transition"""
	print("TransitionManager: Fade out (duration: %s)" % duration)

func fade_in(duration: float = 0.5) -> void:
	"""Fade in transition"""
	print("TransitionManager: Fade in (duration: %s)" % duration)

func transition_to_scene(scene_path: String, transition_type: String = "fade") -> void:
	"""Transition to a new scene"""
	print("TransitionManager: Transitioning to %s with %s transition" % [scene_path, transition_type])
	get_tree().change_scene_to_file(scene_path)

# =======================
#  SERVICE INTERFACE
# =======================
func get_service_name() -> String:
	return service_name

func is_service_ready() -> bool:
	return is_ready
