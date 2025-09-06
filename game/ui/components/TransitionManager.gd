extends Node
class_name TransitionManager

var service_name: String = "TransitionService"
var is_ready: bool = false

func _ready():
	is_ready = true
	print("TransitionManager: Initialized successfully")

# Public API
func fade_out(duration: float = 0.5) -> void:
	print("TransitionManager: Fade out (duration: %s)" % duration)

func fade_in(duration: float = 0.5) -> void:
	print("TransitionManager: Fade in (duration: %s)" % duration)

func transition_to_scene(scene_path: String, transition_type: String = "fade") -> void:
	print("TransitionManager: Transitioning to %s with %s transition" % [scene_path, transition_type])
	get_tree().change_scene_to_file(scene_path)

# Service interface
func get_service_name() -> String:
	return service_name

func is_service_ready() -> bool:
	return is_ready
