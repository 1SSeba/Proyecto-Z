extends "res://game/ui/components/BaseView.gd"

const SettingsControllerScript := preload("res://game/ui/settings/SettingsController.gd")
const SettingsModelScript := preload("res://game/ui/settings/SettingsModel.gd")

signal settings_closed # Used by parent nodes (GameHUD, MainMenu)
signal back_pressed # Used by parent nodes (GameHUD, MainMenu)
signal settings_applied
signal settings_changed

var _config_service = null
var _data_service = null
var _controller = null
var _model = null
var _is_initialized: bool = false

func _ready() -> void:
	await _initialize()

func _input(event: InputEvent) -> void:
	if _is_initialized and event.is_action_pressed("ui_cancel"):
		if _controller and _controller.has_method("request_cancel"):
			_controller.request_cancel()
		get_viewport().set_input_as_handled()

func _initialize() -> void:
	if not ServiceManager:
		push_error("SettingsMenu: ServiceManager not available")
		return

	var services: Dictionary = await ServiceManager.wait_for_services(["ConfigService", "DataService"])
	_config_service = services.get("ConfigService")
	_data_service = services.get("DataService")
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
	_model.call("setup", _config_service, _data_service)

	var controller_instance := SettingsControllerScript.new()
	if controller_instance == null or not (controller_instance is RefCounted):
		push_error("SettingsMenu: Failed to initialize SettingsController")
		return
	if not controller_instance.has_method("setup"):
		push_error("SettingsMenu: SettingsController is missing required setup() method")
		return
	_controller = controller_instance
	_controller.call("setup", self, _model, _config_service)

	if _model.has_signal("settings_changed"):
		_model.settings_changed.connect(func(_section, _key, _value): settings_changed.emit())
	if _model.has_signal("settings_applied"):
		_model.settings_applied.connect(func(_data): settings_applied.emit())
	if _model.has_signal("settings_reset"):
		_model.settings_reset.connect(func(_data): settings_changed.emit())

	_is_initialized = true
