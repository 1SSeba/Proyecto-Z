# GameManager.gd - Básico para roguelike
extends Node

# =======================
#  SEÑALES
# =======================
signal player_spawned(player: Node)
signal player_died
signal player_health_changed(current: float, max_health: float)
signal room_completed
signal enemy_defeated(enemy_name: String)

# =======================
#  CONSTANTES
# =======================
const PLAYER_SCENE = preload("res://content/scenes/Characters/Player/Player.tscn")
const DEFAULT_SPAWN_POINT = Vector2(400, 300)

# Scene preloading optimizado
const CRITICAL_SCENES = {
	"main_menu": "res://content/scenes/Menus/MainMenuModular.tscn",
	"settings_menu": "res://content/scenes/Menus/SettingsMenu.tscn",
	"world": "res://content/scenes/World/world.tscn"
}

# =======================
#  VARIABLES DEL JUGADOR
# =======================
var is_initialized: bool = false
var player: CharacterBody2D = null
var spawn_point: Vector2 = DEFAULT_SPAWN_POINT

# Scene preloading cache
var preloaded_scenes: Dictionary = {}
var scene_loading_queue: Array[String] = []
var is_preloading: bool = false

# Sistema básico de vida
var player_max_health: float = 100.0
var player_current_health: float = 100.0
var is_player_invulnerable: bool = false
var invulnerability_duration: float = 1.0

# =======================
#  VARIABLES DE ROGUELIKE
# =======================
var current_room: int = 1
var total_rooms_per_run: int = 10
var enemies_in_room: int = 0
var enemies_defeated_in_room: int = 0
var total_enemies_defeated: int = 0

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("GameManager: Starting initialization...")
	
	# Esperar a GameStateManager
	if _is_game_state_manager_available():
		while not GameStateManager.is_ready():
			await get_tree().process_frame
		
		# Conectar señales de GameStateManager
		GameStateManager.player_spawned.connect(_on_player_spawn_requested)
		GameStateManager.player_died.connect(_on_player_death_requested)
		GameStateManager.run_started.connect(_on_run_started)
		GameStateManager.run_completed.connect(_on_run_completed)
		GameStateManager.run_failed.connect(_on_run_failed)
		
		print("GameManager: Connected to GameStateManager")
	
	is_initialized = true
	
	# Iniciar preloading de escenas críticas
	_start_scene_preloading()
	
	print("GameManager: Initialization complete with scene preloading")

# =======================
#  SCENE PRELOADING OPTIMIZADO
# =======================

func _start_scene_preloading():
	"""Inicia el preloading asíncrono de escenas críticas"""
	print("GameManager: Starting scene preloading...")
	
	for scene_name in CRITICAL_SCENES.keys():
		scene_loading_queue.append(scene_name)
	
	_preload_next_scene()

func _preload_next_scene():
	"""Precarga la siguiente escena en la cola"""
	if scene_loading_queue.is_empty() or is_preloading:
		return
	
	is_preloading = true
	var scene_name = scene_loading_queue.pop_front()
	var scene_path = CRITICAL_SCENES[scene_name]
	
	# Verificar si la escena existe
	if not ResourceLoader.exists(scene_path):
		print("GameManager: Scene not found: %s" % scene_path)
		is_preloading = false
		_preload_next_scene()
		return
	
	# Precargar de forma asíncrona
	var request = ResourceLoader.load_threaded_request(scene_path)
	if request == OK:
		_wait_for_scene_load(scene_name, scene_path)
	else:
		print("GameManager: Failed to start loading: %s" % scene_path)
		is_preloading = false
		_preload_next_scene()

func _wait_for_scene_load(scene_name: String, scene_path: String):
	"""Espera a que termine de cargar una escena"""
	while true:
		var progress = []
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var scene = ResourceLoader.load_threaded_get(scene_path)
				if scene:
					preloaded_scenes[scene_name] = scene
					print("GameManager: Preloaded scene: %s" % scene_name)
				break
			ResourceLoader.THREAD_LOAD_FAILED:
				print("GameManager: Failed to preload scene: %s" % scene_path)
				break
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				print("GameManager: Invalid resource: %s" % scene_path)
				break
		
		await get_tree().process_frame
	
	is_preloading = false
	_preload_next_scene()

func get_preloaded_scene(scene_name: String) -> PackedScene:
	"""Obtiene una escena precargada"""
	if preloaded_scenes.has(scene_name):
		return preloaded_scenes[scene_name]
	
	print("GameManager: Scene not preloaded: %s" % scene_name)
	return null

func is_scene_preloaded(scene_name: String) -> bool:
	"""Verifica si una escena está precargada"""
	return preloaded_scenes.has(scene_name)

func get_preloading_stats() -> Dictionary:
	"""Retorna estadísticas del preloading"""
	return {
		"preloaded_count": preloaded_scenes.size(),
		"queue_remaining": scene_loading_queue.size(),
		"is_preloading": is_preloading,
		"preloaded_scenes": preloaded_scenes.keys()
	}

# =======================
#  VERIFICACIONES
# =======================
func _is_game_state_manager_available() -> bool:
	return get_node_or_null("/root/GameStateManager") != null

func is_ready() -> bool:
	return is_initialized

# =======================
#  GESTIÓN DEL JUGADOR
# =======================
func spawn_player(position: Vector2 = Vector2.ZERO) -> CharacterBody2D:
	"""Spawna al jugador"""
	
	# Remover jugador existente
	if player and is_instance_valid(player):
		player.queue_free()
		player = null
	
	# Verificar scene del jugador
	if not PLAYER_SCENE:
		print("GameManager: ERROR - No player scene configured")
		return null
	
	# Crear jugador
	player = PLAYER_SCENE.instantiate()
	if not player:
		print("GameManager: ERROR - Failed to instantiate player")
		return null
	
	# Configurar posición
	var spawn_pos = position if position != Vector2.ZERO else spawn_point
	player.global_position = spawn_pos
	
	# Agregar al scene tree
	var current_scene = get_tree().current_scene
	if not current_scene:
		print("GameManager: ERROR - No current scene to add player")
		player.queue_free()
		return null
	
	current_scene.add_child(player)
	
	# Configurar salud
	player_current_health = player_max_health
	player_health_changed.emit(player_current_health, player_max_health)
	
	# Conectar señales del jugador si existen
	_connect_player_signals()
	
	player_spawned.emit(player)
	print("GameManager: Player spawned at %s" % str(spawn_pos))
	
	return player

func _connect_player_signals():
	"""Conecta señales del jugador"""
	if not player:
		return
	
	# Intentar conectar señales comunes del jugador
	if player.has_signal("died"):
		if not player.died.is_connected(_on_player_died_signal):
			player.died.connect(_on_player_died_signal)
	
	if player.has_signal("damaged"):
		if not player.damaged.is_connected(_on_player_damaged_signal):
			player.damaged.connect(_on_player_damaged_signal)

func get_player() -> CharacterBody2D:
	return player

func is_player_valid() -> bool:
	return player != null and is_instance_valid(player)

func set_spawn_point(position: Vector2):
	spawn_point = position
	print("GameManager: Spawn point set to %s" % str(position))

# =======================
#  SISTEMA DE SALUD
# =======================
func damage_player(damage: float):
	"""Daña al jugador"""
	if is_player_invulnerable or not is_player_valid():
		return false
	
	player_current_health -= damage
	player_current_health = max(0, player_current_health)
	
	player_health_changed.emit(player_current_health, player_max_health)
	
	# Invulnerabilidad temporal
	make_player_invulnerable()
	
	print("GameManager: Player damaged for %.1f (remaining: %.1f)" % [damage, player_current_health])
	
	# Verificar muerte
	if player_current_health <= 0:
		kill_player()
		return true
	
	return true

func heal_player(heal_amount: float):
	"""Cura al jugador"""
	if not is_player_valid():
		return
	
	var old_health = player_current_health
	player_current_health = min(player_max_health, player_current_health + heal_amount)
	
	if player_current_health > old_health:
		player_health_changed.emit(player_current_health, player_max_health)
		print("GameManager: Player healed for %.1f" % (player_current_health - old_health))

func kill_player():
	"""Mata al jugador"""
	if not is_player_valid():
		return
	
	player_died.emit()
	print("GameManager: Player died!")
	
	# Notificar a GameStateManager que falle la run
	if _is_game_state_manager_available():
		GameStateManager.fail_run()

func make_player_invulnerable():
	"""Hace al jugador invulnerable temporalmente"""
	if is_player_invulnerable:
		return
	
	is_player_invulnerable = true
	print("GameManager: Player invulnerable for %.1fs" % invulnerability_duration)
	
	get_tree().create_timer(invulnerability_duration).timeout.connect(_end_invulnerability, CONNECT_ONE_SHOT)

func _end_invulnerability():
	is_player_invulnerable = false

# =======================
#  SISTEMA DE HABITACIONES
# =======================
func start_room(room_number: int):
	"""Inicia una nueva habitación"""
	current_room = room_number
	enemies_defeated_in_room = 0
	
	# Generar enemigos para esta habitación
	enemies_in_room = _generate_enemies_for_room(room_number)
	
	print("GameManager: Started room %d with %d enemies" % [current_room, enemies_in_room])

func _generate_enemies_for_room(room_number: int) -> int:
	"""Genera la cantidad de enemigos para una habitación"""
	# Más enemigos en habitaciones posteriores
	var base_enemies = 3
	var extra_enemies = (room_number - 1) / 2.0
	return base_enemies + int(extra_enemies)

func defeat_enemy(enemy_name: String = ""):
	"""Registra la derrota de un enemigo"""
	enemies_defeated_in_room += 1
	total_enemies_defeated += 1
	
	enemy_defeated.emit(enemy_name)
	print("GameManager: Enemy defeated (%d/%d in room)" % [enemies_defeated_in_room, enemies_in_room])
	
	# Verificar si la habitación está completada
	if enemies_defeated_in_room >= enemies_in_room:
		complete_room()

func complete_room():
	"""Completa la habitación actual"""
	room_completed.emit()
	print("GameManager: Room %d completed!" % current_room)
	
	# Verificar si es la última habitación
	if current_room >= total_rooms_per_run:
		# Run completada
		if _is_game_state_manager_available():
			GameStateManager.complete_run()
	else:
		# Ir a siguiente habitación después de un delay
		get_tree().create_timer(2.0).timeout.connect(_proceed_to_next_room, CONNECT_ONE_SHOT)

func _proceed_to_next_room():
	"""Procede a la siguiente habitación"""
	start_room(current_room + 1)
	
	# Curar un poco al jugador entre habitaciones
	heal_player(20.0)

# =======================
#  EVENTOS DE GAMESTATEMANAGER
# =======================
func _on_player_spawn_requested():
	"""GameStateManager solicita spawn del jugador"""
	spawn_player()

func _on_player_death_requested():
	"""GameStateManager notifica muerte del jugador"""
	# Ya manejado en kill_player()
	pass

func _on_run_started(run_number: int):
	"""Maneja el inicio de una nueva run"""
	print("GameManager: Starting run #%d" % run_number)
	
	# Resetear variables de run
	current_room = 1
	total_enemies_defeated = 0
	
	# Resetear salud del jugador
	player_current_health = player_max_health
	player_health_changed.emit(player_current_health, player_max_health)
	
	# Iniciar primera habitación
	start_room(1)

func _on_run_completed(run_number: int, time_elapsed: float):
	"""Maneja la completación de una run"""
	print("GameManager: Run #%d completed! Time: %.2fs, Enemies defeated: %d" % [
		run_number, time_elapsed, total_enemies_defeated
	])

func _on_run_failed(run_number: int, time_elapsed: float):
	"""Maneja el fallo de una run"""
	print("GameManager: Run #%d failed after %.2fs, Enemies defeated: %d" % [
		run_number, time_elapsed, total_enemies_defeated
	])

# =======================
#  SEÑALES DEL JUGADOR
# =======================
func _on_player_died_signal():
	"""Señal del jugador de muerte"""
	kill_player()

func _on_player_damaged_signal(damage_amount: float):
	"""Señal del jugador de daño recibido"""
	print("GameManager: Player reported taking %.1f damage" % damage_amount)

# =======================
#  GETTERS
# =======================
func get_player_health() -> float:
	return player_current_health

func get_player_max_health() -> float:
	return player_max_health

func get_current_room() -> int:
	return current_room

func get_enemies_in_room() -> int:
	return enemies_in_room

func get_enemies_defeated_in_room() -> int:
	return enemies_defeated_in_room

func get_total_enemies_defeated() -> int:
	return total_enemies_defeated

func get_room_progress() -> float:
	"""Obtiene el progreso de la habitación (0.0 a 1.0)"""
	if enemies_in_room == 0:
		return 1.0
	return float(enemies_defeated_in_room) / float(enemies_in_room)

func get_run_progress() -> float:
	"""Obtiene el progreso de la run (0.0 a 1.0)"""
	return float(current_room - 1) / float(total_rooms_per_run)

# =======================
#  CONFIGURACIÓN
# =======================
func set_player_max_health(new_max_health: float):
	player_max_health = new_max_health
	if player_current_health > player_max_health:
		player_current_health = player_max_health
	player_health_changed.emit(player_current_health, player_max_health)

func set_total_rooms_per_run(rooms: int):
	total_rooms_per_run = max(1, rooms)
	print("GameManager: Set total rooms per run to %d" % total_rooms_per_run)

# =======================
#  INFORMACIÓN DEL JUEGO
# =======================
func get_game_info() -> Dictionary:
	"""Obtiene información del estado actual del juego"""
	return {
		"player_valid": is_player_valid(),
		"player_health": player_current_health,
		"player_max_health": player_max_health,
		"current_room": current_room,
		"total_rooms": total_rooms_per_run,
		"enemies_in_room": enemies_in_room,
		"enemies_defeated_in_room": enemies_defeated_in_room,
		"total_enemies_defeated": total_enemies_defeated,
		"room_progress": get_room_progress(),
		"run_progress": get_run_progress(),
		"invulnerable": is_player_invulnerable
	}

# =======================
#  FUNCIONES DE DEBUG
# =======================
func debug_game_info():
	"""Muestra información de debug"""
	print("=== GAME MANAGER DEBUG ===")
	print("Initialized: %s" % is_initialized)
	print("Player Valid: %s" % is_player_valid())
	if is_player_valid():
		print("Player Position: %s" % str(player.global_position))
	print("Spawn Point: %s" % str(spawn_point))
	print("")
	print("=== PLAYER STATUS ===")
	print("Health: %.1f/%.1f" % [player_current_health, player_max_health])
	print("Invulnerable: %s" % is_player_invulnerable)
	print("")
	print("=== ROOM STATUS ===")
	print("Current Room: %d/%d" % [current_room, total_rooms_per_run])
	print("Enemies: %d/%d defeated" % [enemies_defeated_in_room, enemies_in_room])
	print("Room Progress: %.1f%%" % (get_room_progress() * 100))
	print("Run Progress: %.1f%%" % (get_run_progress() * 100))
	print("Total Enemies Defeated: %d" % total_enemies_defeated)
	print("==========================")

func debug_damage_player(amount: float = 25.0):
	"""Debug: daña al jugador"""
	damage_player(amount)

func debug_heal_player(amount: float = 25.0):
	"""Debug: cura al jugador"""
	heal_player(amount)

func debug_complete_room():
	"""Debug: completa la habitación actual"""
	enemies_defeated_in_room = enemies_in_room
	complete_room()

func debug_defeat_enemy():
	"""Debug: derrota un enemigo"""
	defeat_enemy("debug_enemy")

func debug_next_room():
	"""Debug: va a la siguiente habitación"""
	complete_room()

func debug_kill_player():
	"""Debug: mata al jugador"""
	kill_player()

func debug_reset_health():
	"""Debug: resetea salud a máximo"""
	player_current_health = player_max_health
	player_health_changed.emit(player_current_health, player_max_health)

# =======================
#  CLEANUP
# =======================
func _exit_tree():
	if player and is_instance_valid(player):
		player.queue_free()
	
	print("GameManager: Cleanup complete")
