extends Component
class_name MovementComponent

signal direction_changed(direction: Vector2)
signal velocity_changed(velocity: Vector2)

@export var speed: float = 150.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

var _last_direction: Vector2 = Vector2.DOWN

func _on_component_ready() -> void:
	set_physics_process(true)
	direction_changed.emit(_last_direction)
	if not enabled:
		set_physics_process(false)

func get_last_direction() -> Vector2:
	return _last_direction

func _physics_process(delta: float) -> void:
	if not can_run():
		return

	var character := get_owner_actor() as CharacterBody2D
	if character == null:
		return

	if not _is_game_playing():
		return

	var input_vector := _get_input_vector()
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		if not input_vector.is_equal_approx(_last_direction):
			_last_direction = input_vector
			direction_changed.emit(_last_direction)

	var new_velocity: Vector2
	if input_vector != Vector2.ZERO:
		new_velocity = character.velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		new_velocity = character.velocity.move_toward(Vector2.ZERO, friction * delta)

	if not new_velocity.is_equal_approx(character.velocity):
		character.velocity = new_velocity
		velocity_changed.emit(character.velocity)

	character.move_and_slide()

func _on_enabled_changed(value: bool) -> void:
	set_physics_process(value)

func _get_input_vector() -> Vector2:
	if ServiceManager and ServiceManager.has_service("InputService"):
		var input_service = ServiceManager.get_input_service()
		if input_service:
			return input_service.get_movement_vector()

	var fallback := Vector2.ZERO
	fallback.x = Input.get_axis("move_left", "move_right")
	fallback.y = Input.get_axis("move_up", "move_down")
	return fallback

func _is_game_playing() -> bool:
	if ServiceManager:
		var game_flow = ServiceManager.get_game_flow_controller()
		if game_flow and not game_flow.is_playing():
			return false
	return true
