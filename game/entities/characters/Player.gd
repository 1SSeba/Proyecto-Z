extends CharacterBody2D
# Player.gd - Jugador con recursos .res integrados

# =======================
#  SEÑALES
# =======================
signal died
signal damaged(damage_amount: float)
signal health_changed(current: float, max_health: float)

# =======================
#  VARIABLES DE MOVIMIENTO
# =======================
@export var speed: float = 150.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0

# =======================
#  VARIABLES DE SALUD
# =======================
@export var max_health: float = 100.0
var current_health: float = 100.0
var is_invulnerable: bool = false
var invulnerability_duration: float = 1.0

# =======================
#  REFERENCIAS DE NODOS
# =======================
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Variables de estado
var last_direction: Vector2 = Vector2.DOWN
var is_alive: bool = true
var is_initialized: bool = false

# Referencias a recursos
var resource_loader: Node
var player_sprites: Resource

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	# Esperar a que los managers estén listos
	await _wait_for_managers()

	# Cargar recursos
	_load_resources()

	# Configurar salud inicial
	current_health = max_health
	health_changed.emit(current_health, max_health)

	# Configurar animación inicial
	if animated_sprite:
		animated_sprite.play("Idle_down")

	is_initialized = true
	print("Player: Initialized with resources")

func _load_resources():
	"""Carga los recursos del jugador"""
	# Buscar ResourceLoader en la escena
	resource_loader = get_node("/root/ResourceLoader")
	if not resource_loader:
		# Si no existe, crearlo
		resource_loader = preload("res://game/core/ResourceLoader.gd").new()
		get_tree().root.add_child(resource_loader)

	# Obtener sprites del jugador
	player_sprites = resource_loader.player_sprites
	print("Player: Resources loaded")

func _wait_for_managers():
	"""Espera a que los managers estén listos"""
	var max_wait = 100 # Máximo 100 frames
	var wait_count = 0

	while wait_count < max_wait:
		if GameStateManager and ServiceManager:
			break
			await get_tree().process_frame
		wait_count += 1

# =======================
#  FÍSICA Y MOVIMIENTO
# =======================
func _physics_process(delta):
	if not is_initialized or not is_alive:
		return

	# Solo procesar si el juego está en estado de juego
	if GameStateManager and not GameStateManager.is_playing():
			return

	_handle_movement(delta)
	_handle_animation()
	_handle_debug_input()

func _handle_movement(delta):
	"""Maneja el movimiento del jugador"""
	var input_vector = Vector2.ZERO

	# Obtener input usando InputService si está disponible
	if ServiceManager and ServiceManager.has_service("InputService"):
		var input_service = ServiceManager.get_input_service()
		input_vector = input_service.get_movement_vector()
	else:
		# Fallback a input directo
		input_vector.x = Input.get_axis("move_left", "move_right")
		input_vector.y = Input.get_axis("move_up", "move_down")

	# Normalizar input diagonal
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		last_direction = input_vector

	# Aplicar movimiento
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

func _handle_animation():
	"""Maneja las animaciones del jugador"""
	if not animated_sprite:
		return

	var animation_name = "Idle"

	# Determinar animación basada en movimiento
	if velocity.length() > 0:
		animation_name = "Run"

	# Determinar dirección
	var direction = ""
	if abs(last_direction.x) > abs(last_direction.y)):
		direction = "left" if last_direction.x < 0 else "right"
	else:
		direction = "up" if last_direction.y < 0 else "down"

	# Reproducir animación
	var full_animation = animation_name + "_" + direction
	animated_sprite.play(full_animation)

# =======================
#  SISTEMA DE SALUD
# =======================
func take_damage(damage_amount: float):
	"""Aplica daño al jugador"""
	if is_invulnerable or not is_alive:
		return

	current_health = max(0, current_health - damage_amount)
	health_changed.emit(current_health, max_health)
	damaged.emit(damage_amount)

	print("Player: Took damage: %.1f, Health: %.1f/%.1f" % [damage_amount, current_health, max_health])

	# Hacer invulnerable temporalmente
	_make_invulnerable()

	# Verificar si murió
	if current_health <= 0:
		die()

func heal(heal_amount: float):
	"""Cura al jugador"""
	if not is_alive:
		return

	current_health = min(max_health, current_health + heal_amount)
		health_changed.emit(current_health, max_health)

	print("Player: Healed: %.1f, Health: %.1f/%.1f" % [heal_amount, current_health, max_health])

func die():
	"""Mata al jugador"""
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
	"""Revive al jugador"""
	if is_alive:
		return

	is_alive = true
	current_health = max_health
	health_changed.emit(current_health, max_health)

	print("Player: Revived")

func _make_invulnerable():
	"""Hace al jugador invulnerable temporalmente"""
	is_invulnerable = true
	await get_tree().create_timer(invulnerability_duration).timeout
	is_invulnerable = false

# =======================
#  DEBUG Y TESTING
# =======================
func _handle_debug_input():
	"""Maneja input de debug"""
	if not GameStateManager or not GameStateManager.is_playing():
		return

	# Debug damage (F1)
	if Input.is_action_just_pressed("ui_accept"): # Usar tecla existente
		debug_damage()

	# Debug heal (F2)
	if Input.is_key_pressed(KEY_F2):
		debug_heal()

	# Debug kill (F3)
	if Input.is_key_pressed(KEY_F3):
		debug_kill()

func debug_damage():
	"""Debug: Aplica daño"""
	take_damage(10.0)

func debug_heal():
	"""Debug: Cura"""
	heal(20.0)

func debug_kill():
	"""Debug: Mata al jugador"""
	die()

func debug_info():
	"""Debug: Muestra información"""
	print("=== PLAYER DEBUG INFO ===")
	print("Alive: %s" % is_alive)
	print("Health: %.1f/%.1f" % [current_health, max_health])
	print("Position: %s" % global_position)
	print("Velocity: %s" % velocity)
	print("Last Direction: %s" % last_direction)
	print("Invulnerable: %s" % is_invulnerable)
	print("=========================")

# =======================
#  FUNCIONES PÚBLICAS
# =======================
func get_health_percentage() -> float:
	"""Obtiene el porcentaje de salud"""
	return (current_health / max_health) * 100.0

func is_full_health() -> bool:
	"""Verifica si tiene salud completa"""
	return current_health >= max_health

func get_direction() -> Vector2:
	"""Obtiene la dirección actual"""
	return last_direction

func set_speed(new_speed: float):
	"""Cambia la velocidad del jugador"""
	speed = new_speed

func get_speed() -> float:
	"""Obtiene la velocidad actual"""
	return speed
