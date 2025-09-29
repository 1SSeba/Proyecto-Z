extends CharacterBody2D

signal died
signal damaged(damage_amount: float)
signal health_changed(current: float, max_health: float)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var movement_component = $MovementComponent
@onready var animation_component = $AnimationComponent
@onready var health_component = $HealthComponent

var resource_library: Node = null
var player_sprites: Resource = null

var last_direction: Vector2 = Vector2.DOWN
var is_initialized: bool = false

# Inicialización
func _ready() -> void:
	await _wait_for_managers()
	_load_resources()
	_wire_components()
	is_initialized = true
	print("Player: Initialized with modular components")

func _wire_components() -> void:
	if movement_component:
		movement_component.direction_changed.connect(_on_direction_changed)
		movement_component.velocity_changed.connect(_on_velocity_changed)
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_component.damaged.connect(_on_damaged)
		health_component.died.connect(_on_died)
		health_changed.emit(health_component.current_health, health_component.max_health)

func _load_resources() -> void:
	if ServiceManager and ServiceManager.has_service("ResourceLibrary"):
		resource_library = ServiceManager.get_service("ResourceLibrary")

		# Buscar recursos de sprites del jugador
		var sprite_resources = resource_library.get_resources_by_tag("player")
		if sprite_resources.size() > 0:
			player_sprites = load(sprite_resources[0])
		else:
			print("Player: Warning - No player sprite resources found in ResourceLibrary")
	else:
		print("Player: Warning - ResourceLibrary service not available")

	print("Player: Resources loaded")

func _wait_for_managers() -> void:
	var max_wait := 100
	var wait_count := 0

	while wait_count < max_wait:
		if ServiceManager and ServiceManager.get_game_flow_controller():
			break
		await get_tree().process_frame
		wait_count += 1

func _physics_process(_delta: float) -> void:
	if not is_initialized or not is_player_alive():
		return

	_handle_debug_input()

func is_player_alive() -> bool:
	return health_component != null and health_component.is_alive

# Señales de componentes
func _on_direction_changed(direction: Vector2) -> void:
	last_direction = direction

func _on_velocity_changed(_velocity: Vector2) -> void:
	pass

func _on_health_changed(current: float, max_health: float) -> void:
	health_changed.emit(current, max_health)

func _on_damaged(damage_amount: float) -> void:
	if health_component:
		print("Player: Took damage: %.1f, Health: %.1f/%.1f" % [damage_amount, health_component.current_health, health_component.max_health])
	damaged.emit(damage_amount)

func _on_died() -> void:
	if movement_component:
		movement_component.set_enabled(false)
	velocity = Vector2.ZERO
	print("Player: Died")
	var game_flow = ServiceManager.get_game_flow_controller() if ServiceManager else null
	if game_flow:
		game_flow.on_player_died()
	died.emit()

# Sistema de salud (delegado)
func take_damage(damage_amount: float) -> void:
	if health_component:
		health_component.take_damage(damage_amount)

func heal(heal_amount: float) -> void:
	if health_component:
		health_component.heal(heal_amount)
		print("Player: Healed: %.1f, Health: %.1f/%.1f" % [heal_amount, health_component.current_health, health_component.max_health])

func die() -> void:
	if health_component:
		health_component.die()

func revive() -> void:
	if not health_component:
		return
	var was_dead: bool = not health_component.is_alive
	health_component.revive()
	if was_dead and movement_component:
		movement_component.set_enabled(true)
	print("Player: Revived")

# Debug y testing
func _handle_debug_input() -> void:
	var game_flow = ServiceManager.get_game_flow_controller() if ServiceManager else null
	if not game_flow or not game_flow.is_playing():
		return

	if Input.is_action_just_pressed("ui_accept"):
		take_damage(10.0)

	if Input.is_key_pressed(KEY_F2):
		heal(20.0)

	if Input.is_key_pressed(KEY_F3):
		die()

func debug_info() -> void:
	print("=== PLAYER DEBUG INFO ===")
	print("Alive: %s" % is_player_alive())
	if health_component:
		print("Health: %.1f/%.1f" % [health_component.current_health, health_component.max_health])
	print("Position: %s" % global_position)
	print("Velocity: %s" % velocity)
	print("Last Direction: %s" % last_direction)
	print("=========================")

# Funciones públicas
func get_health_percentage() -> float:
	return health_component.get_health_percentage() if health_component else 0.0

func is_full_health() -> bool:
	return health_component.is_full_health() if health_component else false

func get_direction() -> Vector2:
	return last_direction

func set_speed(new_speed: float) -> void:
	if movement_component:
		movement_component.speed = new_speed

func get_speed() -> float:
	return movement_component.speed if movement_component else 0.0
