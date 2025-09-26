extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_text: Label = $HealthText
@onready var fps_label: Label = $FPSLabel
@onready var movement_keys: VBoxContainer = $MovementKeys
@onready var console_logs: VBoxContainer = $ConsoleLogs

var player_reference: CharacterBody2D = null
var console_messages: Array[String] = []

func _ready():
	print("GameHUD: Ready")
	_load_resources()
	_setup_movement_keys()
	_connect_to_player()

func _load_resources():
	# Wait for ServiceManager to be ready
	await _wait_for_service_manager()
	_apply_game_colors()

func _wait_for_service_manager():
	var max_wait = 100
	var wait_count = 0

	while wait_count < max_wait:
		if ServiceManager and ServiceManager.has_service("ResourceLibrary"):
			break
		await get_tree().process_frame
		wait_count += 1

func _apply_game_colors():
	if not ServiceManager or not ServiceManager.has_service("ResourceLibrary"):
		print("GameHUD: ResourceLibrary service not available")
		return

	var resource_library = ServiceManager.get_service("ResourceLibrary")

	# Search for UI color resources
	var ui_resources = resource_library.get_resources_by_category(resource_library.ResourceCategory.UI)

	if ui_resources.size() > 0:
		print("GameHUD: Found %d UI resources" % ui_resources.size())
		# TODO: Apply colors to panels when UI resources are properly defined
	else:
		print("GameHUD: No UI color resources found in ResourceLibrary")

func _setup_movement_keys():
	var keys = [
		"WASD - Moverse",
		"SPACE - Interactuar",
		"ESC - Menú"
	]

	for key in keys:
		var label = Label.new()
		label.text = key
		label.add_theme_font_size_override("font_size", 12)
		movement_keys.add_child(label)

func _connect_to_player():
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("get_player"):
		player_reference = main_scene.get_player()

		if player_reference and player_reference.has_signal("health_changed"):
			player_reference.health_changed.connect(_on_health_changed)

func _process(_delta):
	if fps_label:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

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

	if console_messages.size() > 8:
		console_messages.pop_front()

	_update_console()

func _update_console():
	for child in console_logs.get_children():
		child.queue_free()

	for msg in console_messages:
		var label = Label.new()
		label.text = msg
		label.add_theme_font_size_override("font_size", 10)
		console_logs.add_child(label)
