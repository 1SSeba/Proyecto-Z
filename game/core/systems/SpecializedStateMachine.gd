extends "res://game/core/systems/StateMachine/StateMachine.gd"
class_name SpecializedStateMachine
# SpecializedStateMachine - Una versión especializada del StateMachine básico

# Estados especializados adicionales
var specialized_states: Dictionary = {}
var transition_queue: Array = []
var transition_cooldown: float = 0.0
var min_transition_time: float = 0.1

signal specialized_transition_started(from_state: String, to_state: String)
signal specialized_transition_completed(state: String)
signal transition_queued(state: String)

func _ready():
	super._ready()
	print("SpecializedStateMachine: Initialized")

	# Conectar señales adicionales
	if has_signal("state_changed"):
		state_changed.connect(_on_specialized_state_changed)

func _process(delta):
	super._process(delta)

	# Procesar cooldown de transiciones
	if transition_cooldown > 0:
		transition_cooldown -= delta

	# Procesar cola de transiciones
	if transition_queue.size() > 0 and transition_cooldown <= 0:
		var next_transition = transition_queue.pop_front()
		_execute_queued_transition(next_transition)

# Transición especializada con cola
func queue_transition_to(state_name: String, data: Dictionary = {}):
	if transition_cooldown > 0:
		transition_queue.append({"state": state_name, "data": data})
		transition_queued.emit(state_name)
		print("SpecializedStateMachine: Queued transition to %s" % state_name)
	else:
		transition_to(state_name, data)

func _execute_queued_transition(queued_data: Dictionary):
	var state_name = queued_data.get("state", "")
	var data = queued_data.get("data", {})

	if state_name != "":
		transition_to(state_name, data)
		transition_cooldown = min_transition_time

# Override del transition_to para añadir funcionalidad especializada
func transition_to(state_name: String, _data: Dictionary = {}):
	if current_state:
		specialized_transition_started.emit(current_state.get_state_name(), state_name)

	# Llamar al método padre
	super.transition_to(state_name, _data)

	# Establecer cooldown
	transition_cooldown = min_transition_time

func _on_specialized_state_changed(old_state: String, new_state: String):
	specialized_transition_completed.emit(new_state)
	print("SpecializedStateMachine: Specialized transition completed: %s -> %s" % [old_state, new_state])

# Registro de estados especializados
func register_specialized_state(state_name: String, state_node: Node):
	specialized_states[state_name] = state_node
	add_state(state_name, state_node)
	print("SpecializedStateMachine: Registered specialized state: %s" % state_name)

# Métodos de utilidad especializados
func has_queued_transitions() -> bool:
	return transition_queue.size() > 0

func clear_transition_queue():
	transition_queue.clear()
	print("SpecializedStateMachine: Transition queue cleared")

func get_queued_transition_count() -> int:
	return transition_queue.size()

func is_transition_on_cooldown() -> bool:
	return transition_cooldown > 0

func set_min_transition_time(time: float):
	min_transition_time = max(0.0, time)
	print("SpecializedStateMachine: Min transition time set to %s" % min_transition_time)

# Transiciones con condiciones
func conditional_transition_to(state_name: String, condition: Callable, data: Dictionary = {}):
	if condition.call():
		transition_to(state_name, data)
		return true
	else:
		print("SpecializedStateMachine: Conditional transition to %s failed" % state_name)
		return false

# Debug especializado
func debug_specialized_info():
	print("=== SPECIALIZED STATE MACHINE DEBUG ===")
	print_state_info() # Llamar debug del padre
	print("Specialized States: %s" % specialized_states.keys())
	print("Transition Queue Size: %s" % transition_queue.size())
	print("Transition Cooldown: %s" % transition_cooldown)
	print("Min Transition Time: %s" % min_transition_time)
	print("========================================")
