extends Node

# State Machine simplificada pero funcional
# Diseñada para ser práctica y fácil de usar

# Señales para notificar cambios de estado
signal state_changed(from_state: String, to_state: String)
signal state_entered(state_name: String)
signal state_exited(state_name: String)

# Estado actual
var current_state: Node # Será State
var previous_state: Node # Será State

# Diccionario de estados disponibles
var states: Dictionary = {}

# Datos que se pueden pasar entre estados
var transition_data: Dictionary = {}

# Configuración
@export var debug_mode: bool = false
@export var auto_register_children: bool = true
var debug_service: Node = null

func _ready():
	if debug_mode:
		_log_info("🔄 StateMachine initialized")

	# Auto-registrar estados hijos si está habilitado
	if auto_register_children:
		_register_child_states()

	# Si hay estados disponibles, iniciar con el primero
	if not states.is_empty():
		var first_state = states.keys()[0]
		call_deferred("start", first_state)

func _register_child_states():
	for child in get_children():
		if child.has_method("enter") and child.has_method("exit"): # Duck typing para State
			add_state(child.name, child)

func add_state(state_name: String, state: Node):
	if state_name in states:
		if debug_mode:
			push_warning("State '%s' already exists, overwriting..." % state_name)

	states[state_name] = state
	state.state_machine = self

	if debug_mode:
		_log_info("📋 Added state: %s" % state_name)

func remove_state(state_name: String):
	if state_name in states:
		states.erase(state_name)
		if debug_mode:
			_log_info("🗑️ Removed state: %s" % state_name)

func start(initial_state_name: String, data: Dictionary = {}):
	if initial_state_name not in states:
		push_error("Cannot start with unknown state: %s" % initial_state_name)
		return

	transition_data = data
	_change_state(initial_state_name)

	if debug_mode:
		_log_info("🚀 StateMachine started with state: %s" % initial_state_name)

func transition_to(state_name: String, data: Dictionary = {}):
	if state_name not in states:
		push_error("Cannot transition to unknown state: %s" % state_name)
		return

	if current_state and current_state.name == state_name:
		if debug_mode:
			_log_warn("⚠️ Already in state: %s" % state_name)
		return

	transition_data = data
	_change_state(state_name)

func _change_state(new_state_name: String):
	var old_state_name = ""

	# Salir del estado actual
	if current_state:
		old_state_name = current_state.name
		current_state.exit()
		state_exited.emit(old_state_name)
		previous_state = current_state

	# Entrar al nuevo estado
	current_state = states[new_state_name]
	current_state.enter(previous_state)

	# Emitir señales
	state_entered.emit(new_state_name)
	state_changed.emit(old_state_name, new_state_name)

	if debug_mode:
		_log_info("🔄 State changed: %s → %s" % [old_state_name, new_state_name])

func get_current_state_name() -> String:
	if current_state:
		return current_state.name
	return ""

func get_previous_state_name() -> String:
	if previous_state:
		return previous_state.name
	return ""

func is_in_state(state_name: String) -> bool:
	return current_state and current_state.name == state_name

func get_transition_data() -> Dictionary:
	return transition_data

func clear_transition_data():
	transition_data.clear()

# Delegación de eventos al estado actual
func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func process_state(delta: float):
	if current_state:
		current_state.update(delta)

func _input(event):
	if current_state:
		current_state.handle_input(event)

# Métodos de utilidad
func get_state_list() -> Array:
	return states.keys()

func has_state(state_name: String) -> bool:
	return states.has(state_name)

func print_state_info():
	if debug_mode:
		_log_info("🔍 StateMachine Info:")
		_log_info("  Current: %s" % get_current_state_name())
		_log_info("  Previous: %s" % get_previous_state_name())
		_log_info("  Available states: %s" % str(get_state_list()))
		_log_info("  Transition data: %s" % str(transition_data))

func _to_string() -> String:
	return "StateMachine[%s -> %s]" % [get_previous_state_name(), get_current_state_name()]

#  LOGGING HELPERS

func _ensure_debug_service():
	if debug_service:
		return
	if ServiceManager and ServiceManager.has_service("DebugService"):
		debug_service = ServiceManager.get_service("DebugService")

func _log_info(message: String):
	_ensure_debug_service()
	if debug_service and debug_service.has_method("info"):
		debug_service.info(message)
	else:
		print("[StateMachine][INFO] %s" % message)

func _log_warn(message: String):
	_ensure_debug_service()
	if debug_service and debug_service.has_method("warn"):
		debug_service.warn(message)
	else:
		print("[StateMachine][WARN] %s" % message)
