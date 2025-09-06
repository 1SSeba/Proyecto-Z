extends CharacterBody2D

signal died
signal damaged(damage_amount: float)
signal health_changed(current: float, max_health: float)

@export var speed: float = 150.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

@export var max_health: float = 100.0
var current_health: float = 100.0
var is_invulnerable: bool = false
var invulnerability_duration: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var last_direction: Vector2 = Vector2.DOWN
var is_alive: bool = true
var is_initialized: bool = false

var resource_loader: Node
var player_sprites: Resource

# Inicialización
func _ready():
	await _wait_for_managers()

	_load_resources()

	current_health = max_health
	health_changed.emit(current_health, max_health)

	if animated_sprite:
		animated_sprite.play("Idle_down")

	is_initialized = true
	print("Player: Initialized with resources")

func _load_resources():
	resource_loader = get_node("/root/ResourceLoader")
	if not resource_loader:
		resource_loader = preload("res://game/core/ResourceLoader.gd").new()
		get_tree().root.add_child(resource_loader)

	player_sprites = resource_loader.player_sprites
	print("Player: Resources loaded")

func _wait_for_managers():
	var max_wait = 100
	var wait_count = 0

	while wait_count < max_wait:
		if GameStateManager and ServiceManager:
			break
			await get_tree().process_frame
		wait_count += 1

# Física y movimiento
func _physics_process(delta):
	if not is_initialized or not is_alive:
		return

	if GameStateManager and not GameStateManager.is_playing():
		return

	_handle_movement(delta)
	_handle_animation()
	_handle_debug_input()

func _handle_movement(delta):
	var input_vector = Vector2.ZERO

	if ServiceManager and ServiceManager.has_service("InputService"):
		var input_service = ServiceManager.get_input_service()
		input_vector = input_service.get_movement_vector()
	else:
		input_vector.x = Input.get_axis("move_left", "move_right")
		input_vector.y = Input.get_axis("move_up", "move_down")

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		last_direction = input_vector

	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

func _handle_animation():
	if not animated_sprite:
		return

	var animation_name = "Idle"

	if velocity.length() > 0:
		animation_name = "Run"

	var direction = ""
	if abs(last_direction.x) > abs(last_direction.y):
		direction = "left" if last_direction.x < 0 else "right"
	else:
		direction = "up" if last_direction.y < 0 else "down"

	var full_animation = animation_name + "_" + direction
	animated_sprite.play(full_animation)

# Sistema de salud
func take_damage(damage_amount: float):
	if is_invulnerable or not is_alive:
		return

	current_health = max(0, current_health - damage_amount)
	health_changed.emit(current_health, max_health)
	damaged.emit(damage_amount)

	print("Player: Took damage: %.1f, Health: %.1f/%.1f" % [damage_amount, current_health, max_health])

	_make_invulnerable()

	if current_health <= 0:
		die()

func heal(heal_amount: float):
	if not is_alive:
		return

	current_health = min(max_health, current_health + heal_amount)
	health_changed.emit(current_health, max_health)

	print("Player: Healed: %.1f, Health: %.1f/%.1f" % [heal_amount, current_health, max_health])

func die():
	if not is_alive:
		return

	is_alive = false
	current_health = 0
	health_changed.emit(current_health, max_health)
	died.emit()

	print("Player: Died")

	# Cambiar estado del juego
	if GameStateManager:
		GameStateManager.on_player_died()

func revive():
	if is_alive:
		return

	is_alive = true
	current_health = max_health
	health_changed.emit(current_health, max_health)

	print("Player: Revived")

func _make_invulnerable():
	is_invulnerable = true
	await get_tree().create_timer(invulnerability_duration).timeout
	is_invulnerable = false

# Debug y testing
func _handle_debug_input():
	if not GameStateManager or not GameStateManager.is_playing():
		return

	if Input.is_action_just_pressed("ui_accept"):
		debug_damage()

	if Input.is_key_pressed(KEY_F2):
		debug_heal()

	if Input.is_key_pressed(KEY_F3):
		debug_kill()

func debug_damage():
	take_damage(10.0)

func debug_heal():
	heal(20.0)

func debug_kill():
	die()

func debug_info():
	print("=== PLAYER DEBUG INFO ===")
	print("Alive: %s" % is_alive)
	print("Health: %.1f/%.1f" % [current_health, max_health])
	print("Position: %s" % global_position)
	print("Velocity: %s" % velocity)
	print("Last Direction: %s" % last_direction)
	print("Invulnerable: %s" % is_invulnerable)
	print("=========================")

# Funciones públicas
func get_health_percentage() -> float:
	return (current_health / max_health) * 100.0

func is_full_health() -> bool:
	return current_health >= max_health

func get_direction() -> Vector2:
	return last_direction

func set_speed(new_speed: float):
	speed = new_speed

func get_speed() -> float:
	return speed
