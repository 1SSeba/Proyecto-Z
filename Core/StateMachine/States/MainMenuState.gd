extends "res://Core/StateMachine/State.gd"
class_name MainMenuState
# Estado del menú principal - simplificado

func enter(_previous_state: State = null) -> void:
	if state_machine and state_machine.debug_mode:
		print("🏠 Entering MainMenuState")
	
	# Notificar que entramos al menú principal
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("menu_entered", {"menu": "main"})
	
	# Configurar input context
	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		if input_manager.has_method("set_context"):
			input_manager.set_context("UI_MENU")

func handle_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# Salir del juego desde el menú principal
				_quit_game()
			KEY_ENTER, KEY_SPACE:
				# Iniciar juego
				_start_game()
			KEY_S:
				# Abrir configuración
				_open_settings()

func _start_game():
	"""Inicia el juego"""
	if state_machine and state_machine.debug_mode:
		print("🎮 Starting game...")
	
	# Notificar via EventBus
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("game_started")
	
	transition_to("GameplayState", {"level": 1})

func _open_settings():
	"""Abre configuración"""
	if state_machine and state_machine.debug_mode:
		print("⚙️ Opening settings...")
	
	transition_to("SettingsState")

func _quit_game():
	"""Cierra el juego"""
	if state_machine and state_machine.debug_mode:
		print("👋 Quitting game...")
	
	get_tree().quit()

func exit() -> void:
	if state_machine and state_machine.debug_mode:
		print("🏠 Exiting MainMenuState")
	
	# Notificar que salimos del menú
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish("menu_exited", {"menu": "main"})
