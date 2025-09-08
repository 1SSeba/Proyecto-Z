[gd_resource type="Resource" format=3]

[sub_resource type="Resource" id="Resource_1"]
load_path = "res://game/assets/player_sprites.res"

[sub_resource type="Resource" id="Resource_2"]
load_path = "res://game/assets/map_textures.res"

[sub_resource type="Resource" id="Resource_3"]
load_path = "res://game/assets/game_config.res"

[sub_resource type="Resource" id="Resource_4"]
load_path = "res://game/assets/game_colors.res"

[sub_resource type="Resource" id="Resource_5"]
load_path = "res://game/assets/audio_resources.res"

[resource]
script_name = "GameResources"
player_sprites = SubResource("Resource_1")
map_textures = SubResource("Resource_2")
game_config = SubResource("Resource_3")
game_colors = SubResource("Resource_4")
audio_resources = SubResource("Resource_5")

