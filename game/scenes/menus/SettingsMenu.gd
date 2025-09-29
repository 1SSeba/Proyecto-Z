extends "res://game/ui/components/BaseView.gd"

const SettingsControllerScript := preload("res://game/ui/settings/SettingsController.gd")
const SettingsModelScript := preload("res://game/ui/settings/SettingsModel.gd")

signal settings_closed
signal back_pressed
signal settings_applied
signal settings_changed

var _config_service: Node = null
var _data_service: Node = null
var _controller: RefCounted = null
var _model: RefCounted = null
var _is_initialized: bool = false

func _ready() -> void:
	await _initialize()

func _input(event: InputEvent) -> void:
	if _is_initialized and event.is_action_pressed("ui_cancel"):
		if _controller and _controller.has_method("request_cancel"):
			_controller.request_cancel()
		get_viewport().set_input_as_handled()

func _initialize() -> void:
	await _wait_for_services()
	_config_service = ServiceManager.get_config_service()
	_data_service = ServiceManager.get_data_service()
	if not _config_service:
		push_error("SettingsMenu: ConfigService not available")
		return

	var model_instance := SettingsModelScript.new()
	if model_instance == null or not (model_instance is RefCounted):
		push_error("SettingsMenu: Failed to initialize SettingsModel")
		return
	if not model_instance.has_method("setup"):
		push_error("SettingsMenu: SettingsModel is missing required setup() method")
		return
	_model = model_instance
	model_instance.call("setup", _config_service, _data_service)

	var controller_instance := SettingsControllerScript.new()
	if controller_instance == null or not (controller_instance is RefCounted):
		push_error("SettingsMenu: Failed to initialize SettingsController")
		return
	if not controller_instance.has_method("setup"):
		push_error("SettingsMenu: SettingsController is missing required setup() method")
		return
	_controller = controller_instance
	controller_instance.call("setup", self, model_instance, _config_service)

	if model_instance.has_signal("settings_changed"):
		model_instance.connect("settings_changed", func(_section, _key, _value): settings_changed.emit())
	if model_instance.has_signal("settings_applied"):
		model_instance.connect("settings_applied", func(_data): settings_applied.emit())
	if model_instance.has_signal("settings_reset"):
		model_instance.connect("settings_reset", func(_data): settings_changed.emit())

	_is_initialized = true

func _wait_for_services() -> void:
	while not ServiceManager or not ServiceManager.is_service_ready("ConfigService"):
		await get_tree().process_frame
