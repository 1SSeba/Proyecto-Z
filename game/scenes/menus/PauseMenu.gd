extends Control

const Log := preload("res://game/core/utils/Logger.gd")

signal resume_requested
signal settings_requested
signal main_menu_requested
signal quit_requested

@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	_process_button_connections()
	_grab_initial_focus()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_resume_button_pressed()
		get_viewport().set_input_as_handled()

func show_menu() -> void:
	visible = true
	_grab_initial_focus()

func hide_menu() -> void:
	visible = false

func _process_button_connections() -> void:
	if resume_button and not resume_button.pressed.is_connected(_on_resume_button_pressed):
		resume_button.pressed.connect(_on_resume_button_pressed)
	if settings_button and not settings_button.pressed.is_connected(_on_settings_button_pressed):
		settings_button.pressed.connect(_on_settings_button_pressed)
	if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_button_pressed):
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	if quit_button and not quit_button.pressed.is_connected(_on_quit_button_pressed):
		quit_button.pressed.connect(_on_quit_button_pressed)

func _grab_initial_focus() -> void:
	if resume_button:
		resume_button.grab_focus()

func _on_resume_button_pressed() -> void:
	Log.info("PauseMenu: Resume pressed")
	hide_menu()
	resume_requested.emit()

func _on_settings_button_pressed() -> void:
	Log.info("PauseMenu: Settings pressed")
	settings_requested.emit()

func _on_main_menu_button_pressed() -> void:
	Log.info("PauseMenu: Main menu pressed")
	main_menu_requested.emit()

func _on_quit_button_pressed() -> void:
	Log.info("PauseMenu: Quit pressed")
	quit_requested.emit()
