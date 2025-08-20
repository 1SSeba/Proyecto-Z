# InputManager.gd - Autoload para gestionar todos los inputs del juego
extends Node

# =======================
#  SEÑALES
# =======================
signal input_action_pressed(action: String)
signal input_action_released(action: String)
signal input_context_changed(old_context: String, new_context: String)
signal controls_remapped(action: String, new_event: InputEvent)

# =======================
#  CONSTANTES
# =======================
enum InputContext {
	GAMEPLAY,
	UI_MENU,
	PAUSE,
	SETTINGS,
	DIALOGUE,
	INVENTORY
}

# Mapeo de acciones del juego
const GAME_ACTIONS = {
	# Movimiento (WASD + Arrow Keys configurados automáticamente)
	"move_up": "ui_up",          # W + Up Arrow
	"move_down": "ui_down",      # S + Down Arrow  
	"move_left": "ui_left",      # A + Left Arrow
	"move_right": "ui_right",    # D + Right Arrow
	
	# Acciones principales
	"interact": "ui_accept",
	"cancel": "ui_cancel",
	"action": "action",
	"secondary_action": "secondary_action",
	
	# UI y Menús
	"pause": "pause",            # ESC - Solo funciona durante GAMEPLAY
	"inventory": "inventory",
	"menu": "menu",
	
	# Debug (opcional)
	"debug_toggle": "debug_toggle"
}

# =======================
#  VARIABLES
# =======================
var current_context: InputContext = InputContext.GAMEPLAY
var is_input_enabled: bool = true
var is_initialized: bool = false

# Buffer de inputs para combos o secuencias
var input_buffer: Array[Dictionary] = []
var buffer_max_size: int = 10
var buffer_timeout: float = 1.0

# Configuración de deadzone para gamepad
var gamepad_deadzone: float = 0.2
var gamepad_connected: bool = false

# Input personalizado
var custom_action_map: Dictionary = {}

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("InputManager: Starting initialization...")
	_setup_default_inputs()
	
	# Esperar a ConfigManager si está disponible
	if _is_config_manager_available():
		if ConfigManager.is_ready():
			_load_custom_controls()
			_finalize_initialization()
		else:
			print("InputManager: Waiting for ConfigManager...")
			ConfigManager.config_loaded.connect(_on_config_manager_ready, CONNECT_ONE_SHOT)
	else:
		print("InputManager: ConfigManager not found, using default controls")
		_finalize_initialization()
	
	# Detectar gamepads
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_check_gamepad_connection()

func _on_config_manager_ready():
	print("InputManager: ConfigManager ready, loading custom controls...")
	_load_custom_controls()
	_finalize_initialization()

func _finalize_initialization():
	is_initialized = true
	print("InputManager: Initialization complete")

func _setup_default_inputs():
	"""Configura las acciones de input por defecto si no existen"""
	
	# Configurar WASD + Arrow Keys para movimiento
	_setup_movement_inputs()
	
	# Verificar que las acciones básicas estén definidas
	var actions_to_check = [
		{"name": "action", "events": [KEY_SPACE]},
		{"name": "secondary_action", "events": [KEY_X]},
		{"name": "pause", "events": [KEY_ESCAPE]},
		{"name": "inventory", "events": [KEY_TAB]},
		{"name": "menu", "events": [KEY_M]},
		{"name": "debug_toggle", "events": [KEY_F3]}
	]
	
	for action_data in actions_to_check:
		if not InputMap.has_action(action_data.name):
			InputMap.add_action(action_data.name)
			for key in action_data.events:
				var event = InputEventKey.new()
				event.keycode = key
				InputMap.action_add_event(action_data.name, event)
			print("InputManager: Created default action '%s'" % action_data.name)

func _setup_movement_inputs():
	"""Configura WASD + Arrow Keys para movimiento"""
	var movement_setup = [
		{"action": "ui_up", "keys": [KEY_UP, KEY_W]},
		{"action": "ui_down", "keys": [KEY_DOWN, KEY_S]},
		{"action": "ui_left", "keys": [KEY_LEFT, KEY_A]},
		{"action": "ui_right", "keys": [KEY_RIGHT, KEY_D]}
	]
	
	for setup in movement_setup:
		# Solo agregar WASD si no están ya asignadas
		var existing_events = InputMap.action_get_events(setup.action)
		var existing_keys = []
		
		for event in existing_events:
			if event is InputEventKey:
				existing_keys.append(event.keycode)
		
		# Agregar teclas que falten
		for key in setup.keys:
			if not key in existing_keys:
				var event = InputEventKey.new()
				event.keycode = key
				InputMap.action_add_event(setup.action, event)
				print("InputManager: Added %s to %s" % [OS.get_keycode_string(key), setup.action])

func _check_gamepad_connection():
	"""Verifica si hay un gamepad conectado"""
	var joypads = Input.get_connected_joypads()
	gamepad_connected = joypads.size() > 0
	
	if gamepad_connected:
		print("InputManager: Gamepad detected: %s" % Input.get_joy_name(joypads[0]))
	else:
		print("InputManager: No gamepad detected")

# =======================
#  VERIFICACIONES
# =======================
func _is_config_manager_available() -> bool:
	return get_node_or_null("/root/ConfigManager") != null

func is_ready() -> bool:
	return is_initialized

func wait_for_ready() -> void:
	if is_initialized:
		return
	# Esperar hasta que esté listo (implementar signal si es necesario)
	while not is_initialized:
		await get_tree().process_frame

# =======================
#  FUNCIONES PRINCIPALES DE INPUT
# =======================
func _input(event: InputEvent):
	if not is_input_enabled or not is_initialized:
		return
	
	# Agregar al buffer
	_add_to_input_buffer(event)
	
	# Procesar inputs según el contexto
	_process_input_by_context(event)

func _process_input_by_context(event: InputEvent):
	"""Procesa inputs según el contexto actual"""
	match current_context:
		InputContext.GAMEPLAY:
			_process_gameplay_input(event)
		InputContext.UI_MENU, InputContext.SETTINGS:
			_process_ui_input(event)
		InputContext.PAUSE:
			_process_pause_input(event)
		InputContext.DIALOGUE:
			_process_dialogue_input(event)
		InputContext.INVENTORY:
			_process_inventory_input(event)

func _process_gameplay_input(event: InputEvent):
	"""Procesa inputs durante el gameplay"""
	
	# ESC para pause - SOLO durante gameplay
	if event.is_action_pressed("pause"):
		input_action_pressed.emit("pause")
		return
	
	# Procesar otras acciones del gameplay
	for action in GAME_ACTIONS.keys():
		if action == "pause":  # Ya manejamos pause arriba
			continue
			
		if event.is_action_pressed(get_mapped_action(action)):
			input_action_pressed.emit(action)
		elif event.is_action_released(get_mapped_action(action)):
			input_action_released.emit(action)

func _process_ui_input(event: InputEvent):
	"""Procesa inputs en menús de UI"""
	# En contexto UI (MAIN MENU), ESC NO debe abrir pause
	# Solo permitir navegación básica
	var ui_actions = ["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept", "ui_cancel"]
	for action in ui_actions:
		if event.is_action_pressed(action):
			input_action_pressed.emit(action.replace("ui_", ""))

func _process_pause_input(event: InputEvent):
	"""Procesa inputs cuando el juego está pausado"""
	# ESC para cerrar pause menu y volver al juego
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		input_action_pressed.emit("unpause")
	
	# Permitir navegación en el menú de pausa
	var ui_actions = ["ui_up", "ui_down", "ui_left", "ui_right", "ui_accept"]
	for action in ui_actions:
		if event.is_action_pressed(action):
			input_action_pressed.emit(action.replace("ui_", ""))

func _process_dialogue_input(event: InputEvent):
	"""Procesa inputs durante diálogos"""
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		input_action_pressed.emit("dialogue_continue")
	elif event.is_action_pressed("ui_cancel"):
		input_action_pressed.emit("dialogue_skip")

func _process_inventory_input(event: InputEvent):
	"""Procesa inputs en el inventario"""
	if event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel"):
		input_action_pressed.emit("inventory_close")

# =======================
#  FUNCIONES DE QUERY DE INPUT
# =======================
func is_action_pressed(action: String) -> bool:
	"""Verifica si una acción está siendo presionada"""
	if not is_input_enabled:
		return false
	return Input.is_action_pressed(get_mapped_action(action))

func is_action_just_pressed(action: String) -> bool:
	"""Verifica si una acción fue presionada en este frame"""
	if not is_input_enabled:
		return false
	return Input.is_action_just_pressed(get_mapped_action(action))

func is_action_just_released(action: String) -> bool:
	"""Verifica si una acción fue liberada en este frame"""
	if not is_input_enabled:
		return false
	return Input.is_action_just_released(get_mapped_action(action))

func get_action_strength(action: String) -> float:
	"""Obtiene la fuerza de una acción (útil para gamepad)"""
	if not is_input_enabled:
		return 0.0
	return Input.get_action_strength(get_mapped_action(action))

func get_movement_vector() -> Vector2:
	"""Obtiene el vector de movimiento normalizado"""
	if not is_input_enabled:
		return Vector2.ZERO
	
	var vector = Vector2(
		get_action_strength("move_right") - get_action_strength("move_left"),
		get_action_strength("move_down") - get_action_strength("move_up")
	)
	
	# Aplicar deadzone para gamepad
	if gamepad_connected and vector.length() < gamepad_deadzone:
		return Vector2.ZERO
	
	return vector.normalized() if vector.length() > 1.0 else vector

func get_mapped_action(action: String) -> String:
	"""Obtiene la acción mapeada (custom o default)"""
	if custom_action_map.has(action):
		return custom_action_map[action]
	return GAME_ACTIONS.get(action, action)

# =======================
#  GESTIÓN DE CONTEXTO
# =======================
func set_input_context(new_context: InputContext):
	"""Cambia el contexto actual de input"""
	if new_context != current_context:
		var old_context_name = InputContext.keys()[current_context]
		var new_context_name = InputContext.keys()[new_context]
		
		current_context = new_context
		input_context_changed.emit(old_context_name, new_context_name)
		print("InputManager: Context changed from %s to %s" % [old_context_name, new_context_name])

func get_current_context() -> InputContext:
	"""Obtiene el contexto actual"""
	return current_context

func enable_input():
	"""Habilita el procesamiento de input"""
	is_input_enabled = true
	print("InputManager: Input enabled")

func disable_input():
	"""Deshabilita el procesamiento de input"""
	is_input_enabled = false
	print("InputManager: Input disabled")

func get_input_enabled() -> bool:
	"""Verifica si el input está habilitado"""
	return is_input_enabled

# =======================
#  BUFFER DE INPUT
# =======================
func _add_to_input_buffer(event: InputEvent):
	"""Agrega un evento al buffer de input"""
	if input_buffer.size() >= buffer_max_size:
		input_buffer.pop_front()
	
	input_buffer.push_back({
		"event": event,
		"timestamp": Time.get_time_dict_from_system()
	})
	
	# Limpiar buffer antiguo
	_clean_old_buffer_entries()

func _clean_old_buffer_entries():
	"""Limpia entradas antiguas del buffer"""
	var current_time = Time.get_time_dict_from_system()
	var i = 0
	while i < input_buffer.size():
		var entry_time = input_buffer[i].timestamp
		var time_diff = _calculate_time_difference(current_time, entry_time)
		
		if time_diff > buffer_timeout:
			input_buffer.remove_at(i)
		else:
			i += 1

func _calculate_time_difference(current: Dictionary, past: Dictionary) -> float:
	"""Calcula diferencia de tiempo en segundos"""
	var current_seconds = current.hour * 3600 + current.minute * 60 + current.second
	var past_seconds = past.hour * 3600 + past.minute * 60 + past.second
	return current_seconds - past_seconds

func get_recent_inputs(time_window: float = 0.5) -> Array:
	"""Obtiene inputs recientes dentro de una ventana de tiempo"""
	var recent_inputs = []
	var current_time = Time.get_time_dict_from_system()
	
	for entry in input_buffer:
		var time_diff = _calculate_time_difference(current_time, entry.timestamp)
		if time_diff <= time_window:
			recent_inputs.append(entry.event)
	
	return recent_inputs

# =======================
#  CONFIGURACIÓN PERSONALIZADA
# =======================
func _load_custom_controls():
	"""Carga controles personalizados desde ConfigManager"""
	if not _is_config_manager_available():
		return
	
	var custom_inputs = ConfigManager.get_setting("controls", "custom_inputs", {})
	
	for action in custom_inputs.keys():
		remap_action(action, custom_inputs[action])
	
	print("InputManager: Loaded %d custom control mappings" % custom_inputs.size())

func remap_action(action: String, new_event_data: Dictionary) -> bool:
	"""Remapea una acción a un nuevo input"""
	if not GAME_ACTIONS.has(action):
		print("InputManager: ERROR - Unknown action: %s" % action)
		return false
	
	# Crear nuevo InputEvent desde datos
	var new_event = _create_input_event_from_data(new_event_data)
	if not new_event:
		return false
	
	var mapped_action = get_mapped_action(action)
	
	# Limpiar eventos existentes
	InputMap.action_erase_events(mapped_action)
	
	# Agregar nuevo evento
	InputMap.action_add_event(mapped_action, new_event)
	
	# Guardar en configuración
	if _is_config_manager_available():
		var custom_inputs = ConfigManager.get_setting("controls", "custom_inputs", {})
		custom_inputs[action] = new_event_data
		ConfigManager.set_setting("controls", "custom_inputs", custom_inputs)
	
	controls_remapped.emit(action, new_event)
	print("InputManager: Remapped '%s' to %s" % [action, str(new_event_data)])
	return true

func _create_input_event_from_data(event_data: Dictionary) -> InputEvent:
	"""Crea un InputEvent desde datos serializados"""
	match event_data.get("type", ""):
		"key":
			var event = InputEventKey.new()
			event.keycode = event_data.get("keycode", 0)
			event.physical_keycode = event_data.get("physical_keycode", 0)
			return event
		"mouse":
			var event = InputEventMouseButton.new()
			event.button_index = event_data.get("button_index", 0)
			return event
		"joypad_button":
			var event = InputEventJoypadButton.new()
			event.button_index = event_data.get("button_index", 0)
			return event
		"joypad_motion":
			var event = InputEventJoypadMotion.new()
			event.axis = event_data.get("axis", 0)
			event.axis_value = event_data.get("axis_value", 0.0)
			return event
	
	print("InputManager: ERROR - Unknown event type: %s" % event_data.get("type", ""))
	return null

func reset_action_to_default(action: String) -> bool:
	"""Resetea una acción a su mapeo por defecto"""
	if not GAME_ACTIONS.has(action):
		return false
	
	var _default_action = GAME_ACTIONS[action]  # Referenced for potential future use
	custom_action_map.erase(action)
	
	# Actualizar configuración
	if _is_config_manager_available():
		var custom_inputs = ConfigManager.get_setting("controls", "custom_inputs", {})
		custom_inputs.erase(action)
		ConfigManager.set_setting("controls", "custom_inputs", custom_inputs)
	
	print("InputManager: Reset '%s' to default mapping" % action)
	return true

func reset_all_controls_to_default():
	"""Resetea todos los controles a su configuración por defecto"""
	custom_action_map.clear()
	
	if _is_config_manager_available():
		ConfigManager.set_setting("controls", "custom_inputs", {})
	
	print("InputManager: All controls reset to default")

# =======================
#  GAMEPAD
# =======================
func _on_joy_connection_changed(device: int, connected: bool):
	"""Maneja conexión/desconexión de gamepads"""
	if connected:
		print("InputManager: Gamepad connected - %s" % Input.get_joy_name(device))
		gamepad_connected = true
	else:
		print("InputManager: Gamepad disconnected")
		gamepad_connected = Input.get_connected_joypads().size() > 0

func set_gamepad_deadzone(deadzone: float):
	"""Configura el deadzone del gamepad"""
	gamepad_deadzone = clamp(deadzone, 0.0, 1.0)
	print("InputManager: Gamepad deadzone set to %.2f" % gamepad_deadzone)

func is_using_gamepad() -> bool:
	"""Verifica si se está usando un gamepad"""
	return gamepad_connected

# =======================
#  FUNCIONES DE DEBUG
# =======================
func debug_input_status():
	"""Muestra información de debug sobre el estado del input"""
	print("=== INPUT MANAGER STATUS ===")
	print("Initialized: %s" % is_initialized)
	print("Input Enabled: %s" % is_input_enabled)
	print("Current Context: %s" % InputContext.keys()[current_context])
	print("Gamepad Connected: %s" % gamepad_connected)
	print("Gamepad Deadzone: %.2f" % gamepad_deadzone)
	print("Buffer Size: %d/%d" % [input_buffer.size(), buffer_max_size])
	print("Custom Mappings: %d" % custom_action_map.size())
	print("")
	print("=== DEFAULT BINDINGS ===")
	print("Movement: WASD + Arrow Keys")
	print("Pause: ESC (ONLY during gameplay)")
	print("Interact: SPACE/ENTER")
	print("Inventory: TAB")
	print("============================")

func debug_show_current_bindings():
	"""Muestra todas las teclas actualmente asignadas"""
	print("=== CURRENT KEY BINDINGS ===")
	
	for action in GAME_ACTIONS.keys():
		var mapped_action = get_mapped_action(action)
		var events = InputMap.action_get_events(mapped_action)
		var key_names = []
		
		for event in events:
			if event is InputEventKey:
				key_names.append(OS.get_keycode_string(event.keycode))
		
		if key_names.size() > 0:
			print("%s: %s" % [action, " + ".join(key_names)])
	
	print("============================")

func get_all_action_mappings() -> Dictionary:
	"""Obtiene todos los mapeos de acción actuales"""
	var mappings = {}
	for action in GAME_ACTIONS.keys():
		var mapped_action = get_mapped_action(action)
		var events = InputMap.action_get_events(mapped_action)
		mappings[action] = {
			"mapped_to": mapped_action,
			"events": events
		}
	return mappings
