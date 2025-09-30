extends Control

const Log := preload("res://game/core/utils/Logger.gd")
const DEBUG_KEY_HINTS := [
	"F1 - Mostrar/Ocultar ayuda",
	"F5 - Daño rápido",
	"F6 - Curación rápida",
	"F7 - Forzar muerte",
	"F8 - Revivir jugador",
	"F9 - Mostrar/Ocultar consola",
	"F10 - Info del jugador"
]
const PAUSE_MENU_SCENE := preload("res://game/scenes/menus/PauseMenu.tscn")
const SETTINGS_MENU_SCENE := preload("res://game/scenes/menus/SettingsMenu.tscn")

@export var console_toggle_action: StringName = "debug_toggle_console"
@export var keybinds_toggle_action: StringName = "debug_toggle_keybinds"
@export var show_console_on_start: bool = false
@export var show_keybinds_on_start: bool = true
@export var max_console_messages: int = 20

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_text: Label = $HealthText
@onready var fps_label: Label = $FPSLabel
@onready var keybinds_panel: PanelContainer = $KeybindsPanel
@onready var console_panel: PanelContainer = $ConsolePanel
@onready var movement_keys: VBoxContainer = $KeybindsPanel/Margin/Content/MovementKeys
@onready var debug_keys: VBoxContainer = $KeybindsPanel/Margin/Content/DebugKeys
@onready var console_logs: VBoxContainer = $ConsolePanel/Margin/Content/ConsoleScroll/ConsoleLogs
@onready var console_scroll: ScrollContainer = $ConsolePanel/Margin/Content/ConsoleScroll
@onready var command_input: LineEdit = $ConsolePanel/Margin/Content/CommandRow/CommandInput
@onready var execute_button: Button = $ConsolePanel/Margin/Content/CommandRow/ExecuteButton

var player_reference: CharacterBody2D = null
var console_messages: Array[String] = []
var command_history: Array[String] = []
var _history_index: int = -1
var _resource_library: Node = null
var pause_menu: Control = null
var is_pause_menu_open: bool = false
var settings_menu: Control = null
var is_settings_open: bool = false

func _ready():
	Log.info("GameHUD: Ready")
	_load_resources()
	_setup_movement_keys()
	_setup_debug_keys()
	_connect_to_player()
	_setup_console_controls()
	_set_console_visibility(show_console_on_start)
	_set_keybinds_visibility(show_keybinds_on_start)
	_ensure_toggle_actions()
	if console_toggle_action != StringName() and not InputMap.has_action(console_toggle_action):
		Log.warn("GameHUD: Input action '%s' not found; console toggle disabled" % console_toggle_action)
	if keybinds_toggle_action != StringName() and not InputMap.has_action(keybinds_toggle_action):
		Log.warn("GameHUD: Input action '%s' not found; keybinds toggle disabled" % keybinds_toggle_action)

func _load_resources():
	if ServiceManager:
		var services := await ServiceManager.wait_for_services(["ResourceLibrary"])
		_resource_library = services.get("ResourceLibrary")
	_apply_game_colors()

func _apply_game_colors():
	if not _resource_library:
		Log.warn("GameHUD: ResourceLibrary service not available")
		return

	# Search for UI color resources
	var ui_resources = _resource_library.get_resources_by_category(_resource_library.ResourceCategory.UI)

	if ui_resources.size() > 0:
		Log.info("GameHUD: Found %d UI resources" % ui_resources.size())
		# TODO: Apply colors to panels when UI resources are properly defined
	else:
		Log.warn("GameHUD: No UI color resources found in ResourceLibrary")

func _setup_movement_keys():
	if not is_instance_valid(movement_keys):
		return
	var keys = [
		"WASD - Moverse",
		"SPACE - Interactuar",
		"ESC - Menú"
	]

	for child in movement_keys.get_children():
		child.queue_free()

	for key in keys:
		var label = Label.new()
		label.text = key
		label.add_theme_font_size_override("font_size", 14)
		movement_keys.add_child(label)

func _setup_debug_keys() -> void:
	if not is_instance_valid(debug_keys):
		return

	for child in debug_keys.get_children():
		child.queue_free()

	for hint in DEBUG_KEY_HINTS:
		var label := Label.new()
		label.text = hint
		label.add_theme_font_size_override("font_size", 14)
		debug_keys.add_child(label)

func _setup_console_controls() -> void:
	_ensure_console_toggle_action()
	if command_input:
		command_input.text_submitted.connect(_on_command_submitted)
		command_input.gui_input.connect(_on_command_input_gui_input)
		# Placeholder text is configured in the Godot editor
	if execute_button:
		execute_button.pressed.connect(_on_execute_button_pressed)

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

func _process(_delta):
	if fps_label:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

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

	if is_pause_menu_open or is_settings_open:
		return

	if console_toggle_action != StringName() and InputMap.has_action(console_toggle_action) and event.is_action_pressed(console_toggle_action):
		toggle_console_visibility()
		get_viewport().set_input_as_handled()
	
	if keybinds_toggle_action != StringName() and InputMap.has_action(keybinds_toggle_action) and event.is_action_pressed(keybinds_toggle_action):
		toggle_keybinds_visibility()
		get_viewport().set_input_as_handled()

func _on_health_changed(current: float, max_health: float):
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current

	if health_text:
		var percentage = (current / max_health) * 100
		health_text.text = "%.0f/%.0f (%.0f%%)" % [current, max_health, percentage]

	add_log("Salud: %.0f%%" % ((current / max_health) * 100))

func add_log(message: String):
	console_messages.append(message)

	if max_console_messages > 0 and console_messages.size() > max_console_messages:
		console_messages.pop_front()

	_update_console()

func _update_console():
	for child in console_logs.get_children():
		child.queue_free()

	for msg in console_messages:
		var label = Label.new()
		label.text = msg
		label.add_theme_font_size_override("font_size", 13)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		console_logs.add_child(label)

	await get_tree().process_frame
	_scroll_console_to_bottom()

func _scroll_console_to_bottom() -> void:
	if not is_instance_valid(console_scroll):
		return
	await get_tree().process_frame
	var v_bar := console_scroll.get_v_scroll_bar()
	if v_bar and v_bar.max_value > 0:
		console_scroll.scroll_vertical = int(v_bar.max_value + 100)

func _set_console_visibility(value: bool) -> void:
	if not is_instance_valid(console_panel):
		return
	console_panel.visible = value
	if value and command_input:
		command_input.grab_focus()
		command_input.caret_column = command_input.text.length()
	elif not value and command_input and command_input.has_focus():
		command_input.release_focus()

func toggle_console_visibility() -> void:
	_set_console_visibility(not console_panel.visible)

func _set_keybinds_visibility(value: bool) -> void:
	if not is_instance_valid(keybinds_panel):
		return
	keybinds_panel.visible = value

func toggle_keybinds_visibility() -> void:
	_set_keybinds_visibility(not keybinds_panel.visible)

func _on_execute_button_pressed() -> void:
	if command_input:
		_submit_command(command_input.text)
		command_input.grab_focus()
		command_input.caret_column = command_input.text.length()

func _on_command_submitted(text: String) -> void:
	_submit_command(text)

func _submit_command(raw_text: String) -> void:
	var command_text := raw_text.strip_edges()
	if command_text.is_empty():
		return
	command_history.append(command_text)
	_history_index = command_history.size()
	if command_input:
		command_input.text = ""
	add_log("> " + command_text)
	_execute_console_command(command_text)

func _execute_console_command(command_text: String) -> void:
	var parts := command_text.split(" ", false)
	if parts.is_empty():
		return
	var command := parts[0].to_lower()
	var args: Array = []
	if parts.size() > 1:
		args = parts.slice(1, parts.size())
	match command:
		"help":
			add_log("Comandos: damage [n], heal [n], die, revive, info, clear, toggle")
		"damage":
			_execute_damage_command(args)
		"heal":
			_execute_heal_command(args)
		"die":
			_execute_simple_player_command("die")
		"revive":
			_execute_simple_player_command("revive")
		"info":
			_show_player_info()
		"clear":
			console_messages.clear()
			_update_console()
		"toggle":
			toggle_console_visibility()
		_:
			add_log("Comando desconocido: %s" % command)

func _execute_damage_command(args: Array) -> void:
	var amount := _parse_float_argument(args, 10.0)
	if _ensure_player_available():
		player_reference.take_damage(amount)
		add_log("Aplicado daño: %.1f" % amount)

func _execute_heal_command(args: Array) -> void:
	var amount := _parse_float_argument(args, 20.0)
	if _ensure_player_available():
		player_reference.heal(amount)
		add_log("Aplicada curación: %.1f" % amount)

func _execute_simple_player_command(method: String) -> void:
	if not _ensure_player_available():
		return
	if player_reference.has_method(method):
		player_reference.call(method)
		add_log("Ejecutado comando: %s" % method)

func _show_player_info() -> void:
	if not _ensure_player_available():
		return
	var health_component = player_reference.health_component if "health_component" in player_reference else null
	if health_component:
		add_log("Salud -> %.1f/%.1f" % [health_component.current_health, health_component.max_health])
	else:
		add_log("No se encontró HealthComponent en jugador")
	add_log("Posición -> %s" % player_reference.global_position)
	add_log("Velocidad -> %s" % player_reference.velocity)

func _parse_float_argument(args: Array, default_value: float) -> float:
	if args.is_empty():
		return default_value
	var value = args[0]
	var number = value.to_float()
	if is_nan(number):
		add_log("Valor numérico inválido: %s (usando %.1f)" % [value, default_value])
		return default_value
	return number

func _ensure_player_available() -> bool:
	if player_reference and is_instance_valid(player_reference):
		return true
	_connect_to_player()
	if player_reference and is_instance_valid(player_reference):
		return true
	add_log("Jugador no disponible")
	return false

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

func _on_command_input_gui_input(event: InputEvent) -> void:
	if not command_input:
		return
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key: int = event.physical_keycode
	if key == KEY_UP:
		_browse_command_history(-1)
		command_input.accept_event()
	elif key == KEY_DOWN:
		_browse_command_history(1)
		command_input.accept_event()

func _browse_command_history(direction: int) -> void:
	if command_history.is_empty():
		return
	_history_index = clampi(_history_index + direction, 0, command_history.size())
	if _history_index >= command_history.size():
		command_input.text = ""
	else:
		command_input.text = command_history[_history_index]
	command_input.caret_column = command_input.text.length()

func _ensure_console_toggle_action() -> void:
	if console_toggle_action == StringName():
		return
	if not InputMap.has_action(console_toggle_action):
		InputMap.add_action(console_toggle_action)
	var events := InputMap.action_get_events(console_toggle_action)
	if events.is_empty():
		var event := InputEventKey.new()
		event.physical_keycode = KEY_F9
		event.keycode = KEY_F9
		InputMap.action_add_event(console_toggle_action, event)

func _ensure_toggle_actions() -> void:
	_ensure_console_toggle_action()
	
	# Setup keybinds toggle (F1)
	if keybinds_toggle_action == StringName():
		return
	if not InputMap.has_action(keybinds_toggle_action):
		InputMap.add_action(keybinds_toggle_action)
	var events := InputMap.action_get_events(keybinds_toggle_action)
	if events.is_empty():
		var event := InputEventKey.new()
		event.physical_keycode = KEY_F1
		event.keycode = KEY_F1
		InputMap.action_add_event(keybinds_toggle_action, event)

func _open_pause_menu() -> void:
	if is_pause_menu_open:
		return
	if not PAUSE_MENU_SCENE:
		add_log("No se pudo cargar el menú de pausa")
		return
	var instance := PAUSE_MENU_SCENE.instantiate()
	if not instance:
		add_log("No se pudo crear el menú de pausa")
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
		add_log("No se pudo cargar el menú de configuración")
		return
	var instance := SETTINGS_MENU_SCENE.instantiate()
	if not instance:
		add_log("No se pudo crear el menú de configuración")
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
