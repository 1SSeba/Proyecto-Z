extends Component
class_name MovementComponent

signal movement_started()
signal movement_stopped()
signal direction_changed(new_direction: Vector2)

@export var movement_speed: float = 100.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0
@export var can_move: bool = true

var velocity: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false

var body: CharacterBody2D

func _initialize():
	component_id = "MovementComponent"

	body = get_entity() as CharacterBody2D
	if not body:
		print("MovementComponent: Entity must be a CharacterBody2D")
		return

	set_physics_process(true)

func _physics_process(delta):
	if not enabled or not can_move or not body:
		return

	_handle_movement(delta)

func _handle_movement(delta: float):
	var was_moving = is_moving

	if input_direction != Vector2.ZERO:
		var target_velocity = input_direction * movement_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		is_moving = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		is_moving = velocity.length() > 0.1

	body.velocity = velocity
	body.move_and_slide()

	if was_moving != is_moving:
		if is_moving:
			movement_started.emit()
		else:
			movement_stopped.emit()

func set_input_direction(direction: Vector2):
	var old_direction = input_direction
	input_direction = direction.normalized()

	if old_direction != input_direction:
		direction_changed.emit(input_direction)

func move_to_direction(direction: Vector2):
	set_input_direction(direction)

func stop_movement():
	set_input_direction(Vector2.ZERO)

func set_movement_speed(speed: float):
	movement_speed = max(0.0, speed)

func get_current_velocity() -> Vector2:
	return velocity

func get_movement_direction() -> Vector2:
	return input_direction

func is_entity_moving() -> bool:
	return is_moving

func get_speed_percentage() -> float:
	if movement_speed <= 0.0:
		return 0.0
	return velocity.length() / movement_speed

func apply_knockback(force: Vector2, duration: float = 0.3):
	velocity += force

	var old_can_move = can_move
	can_move = false

	await get_tree().create_timer(duration).timeout
	can_move = old_can_move

func enable_movement():
	can_move = true

func disable_movement():
	can_move = false
	stop_movement()

func get_movement_status() -> Dictionary:
	return {
		"movement_speed": movement_speed,
		"current_velocity": velocity,
		"input_direction": input_direction,
		"is_moving": is_moving,
		"can_move": can_move,
		"speed_percentage": get_speed_percentage()
	}
