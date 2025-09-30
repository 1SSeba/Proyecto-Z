## SettingsModel - Settings Data Model
##
## Manages settings data and state. Handles loading, saving, validation,
## and change tracking for all game settings.
## Part of the MVC pattern for settings management.
##
## @author: Professional Refactor
## @version: 2.0

extends RefCounted
class_name SettingsModel

# ============================================================================
# PRELOADS
# ============================================================================

const SettingsValidator := preload("res://game/ui/settings/SettingsValidator.gd")
const GAME_SETTINGS_DATA_SCRIPT := preload("res://game/data/settings/GameSettingsData.gd")

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when settings are loaded from config
signal settings_loaded(data: Dictionary)

## Emitted when any setting value changes
signal settings_changed(section: String, key: String, value)

## Emitted when settings are reset to defaults
signal settings_reset(data: Dictionary)

## Emitted when settings are applied/saved
signal settings_applied(data: Dictionary)

# ============================================================================
# DEPENDENCIES
# ============================================================================

var _config_service = null
var _data_service = null

# ============================================================================
# STATE
# ============================================================================

## Current settings values
var _current_settings: Dictionary = {}

## Default settings values
var _default_settings: Dictionary = {}

## Tracks which settings have been modified
var _dirty_map: Dictionary = {}

## Initialize the model with required services
## @param config_service: Service for loading/saving configuration
## @param data_service: Service for accessing default settings data
func setup(config_service, data_service) -> void:
	_config_service = config_service
	_data_service = data_service
	_load_default_settings()
	_load_from_config()

## Load default settings from data service or fallback
func _load_default_settings() -> void:
	_default_settings = {}
	if _data_service and _data_service.has_method("get_settings_defaults_dict"):
		var defaults: Dictionary = _data_service.get_settings_defaults_dict()
		if not defaults.is_empty():
			_default_settings = defaults.duplicate(true)

	if _default_settings.is_empty():
		var fallback := GAME_SETTINGS_DATA_SCRIPT.new()
		_default_settings = fallback.to_dictionary()

## Load settings from config service and merge with defaults
func _load_from_config() -> void:
	if _config_service and _config_service.has_method("get_all_settings"):
		var loaded: Dictionary = _config_service.get_all_settings()
		_current_settings = _merge_defaults(_default_settings, loaded)

		# Validate loaded settings
		_validate_and_sanitize_settings()
	else:
		_current_settings = _default_settings.duplicate(true)
	_dirty_map.clear()
	settings_loaded.emit(_current_settings.duplicate(true))

## Get a complete copy of all current settings
## @return Dictionary: All settings organized by section
func get_all_settings() -> Dictionary:
	return _current_settings.duplicate(true)

## Get all settings for a specific section
## @param section: The settings section name (e.g., "audio", "video")
## @return Dictionary: Settings for the requested section
func get_section(section: String) -> Dictionary:
	return _current_settings.get(section, {}).duplicate(true)

## Get a specific setting value
## @param section: The settings section name
## @param key: The setting key within the section
## @param default_value: Value to return if setting doesn't exist
## @return: The setting value or default_value if not found
func get_value(section: String, key: String, default_value = null):
	if _current_settings.has(section) and _current_settings[section].has(key):
		return _current_settings[section][key]
	return default_value

## Set a specific setting value with validation
## @param section: The settings section name
## @param key: The setting key within the section
## @param value: The new value to set
func set_value(section: String, key: String, value) -> void:
	# Validate the value before setting
	var validation_error := SettingsValidator.validate_value(section, key, value)
	if not validation_error.is_empty():
		push_warning("SettingsModel: Validation failed - %s" % validation_error)
		return

	if not _current_settings.has(section):
		_current_settings[section] = {}

	if _current_settings[section].get(key) == value:
		return

	_current_settings[section][key] = value
	_mark_dirty(section, key)
	settings_changed.emit(section, key, value)

## Reset all settings to their default values
func reset_to_defaults() -> void:
	_current_settings = _default_settings.duplicate(true)
	_dirty_map.clear()
	settings_reset.emit(_current_settings.duplicate(true))

## Check if there are any unsaved changes
## @return bool: True if settings have been modified but not saved
func is_dirty() -> bool:
	return not _dirty_map.is_empty()

## Get list of sections that have unsaved changes
## @return Array: Section names with pending changes
func get_dirty_sections() -> Array:
	return _dirty_map.keys()

## Apply all pending changes and save to config
func apply_changes() -> void:
	if not _config_service:
		return

	for section in _current_settings.keys():
		for key in _current_settings[section].keys():
			if _config_service.has_method("set_value"):
				_config_service.set_value(section, key, _current_settings[section][key])

	if _config_service.has_method("save_config"):
		_config_service.save_config()

	_dirty_map.clear()
	settings_applied.emit(_current_settings.duplicate(true))

## Reload settings from config (discards unsaved changes)
func reload() -> void:
	_load_from_config()

## Get a copy of the default settings
## @return Dictionary: Default settings for all sections
func get_defaults() -> Dictionary:
	return _default_settings.duplicate(true)

# ============================================================================
# INTERNAL METHODS
# ============================================================================

## Mark a setting as dirty (modified but not saved)
func _mark_dirty(section: String, key: String) -> void:
	if not _dirty_map.has(section):
		_dirty_map[section] = {}
	_dirty_map[section][key] = true

## Merge default settings with user overrides
## @param defaults: Default settings dictionary
## @param overrides: User settings to override defaults
## @return Dictionary: Merged settings
func _merge_defaults(defaults: Dictionary, overrides: Dictionary) -> Dictionary:
	var merged := defaults.duplicate(true)
	for section in overrides.keys():
		if not merged.has(section):
			merged[section] = {}
		for key in overrides[section].keys():
			merged[section][key] = overrides[section][key]
	return merged

## Validate and sanitize all current settings
func _validate_and_sanitize_settings() -> void:
	var validation_result: Dictionary = SettingsValidator.validate_settings(_current_settings)

	if not validation_result.valid:
		push_warning("SettingsModel: Settings validation failed:")
		for error in validation_result.errors:
			push_warning("  - %s" % error)

		# Sanitize invalid values
		_sanitize_invalid_settings()

## Sanitize settings by clamping/defaulting invalid values
func _sanitize_invalid_settings() -> void:
	for section in _current_settings.keys():
		if not SettingsValidator.has_section(section):
			push_warning("SettingsModel: Removing unknown section: %s" % section)
			_current_settings.erase(section)
			continue

		var section_data: Dictionary = _current_settings[section]
		var keys_to_sanitize := section_data.keys()

		for key in keys_to_sanitize:
			if not SettingsValidator.has_key(section, key):
				push_warning("SettingsModel: Removing unknown key: %s.%s" % [section, key])
				section_data.erase(key)
				continue

			var value = section_data[key]
			var error := SettingsValidator.validate_value(section, key, value)

			if not error.is_empty():
				var clamped = SettingsValidator.clamp_value(section, key, value)
				if clamped != value:
					push_warning("SettingsModel: Clamping %s.%s from %s to %s" % [section, key, value, clamped])
					section_data[key] = clamped
				else:
					var default = SettingsValidator.get_safe_default(section, key)
					push_warning("SettingsModel: Resetting %s.%s to default: %s" % [section, key, default])
					section_data[key] = default
