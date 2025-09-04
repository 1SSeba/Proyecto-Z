extends Node
class_name Component

## Base Component Class
## Professional component-based architecture for indie/roguelike games
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  COMPONENT BASE INTERFACE
# ============================================================================

signal component_ready()
signal component_destroyed()

# ============================================================================
#  CORE PROPERTIES
# ============================================================================

@export var component_id: String = ""
@export var auto_initialize: bool = true
@export var enabled: bool = true

var is_component_ready: bool = false
var owner_entity: Node
var dependencies: Array[Component] = []

# ============================================================================
#  LIFECYCLE
# ============================================================================

func _ready():
	if auto_initialize:
		await initialize_component()

func initialize_component():
	"""Initialize this component - Override in child classes"""
	if is_component_ready:
		return
	
	# Set owner entity
	owner_entity = get_parent()
	
	# Wait for dependencies
	await _wait_for_dependencies()
	
	# Component-specific initialization
	await _initialize()
	
	is_component_ready = true
	component_ready.emit()

func _initialize():
	"""Component-specific initialization - Override in child classes"""
	pass

func destroy_component():
	"""Clean up component"""
	_cleanup()
	component_destroyed.emit()
	queue_free()

func _cleanup():
	"""Component-specific cleanup - Override in child classes"""
	pass

# ============================================================================
#  DEPENDENCY MANAGEMENT
# ============================================================================

func add_dependency(component: Component):
	"""Add a component dependency"""
	if component and component not in dependencies:
		dependencies.append(component)

func _wait_for_dependencies():
	"""Wait for all dependencies to be ready"""
	for dependency in dependencies:
		if dependency and not dependency.is_component_ready:
			await dependency.component_ready

# ============================================================================
#  COMPONENT STATE
# ============================================================================

func enable():
	"""Enable this component"""
	enabled = true
	set_process(true)
	set_physics_process(true)
	_on_component_enabled()

func disable():
	"""Disable this component"""
	enabled = false
	set_process(false)
	set_physics_process(false)
	_on_component_disabled()

func _on_component_enabled():
	"""Called when component is enabled - Override in child classes"""
	pass

func _on_component_disabled():
	"""Called when component is disabled - Override in child classes"""
	pass

# ============================================================================
#  UTILITIES
# ============================================================================

func get_entity() -> Node:
	"""Get the entity that owns this component"""
	return owner_entity

func get_component(component_type: String) -> Component:
	"""Get another component from the same entity"""
	if not owner_entity:
		return null
	
	for child in owner_entity.get_children():
		if child is Component and child.get_script().get_global_name() == component_type:
			return child
	
	return null

func has_component(component_type: String) -> bool:
	"""Check if entity has a specific component"""
	return get_component(component_type) != null

# ============================================================================
#  VALIDATION
# ============================================================================

func is_valid() -> bool:
	"""Check if component is in a valid state"""
	return is_component_ready and enabled and owner_entity != null
