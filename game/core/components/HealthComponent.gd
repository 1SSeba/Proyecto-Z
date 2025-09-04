extends Component
class_name HealthComponent

## Professional Health Component
## Modular health system for roguelike entities
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  HEALTH SIGNALS
# ============================================================================

signal health_changed(current: int, maximum: int)
signal health_depleted(entity: Node)
signal damage_taken(damage: int, source: Node)
signal healed(amount: int)

# ============================================================================
#  HEALTH PROPERTIES
# ============================================================================

@export var max_health: int = 100 : set = set_max_health
@export var current_health: int = 100 : set = set_current_health
@export var regeneration_rate: float = 0.0
@export var invulnerable: bool = false

var is_alive: bool = true

# ============================================================================
#  COMPONENT LIFECYCLE
# ============================================================================

func _initialize():
	component_id = "HealthComponent"
	current_health = max_health
	
	if regeneration_rate > 0.0:
		_start_regeneration()

func _start_regeneration():
	"""Start health regeneration timer"""
	var timer = Timer.new()
	timer.wait_time = 1.0  # Regenerate every second
	timer.timeout.connect(_regenerate_health)
	add_child(timer)
	timer.start()

# ============================================================================
#  HEALTH MANAGEMENT
# ============================================================================

func take_damage(amount: int, source: Node = null) -> bool:
	"""Apply damage to this entity"""
	if not is_alive or invulnerable or amount <= 0:
		return false
	
	var old_health = current_health
	current_health = max(0, current_health - amount)
	
	# Emit signals
	damage_taken.emit(amount, source)
	health_changed.emit(current_health, max_health)
	
	# Check if health depleted
	if current_health <= 0 and old_health > 0:
		_handle_health_depleted()
	
	return true

func heal(amount: int) -> bool:
	"""Heal this entity"""
	if not is_alive or amount <= 0:
		return false
	
	if current_health >= max_health:
		return false
	
	current_health = min(max_health, current_health + amount)
	
	# Emit signals
	healed.emit(amount)
	health_changed.emit(current_health, max_health)
	
	return true

func _regenerate_health():
	"""Regenerate health over time"""
	if regeneration_rate > 0.0 and is_alive:
		heal(int(regeneration_rate))

func _handle_health_depleted():
	"""Handle when health reaches zero"""
	is_alive = false
	health_depleted.emit(get_entity())
	
	# Notify EventBus if available
	if EventBus:
		var entity = get_entity()
		if entity and entity.has_method("get_entity_type"):
			var entity_type = entity.get_entity_type()
			if entity_type == "player":
				EventBus.player_died.emit(entity)
			elif entity_type == "enemy":
				EventBus.enemy_defeated.emit(entity)

# ============================================================================
#  PROPERTY SETTERS
# ============================================================================

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

# ============================================================================
#  HEALTH QUERIES
# ============================================================================

func get_health_percentage() -> float:
	"""Get health as percentage (0.0 to 1.0)"""
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)

func is_at_full_health() -> bool:
	"""Check if at maximum health"""
	return current_health >= max_health

func is_critically_injured() -> bool:
	"""Check if health is critically low (< 25%)"""
	return get_health_percentage() < 0.25

func can_be_healed() -> bool:
	"""Check if entity can be healed"""
	return is_alive and current_health < max_health

# ============================================================================
#  COMPONENT STATUS
# ============================================================================

func get_health_status() -> Dictionary:
	"""Get health component status"""
	return {
		"current_health": current_health,
		"max_health": max_health,
		"health_percentage": get_health_percentage(),
		"is_alive": is_alive,
		"invulnerable": invulnerable,
		"regeneration_rate": regeneration_rate
	}
