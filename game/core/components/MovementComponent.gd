extends Component
class_name MovementComponent

## Professional Movement Component
## Modular movement system for roguelike entities
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  MOVEMENT SIGNALS
# ============================================================================

signal movement_started()
signal movement_stopped()
signal direction_changed(new_direction: Vector2)

# ============================================================================
#  MOVEMENT PROPERTIES
# ============================================================================

@export var movement_speed: float = 100.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0
@export var can_move: bool = true

var velocity: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false

var body: CharacterBody2D

# ============================================================================
#  COMPONENT LIFECYCLE
# ============================================================================

func _initialize():
	component_id = "MovementComponent"
	
	# Get CharacterBody2D reference
	body = get_entity() as CharacterBody2D
	if not body:
		print("MovementComponent: Entity must be a CharacterBody2D")
		return
	
	set_physics_process(true)

func _physics_process(delta):
	if not enabled or not can_move or not body:
		return
	
	_handle_movement(delta)

# ============================================================================
#  MOVEMENT PROCESSING
# ============================================================================

func _handle_movement(delta: float):
	"""Process movement physics"""
	var was_moving = is_moving
	
	if input_direction != Vector2.ZERO:
		# Accelerate towards target velocity
		var target_velocity = input_direction * movement_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		is_moving = true
	else:
		# Apply friction
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		is_moving = velocity.length() > 0.1
	
	# Apply movement
	body.velocity = velocity
	body.move_and_slide()
	
	# Emit movement signals
	if was_moving != is_moving:
		if is_moving:
			movement_started.emit()
		else:
			movement_stopped.emit()

# ============================================================================
#  MOVEMENT CONTROL
# ============================================================================

func set_input_direction(direction: Vector2):
	"""Set movement input direction"""
	var old_direction = input_direction
	input_direction = direction.normalized()
	
	if old_direction != input_direction:
		direction_changed.emit(input_direction)

func move_to_direction(direction: Vector2):
	"""Move in a specific direction"""
	set_input_direction(direction)

func stop_movement():
	"""Stop all movement"""
	set_input_direction(Vector2.ZERO)

func set_movement_speed(speed: float):
	"""Set movement speed"""
	movement_speed = max(0.0, speed)

# ============================================================================
#  MOVEMENT QUERIES
# ============================================================================

func get_current_velocity() -> Vector2:
	"""Get current velocity"""
	return velocity

func get_movement_direction() -> Vector2:
	"""Get current movement direction"""
	return input_direction

func is_entity_moving() -> bool:
	"""Check if entity is currently moving"""
	return is_moving

func get_speed_percentage() -> float:
	"""Get current speed as percentage of max speed"""
	if movement_speed <= 0.0:
		return 0.0
	return velocity.length() / movement_speed

# ============================================================================
#  MOVEMENT MODIFIERS
# ============================================================================

func apply_knockback(force: Vector2, duration: float = 0.3):
	"""Apply knockback force"""
	velocity += force
	
	# Temporarily disable input for knockback duration
	var old_can_move = can_move
	can_move = false
	
	await get_tree().create_timer(duration).timeout
	can_move = old_can_move

func enable_movement():
	"""Enable movement"""
	can_move = true

func disable_movement():
	"""Disable movement"""
	can_move = false
	stop_movement()

# ============================================================================
#  COMPONENT STATUS
# ============================================================================

func get_movement_status() -> Dictionary:
	"""Get movement component status"""
	return {
		"movement_speed": movement_speed,
		"current_velocity": velocity,
		"input_direction": input_direction,
		"is_moving": is_moving,
		"can_move": can_move,
		"speed_percentage": get_speed_percentage()
	}
