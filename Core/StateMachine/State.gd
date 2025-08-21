class_name State
extends Node
# Base class para todos los estados

# Referencias comunes
var state_machine: Node  # Será StateMachine pero evitamos dependencia circular
var game_manager: Node

# Métodos virtuales que cada estado debe implementar
func enter(_previous_state: State = null) -> void:
	"""Llamado cuando se entra al estado"""
	pass

func exit() -> void:
	"""Llamado cuando se sale del estado"""
	pass

func update(_delta: float) -> void:
	"""Llamado cada frame mientras el estado está activo"""
	pass

func handle_input(_event: InputEvent) -> void:
	"""Maneja eventos de input específicos del estado"""
	pass

func physics_update(_delta: float) -> void:
	"""Llamado cada physics frame"""
	pass

# Métodos de utilidad
func transition_to(state_name: String, data: Dictionary = {}) -> void:
	"""Transición a otro estado"""
	if state_machine:
		state_machine.transition_to(state_name, data)
	else:
		push_error("No state machine reference found in state: " + name)

func get_state_name() -> String:
	"""Retorna el nombre del estado"""
	return name

# Debug
func _to_string() -> String:
	return "State: " + get_state_name()
