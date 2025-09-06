extends Node
# InputService.gd - Gestiona la entrada de usuario

## Professional Input Service
## Clean input handling for indie/roguelike games
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  INPUT CONFIGURATION
# ============================================================================

@export var enable_keyboard: bool = true
@export var enable_gamepad: bool = true
@export var input_buffer_size: int = 5

# Mouse settings
@export var mouse_sensitivity: float = 1.0
@export var mouse_invert_x: bool = false
@export var mouse_invert_y: bool = false

# Gamepad settings
@export var gamepad_deadzone: float = 0.2
@export var gamepad_vibration: bool = true

# ============================================================================
#  INPUT STATE
# ============================================================================

# Variables del servicio
var service_name: String = "InputService"
var is_service_ready: bool = false

# Variables principales
var input_actions: Dictionary = {}
var custom_bindings: Dictionary = {}
var current_input: Dictionary = {}
var input_buffer: Array = []
var is_input_enabled: bool = true

# Input actions we care about
var tracked_actions: Array[String] = [
	"move_up", "move_down", "move_left", "move_right",
	"interact", "cancel", "ui_accept", "ui_cancel"
]

# ============================================================================
#  SERVICE LIFECYCLE
# ============================================================================

func _start():
	service_name = "InputService"
	set_process_unhandled_input(true)
	_initialize_input_state()
	is_service_ready = true
	print("InputService: Input system initialized")

func start_service():
	"""Public method to start the service"""
	_start()

func _initialize_input_state():
	"""Initialize input state tracking"""
	for action in tracked_actions:
		current_input[action] = false

# ============================================================================
#  INPUT PROCESSING
# ============================================================================

func _unhandled_input(event: InputEvent):
	if not is_input_enabled:
		return
	
	_process_input_event(event)

func _process_input_event(event: InputEvent):
	"""Process individual input events"""
	# Handle action events
	for action in tracked_actions:
		if event.is_action_pressed(action):
			_handle_action_pressed(action)
		elif event.is_action_released(action):
			_handle_action_released(action)

func _handle_action_pressed(action: String):
	"""Handle action press"""
	current_input[action] = true
	
	# Add to input buffer
	_add_to_buffer(action, true)
	
	# Notify EventBus
	if EventBus:
		EventBus.input_action_pressed.emit(action)

func _handle_action_released(action: String):
	"""Handle action release"""
	current_input[action] = false
	
	# Add to input buffer
	_add_to_buffer(action, false)
	
	# Notify EventBus
	if EventBus:
		EventBus.input_action_released.emit(action)

func _add_to_buffer(action: String, pressed: bool):
	"""Add input to buffer for frame-perfect input detection"""
	var input_data = {
		"action": action,
		"pressed": pressed,
		"timestamp": Time.get_ticks_msec()
	}
	
	input_buffer.append(input_data)
	
	# Limit buffer size
	if input_buffer.size() > input_buffer_size:
		input_buffer.pop_front()

# ============================================================================
#  INPUT QUERIES
# ============================================================================

func is_action_pressed(action: String) -> bool:
	"""Check if action is currently pressed"""
	return current_input.get(action, false)

func get_movement_vector() -> Vector2:
	"""Get normalized movement vector"""
	var movement = Vector2.ZERO
	
	if is_action_pressed("move_left"):
		movement.x -= 1.0
	if is_action_pressed("move_right"):
		movement.x += 1.0
	if is_action_pressed("move_up"):
		movement.y -= 1.0
	if is_action_pressed("move_down"):
		movement.y += 1.0
	
	return movement.normalized()

func was_action_just_pressed(action: String, frames_ago: int = 0) -> bool:
	"""Check if action was pressed in recent frames"""
	var target_time = Time.get_ticks_msec() - (frames_ago * 16)  # ~16ms per frame
	
	for input_data in input_buffer:
		if input_data.action == action and input_data.pressed:
			if input_data.timestamp >= target_time:
				return true
	
	return false

# ============================================================================
#  INPUT CONTROL
# ============================================================================

func enable_input():
	"""Enable input processing"""
	is_input_enabled = true

func disable_input():
	"""Disable input processing"""
	is_input_enabled = false
	_clear_current_input()

func _clear_current_input():
	"""Clear all current input states"""
	for action in current_input.keys():
		current_input[action] = false

func clear_input_buffer():
	"""Clear the input buffer"""
	input_buffer.clear()

# ============================================================================
#  INPUT CONFIGURATION
# ============================================================================

func set_action_deadzone(action: String, deadzone: float):
	"""Set deadzone for an action"""
	InputMap.action_set_deadzone(action, deadzone)

func get_action_strength(action: String) -> float:
	"""Get action strength (for analog inputs)"""
	return Input.get_action_strength(action)

# ============================================================================
#  ADVANCED INPUT CONFIGURATION
# ============================================================================

func set_mouse_sensitivity(sensitivity: float):
	"""Set mouse sensitivity"""
	mouse_sensitivity = clamp(sensitivity, 0.1, 5.0)

func set_mouse_invert_x(invert: bool):
	"""Set mouse X axis inversion"""
	mouse_invert_x = invert

func set_mouse_invert_y(invert: bool):
	"""Set mouse Y axis inversion"""
	mouse_invert_y = invert

func set_gamepad_deadzone(deadzone: float):
	"""Set gamepad stick deadzone"""
	gamepad_deadzone = clamp(deadzone, 0.0, 0.9)
	# Apply to movement actions
	var movement_actions = ["move_up", "move_down", "move_left", "move_right"]
	for action in movement_actions:
		if InputMap.has_action(action):
			InputMap.action_set_deadzone(action, gamepad_deadzone)

func set_gamepad_vibration(enabled: bool):
	"""Enable or disable gamepad vibration"""
	gamepad_vibration = enabled

func get_mouse_delta_adjusted(delta: Vector2) -> Vector2:
	"""Get mouse delta with sensitivity and inversion applied"""
	var adjusted_delta = delta * mouse_sensitivity
	
	if mouse_invert_x:
		adjusted_delta.x *= -1
	if mouse_invert_y:
		adjusted_delta.y *= -1
	
	return adjusted_delta

# ============================================================================
#  SERVICE STATUS
# ============================================================================

func get_input_status() -> Dictionary:
	"""Get input service status"""
	return {
		"enabled": is_input_enabled,
		"current_inputs": current_input.duplicate(),
		"buffer_size": input_buffer.size(),
		"movement_vector": get_movement_vector(),
		"tracked_actions": tracked_actions.size(),
		"mouse_sensitivity": mouse_sensitivity,
		"mouse_invert_x": mouse_invert_x,
		"mouse_invert_y": mouse_invert_y,
		"gamepad_deadzone": gamepad_deadzone,
		"gamepad_vibration": gamepad_vibration
	}
