extends Node
class_name Component

signal component_ready()
signal component_destroyed()

@export var component_id: String = ""
@export var auto_initialize: bool = true
@export var enabled: bool = true

var is_component_ready: bool = false
var owner_entity: Node
var dependencies: Array[Component] = []

func _ready():
	if auto_initialize:
		await initialize_component()

func initialize_component():
	if is_component_ready:
		return

	owner_entity = get_parent()
	await _wait_for_dependencies()
	await _initialize()

	is_component_ready = true
	component_ready.emit()

func _initialize():
	pass

func destroy_component():
	_cleanup()
	component_destroyed.emit()
	queue_free()

func _cleanup():
	pass

func add_dependency(component: Component):
	if component and component not in dependencies:
		dependencies.append(component)

func _wait_for_dependencies():
	for dependency in dependencies:
		if dependency and not dependency.is_component_ready:
			await dependency.component_ready

func enable():
	enabled = true
	set_process(true)
	set_physics_process(true)
	_on_component_enabled()

func disable():
	enabled = false
	set_process(false)
	set_physics_process(false)
	_on_component_disabled()

func _on_component_enabled():
	pass

func _on_component_disabled():
	pass

func get_entity() -> Node:
	return owner_entity

func get_component(component_type: String) -> Component:
	if not owner_entity:
		return null

	for child in owner_entity.get_children():
		if child is Component and child.get_script().get_global_name() == component_type:
			return child

	return null

func has_component(component_type: String) -> bool:
	return get_component(component_type) != null

func is_valid() -> bool:
	return is_component_ready and enabled and owner_entity != null
