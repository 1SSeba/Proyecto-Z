extends Control

@onready var start_button: Button = %StartButton
@onready var multiplayer_button: Button = %MultiplayerButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton

var current_settings_menu: Control = null
var is_settings_open: bool = false
var is_initialized: bool = false

var settings_scene: PackedScene = null

func _ready():
	await _initialize_menu()

func _input(event: InputEvent) -> void:
	if not is_initialized:
		return

	if event.is_action_pressed("ui_cancel"):
		if is_settings_open:
			_close_settings_menu()
			get_viewport().set_input_as_handled()

func _initialize_menu():
	# Wait for scene tree and EventBus
	await get_tree().process_frame
	await _ensure_event_bus_ready()

	# Preload settings scene
	_preload_settings_scene()

	# Setup UI elements
	_setup_button_focus()

	# Set initial focus
	if start_button:
		start_button.grab_focus()

	is_initialized = true

func _preload_settings_scene():
	settings_scene = preload("res://game/scenes/menus/SettingsMenu.tscn")
	if not settings_scene:
		push_error("MainMenu: Failed to preload SettingsMenu.tscn")
		settings_scene = load("res://game/scenes/menus/SettingsMenu.tscn")

func _ensure_event_bus_ready() -> void:
	if EventBus:
		return

	await get_tree().process_frame

	if not EventBus:
		push_warning("MainMenu: EventBus autoload not found; menu actions might fail")

func _setup_button_focus():
	if not (start_button and multiplayer_button and settings_button and quit_button):
		return

	# Connect focus signals for visual feedback
	start_button.focus_entered.connect(_on_button_focus_entered.bind(start_button))
	multiplayer_button.focus_entered.connect(_on_button_focus_entered.bind(multiplayer_button))
	settings_button.focus_entered.connect(_on_button_focus_entered.bind(settings_button))
	quit_button.focus_entered.connect(_on_button_focus_entered.bind(quit_button))

#  BUTTON EVENT HANDLERS

func _on_start_button_activated():
	_play_button_sound()

	if EventBus:
		EventBus.emit_event("game_start_requested")

	var game_flow = ServiceManager.get_game_flow_controller() if ServiceManager else null
	if game_flow:
		game_flow.start_new_game()
	else:
		get_tree().change_scene_to_file("res://game/scenes/gameplay/Main.tscn")

func _on_multiplayer_button_activated():
	_play_button_sound()

	if EventBus:
		EventBus.emit_event("multiplayer_requested")

	var game_flow = ServiceManager.get_game_flow_controller() if ServiceManager else null
	if game_flow:
		game_flow.go_to_lobby()
	else:
		get_tree().change_scene_to_file("res://game/scenes/environments/Lobby/Lobby.tscn")

func _on_settings_button_activated():
	_play_button_sound()

	if is_settings_open:
		_close_settings_menu()
	else:
		_open_settings_menu()

func _on_quit_button_activated():
	_play_button_sound()

	if EventBus:
		EventBus.emit_event("quit_requested")

	get_tree().quit()

#  FOCUS EFFECTS

func _on_button_focus_entered(_button: Button):
	_play_focus_sound()

#  SETTINGS MENU MANAGEMENT

func _open_settings_menu():
	if current_settings_menu:
		return

	if not settings_scene:
		settings_scene = load("res://game/scenes/menus/SettingsMenu.tscn")

	if not settings_scene:
		push_error("MainMenu: Failed to load SettingsMenu.tscn")
		return

	current_settings_menu = settings_scene.instantiate()
	if not current_settings_menu:
		push_error("MainMenu: Failed to instantiate SettingsMenu")
		return

	get_tree().current_scene.add_child(current_settings_menu)
	is_settings_open = true
	_connect_settings_signals()

func _close_settings_menu():
	if not current_settings_menu:
		return

	_disconnect_settings_signals()
	current_settings_menu.queue_free()
	current_settings_menu = null
	is_settings_open = false

	if settings_button:
		settings_button.grab_focus()

func _connect_settings_signals():
	if not current_settings_menu:
		return

	if current_settings_menu.has_signal("settings_closed"):
		current_settings_menu.settings_closed.connect(_on_settings_menu_closed)
	if current_settings_menu.has_signal("back_pressed"):
		current_settings_menu.back_pressed.connect(_on_settings_back_pressed)

func _disconnect_settings_signals():
	if not current_settings_menu:
		return

	if current_settings_menu.has_signal("settings_closed"):
		if current_settings_menu.settings_closed.is_connected(_on_settings_menu_closed):
			current_settings_menu.settings_closed.disconnect(_on_settings_menu_closed)
	if current_settings_menu.has_signal("back_pressed"):
		if current_settings_menu.back_pressed.is_connected(_on_settings_back_pressed):
			current_settings_menu.back_pressed.disconnect(_on_settings_back_pressed)

func _on_settings_menu_closed():
	_close_settings_menu()

func _on_settings_back_pressed():
	_close_settings_menu()

# AUDIO EFFECTS

func _play_button_sound():
	pass

func _play_focus_sound():
	pass
