extends Control
# GameHUD.gd - HUD simple del juego

# =======================
#  REFERENCIAS
# =======================
@onready var health_bar: ProgressBar = $TopBar/HealthContainer/HealthBar
@onready var health_text: Label = $TopBar/HealthContainer/HealthText
@onready var score_label: Label = $TopBar/ScoreContainer/ScoreLabel
@onready var level_label: Label = $TopBar/ScoreContainer/LevelLabel
@onready var position_label: Label = $BottomInfo/InfoContainer/PositionLabel
@onready var fps_label: Label = $BottomInfo/InfoContainer/FPSLabel

# =======================
#  VARIABLES
# =======================
var player_reference: CharacterBody2D = null
var current_score: int = 0
var current_level: int = 1
var is_ready: bool = false

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("GameHUD: Initializing...")
	
	# Configurar HUD inicial
	_setup_initial_values()
	
	# Intentar conectar con el player
	_connect_to_player()
	
	is_ready = true
	print("GameHUD: Ready")

func _setup_initial_values():
	"""Configura los valores iniciales del HUD"""
	if health_bar:
		health_bar.max_value = 100.0
		health_bar.value = 100.0
	
	if health_text:
		health_text.text = "100/100"
	
	if score_label:
		score_label.text = "Score: 0"
	
	if level_label:
		level_label.text = "Level: 1"
	
	if position_label:
		position_label.text = "Position: (0, 0)"
	
	if fps_label:
		fps_label.text = "FPS: 60"

func _connect_to_player():
	"""Intenta conectar con el player"""
	# Buscar el player en la escena
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("get_player"):
		player_reference = main_scene.get_player()
		
		if player_reference:
			# Conectar señales del player
			if player_reference.has_signal("health_changed"):
				var callable = Callable(self, "_on_player_health_changed")
				if not player_reference.is_connected("health_changed", callable):
					player_reference.health_changed.connect(_on_player_health_changed)
			
			if player_reference.has_signal("died"):
				var callable = Callable(self, "_on_player_died")
				if not player_reference.is_connected("died", callable):
					player_reference.died.connect(_on_player_died)
			
			print("GameHUD: Connected to player successfully")
		else:
			print("GameHUD: Player not found, will retry later")
			# Intentar de nuevo después de un frame
			await get_tree().process_frame
			_connect_to_player()

# =======================
#  ACTUALIZACIÓN
# =======================
func _process(_delta):
	"""Actualiza elementos del HUD que cambian constantemente"""
	if not is_ready:
		return
	
	# Actualizar FPS
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	
	# Actualizar posición del player si existe
	if player_reference and position_label:
		var pos = player_reference.global_position
		position_label.text = "Position: (%d, %d)" % [pos.x, pos.y]

# =======================
#  CALLBACKS DEL PLAYER
# =======================
func _on_player_health_changed(current: float, max_health: float):
	"""Actualiza la barra de vida cuando cambia la salud del player"""
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current
	
	if health_text:
		health_text.text = "%.0f/%.0f" % [current, max_health]
	
	print("GameHUD: Health updated - %.0f/%.0f" % [current, max_health])

func _on_player_died():
	"""Maneja cuando el player muere"""
	print("GameHUD: Player died")
	# Aquí podríamos mostrar un mensaje de muerte, etc.

# =======================
#  FUNCIONES PÚBLICAS
# =======================
func update_score(new_score: int):
	"""Actualiza el puntaje"""
	current_score = new_score
	if score_label:
		score_label.text = "Score: %d" % current_score

func update_level(new_level: int):
	"""Actualiza el nivel"""
	current_level = new_level
	if level_label:
		level_label.text = "Level: %d" % current_level

func add_score(points: int):
	"""Añade puntos al puntaje actual"""
	current_score += points
	update_score(current_score)

func set_player_reference(player: CharacterBody2D):
	"""Establece la referencia al player manualmente"""
	player_reference = player
	_connect_to_player()

# =======================
#  UTILIDADES
# =======================
func show_hud():
	"""Muestra el HUD"""
	visible = true

func hide_hud():
	"""Oculta el HUD"""
	visible = false

func toggle_hud():
	"""Alterna la visibilidad del HUD"""
	visible = not visible

# =======================
#  DEBUG
# =======================
func debug_info():
	"""Muestra información de debug del HUD"""
	print("=== HUD DEBUG INFO ===")
	print("Ready: %s" % is_ready)
	print("Player Connected: %s" % ("Yes" if player_reference else "No"))
	print("Score: %d" % current_score)
	print("Level: %d" % current_level)
	print("Visible: %s" % visible)
	print("======================")
