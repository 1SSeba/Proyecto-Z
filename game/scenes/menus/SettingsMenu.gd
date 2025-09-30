## SettingsMenu - Main Settings Menu View
##
## View layer for the settings menu. Coordinates the controller and model
## following the MVC pattern. Handles initialization and service setup.
##
## @author: Professional Refactor
## @version: 2.0

extends "res://game/ui/components/BaseView.gd"

# ============================================================================
# PRELOADS
# ============================================================================

const SettingsControllerScript := preload("res://game/ui/settings/SettingsController.gd")
const SettingsModelScript := preload("res://game/ui/settings/SettingsModel.gd")

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when settings menu is closed
@warning_ignore("unused_signal")
signal settings_closed

## Emitted when back/cancel is pressed
@warning_ignore("unused_signal")
signal back_pressed

## Emitted when settings are successfully applied
signal settings_applied

## Emitted when any setting value changes
signal settings_changed

# ============================================================================
# DEPENDENCIES
# ============================================================================

var _config_service = null
var _data_service = null
var _controller = null
var _model = null

# ============================================================================
# STATE
# ============================================================================

var _is_initialized: bool = false

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	await _initialize()

func _input(event: InputEvent) -> void:
	if not _is_initialized or not event.is_action_pressed("ui_cancel"):
		return
	
	_handle_cancel_input()
	get_viewport().set_input_as_handled()

# ============================================================================
# INITIALIZATION
# ============================================================================

## Initialize the settings menu system
func _initialize() -> void:
	if not _validate_service_manager():
		return
	
	if not await _setup_services():
		return
	
	if not _create_model():
		return
	
	if not _create_controller():
		return
	
	_connect_model_signals()
	
	_is_initialized = true

## Validate ServiceManager availability
func _validate_service_manager() -> bool:
	if not ServiceManager:
		push_error("SettingsMenu: ServiceManager not available")
		_handle_initialization_failure("ServiceManager missing")
		return false
	return true

## Setup required services
func _setup_services() -> bool:
	var services: Dictionary = await ServiceManager.wait_for_services([
		"ConfigService",
		"DataService"
	])
	
	_config_service = services.get("ConfigService")
	_data_service = services.get("DataService")
	
	if not _config_service:
		push_error("SettingsMenu: ConfigService not available")
		_handle_initialization_failure("ConfigService unavailable")
		return false
	
	# DataService is optional
	if not _data_service:
		push_warning("SettingsMenu: DataService not available - some features may be limited")
	
	return true

## Create and setup the model
func _create_model() -> bool:
	var model_instance := SettingsModelScript.new()
	
	if not _validate_component(model_instance, "SettingsModel"):
		return false
	
	_model = model_instance
	_model.call("setup", _config_service, _data_service)
	
	return true

## Create and setup the controller
func _create_controller() -> bool:
	var controller_instance := SettingsControllerScript.new()
	
	if not _validate_component(controller_instance, "SettingsController"):
		return false
	
	_controller = controller_instance
	_controller.call("setup", self, _model, _config_service)
	
	return true

## Validate a component (model or controller)
func _validate_component(instance, component_name: String) -> bool:
	if instance == null or not (instance is RefCounted):
		push_error("SettingsMenu: Failed to initialize %s" % component_name)
		_handle_initialization_failure("%s initialization failed" % component_name)
		return false
	
	if not instance.has_method("setup"):
		push_error("SettingsMenu: %s is missing required setup() method" % component_name)
		_handle_initialization_failure("%s missing setup()" % component_name)
		return false
	
	return true

## Connect model signals to view signals
func _connect_model_signals() -> void:
	if _model.has_signal("settings_changed"):
		_model.settings_changed.connect(_on_model_settings_changed)
	
	if _model.has_signal("settings_applied"):
		_model.settings_applied.connect(_on_model_settings_applied)
	
	if _model.has_signal("settings_reset"):
		_model.settings_reset.connect(_on_model_settings_reset)

# ============================================================================
# INPUT HANDLING
# ============================================================================

## Handle cancel/back input
func _handle_cancel_input() -> void:
	if _controller and _controller.has_method("request_cancel"):
		_controller.request_cancel()

# ============================================================================
# MODEL EVENT HANDLERS
# ============================================================================

## Called when any setting changes in the model
func _on_model_settings_changed(_section: String, _key: String, _value) -> void:
	settings_changed.emit()

## Called when settings are successfully applied
func _on_model_settings_applied(_data: Dictionary) -> void:
	settings_applied.emit()

## Called when settings are reset to defaults
func _on_model_settings_reset(_data: Dictionary) -> void:
	settings_changed.emit()

# ============================================================================
# ERROR HANDLING
# ============================================================================

## Handle initialization failure gracefully
func _handle_initialization_failure(reason: String) -> void:
	push_error("SettingsMenu: Critical initialization failure - %s" % reason)
	
	# Give time for error to be logged
	await get_tree().create_timer(0.1).timeout
	
	# Close menu
	emit_signal("settings_closed")
	queue_free()

# ============================================================================
# PUBLIC API
# ============================================================================

## Check if the menu is fully initialized
func is_ready() -> bool:
	return _is_initialized

## Get the controller (for external access if needed)
func get_controller():
	return _controller

## Get the model (for external access if needed)
func get_model():
	return _model

## Request immediate application of settings
func apply_settings() -> void:
	if _controller and _controller.has_method("request_apply"):
		await _controller.request_apply()

## Request reset to default settings
func reset_settings() -> void:
	if _controller and _controller.has_method("request_reset"):
		_controller.request_reset()

## Check if there are unsaved changes
func has_unsaved_changes() -> bool:
	if _controller and _controller.has_method("is_dirty"):
		return _controller.is_dirty()
	return false
