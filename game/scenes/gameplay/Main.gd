extends Node2D
# Main.gd - Escena principal del juego simplificada

# =======================
#  REFERENCIAS
# =======================
@onready var ui_layer: CanvasLayer = $UILayer
@onready var game_world: Node2D = $GameWorld
@onready var player: CharacterBody2D = $GameWorld/Player
@onready var dungeon_system = $GameWorld/DungeonSystem  # Cambiar tipo para que sea genérico
@onready var game_hud: Control = $UILayer/GameHUD

# Variables de estado
var is_main_ready: bool = false

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("Main: Starting main scene initialization...")
	
	# Verificar que los nodos existen
	if not player:
		print("Main: ERROR - Player not found!")
		return
	
	if not dungeon_system:
		print("Main: ERROR - DungeonSystem not found!")
		return
	
	# Configurar referencias
	_setup_player()
	_setup_dungeon()
	_setup_hud()
	
	# La escena está lista
	is_main_ready = true
	print("Main: Scene ready with player, dungeon system and HUD instantiated")

func _setup_player():
	"""Configura el jugador instanciado"""
	print("Main: Setting up player...")
	
	# Posicionar jugador en el centro temporalmente
	player.global_position = Vector2(640, 360)
	
	# Conectar señales si existen
	if player.has_signal("died"):
		var callable = Callable(self, "_on_player_died")
		if not player.is_connected("died", callable):
			player.died.connect(_on_player_died)
	
	print("Main: Player configured at position: %s" % str(player.global_position))

func _setup_dungeon():
	"""Configura el sistema de mazmorra instanciado"""
	print("Main: Setting up dungeon system...")
	
	# El sistema de mazmorra ya está instanciado como DungeonSystem
	# Conectar señales del sistema si existen
	if dungeon_system.has_signal("room_entered"):
		dungeon_system.room_entered.connect(_on_room_entered)
	
	print("Main: Dungeon system configured successfully")

func _setup_hud():
	"""Configura el HUD del juego"""
	print("Main: Setting up HUD...")
	
	if not game_hud:
		print("Main: WARNING - GameHUD not found!")
		return
	
	# Configurar la referencia del player en el HUD
	if player and game_hud.has_method("set_player_reference"):
		game_hud.set_player_reference(player)
	
	print("Main: HUD configured successfully")

# =======================
#  CALLBACKS
# =======================
func _on_player_died():
	"""Maneja la muerte del jugador"""
	print("Main: Player died!")
	# Aquí podríamos manejar game over, respawn, etc.

func _on_room_entered(room):
	"""Maneja cuando el jugador entra a una nueva habitación"""
	print("Main: Player entered room: %s" % str(room))

# =======================
#  UTILIDADES PÚBLICAS
# =======================
func get_player() -> CharacterBody2D:
	"""Obtiene referencia al jugador"""
	return player

func get_rooms_system() -> RoomsSystem:
	"""Obtiene referencia al sistema de habitaciones"""
	return dungeon_system

func get_game_world() -> Node2D:
	"""Obtiene referencia al contenedor del mundo del juego"""
	return game_world

func get_ui_layer() -> CanvasLayer:
	"""Obtiene referencia a la capa de UI"""
	return ui_layer

func get_hud() -> Control:
	"""Obtiene referencia al HUD del juego"""
	return game_hud

func is_ready() -> bool:
	"""Verifica si la escena principal está lista"""
	return is_main_ready
# =======================
#  DEBUG
# =======================
func _input(event):
	"""Maneja input de debug"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				debug_info()
			KEY_F2:
				debug_reset_player_position()
			KEY_F3:
				debug_test_hud()
			KEY_F4:
				debug_heal_player()
			KEY_F5:
				debug_low_health()

func debug_test_hud():
	"""Debug: Prueba el HUD dañando al jugador"""
	if player:
		player.debug_damage(20.0)
		print("Main: HUD test - player damaged")

func debug_heal_player():
	"""Debug: Cura al jugador completamente"""
	if player:
		player.debug_full_heal()
		print("Main: Player healed completely")

func debug_low_health():
	"""Debug: Establece salud baja"""
	if player:
		player.debug_set_low_health()
		print("Main: Player health set to low")

func debug_reset_player_position():
	"""Debug: Resetea la posición del jugador"""
	if player:
		player.global_position = Vector2(640, 360)
		print("Main: Player position reset to center")

func debug_info():
	"""Muestra información de debug"""
	print("=== MAIN DEBUG INFO ===")
	print("Ready: %s" % is_main_ready)
	
	var player_status = "Present" if player else "None"
	var player_pos = str(player.global_position) if player else "N/A"
	print("Player: %s at %s" % [player_status, player_pos])
	
	print("DungeonSystem: %s" % ("Present" if dungeon_system else "None"))
	print("Game World Children: %d" % game_world.get_child_count())
	print("HUD: %s" % ("Present" if game_hud else "None"))
	print("=======================")
