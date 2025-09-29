extends Resource
class_name EnemyDefinition

@export_category("Metadata")
@export var enemy_id: StringName = &"enemy_id"
@export var display_name: String = "Enemy"
@export var description: String = ""

@export_category("Stats")
@export_range(1, 1000, 1, "or_greater") var max_health: int = 50
@export_range(0, 1000, 0.1, "or_greater") var move_speed: float = 120.0
@export_range(0, 1000, 0.1, "or_greater") var acceleration: float = 600.0
@export_range(0, 1000, 0.1, "or_greater") var friction: float = 500.0

@export_category("Combat")
@export_range(0, 1000, 0.1, "or_greater") var attack_damage: float = 10.0
@export_range(0.1, 60.0, 0.1, "or_greater") var attack_cooldown: float = 1.0
@export var attack_range: float = 64.0
@export var projectile_scene: PackedScene

@export_category("Rewards")
@export_range(0, 1000, 1, "or_greater") var experience_reward: int = 5
@export var loot_table_id: StringName = &"default"

@export_category("Visuals")
@export var character_scene: PackedScene
@export var portrait_texture: Texture2D
@export var tint_color: Color = Color.WHITE

func to_dictionary() -> Dictionary:
	return {
		"enemy_id": String(enemy_id),
		"display_name": display_name,
		"description": description,
		"stats": {
			"max_health": max_health,
			"move_speed": move_speed,
			"acceleration": acceleration,
			"friction": friction,
		},
		"combat": {
			"attack_damage": attack_damage,
			"attack_cooldown": attack_cooldown,
			"attack_range": attack_range,
		},
		"rewards": {
			"experience": experience_reward,
			"loot_table": String(loot_table_id)
		},
		"visuals": {
			"character_scene": character_scene,
			"portrait_texture": portrait_texture,
			"tint_color": tint_color,
		}
	}
