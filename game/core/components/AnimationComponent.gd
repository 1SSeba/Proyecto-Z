extends Component
class_name AnimationComponent

@export var sprite_node_path: NodePath
@export var movement_component_path: NodePath
@export var idle_animation_name: String = "Idle"
@export var moving_animation_name: String = "Run"

var _sprite: AnimatedSprite2D = null
var _movement_component: MovementComponent = null
var _current_direction: Vector2 = Vector2.DOWN
var _current_velocity: Vector2 = Vector2.ZERO

func _on_component_ready() -> void:
	_sprite = _resolve_sprite()
	_movement_component = _resolve_movement_component()
	if _movement_component:
		_current_direction = _movement_component.get_last_direction()
		_movement_component.direction_changed.connect(_on_direction_changed)
		_movement_component.velocity_changed.connect(_on_velocity_changed)
	set_process(true)
	_update_animation()
	if not enabled:
		set_process(false)

func _process(_delta: float) -> void:
	if not can_run():
		return
	_update_animation()

func _resolve_sprite() -> AnimatedSprite2D:
	if sprite_node_path != NodePath() and has_node(sprite_node_path):
		return get_node(sprite_node_path) as AnimatedSprite2D

	if owner_actor and owner_actor.has_node("AnimatedSprite2D"):
		return owner_actor.get_node("AnimatedSprite2D") as AnimatedSprite2D

	return null

func _resolve_movement_component() -> MovementComponent:
	if movement_component_path != NodePath() and has_node(movement_component_path):
		return get_node(movement_component_path) as MovementComponent

	if owner_actor and owner_actor.has_node("MovementComponent"):
		return owner_actor.get_node("MovementComponent") as MovementComponent

	return null

func _on_direction_changed(direction: Vector2) -> void:
	_current_direction = direction

func _on_velocity_changed(velocity: Vector2) -> void:
	_current_velocity = velocity

func _update_animation() -> void:
	if not _sprite:
		return

	var base_name := idle_animation_name
	if _current_velocity.length() > 0.1:
		base_name = moving_animation_name

	var direction_suffix := _direction_to_suffix(_current_direction)
	var target_animation := "%s_%s" % [base_name, direction_suffix]

	if _sprite.animation != target_animation:
		_sprite.play(target_animation)

func _direction_to_suffix(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "left" if direction.x < 0 else "right"
	return "up" if direction.y < 0 else "down"

func _on_enabled_changed(value: bool) -> void:
	set_process(value)
