# 🎛️ SpecializedStateMachine
# StateMachine simplificado solo para casos que requieren lógica compleja
# (ej: gameplay con múltiples fases, AI compleja, etc.)

extends Node

# Señales básicas
signal state_entered(state_name: String)
signal state_exited(state_name: String)
signal state_changed(from_state: String, to_state: String)

# Estado actual
var current_state: Node = null
var previous_state: Node = null

# Estados disponibles
var states: Dictionary = {}

# Datos de transición
var transition_data: Dictionary = {}

# Configuración
@export var debug_mode: bool = false
@export var auto_start: bool = true

func _ready():
	if debug_mode:
		print("SpecializedStateMachine: Initialized")

	# Auto-registrar estados hijos
	_register_child_states()

	# Auto-iniciar si está habilitado
	if auto_start and not states.is_empty():
		var first_state = states.keys()[0]
		call_deferred("start", first_state)

func _register_child_states():
	"""Registrar automáticamente los estados hijos"""
	for child in get_children():
		if child.has_method("enter") and child.has_method("exit"):
			add_state(child.name, child)

func add_state(state_name: String, state: Node):
	"""Agregar un estado al sistema"""
	states[state_name] = state
	state.state_machine = self

	if debug_mode:
		print("SpecializedStateMachine: Added state: ", state_name)

func start(initial_state_name: String, data: Dictionary = {}):
	"""Iniciar la máquina de estados"""
	if initial_state_name not in states:
		push_error("Unknown initial state: " + initial_state_name)
		return

	transition_data = data
	_change_state(initial_state_name)

	if debug_mode:
		print("SpecializedStateMachine: Started with state: ", initial_state_name)

func transition_to(state_name: String, data: Dictionary = {}):
	"""Transición a un nuevo estado"""
	if state_name not in states:
		push_error("Unknown state: " + state_name)
		return

	if current_state and current_state.name == state_name:
		if debug_mode:
			print("SpecializedStateMachine: Already in state: ", state_name)
		return

	transition_data = data
	_change_state(state_name)

func _change_state(new_state_name: String):
	"""Cambiar al nuevo estado"""
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
		print("SpecializedStateMachine: %s → %s" % [old_state_name, new_state_name])

# ═══════════════════════════════════════════════════════════════════════════
# 🔄 DELEGACIÓN DE EVENTOS
# ═══════════════════════════════════════════════════════════════════════════

func _process(delta):
	if current_state and current_state.has_method("update"):
		current_state.update(delta)

func _physics_process(delta):
	if current_state and current_state.has_method("physics_update"):
		current_state.physics_update(delta)

func _input(event):
	if current_state and current_state.has_method("handle_input"):
		current_state.handle_input(event)

# ═══════════════════════════════════════════════════════════════════════════
# 📊 CONSULTAS
# ═══════════════════════════════════════════════════════════════════════════

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

func get_available_states() -> Array:
	return states.keys()

# ═══════════════════════════════════════════════════════════════════════════
# 🐛 DEBUG
# ═══════════════════════════════════════════════════════════════════════════

func debug_info():
	if debug_mode:
		print("=== SPECIALIZED STATE MACHINE ===")
		print("Current: %s" % get_current_state_name())
		print("Previous: %s" % get_previous_state_name())
		print("Available: %s" % get_available_states())
		print("Data: %s" % transition_data)
		print("================================")
