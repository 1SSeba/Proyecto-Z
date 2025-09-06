extends Node

var game_resources: Resource
var player_sprites: Resource
var map_textures: Resource
var game_config: Resource
var game_colors: Resource
var audio_resources: Resource

func _ready():
	print("ResourceLoader: Loading game resources...")
	_load_resources()

func _load_resources():
	# Cargar recurso principal
	game_resources = load("res://game/assets/game_resources.res")

	if game_resources:
		player_sprites = game_resources.player_sprites
		map_textures = game_resources.map_textures
		game_config = game_resources.game_config
		game_colors = game_resources.game_colors
		audio_resources = game_resources.audio_resources

		print("ResourceLoader: All resources loaded successfully")
	else:
		print("ResourceLoader: Failed to load game resources")

# Funciones para obtener recursos
func get_player_sprite(animation: String, direction: String) -> Texture2D:
	if player_sprites and player_sprites.has_method("get"):
		var sprite_name = animation + "_" + direction
		return player_sprites.get(sprite_name)
	return null

func get_map_texture(texture_name: String) -> Texture2D:
	if map_textures and map_textures.has_method("get"):
		return map_textures.get(texture_name)
	return null

func get_config_value(key: String, default_value = null):
	if game_config and game_config.has_method("get"):
		return game_config.get(key, default_value)
	return default_value

func get_color(color_name: String) -> Color:
	if game_colors and game_colors.has_method("get"):
		return game_colors.get(color_name, Color.WHITE)
	return Color.WHITE

func get_audio_path(audio_name: String) -> String:
	if audio_resources and audio_resources.has_method("get"):
		return audio_resources.get(audio_name, "")
	return ""

# Funciones de utilidad
func get_player_speed() -> float:
	return get_config_value("player_speed", 150.0)

func get_player_max_health() -> float:
	return get_config_value("player_max_health", 100.0)

func get_ui_color(color_name: String) -> Color:
	return get_color(color_name)
