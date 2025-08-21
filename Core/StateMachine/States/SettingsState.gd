extends "res://Core/StateMachine/State.gd"
class_name SettingsState
# Estado de configuraciones

var settings_scene: PackedScene
var settings_node: Node
var return_state: String = "MainMenu"

func enter(_previous_state: Node = null) -> void:
	print("⚙️ Entering SettingsState")
	
	# Obtener estado de retorno de los datos de transición
	var data = state_machine.get_transition_data()
	if "return_state" in data:
		return_state = data["return_state"]
	
	# Cargar escena de configuraciones
	_load_settings_scene()
	
	# Configurar input context
	if InputManager:
		InputManager.set_context("UI_MENU")

func _load_settings_scene():
	"""Carga la escena de configuraciones"""
	settings_scene = load("res://Scenes/MainMenu/SettingsMenu.tscn")
	
	if settings_scene:
		settings_node = settings_scene.instantiate()
		get_tree().current_scene.add_child(settings_node)
		
		# Conectar señales si las tiene
		_connect_settings_signals()
	else:
		print("❌ Could not load settings scene")
		transition_to(return_state)

func _connect_settings_signals():
	"""Conecta las señales del menú de configuraciones"""
	if settings_node:
		# Buscar señales específicas del menú de settings
		if settings_node.has_signal("settings_closed"):
			settings_node.settings_closed.connect(_on_settings_closed)
		if settings_node.has_signal("back_requested"):
			settings_node.back_requested.connect(_on_back_requested)

func _on_settings_closed():
	"""Maneja el cierre de configuraciones"""
	transition_to(return_state)

func _on_back_requested():
	"""Maneja el botón de volver"""
	transition_to(return_state)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# ESC vuelve al estado anterior
		transition_to(return_state)

func update(_delta: float) -> void:
	pass

func exit() -> void:
	print("⚙️ Exiting SettingsState")
	
	# Limpiar escena de configuraciones
	if settings_node:
		settings_node.queue_free()
		settings_node = null
