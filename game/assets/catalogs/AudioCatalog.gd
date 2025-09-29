extends Resource
class_name AudioCatalog

@export_group("Music")
@export var music_main_menu: AudioStream = null
@export var music_gameplay: AudioStream = null
@export var music_boss: AudioStream = null

@export_group("Sound Effects")
@export var sfx_player_move: AudioStream = null
@export var sfx_player_attack: AudioStream = null
@export var sfx_player_hurt: AudioStream = null
@export var sfx_player_death: AudioStream = null
@export var sfx_enemy_hurt: AudioStream = null
@export var sfx_enemy_death: AudioStream = null
@export var sfx_item_pickup: AudioStream = null
@export var sfx_door_open: AudioStream = null
@export var sfx_ui_click: AudioStream = null
@export var sfx_ui_hover: AudioStream = null

@export_group("Settings")
@export_range(0.0, 1.0, 0.05, "or_greater") var default_volume: float = 1.0
@export_range(0.0, 5.0, 0.05, "or_greater") var fade_duration: float = 1.0
@export_range(1, 32, 1, "or_greater") var max_sfx_players: int = 8
