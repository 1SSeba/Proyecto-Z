extends Control

const Log := preload("res://game/core/utils/Logger.gd")
const PAUSE_MENU_SCENE := preload("res://game/scenes/menus/PauseMenu.tscn")
const SETTINGS_MENU_SCENE := preload("res://game/scenes/menus/SettingsMenu.tscn")

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_text: Label = $HealthText

var player_reference: CharacterBody2D = null
var _resource_library: Node = null
var pause_menu: Control = null
var is_pause_menu_open: bool = false
var settings_menu: Control = null
var is_settings_open: bool = false

func _ready():
	Log.info("GameHUD: Ready")
	_load_resources()
	_connect_to_player()

func _load_resources():
	if ServiceManager:
		var services := await ServiceManager.wait_for_services(["ResourceLibrary"])
		_resource_library = services.get("ResourceLibrary")
	_apply_game_colors()

func _apply_game_colors():
	if not _resource_library:
		Log.warn("GameHUD: ResourceLibrary service not available")
		return

	var ui_resources = _resource_library.get_resources_by_category(_resource_library.ResourceCategory.UI)

	if ui_resources.size() > 0:
		Log.info("GameHUD: Found %d UI resources" % ui_resources.size())
	else:
		Log.warn("GameHUD: No UI color resources found in ResourceLibrary")

func _connect_to_player():
	if player_reference and is_instance_valid(player_reference):
		return

	var main_scene := get_tree().current_scene
	if not main_scene:
		await get_tree().process_frame
		main_scene = get_tree().current_scene
	if not main_scene:
		Log.warn("GameHUD: Main scene not ready")
		return
	if not main_scene.has_method("get_player"):
		Log.warn("GameHUD: Main scene lacks get_player()")
		return

	var player = main_scene.get_player()
	if not is_instance_valid(player):
		Log.warn("GameHUD: Player not found")
		return

	player_reference = player

	if player_reference.has_signal("health_changed"):
		var health_signal = player_reference.health_changed
		if not health_signal.is_connected(_on_health_changed):
			health_signal.connect(_on_health_changed)

	_refresh_health_display()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if is_settings_open:
			_close_settings_menu()
		elif is_pause_menu_open:
			_close_pause_menu()
		else:
			_open_pause_menu()
		get_viewport().set_input_as_handled()
		return

func _on_health_changed(current: float, max_health: float):
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current

	if health_text:
		var percentage = (current / max_health) * 100
		health_text.text = "%.0f/%.0f (%.0f%%)" % [current, max_health, percentage]

func _refresh_health_display() -> void:
	if not player_reference or not is_instance_valid(player_reference):
		return
	var has_health_component := "health_component" in player_reference
	if has_health_component:
		var health_component = player_reference.health_component
		if health_component and health_component.has_method("get_current_health"):
			_on_health_changed(health_component.get_current_health(), health_component.max_health)
		elif health_component and "current_health" in health_component:
			_on_health_changed(health_component.current_health, health_component.max_health)

func _open_pause_menu() -> void:
	if is_pause_menu_open:
		return
	if not PAUSE_MENU_SCENE:
		Log.error("GameHUD: No se pudo cargar el menú de pausa")
		return
	var instance := PAUSE_MENU_SCENE.instantiate()
	if not instance:
		Log.error("GameHUD: No se pudo crear el menú de pausa")
		return
	pause_menu = instance
	pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_add_pause_menu_signals()
	add_child(pause_menu)
	if pause_menu.has_method("show_menu"):
		pause_menu.show_menu()
	else:
		pause_menu.visible = true
	if pause_menu is CanvasItem:
		pause_menu.z_index = 100
	var game_state_manager = _get_game_state_manager()
	if game_state_manager and game_state_manager.has_method("pause_game"):
		game_state_manager.pause_game()
	get_tree().paused = true
	is_pause_menu_open = true

func _close_pause_menu(resume_state: bool = true) -> void:
	if not is_pause_menu_open:
		return
	_close_settings_menu()
	if resume_state:
		var game_state_manager = _get_game_state_manager()
		if game_state_manager and game_state_manager.has_method("resume_game"):
			game_state_manager.resume_game()
	get_tree().paused = false
	_remove_pause_menu_signals()
	if pause_menu:
		if pause_menu.has_method("hide_menu"):
			pause_menu.hide_menu()
		pause_menu.queue_free()
		pause_menu = null
	is_pause_menu_open = false

func _add_pause_menu_signals() -> void:
	if not pause_menu:
		return
	if pause_menu.has_signal("resume_requested"):
		pause_menu.resume_requested.connect(_on_pause_menu_resume_requested)
	if pause_menu.has_signal("settings_requested"):
		pause_menu.settings_requested.connect(_on_pause_menu_settings_requested)
	if pause_menu.has_signal("main_menu_requested"):
		pause_menu.main_menu_requested.connect(_on_pause_menu_main_menu_requested)
	if pause_menu.has_signal("quit_requested"):
		pause_menu.quit_requested.connect(_on_pause_menu_quit_requested)

func _remove_pause_menu_signals() -> void:
	if not pause_menu:
		return
	if pause_menu.has_signal("resume_requested") and pause_menu.resume_requested.is_connected(_on_pause_menu_resume_requested):
		pause_menu.resume_requested.disconnect(_on_pause_menu_resume_requested)
	if pause_menu.has_signal("settings_requested") and pause_menu.settings_requested.is_connected(_on_pause_menu_settings_requested):
		pause_menu.settings_requested.disconnect(_on_pause_menu_settings_requested)
	if pause_menu.has_signal("main_menu_requested") and pause_menu.main_menu_requested.is_connected(_on_pause_menu_main_menu_requested):
		pause_menu.main_menu_requested.disconnect(_on_pause_menu_main_menu_requested)
	if pause_menu.has_signal("quit_requested") and pause_menu.quit_requested.is_connected(_on_pause_menu_quit_requested):
		pause_menu.quit_requested.disconnect(_on_pause_menu_quit_requested)

func _on_pause_menu_resume_requested() -> void:
	_close_pause_menu()

func _on_pause_menu_settings_requested() -> void:
	_open_settings_menu()

func _on_pause_menu_main_menu_requested() -> void:
	_close_pause_menu(false)
	var game_flow = ServiceManager.get_game_flow_controller() if ServiceManager else null
	if game_flow:
		game_flow.return_to_main_menu()
	else:
		get_tree().change_scene_to_file("res://game/scenes/menus/MainMenu.tscn")

func _on_pause_menu_quit_requested() -> void:
	_close_pause_menu(false)
	var game_flow = ServiceManager.get_game_flow_controller() if ServiceManager else null
	if game_flow:
		game_flow.quit_game()
	else:
		get_tree().quit()

func _open_settings_menu() -> void:
	if is_settings_open:
		return
	if not SETTINGS_MENU_SCENE:
		Log.error("GameHUD: No se pudo cargar el menú de configuración")
		return
	var instance := SETTINGS_MENU_SCENE.instantiate()
	if not instance:
		Log.error("GameHUD: No se pudo crear el menú de configuración")
		return
	settings_menu = instance
	settings_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_add_settings_menu_signals()
	add_child(settings_menu)
	if settings_menu is CanvasItem:
		settings_menu.z_index = 110
	is_settings_open = true
	if pause_menu and pause_menu.has_method("hide_menu"):
		pause_menu.hide_menu()

func _close_settings_menu() -> void:
	if not settings_menu:
		is_settings_open = false
		if pause_menu and pause_menu.has_method("show_menu") and pause_menu.visible == false:
			pause_menu.show_menu()
		return
	_remove_settings_menu_signals()
	settings_menu.queue_free()
	settings_menu = null
	is_settings_open = false
	if pause_menu and pause_menu.has_method("show_menu"):
		pause_menu.show_menu()

func _add_settings_menu_signals() -> void:
	if not settings_menu:
		return
	if settings_menu.has_signal("settings_closed"):
		settings_menu.settings_closed.connect(_on_settings_menu_closed)
	if settings_menu.has_signal("back_pressed"):
		settings_menu.back_pressed.connect(_on_settings_menu_closed)

func _remove_settings_menu_signals() -> void:
	if not settings_menu:
		return
	if settings_menu.has_signal("settings_closed") and settings_menu.settings_closed.is_connected(_on_settings_menu_closed):
		settings_menu.settings_closed.disconnect(_on_settings_menu_closed)
	if settings_menu.has_signal("back_pressed") and settings_menu.back_pressed.is_connected(_on_settings_menu_closed):
		settings_menu.back_pressed.disconnect(_on_settings_menu_closed)

func _on_settings_menu_closed() -> void:
	_close_settings_menu()

func _get_game_state_manager() -> Node:
	if ServiceManager:
		var game_flow = ServiceManager.get_game_flow_controller()
		if game_flow and "game_state_manager" in game_flow:
			return game_flow.game_state_manager
	return get_tree().root.get_node_or_null("GameStateManager")
