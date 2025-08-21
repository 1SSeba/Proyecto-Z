extends "res://Core/StateMachine/State.gd"
class_name PausedState
# Estado de pausa del juego - simplificado

func enter(_previous_state: State = null) -> void:
	if state_machine and state_machine.debug_mode:
		print("⏸️ Entering PausedState")
	
	# Pausar el juego
	get_tree().paused = true
	
	# Notificar via EventBus
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish_game_paused()
	
	# Cambiar contexto de input
	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		if input_manager.has_method("set_context"):
			input_manager.set_context("UI_MENU")

func handle_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE, KEY_P:
				# Reanudar el juego
				_resume_game()
			KEY_M:
				# Volver al menú principal
				_return_to_menu()

func _resume_game():
	"""Reanuda el juego"""
	if state_machine and state_machine.debug_mode:
		print("▶️ Resuming game...")
	
	if has_node("/root/EventBus"):
		var event_bus = get_node("/root/EventBus")
		event_bus.publish_game_resumed()
	
	transition_to("GameplayState")

func _return_to_menu():
	"""Vuelve al menú principal"""
	if state_machine and state_machine.debug_mode:
		print("🏠 Returning to main menu...")
	
	# Primero despausar
	get_tree().paused = false
	
	transition_to("MainMenuState")

func exit() -> void:
	if state_machine and state_machine.debug_mode:
		print("⏸️ Exiting PausedState")
	
	# Despausar el juego
	get_tree().paused = false
