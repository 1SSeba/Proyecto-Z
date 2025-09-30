extends CharacterBody2D

const Log := preload("res://game/core/utils/Logger.gd")

const DEFAULT_DEBUG_ACTIONS := {
	"debug_damage": KEY_F5,
	"debug_heal": KEY_F6,
	"debug_die": KEY_F7,
	"debug_revive": KEY_F8,
	"debug_toggle_console": KEY_F9,
	"debug_print_info": KEY_F10
}

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
	_ensure_debug_actions()
	await _ensure_services_ready()
	_load_resources()
	_wire_components()
	is_initialized = true
	_log_info("Initialized with modular components")

func _wire_components() -> void:
	if movement_component:
		movement_component.direction_changed.connect(_on_direction_changed)
		movement_component.velocity_changed.connect(_on_velocity_changed)
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_component.damaged.connect(_on_damaged)
		health_component.died.connect(_on_died)
		health_changed.emit(health_component.current_health, health_component.max_health)

	_log_info("Components wired")

func _load_resources() -> void:
	if ServiceManager and ServiceManager.has_service("ResourceLibrary"):
		resource_library = ServiceManager.get_service("ResourceLibrary")

		# Buscar recursos de sprites del jugador
		var sprite_resources = resource_library.get_resources_by_tag("player")
		if sprite_resources.size() > 0:
			player_sprites = load(sprite_resources[0])
		else:
			_log_warn("No player sprite resources found in ResourceLibrary")
	else:
		_log_warn("ResourceLibrary service not available")

	_log_info("Resources loaded")

func _ensure_services_ready() -> void:
	if not ServiceManager:
		return

	await ServiceManager.wait_for_services(["GameFlowController", "ResourceLibrary"])

func _physics_process(_delta: float) -> void:
	if not is_initialized:
		return

	_handle_debug_input()

	if not is_player_alive():
		return

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
		_log_info("Took damage: %.1f, Health: %.1f/%.1f" % [damage_amount, health_component.current_health, health_component.max_health])
	damaged.emit(damage_amount)

func _on_died() -> void:
	if movement_component:
		movement_component.set_enabled(false)
	velocity = Vector2.ZERO
	_log_warn("Died")
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
		_log_info("Healed: %.1f, Health: %.1f/%.1f" % [heal_amount, health_component.current_health, health_component.max_health])

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
	if was_dead:
		var game_state_manager = _get_game_state_manager()
		if game_state_manager and game_state_manager.has_method("is_playing") and not game_state_manager.call("is_playing"):
			if game_state_manager.has_method("start_game"):
				game_state_manager.start_game()
		if get_tree().paused:
			get_tree().paused = false
	_log_info("Revived")

func _get_game_state_manager() -> Node:
	if ServiceManager:
		var game_flow = ServiceManager.get_game_flow_controller()
		if game_flow and "game_state_manager" in game_flow:
			return game_flow.game_state_manager
	return get_tree().root.get_node_or_null("GameStateManager")

# Debug y testing
func _handle_debug_input() -> void:
	if Input.is_action_just_pressed("debug_revive"):
		revive()

	var game_flow = ServiceManager.get_game_flow_controller() if ServiceManager else null
	if not game_flow or not game_flow.is_playing():
		return

	if Input.is_action_just_pressed("debug_damage"):
		take_damage(10.0)

	if Input.is_action_just_pressed("debug_heal"):
		heal(20.0)

	if Input.is_action_just_pressed("debug_die"):
		die()

	if Input.is_action_just_pressed("debug_print_info"):
		debug_info()

func debug_info() -> void:
	Log.log("=== PLAYER DEBUG INFO ===")
	Log.log("Alive: %s" % is_player_alive())
	if health_component:
		Log.log("Health: %.1f/%.1f" % [health_component.current_health, health_component.max_health])
	Log.log("Position: %s" % global_position)
	Log.log("Velocity: %s" % velocity)
	Log.log("Last Direction: %s" % last_direction)
	Log.log("=========================")

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

# Logging helpers

func _log_info(message: String) -> void:
	Log.info("Player: %s" % message)

func _log_warn(message: String) -> void:
	Log.warn("Player: %s" % message)

func _ensure_debug_actions() -> void:
	for action in DEFAULT_DEBUG_ACTIONS.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var events := InputMap.action_get_events(action)
		if events.size() == 0:
			var event := InputEventKey.new()
			event.physical_keycode = DEFAULT_DEBUG_ACTIONS[action]
			event.keycode = DEFAULT_DEBUG_ACTIONS[action]
			InputMap.action_add_event(action, event)
