extends Resource
class_name GameFlowDefinition

@export var main_menu_scene: PackedScene = preload("res://game/scenes/menus/MainMenu.tscn")
@export var gameplay_scene: PackedScene = preload("res://game/scenes/gameplay/Main.tscn")
@export var lobby_scene: PackedScene = preload("res://game/scenes/environments/Lobby/Lobby.tscn")
@export var fallback_scene_controller: bool = true

@export_group("State Machine")
@export var loading_state: StringName = &"LoadingState"
@export var playing_state: StringName = &"PlayingState"
@export var lobby_state: StringName = &"LobbyState"

func get_scene_path_or_default(scene: PackedScene, default_path: String) -> String:
	if scene and scene.resource_path != "":
		return scene.resource_path
	return default_path
