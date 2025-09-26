# 🎬 SceneController
# Controlador simplificado para cambios de escena

extends Node

var current_scene_path: String = ""
var is_transitioning: bool = false

# Señales
signal scene_changed(scene_path: String)
signal scene_change_started(scene_path: String)
signal scene_change_failed(scene_path: String, error: String)

func _ready():
	# Conectar al GameFlowController
	if has_node("/root/GameFlowController"):
		var game_flow = get_node("/root/GameFlowController")
		game_flow.scene_change_requested.connect(_on_scene_change_requested)

	print("SceneController: Initialized")

func _on_scene_change_requested(scene_path: String):
	change_scene(scene_path)

func change_scene(scene_path: String):
	"""Cambiar a una nueva escena de forma segura"""
	if is_transitioning:
		print("SceneController: Already transitioning, ignoring request")
		return

	if not ResourceLoader.exists(scene_path):
		print("SceneController: Scene does not exist: ", scene_path)
		scene_change_failed.emit(scene_path, "Scene file not found")
		return

	is_transitioning = true
	current_scene_path = scene_path

	print("SceneController: Changing to scene: ", scene_path)
	scene_change_started.emit(scene_path)

	# Cambiar escena
	var result = get_tree().change_scene_to_file(scene_path)

	if result == OK:
		# Esperar un frame para que la escena esté lista
		await get_tree().process_frame
		scene_changed.emit(scene_path)
		print("SceneController: Scene changed successfully")
	else:
		scene_change_failed.emit(scene_path, "Failed to load scene")
		print("SceneController: Failed to change scene: ", result)

	is_transitioning = false

func get_current_scene_path() -> String:
	return current_scene_path

func reload_current_scene():
	"""Recargar la escena actual"""
	if current_scene_path != "":
		change_scene(current_scene_path)
