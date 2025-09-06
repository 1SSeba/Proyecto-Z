extends Control

## MainMenu - Professional Implementation
## Clean, modern main menu for roguelike indie games
## @version 1.0.0
## @author Indie Studio

# ============================================================================
#  UI REFERENCES
# ============================================================================

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton  
@onready var quit_button: Button = %QuitButton
@onready var title_label: Label = %GameTitle
@onready var subtitle_label: Label = %SubtitleLabel
@onready var version_label: Label = %VersionLabel
@onready var developer_label: Label = %DeveloperLabel
@onready var button_container: VBoxContainer = %ButtonContainer

# ============================================================================
#  MENU STATE
# ============================================================================

var current_settings_menu: Control = null
var is_settings_open: bool = false
var is_initialized: bool = false

# Hybrid system - preload but instantiate dynamically
var settings_scene: PackedScene = null

# ============================================================================
#  LIFECYCLE
# ============================================================================

func _ready():
	await _initialize_menu()

func _input(event: InputEvent) -> void:
	"""Handle global input - ESC to close settings"""
	if not is_initialized:
		return
		
	if event.is_action_pressed("ui_cancel"):
		if is_settings_open:
			_close_settings_menu()
			get_viewport().set_input_as_handled()

# ============================================================================
#  INITIALIZATION
# ============================================================================

func _initialize_menu():
	"""Initialize main menu components"""
	print("MainMenu: Initializing...")
	
	# Wait for scene tree and EventBus
	await get_tree().process_frame
	await _wait_for_event_bus()
	
	# Preload settings scene for hybrid system
	_preload_settings_scene()
	
	# Setup UI elements
	_setup_ui_content()
	_setup_button_focus()
	_setup_animations()
	
	# Set initial focus
	if start_button:
		start_button.grab_focus()
	
	is_initialized = true
	print("MainMenu: Initialization complete")

func _preload_settings_scene():
	"""Preload settings scene for faster instantiation"""
	settings_scene = preload("res://game/scenes/menus/SettingsMenu.tscn")
	if settings_scene:
		print("MainMenu: SettingsMenu scene preloaded successfully")
	else:
		push_error("MainMenu: Failed to preload SettingsMenu.tscn")
		# Try fallback
		print("MainMenu: Attempting to load at runtime...")
		settings_scene = load("res://game/scenes/menus/SettingsMenu.tscn")

func _wait_for_event_bus():
	"""Wait for EventBus to be ready"""
	var attempts = 0
	while not EventBus and attempts < 10:
		await get_tree().process_frame
		attempts += 1

func _setup_ui_content():
	"""Setup UI element content and properties"""
	if title_label:
		title_label.text = "ROGUELIKE ADVENTURE"
	if subtitle_label:
		subtitle_label.text = "A Modern Indie Experience"
	if version_label:
		version_label.text = "Version 1.0.0"
	if developer_label:
		developer_label.text = "Made with ❤️ by Indie Studio"

func _setup_button_focus():
	"""Setup button focus and navigation"""
	if not (start_button and settings_button and quit_button):
		return
	
	# Connect focus signals for simple visual feedback
	start_button.focus_entered.connect(_on_button_focus_entered.bind(start_button))
	settings_button.focus_entered.connect(_on_button_focus_entered.bind(settings_button))
	quit_button.focus_entered.connect(_on_button_focus_entered.bind(quit_button))

func _setup_animations():
	"""Setup disabled - no animations for simplicity"""
	pass

# ============================================================================
#  BUTTON EVENT HANDLERS
# ============================================================================

func _on_start_button_activated():
	"""Handle start button press"""
	print("MainMenu: Start game requested")
	_play_button_sound()
	
	# Emit to EventBus for any systems that listen
	if EventBus:
		EventBus.emit_event("game_start_requested")
	
	# Direct scene transition to Main.tscn
	print("MainMenu: Transitioning to Main scene...")
	get_tree().change_scene_to_file("res://game/scenes/gameplay/Main.tscn")

func _on_settings_button_activated():
	"""Handle settings button press"""
	print("MainMenu: Settings requested")
	_play_button_sound()
	
	if is_settings_open:
		_close_settings_menu()
	else:
		_open_settings_menu()

func _on_quit_button_activated():
	"""Handle quit button press"""
	print("MainMenu: Quit requested")
	_play_button_sound()
	
	if EventBus:
		EventBus.emit_event("quit_requested")
	
	# Simple quit without complex animations
	get_tree().quit()

# ============================================================================
#  FOCUS EFFECTS
# ============================================================================

func _on_button_focus_entered(_button: Button):
	"""Handle button focus gained - simple sound only"""
	_play_focus_sound()

func _animate_button_focus(_button: Button, _focused: bool):
	"""Disabled - no animations for simplicity"""
	pass

# ============================================================================
#  SETTINGS MENU MANAGEMENT
# ============================================================================

func _open_settings_menu():
	"""Open settings menu - simplified version"""
	if current_settings_menu:
		print("MainMenu: Settings already open")
		return
	
	# Simple load and instantiate
	if not settings_scene:
		settings_scene = load("res://game/scenes/menus/SettingsMenu.tscn")
	
	if not settings_scene:
		push_error("MainMenu: Failed to load SettingsMenu.tscn")
		return
	
	# Create instance
	current_settings_menu = settings_scene.instantiate()
	if not current_settings_menu:
		push_error("MainMenu: Failed to instantiate SettingsMenu")
		return
	
	# Add directly to current scene - no overlay layer needed
	get_tree().current_scene.add_child(current_settings_menu)
	is_settings_open = true
	
	# Connect basic signals
	_connect_settings_signals()
	
	print("MainMenu: SettingsMenu opened (basic system)")

func _close_settings_menu():
	"""Close settings menu - simplified version"""
	if not current_settings_menu:
		return
	
	# Disconnect and remove
	_disconnect_settings_signals()
	current_settings_menu.queue_free()
	current_settings_menu = null
	is_settings_open = false
	
	# Return focus to settings button
	if settings_button:
		settings_button.grab_focus()
	
	print("MainMenu: SettingsMenu closed (basic system)")

func _connect_settings_signals():
	"""Connect settings menu signals"""
	if not current_settings_menu:
		return
	
	if current_settings_menu.has_signal("settings_closed"):
		current_settings_menu.settings_closed.connect(_on_settings_menu_closed)
	if current_settings_menu.has_signal("back_pressed"):
		current_settings_menu.back_pressed.connect(_on_settings_back_pressed)

func _disconnect_settings_signals():
	"""Disconnect settings signals"""
	if not current_settings_menu:
		return
	
	if current_settings_menu.has_signal("settings_closed"):
		if current_settings_menu.settings_closed.is_connected(_on_settings_menu_closed):
			current_settings_menu.settings_closed.disconnect(_on_settings_menu_closed)
	if current_settings_menu.has_signal("back_pressed"):
		if current_settings_menu.back_pressed.is_connected(_on_settings_back_pressed):
			current_settings_menu.back_pressed.disconnect(_on_settings_back_pressed)

func _on_settings_menu_closed():
	"""Handle settings menu closed signal"""
	_close_settings_menu()

func _on_settings_back_pressed():
	"""Handle settings back button"""
	_close_settings_menu()

# ============================================================================
#  AUDIO EFFECTS
# ============================================================================

func _play_button_sound():
	"""Play button press sound"""
	if EventBus:
		EventBus.request_audio("sfx", "button_press")

func _play_focus_sound():
	"""Play focus sound"""
	if EventBus:
		EventBus.request_audio("sfx", "button_hover")

# ============================================================================
#  UTILITIES
# ============================================================================

func _show_message(message: String):
	"""Show temporary message"""
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()
	
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(dialog):
		dialog.queue_free()
