class_name GameState
extends Node
# Base class para todos los estados

# Referencias comunes
var state_machine: Node # Será StateMachine pero evitamos dependencia circular
var game_manager: Node

# Métodos virtuales que cada estado debe implementar
func enter(_previous_state: GameState = null) -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

# Métodos de utilidad
func transition_to(state_name: String, data: Dictionary = {}) -> void:
	if state_machine:
		state_machine.transition_to(state_name, data)
	else:
		push_error("No state machine reference found in state: " + name)

func get_state_name() -> String:
	return name

# Debug
func _to_string() -> String:
	return "State: " + get_state_name()
