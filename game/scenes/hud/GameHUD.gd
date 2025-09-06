extends Control
# GameHUD.gd - HUD simple para pre-alpha

# Referencias
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_text: Label = $HealthText
@onready var fps_label: Label = $FPSLabel
@onready var movement_keys: VBoxContainer = $MovementKeys
@onready var console_logs: VBoxContainer = $ConsoleLogs

# Variables
var player_reference: CharacterBody2D = null
var console_messages: Array[String] = []

func _ready():
	print("GameHUD: Ready")
	_load_resources()
	_setup_movement_keys()
	_connect_to_player()

func _load_resources():
	"""Carga recursos del juego"""
	# Buscar ResourceLoader
	var resource_loader = get_node("/root/ResourceLoader")
	if not resource_loader:
		resource_loader = preload("res://game/core/ResourceLoader.gd").new()
		get_tree().root.add_child(resource_loader)

	# Aplicar colores del juego
	_apply_game_colors()

func _apply_game_colors():
	"""Aplica colores del juego al HUD"""
	var resource_loader = get_node("/root/ResourceLoader")
	if not resource_loader:
		return

	# Aplicar colores de fondo
	var bg_color = resource_loader.get_ui_color("ui_background")
	var panel_color = resource_loader.get_ui_color("ui_panel")

	# Aplicar a paneles (si existen)
	# Esto se puede expandir según la estructura del HUD

func _setup_movement_keys():
	"""Muestra las teclas de movimiento"""
	var keys = [
		"WASD - Moverse",
		"SPACE - Interactuar",
		"ESC - Menú"
	]

	for key in keys:
		var label = Label.new()
		label.text = key
		label.add_theme_font_size_override("font_size", 12)
		movement_keys.add_child(label)

func _connect_to_player():
	"""Conecta con el player"""
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("get_player"):
		player_reference = main_scene.get_player()

		if player_reference and player_reference.has_signal("health_changed"):
			player_reference.health_changed.connect(_on_health_changed)

func _process(_delta):
	"""Actualiza FPS"""
	if fps_label:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_health_changed(current: float, max_health: float):
	"""Actualiza la salud"""
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current

	if health_text:
		var percentage = (current / max_health) * 100
		health_text.text = "%.0f/%.0f (%.0f%%)" % [current, max_health, percentage]

	# Añadir a consola
	add_log("Salud: %.0f%%" % ((current / max_health) * 100))

func add_log(message: String):
	"""Añade mensaje a la consola"""
	console_messages.append(message)

	# Limitar mensajes
	if console_messages.size() > 8:
		console_messages.pop_front()

	# Actualizar display
	_update_console()

func _update_console():
	"""Actualiza la consola"""
	# Limpiar
	for child in console_logs.get_children():
		child.queue_free()

	# Mostrar últimos mensajes
	for msg in console_messages:
		var label = Label.new()
		label.text = msg
		label.add_theme_font_size_override("font_size", 10)
		console_logs.add_child(label)
