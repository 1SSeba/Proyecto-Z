extends Component
class_name HealthComponent

signal health_changed(current: int, maximum: int)
signal health_depleted(entity: Node)
signal damage_taken(damage: int, source: Node)
signal healed(amount: int)

@export var max_health: int = 100: set = set_max_health
@export var current_health: int = 100: set = set_current_health
@export var regeneration_rate: float = 0.0
@export var invulnerable: bool = false

var is_alive: bool = true

func _initialize():
	component_id = "HealthComponent"
	current_health = max_health

	if regeneration_rate > 0.0:
		_start_regeneration()

func _start_regeneration():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_regenerate_health)
	add_child(timer)
	timer.start()

func take_damage(amount: int, source: Node = null) -> bool:
	if not is_alive or invulnerable or amount <= 0:
		return false

	var old_health = current_health
	current_health = max(0, current_health - amount)

	damage_taken.emit(amount, source)
	health_changed.emit(current_health, max_health)

	if current_health <= 0 and old_health > 0:
		_handle_health_depleted()

	return true

func heal(amount: int) -> bool:
	if not is_alive or amount <= 0:
		return false

	if current_health >= max_health:
		return false

	current_health = min(max_health, current_health + amount)

	healed.emit(amount)
	health_changed.emit(current_health, max_health)

	return true

func _regenerate_health():
	if regeneration_rate > 0.0 and is_alive:
		heal(int(regeneration_rate))

func _handle_health_depleted():
	is_alive = false
	health_depleted.emit(get_entity())

	if EventBus:
		var entity = get_entity()
		if entity and entity.has_method("get_entity_type"):
			var entity_type = entity.get_entity_type()
			if entity_type == "enemy":
				EventBus.enemy_defeated.emit(entity)

func set_max_health(value: int):
	max_health = max(1, value)
	if current_health > max_health:
		current_health = max_health

	if is_component_ready:
		health_changed.emit(current_health, max_health)

func set_current_health(value: int):
	var old_health = current_health
	current_health = clamp(value, 0, max_health)

	if is_component_ready and current_health != old_health:
		health_changed.emit(current_health, max_health)

		if current_health <= 0 and old_health > 0:
			_handle_health_depleted()

func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)

func is_at_full_health() -> bool:
	return current_health >= max_health

func is_critically_injured() -> bool:
	return get_health_percentage() < 0.25

func can_be_healed() -> bool:
	return is_alive and current_health < max_health

func get_health_status() -> Dictionary:
	return {
		"current_health": current_health,
		"max_health": max_health,
		"health_percentage": get_health_percentage(),
		"is_alive": is_alive,
		"invulnerable": invulnerable,
		"regeneration_rate": regeneration_rate
	}
