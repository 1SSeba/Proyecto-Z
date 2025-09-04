extends Control

## Main Menu - Professional Implementation
## Clean, component-based main menu for indie/roguelike games
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  CORE PROPERTIES
# ============================================================================

var start_button: Button
var settings_button: Button
var quit_button: Button
var title_label: Label
var version_label: Label

# Settings Menu - Now instantiated in scene
@onready var settings_menu: Control = %SettingsMenu

# Menu State Management
var is_settings_open: bool = false

# Observer Pattern for Dynamic UI Management
var ui_observers: Array[Callable] = []

# ============================================================================
#  LIFECYCLE METHODS
# ============================================================================

func _ready():
	"""Initialize main menu"""
	print("MainMenu: Starting initialization...")
	
	# Initialize the menu
	_initialize_menu()
	
	# Setup input handling
	set_process_input(true)
	
	# Setup settings menu
	_setup_settings_menu()
	
	print("MainMenu: Ready and operational")

func _input(event):
	"""Handle input events"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				if is_settings_open:
					_close_settings_menu()
					get_viewport().set_input_as_handled()

# ============================================================================
#  OBSERVER PATTERN IMPLEMENTATION
# ============================================================================

func add_observer(callback: Callable) -> void:
	"""Add an observer for UI state changes"""
	if callback not in ui_observers:
		ui_observers.append(callback)

func remove_observer(callback: Callable) -> void:
	"""Remove an observer"""
	ui_observers.erase(callback)

func notify_observers(event: String, data: Dictionary = {}) -> void:
	"""Notify all observers about UI state changes"""
	for observer in ui_observers:
		if observer.is_valid():
			observer.call(event, data)

# ============================================================================
#  DYNAMIC MENU MANAGEMENT
# ============================================================================

func _setup_settings_menu():
	"""Setup the instantiated settings menu"""
	if settings_menu:
		# Initially hidden
		settings_menu.visible = false
		print("MainMenu: SettingsMenu setup complete")
	else:
		print("MainMenu: Warning - SettingsMenu not found in scene")

func _initialize_menu():
	"""Initialize main menu"""
	print("MainMenu: Initializing...")
	
	# Wait for EventBus
	await _wait_for_event_bus()
	
	# Get button references using unique names
	_get_button_references()
	
	# Connect signals if buttons exist
	_connect_button_signals()
	
	# Notify observers
	notify_observers("menu_initialized", {})
	
	print("MainMenu: Initialization complete")

func _get_button_references():
	"""Get button references from scene tree"""
	# Try to get buttons using unique names (set by user in MainMenu.tscn)
	start_button = get_node("%StartButton") if has_node("%StartButton") else null
	settings_button = get_node("%SettingsButton") if has_node("%SettingsButton") else null
	quit_button = get_node("%QuitButton") if has_node("%QuitButton") else null
	title_label = get_node("%TitleLabel") if has_node("%TitleLabel") else null
	version_label = get_node("%VersionLabel") if has_node("%VersionLabel") else null
	
	# Log what we found
	print("MainMenu: Button references:")
	print("  - StartButton: ", start_button != null)
	print("  - SettingsButton: ", settings_button != null)
	print("  - QuitButton: ", quit_button != null)

func _connect_button_signals():
	"""Connect button signals to handlers"""
	# Note: Signals are connected in MainMenu.tscn to *_button_activated methods
	# These methods are implemented below to match the scene file
	print("MainMenu: Button signals handled via scene connections")

func _wait_for_event_bus() -> void:
	"""Wait for EventBus to be available"""
	var attempts = 0
	while not EventBus and attempts < 50:
		await get_tree().process_frame
		attempts += 1
	
	if EventBus:
		print("MainMenu: EventBus connected")
	else:
		print("MainMenu: Warning - EventBus not available after 50 attempts")

# ============================================================================
#  SETTINGS MENU MANAGEMENT (Scene-Instantiated)
# ============================================================================

func show_settings_menu():
	"""Show settings menu that's instantiated in scene"""
	if is_settings_open:
		print("MainMenu: Settings menu already open")
		return
	
	if not settings_menu:
		_show_message("SettingsMenu not found in scene")
		return
	
	print("MainMenu: Opening settings menu...")
	
	# Update state
	is_settings_open = true
	
	# Show the menu
	settings_menu.visible = true
	settings_menu.show_menu()
	
	# Notify observers
	notify_observers("settings_opened", {"menu": settings_menu})
	
	print("MainMenu: Settings menu opened successfully")

func _close_settings_menu():
	"""Close settings menu"""
	if not is_settings_open or not settings_menu:
		return
	
	print("MainMenu: Closing settings menu...")
	
	# Update state first to prevent recursion
	is_settings_open = false
	
	# Hide menu
	settings_menu.hide_menu()
	settings_menu.visible = false
	
	# Notify observers
	notify_observers("settings_closed", {})
	
	print("MainMenu: Settings menu closed")

func _on_settings_pressed():
	"""Handle settings button press - internal method"""
	print("MainMenu: Settings button pressed")
	show_settings_menu()

# ============================================================================
#  SIGNAL HANDLERS (Scene connections handle these automatically)
# ============================================================================

func _on_settings_menu_closed():
	"""Handle settings menu closed signal"""
	# Don't call _close_settings_menu to avoid recursion
	if is_settings_open:
		is_settings_open = false
		settings_menu.visible = false
		notify_observers("settings_closed", {})
		print("MainMenu: Settings menu closed via signal")

func _on_settings_back_pressed():
	"""Handle back button pressed in settings"""
	_close_settings_menu()

# ============================================================================
#  SIGNAL HANDLERS (Aligned with MainMenu.tscn signals)
# ============================================================================

func _on_start_button_activated():
	"""Handle start button activation"""
	print("MainMenu: Start game requested")
	
	if EventBus:
		EventBus.emit_event("game_start_requested")

func _on_settings_button_activated():
	"""Handle settings button activation - unified handler"""
	_on_settings_pressed()

func _on_quit_button_activated():
	"""Handle quit button activation"""
	print("MainMenu: Quit requested")
	
	if EventBus:
		EventBus.emit_event("quit_requested")
	
	get_tree().quit()

# ============================================================================
#  UTILITIES
# ============================================================================

func _show_message(message: String):
	"""Show a temporary message"""
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.popup_centered()
	
	# Auto-close after 3 seconds
	await get_tree().create_timer(3.0).timeout
	if dialog and is_instance_valid(dialog):
		dialog.queue_free()

func get_menu_state() -> Dictionary:
	"""Get current menu state for debugging"""
	return {
		"is_settings_open": is_settings_open,
		"has_settings_menu": settings_menu != null,
		"observers_count": ui_observers.size(),
		"settings_menu_visible": settings_menu.visible if settings_menu else false
	}

# ============================================================================
#  DEBUG HELPERS
# ============================================================================

func _print_debug_info():
	"""Print debug information"""
	print("=== MainMenu Debug Info ===")
	print("Settings open: ", is_settings_open)
	print("Settings menu: ", settings_menu)
	print("Settings visible: ", str(settings_menu.visible) if settings_menu else "N/A")
	print("Observers: ", ui_observers.size())
	print("========================")
