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
	if value:
		set_process(true)
		set_physics_process(true)
	else:
		set_process(false)
		set_physics_process(false)
