extends Control

@onready var btn_start: Button = $BoxContainer/StartGame
@onready var btn_settings: Button = $BoxContainer/Settings
@onready var btn_quit: Button = $BoxContainer/Quit
@onready var settings_menu: Control = $SettingsMenu

func _ready():
	btn_start.pressed.connect(_on_start_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_quit.pressed.connect(_on_exit_pressed)
	settings_menu.hide()	

func _on_start_pressed():
	print("Start Game")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed():
	settings_menu.show()

func _on_exit_pressed():
	get_tree().quit()
