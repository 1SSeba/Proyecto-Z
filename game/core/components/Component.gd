extends Node
class_name Component

@export var enabled: bool = true

var owner_actor: Node = null

func _ready() -> void:
	owner_actor = get_parent()
	_on_component_ready()
	_apply_enabled_state(enabled)

func _on_component_ready() -> void:
	# Override in child components for initialization once owner is assigned.
	pass

func get_owner_actor() -> Node:
	return owner_actor

func set_owner_actor(actor: Node) -> void:
	owner_actor = actor

func set_enabled(value: bool) -> void:
	if enabled == value:
		return
	enabled = value
	_apply_enabled_state(value)
	_on_enabled_changed(value)

func _on_enabled_changed(_value: bool) -> void:
	# Override in child components to react to enabled state changes.
	pass

func can_run() -> bool:
	return enabled and owner_actor != null and owner_actor.is_inside_tree()

func _apply_enabled_state(value: bool) -> void:
	# Solo modificar los procesos que el componente realmente necesita
	# Verificamos si el componente tiene implementados los métodos _process o _physics_process
	set_process(value)
	set_physics_process(value)
