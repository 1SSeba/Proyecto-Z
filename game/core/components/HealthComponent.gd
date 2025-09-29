extends Component
class_name HealthComponent

signal died
signal damaged(damage_amount: float)
signal health_changed(current: float, max_health: float)

@export var max_health: float = 100.0
@export var invulnerability_duration: float = 1.0

var current_health: float = 0.0
var is_invulnerable: bool = false
var is_alive: bool = true

func _on_component_ready() -> void:
	current_health = max_health
	is_alive = true
	health_changed.emit(current_health, max_health)

func take_damage(damage_amount: float) -> void:
	if not is_alive or is_invulnerable:
		return

	current_health = max(0.0, current_health - damage_amount)
	health_changed.emit(current_health, max_health)
	damaged.emit(damage_amount)

	if current_health <= 0.0:
		die()
		return

	_make_invulnerable()

func heal(heal_amount: float) -> void:
	if not is_alive:
		return

	current_health = min(max_health, current_health + heal_amount)
	health_changed.emit(current_health, max_health)

func die() -> void:
	if not is_alive:
		return

	is_alive = false
	current_health = 0.0
	health_changed.emit(current_health, max_health)
	died.emit()

func revive() -> void:
	is_alive = true
	is_invulnerable = false
	current_health = max_health
	health_changed.emit(current_health, max_health)

func set_max_health(value: float) -> void:
	max_health = value
	current_health = clamp(current_health, 0.0, max_health)
	health_changed.emit(current_health, max_health)

func get_health_percentage() -> float:
	return 0.0 if max_health <= 0 else (current_health / max_health) * 100.0

func is_full_health() -> bool:
	return current_health >= max_health

func _make_invulnerable() -> void:
	if invulnerability_duration <= 0:
		return

	is_invulnerable = true
	await get_tree().create_timer(invulnerability_duration).timeout
	is_invulnerable = false
