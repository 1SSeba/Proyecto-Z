extends "res://game/core/systems/game-state/StateMachine/State.gd"
# MenuState.gd - Estado genérico para menús (principal, configuración, etc.)

var menu_scene: PackedScene
var menu_node: Node
var menu_type: String = "MainMenu" # Puede ser "MainMenu", "Settings", etc.
var return_state: String = ""

func enter(_previous_state: Node = null) -> void:
	print("🟦 Entering MenuState: %s" % menu_type)
	var data = state_machine.get_transition_data()
	if "menu_type" in data:
		menu_type = data["menu_type"]
	if "return_state" in data:
		return_state = data["return_state"]
	else:
		return_state = _previous_state.get_state_name() if _previous_state else ""
	_load_menu_scene()

func _load_menu_scene():
	var scene_path = "res://game/scenes/menus/%sMenu.tscn" % menu_type
	menu_scene = load(scene_path)
	if menu_scene:
		menu_node = menu_scene.instantiate()
		var current_scene = get_tree().current_scene
		if current_scene:
			current_scene.add_child(menu_node)
			_connect_menu_signals()
		else:
			print("❌ No current scene available for menu: %s" % menu_type)
	else:
		print("❌ Could not load menu scene: %s" % scene_path)
		if return_state:
			transition_to(return_state)

func _connect_menu_signals():
	if menu_node:
		if menu_node.has_signal("start_game_requested"):
			menu_node.start_game_requested.connect(_on_start_game_requested)
		if menu_node.has_signal("settings_requested"):
			menu_node.settings_requested.connect(_on_settings_requested)
		if menu_node.has_signal("quit_requested"):
			menu_node.quit_requested.connect(_on_quit_requested)
		if menu_node.has_signal("menu_closed"):
			menu_node.menu_closed.connect(_on_menu_closed)
		if menu_node.has_signal("back_requested"):
			menu_node.back_requested.connect(_on_back_requested)

func _on_start_game_requested():
	transition_to("LoadingState")

func _on_settings_requested():
	transition_to("MenuState", {"menu_type": "Settings", "return_state": menu_type})

func _on_quit_requested():
	get_tree().quit()

func _on_menu_closed():
	if return_state:
		transition_to(return_state)

func _on_back_requested():
	if return_state:
		transition_to(return_state)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if return_state:
			transition_to(return_state)

func exit() -> void:
	print("🟦 Exiting MenuState: %s" % menu_type)
	if menu_node:
		menu_node.queue_free()
		menu_node = null
