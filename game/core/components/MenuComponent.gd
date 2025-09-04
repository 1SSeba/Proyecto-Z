extends Component
# MenuComponent.gd - Componente de menú modular

## Professional Menu Component
## Clean, modular menu system for indie/roguelike games
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  MENU CONFIGURATION
# ============================================================================

signal menu_action(action: String, data: Dictionary)

@export_group("Menu Settings")
@export var menu_name: String = ""
@export var auto_focus_first_button: bool = true

@export_group("UI Elements")
@export var menu_container: Control
@export var buttons: Array[Button] = []

# ============================================================================
#  INTERNAL PROPERTIES
# ============================================================================

var focused_button_index: int = 0
var is_menu_active: bool = true

# ============================================================================
#  COMPONENT LIFECYCLE
# ============================================================================

func _initialize():
	component_id = "MenuComponent"
	_setup_menu()
	_connect_buttons()
	_setup_navigation()

func _setup_menu():
	"""Setup menu container and validate UI elements"""
	if not menu_container:
		menu_container = get_parent() as Control
	
	if not menu_container:
		print("MenuComponent: Warning - No menu container found")
		return
	
	# Auto-discover buttons if not assigned
	if buttons.is_empty():
		_auto_discover_buttons()

func _auto_discover_buttons():
	"""Automatically find buttons in the menu"""
	if not menu_container:
		return
	
	_find_buttons_recursive(menu_container)
	print("MenuComponent: Found %d buttons" % buttons.size())

func _find_buttons_recursive(node: Node):
	"""Recursively find all buttons"""
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		elif child.get_child_count() > 0:
			_find_buttons_recursive(child)

# ============================================================================
#  BUTTON MANAGEMENT
# ============================================================================

func _connect_buttons():
	"""Connect button signals"""
	for i in buttons.size():
		var button = buttons[i]
		if not button:
			continue
		
		# Connect button pressed signal
		if not button.pressed.is_connected(_on_button_pressed):
			button.pressed.connect(_on_button_pressed.bind(button))
		
		# Connect focus signals
		if not button.focus_entered.is_connected(_on_button_focus_entered):
			button.focus_entered.connect(_on_button_focus_entered.bind(i))

func _setup_navigation():
	"""Setup keyboard/gamepad navigation"""
	if auto_focus_first_button and buttons.size() > 0:
		buttons[0].grab_focus()
		focused_button_index = 0

# ============================================================================
#  INPUT HANDLING
# ============================================================================

func _unhandled_input(event: InputEvent):
	if not is_menu_active or not enabled:
		return
	
	if event.is_action_pressed("ui_up"):
		_navigate_up()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_navigate_down()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		_activate_focused_button()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_handle_cancel()
		get_viewport().set_input_as_handled()

func _navigate_up():
	"""Navigate to previous button"""
	if buttons.is_empty():
		return
	
	focused_button_index = (focused_button_index - 1) % buttons.size()
	_focus_button(focused_button_index)

func _navigate_down():
	"""Navigate to next button"""
	if buttons.is_empty():
		return
	
	focused_button_index = (focused_button_index + 1) % buttons.size()
	_focus_button(focused_button_index)

func _focus_button(index: int):
	"""Focus a specific button"""
	if index >= 0 and index < buttons.size():
		buttons[index].grab_focus()

func _activate_focused_button():
	"""Activate the currently focused button"""
	if focused_button_index >= 0 and focused_button_index < buttons.size():
		var button = buttons[focused_button_index]
		button.pressed.emit()

# ============================================================================
#  EVENT HANDLERS
# ============================================================================

func _on_button_pressed(button: Button):
	"""Handle button press"""
	var button_name = button.name.to_lower()
	var action_data = {
		"button_name": button_name,
		"menu_name": menu_name
	}
	
	# Emit component signal
	menu_action.emit(button_name, action_data)
	
	# Send to EventBus
	if EventBus:
		EventBus.ui_button_pressed.emit(button_name)
	
	# Handle common actions
	_handle_button_action(button_name, action_data)

func _on_button_focus_entered(button_index: int):
	"""Handle button focus change"""
	focused_button_index = button_index
	
	if EventBus:
		EventBus.ui_element_focused.emit(buttons[button_index])

# ============================================================================
#  ACTION HANDLING
# ============================================================================

func _handle_button_action(action: String, _data: Dictionary):
	"""Handle specific button actions"""
	match action:
		"start", "startbutton", "play":
			_request_game_start()
		"settings", "settingsbutton", "options":
			_request_settings()
		"quit", "quitbutton", "exit":
			_request_quit()
		"credits", "creditsbutton":
			_request_credits()
		"back", "backbutton", "return":
			_request_back()

func _request_game_start():
	"""Request game start"""
	if EventBus:
		EventBus.emit_event("game_start_requested")

func _request_settings():
	"""Request settings menu"""
	if EventBus:
		EventBus.emit_event("settings_menu_requested")

func _request_quit():
	"""Request application quit"""
	if EventBus:
		EventBus.emit_event("quit_requested")

func _request_credits():
	"""Request credits screen"""
	if EventBus:
		EventBus.emit_event("credits_requested")

func _request_back():
	"""Request back/return action"""
	if EventBus:
		EventBus.emit_event("menu_back_requested")

func _handle_cancel():
	"""Handle cancel/escape input"""
	_request_back()

# ============================================================================
#  MENU CONTROL
# ============================================================================

func show_menu():
	"""Show the menu"""
	is_menu_active = true
	if menu_container:
		menu_container.visible = true
	
	if auto_focus_first_button and buttons.size() > 0:
		buttons[0].grab_focus()

func hide_menu():
	"""Hide the menu"""
	is_menu_active = false
	if menu_container:
		menu_container.visible = false

func enable_menu():
	"""Enable menu interactions"""
	enable()
	is_menu_active = true

func disable_menu():
	"""Disable menu interactions"""
	disable()
	is_menu_active = false

# ============================================================================
#  COMPONENT INFO
# ============================================================================

func get_menu_status() -> Dictionary:
	"""Get menu component status"""
	return {
		"menu_name": menu_name,
		"active": is_menu_active,
		"enabled": enabled,
		"buttons_count": buttons.size(),
		"focused_button": focused_button_index
	}
