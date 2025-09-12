extends Node

var game_resources: Resource
var player_sprites: Resource
var map_textures: Resource
var game_config: Resource
var game_colors: Resource
var audio_resources: Resource

# Small contract:
# - Inputs: none (loads from fixed res:// paths)
# - Outputs: in-memory Resource references (or null)
# - Error modes: missing files, missing fields, wrong resource types


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
	var sprite_name = animation + "_" + direction
	if not player_sprites:
		return null
	# Try method get(key) safely
	if player_sprites.has_method("get"):
		var candidate = player_sprites.get(sprite_name)
		if candidate and candidate is Texture2D:
			return candidate
		return null
	# Fallback: treat as Dictionary-like Resource
	if sprite_name in player_sprites:
		var candidate2 = player_sprites[sprite_name]
		if candidate2 and candidate2 is Texture2D:
			return candidate2
	return null

func get_map_texture(texture_name: String) -> Texture2D:
	if not map_textures:
		return null
	if map_textures.has_method("get"):
		var candidate = map_textures.get(texture_name)
		if candidate and candidate is Texture2D:
			return candidate
		return null
	if texture_name in map_textures:
		var candidate2 = map_textures[texture_name]
		if candidate2 and candidate2 is Texture2D:
			return candidate2
	return null

func get_config_value(key: String, default_value = null):
	if not game_config:
		return default_value
	if game_config.has_method("get"):
		var val = game_config.get(key)
		if val == null:
			return default_value
		return val
	if key in game_config:
		var v2 = game_config[key]
		if v2 == null:
			return default_value
		return v2
	return default_value

func get_color(color_name: String) -> Color:
	if not game_colors:
		return Color.WHITE
	if game_colors.has_method("get"):
		var c = game_colors.get(color_name)
		if c and c is Color:
			return c
		return Color.WHITE
	if color_name in game_colors:
		var c2 = game_colors[color_name]
		if c2 and c2 is Color:
			return c2
	return Color.WHITE

func get_audio_path(audio_name: String) -> String:
	if not audio_resources:
		return ""
	if audio_resources.has_method("get"):
		var p = audio_resources.get(audio_name)
		if p:
			return str(p)
		return ""
	if audio_name in audio_resources:
		var p2 = audio_resources[audio_name]
		if p2:
			return str(p2)
	return ""

# Funciones de utilidad
func get_player_speed() -> float:
	return get_config_value("player_speed", 150.0)

func get_player_max_health() -> float:
	return get_config_value("player_max_health", 100.0)

func get_ui_color(color_name: String) -> Color:
	return get_color(color_name)
