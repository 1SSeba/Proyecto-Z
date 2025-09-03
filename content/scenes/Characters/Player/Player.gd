extends CharacterBody2D

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
#  REFERENCIAS DE NODOS (CORREGIDAS PARA LA ESTRUCTURA ACTUAL)
# =======================
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Variables de estado
var last_direction: Vector2 = Vector2.DOWN
var is_alive: bool = true
var is_initialized: bool = false

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	# Esperar a que los managers estén listos
	await _wait_for_managers()
	
	# Configurar salud inicial
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
	# Configurar animación inicial
	if animated_sprite:
		animated_sprite.play("Idle_down")  # Usar nombre correcto con mayúscula
	
	is_initialized = true
	print("Player: Ready - Health: %.1f/%.1f" % [current_health, max_health])
	
	# Log al debug system de forma segura
	_log_to_debug("Player initialized at %s" % str(global_position), "green")

func _wait_for_managers():
	"""Espera a que los managers necesarios estén listos"""
	# Esperar un frame para que los autoloads estén completamente listos
	await get_tree().process_frame
	
	# Esperar InputManager si está disponible
	var input_manager = get_node_or_null("/root/InputManager")
	if input_manager and input_manager.has_method("is_ready"):
		while not input_manager.is_ready():
			await get_tree().process_frame
	
	# Esperar GameManager si existe
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_method("is_ready"):
		while not game_manager.is_ready():
			await get_tree().process_frame

# =======================
#  VERIFICACIONES SEGURAS
# =======================
func _is_manager_available(manager_name: String) -> bool:
	return get_node_or_null("/root/" + manager_name) != null

func _log_to_debug(message: String, color: String = "white"):
	"""Envía mensaje al sistema de debug de forma segura"""
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager and debug_manager.has_method("log_to_console"):
		debug_manager.log_to_console(message, color)

# =======================
#  MOVIMIENTO
# =======================
func _physics_process(delta):
	if not is_alive or not is_initialized:
		return
	
	# Solo moverse si estamos en gameplay (verificación segura)
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager and game_state_manager.has_method("is_playing"):
		if not game_state_manager.is_playing():
			return
	
	handle_movement(delta)
	handle_animations()

func handle_movement(delta):
	"""Maneja el movimiento del jugador"""
	var input_direction = Vector2.ZERO
	
	# Obtener input de movimiento (con fallback seguro)
	var input_manager = get_node_or_null("/root/InputManager")
	if input_manager and input_manager.has_method("get_movement_vector"):
		input_direction = input_manager.get_movement_vector()
	else:
		# Fallback a input directo
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Aplicar movimiento
	if input_direction != Vector2.ZERO:
		last_direction = input_direction
		velocity = velocity.move_toward(input_direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Mover el personaje
	move_and_slide()

func handle_animations():
	"""Maneja las animaciones del jugador"""
	if not animated_sprite:
		return
	
	if velocity.length() > 10.0:  # Moviéndose
		handle_running_animation(last_direction)
	else:  # Idle
		handle_idle_animation()

func handle_running_animation(direction: Vector2):
	"""Maneja animaciones de correr"""
	var animation_to_play = ""
	
	if abs(direction.x) > abs(direction.y):
		animation_to_play = "Run_right" if direction.x > 0 else "Run_left"
	else:
		animation_to_play = "Run_down" if direction.y > 0 else "Run_up"
	
	_play_animation_safe(animation_to_play)

func handle_idle_animation():
	"""Maneja animaciones idle"""
	var animation_to_play = ""
	
	if abs(last_direction.x) > abs(last_direction.y):
		animation_to_play = "Idle_right" if last_direction.x > 0 else "Idle_left"
	else:
		animation_to_play = "Idle_down" if last_direction.y > 0 else "Idle_up"
	
	_play_animation_safe(animation_to_play)

func _play_animation_safe(animation_name: String):
	"""Reproduce una animación verificando que existe"""
	if animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation(animation_name):
			animated_sprite.play(animation_name)
		else:
			print("Player: Animation '%s' not found, playing default" % animation_name)
			if animated_sprite.sprite_frames.has_animation("Idle_down"):
				animated_sprite.play("Idle_down")
			else:
				print("Player: Warning - Even default animation 'Idle_down' not found!")

# =======================
#  SISTEMA DE SALUD
# =======================
func take_damage(damage_amount: float) -> bool:
	"""Recibe daño"""
	if not is_alive or is_invulnerable:
		return false
	
	# Reducir salud
	current_health -= damage_amount
	current_health = max(0, current_health)
	
	# Emitir señales
	damaged.emit(damage_amount)
	health_changed.emit(current_health, max_health)
	
	# Activar invulnerabilidad temporal
	make_invulnerable()
	
	# Efectos visuales de daño
	_show_damage_effect()
	
	print("Player: Took %.1f damage (%.1f/%.1f HP remaining)" % [damage_amount, current_health, max_health])
	_log_to_debug("Player damaged: %.1f (%.1f HP left)" % [damage_amount, current_health], "red")
	
	# Verificar muerte
	if current_health <= 0:
		die()
		return true
	
	return true

func heal(heal_amount: float):
	"""Cura al jugador"""
	if not is_alive:
		return
	
	var old_health = current_health
	current_health = min(max_health, current_health + heal_amount)
	
	if current_health > old_health:
		health_changed.emit(current_health, max_health)
		print("Player: Healed for %.1f (%.1f/%.1f HP)" % [current_health - old_health, current_health, max_health])

func die():
	"""Mata al jugador"""
	if not is_alive:
		return
	
	is_alive = false
	current_health = 0
	
	# Parar movimiento
	velocity = Vector2.ZERO
	
	# Animación de muerte
	_play_death_animation()
	
	# Emitir señal
	died.emit()
	
	print("Player: Died!")
	_log_to_debug("Player DIED", "red")

func revive():
	"""Revive al jugador (para respawn)"""
	is_alive = true
	current_health = max_health
	is_invulnerable = false
	
	health_changed.emit(current_health, max_health)
	
	if animated_sprite:
		animated_sprite.play("Idle_down")
	
	print("Player: Revived with full health")
	_log_to_debug("Player revived", "green")

func make_invulnerable():
	"""Hace al jugador invulnerable temporalmente"""
	if is_invulnerable:
		return
	
	is_invulnerable = true
	
	# Efecto visual de invulnerabilidad
	_start_invulnerability_effect()
	
	# Timer para terminar invulnerabilidad
	get_tree().create_timer(invulnerability_duration).timeout.connect(_end_invulnerability, CONNECT_ONE_SHOT)

func _end_invulnerability():
	"""Termina la invulnerabilidad"""
	is_invulnerable = false
	_stop_invulnerability_effect()

# =======================
#  EFECTOS VISUALES
# =======================
func _show_damage_effect():
	"""Efecto visual al recibir daño"""
	if not animated_sprite:
		return
	
	# Flash rojo rápido
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

func _play_death_animation():
	"""Reproduce animación de muerte"""
	if animated_sprite:
		animated_sprite.play("Idle_down")  # Fallback hasta que tengas animación de muerte
		animated_sprite.modulate = Color.GRAY

func _start_invulnerability_effect():
	"""Inicia efecto visual de invulnerabilidad"""
	if not animated_sprite:
		return
	
	# Parpadeo durante invulnerabilidad
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(animated_sprite, "modulate:a", 0.5, 0.1)
	tween.tween_property(animated_sprite, "modulate:a", 1.0, 0.1)

func _stop_invulnerability_effect():
	"""Termina efecto visual de invulnerabilidad"""
	if animated_sprite:
		animated_sprite.modulate = Color.WHITE

# =======================
#  INPUT HANDLING - SIN CONFLICTOS CON DEBUG
# =======================
func _unhandled_input(event):
	"""Maneja inputs específicos del jugador - usa _unhandled_input para evitar conflictos"""
	if not is_alive or not is_initialized:
		return
	
	# Solo procesar input durante gameplay (verificación segura)
	var game_state_manager = get_node_or_null("/root/GameStateManager")
	if game_state_manager and game_state_manager.has_method("is_playing"):
		if not game_state_manager.is_playing():
			return
	
	# Solo procesar eventos de teclado presionados
	if not event is InputEventKey or not event.pressed:
		return
	
	# Manejar acciones específicas (evitar teclas de debug)
	var input_manager = get_node_or_null("/root/InputManager")
	if input_manager and input_manager.has_method("is_action_just_pressed"):
		if input_manager.is_action_just_pressed("interact"):
			handle_interact()
	else:
		if Input.is_action_just_pressed("ui_accept"):
			handle_interact()

func handle_interact():
	"""Maneja la acción de interactuar"""
	print("Player: Interact!")
	_log_to_debug("Player interaction!", "cyan")

# =======================
#  GETTERS Y SETTERS
# =======================
func get_health() -> float:
	return current_health

func get_max_health() -> float:
	return max_health

func get_health_percentage() -> float:
	if max_health == 0:
		return 0.0
	return current_health / max_health

func is_player_alive() -> bool:
	return is_alive

func is_player_invulnerable() -> bool:
	return is_invulnerable

func get_current_direction() -> Vector2:
	return last_direction

func set_speed(new_speed: float):
	speed = new_speed

func set_max_health(new_max_health: float):
	max_health = new_max_health
	current_health = min(current_health, max_health)
	health_changed.emit(current_health, max_health)

# =======================
#  UTILIDADES
# =======================
func teleport_to(target_position: Vector2):
	"""Teletransporta al jugador"""
	global_position = target_position
	velocity = Vector2.ZERO
	_log_to_debug("Player teleported to %s" % str(target_position), "yellow")

func reset_player():
	"""Resetea el jugador a estado inicial"""
	revive()
	velocity = Vector2.ZERO
	last_direction = Vector2.DOWN

# =======================
#  FUNCIONES DE DEBUG
# =======================
func debug_damage(amount: float = 25.0):
	"""Debug: daña al jugador"""
	take_damage(amount)

func debug_heal(amount: float = 25.0):
	"""Debug: cura al jugador"""
	heal(amount)

func debug_kill():
	"""Debug: mata al jugador"""
	take_damage(current_health)

func debug_info():
	"""Muestra información de debug del jugador"""
	print("=== PLAYER DEBUG INFO ===")
	print("Position: %s" % str(global_position))
	print("Velocity: %s (speed: %.1f)" % [str(velocity), velocity.length()])
	print("Health: %.1f/%.1f (%.1f%%)" % [current_health, max_health, get_health_percentage() * 100])
	print("Alive: %s" % is_alive)
	print("Invulnerable: %s" % is_invulnerable)
	print("Last Direction: %s" % str(last_direction))
	if animated_sprite:
		print("Current Animation: %s" % animated_sprite.animation)
	print("==========================")
	
	# También enviar al debug console
	_log_to_debug("=== PLAYER DEBUG INFO ===", "cyan")
	_log_to_debug("Position: %s" % str(global_position), "white")
	_log_to_debug("Health: %.1f/%.1f" % [current_health, max_health], "green")
	_log_to_debug("Velocity: %.1f" % velocity.length(), "white")

func force_debug_init():
	"""Fuerza inicialización de debug"""
	print("Player: Force debug init called")
	_log_to_debug("Player force debug initialized", "yellow")

func get_movement_input() -> Vector2:
	"""Obtiene el input de movimiento actual"""
	var input_manager = get_node_or_null("/root/InputManager")
	if input_manager and input_manager.has_method("get_movement_vector"):
		return input_manager.get_movement_vector()
	else:
		return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
