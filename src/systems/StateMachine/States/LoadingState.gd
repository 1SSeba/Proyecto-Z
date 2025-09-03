extends "res://src/systems/StateMachine/State.gd"
class_name LoadingState
# Estado de carga inicial del juego - simplificado

var loading_progress: float = 0.0

func enter(_previous_state: State = null) -> void:
	if state_machine and state_machine.debug_mode:
		print("🔄 Entering LoadingState")
	
	loading_progress = 0.0
	_start_loading()

func _start_loading():
	"""Inicia el proceso de carga simplificado"""
	# Simular carga básica
	await get_tree().create_timer(1.0).timeout
	loading_progress = 1.0
	
	if state_machine and state_machine.debug_mode:
		print("✅ Loading completed")
	
	# Ir al menú principal
	transition_to("MainMenuState")

func update(_delta: float) -> void:
	# Actualización opcional
	pass

func exit() -> void:
	if state_machine and state_machine.debug_mode:
		print("🔄 Exiting LoadingState")
