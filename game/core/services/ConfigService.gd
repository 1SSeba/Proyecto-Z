extends Node
# ConfigService.gd - Gestiona la configuración del juego

## Professional Configuration Service
## Clean, modular configuration management
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  CONFIGURATION PROPERTIES
# ============================================================================

# Variables del servicio
var service_name: String = "ConfigService"
var is_service_ready: bool = false

var config_data: Dictionary = {}
var config_file_path: String = "user://game_config.cfg"
var config_file: ConfigFile = ConfigFile.new()

# Default configuration
var default_config: Dictionary = {
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.8,
		"sfx_volume": 1.0
	},
	"graphics": {
		"fullscreen": false,
		"vsync": true,
		"resolution": "1280x720"
	},
	"gameplay": {
		"difficulty": "normal",
		"auto_save": true
	},
	"controls": {
		"move_up": "w",
		"move_down": "s",
		"move_left": "a",
		"move_right": "d",
		"interact": "e"
	}
}

# ============================================================================
#  SERVICE LIFECYCLE
# ============================================================================

func _start():
	service_name = "ConfigService"
	load_config()
	print("ConfigService: Configuration loaded successfully")

# ============================================================================
#  CONFIGURATION MANAGEMENT
# ============================================================================

func load_config():
	"""Load configuration from file"""
	config_data = default_config.duplicate(true)
	
	if config_file.load(config_file_path) == OK:
		_merge_loaded_config()
		print("ConfigService: Config file loaded from: ", config_file_path)
	else:
		print("ConfigService: No config file found, using defaults")
		save_config()

func _merge_loaded_config():
	"""Merge loaded config with defaults"""
	for section in config_file.get_sections():
		if not config_data.has(section):
			config_data[section] = {}
		
		for key in config_file.get_section_keys(section):
			config_data[section][key] = config_file.get_value(section, key)

func save_config():
	"""Save configuration to file"""
	config_file = ConfigFile.new()
	
	for section in config_data.keys():
		for key in config_data[section].keys():
			config_file.set_value(section, key, config_data[section][key])
	
	if config_file.save(config_file_path) == OK:
		print("ConfigService: Configuration saved to: ", config_file_path)
	else:
		print("ConfigService: Failed to save configuration")

# ============================================================================
#  CONFIG ACCESS METHODS
# ============================================================================

func get_setting(section: String, key: String, default_value = null):
	"""Get a configuration setting"""
	if config_data.has(section) and config_data[section].has(key):
		return config_data[section][key]
	return default_value

func set_setting(section: String, key: String, value):
	"""Set a configuration setting"""
	if not config_data.has(section):
		config_data[section] = {}
	
	config_data[section][key] = value

# Aliases para compatibilidad
func get_value(section: String, key: String, default_value = null):
	"""Alias para get_setting"""
	return get_setting(section, key, default_value)

func set_value(section: String, key: String, value):
	"""Alias para set_setting"""
	set_setting(section, key, value)

# ============================================================================
#  CONVENIENCE METHODS
# ============================================================================

func get_audio_setting(key: String, default_value = null):
	"""Get audio setting"""
	return get_setting("audio", key, default_value)

func set_audio_setting(key: String, value):
	"""Set audio setting"""
	set_setting("audio", key, value)

func get_graphics_setting(key: String, default_value = null):
	"""Get graphics setting"""
	return get_setting("graphics", key, default_value)

func set_graphics_setting(key: String, value):
	"""Set graphics setting"""
	set_setting("graphics", key, value)

func get_gameplay_setting(key: String, default_value = null):
	"""Get gameplay setting"""
	return get_setting("gameplay", key, default_value)

func set_gameplay_setting(key: String, value):
	"""Set gameplay setting"""
	set_setting("gameplay", key, value)

# ============================================================================
#  BULK OPERATIONS
# ============================================================================

func reset_to_defaults():
	"""Reset all settings to defaults"""
	config_data = default_config.duplicate(true)
	save_config()
	print("ConfigService: Reset to default configuration")

func get_all_settings() -> Dictionary:
	"""Get all configuration settings"""
	return config_data.duplicate(true)

func import_settings(settings: Dictionary):
	"""Import settings from dictionary"""
	config_data = settings.duplicate(true)
	save_config()
	print("ConfigService: Imported new configuration")

# ============================================================================
#  SERVICE INFO
# ============================================================================

func get_config_status() -> Dictionary:
	"""Get configuration service status"""
	return {
		"config_file_exists": FileAccess.file_exists(config_file_path),
		"config_file_path": config_file_path,
		"sections_count": config_data.size(),
		"total_settings": _count_total_settings()
	}

func _count_total_settings() -> int:
	"""Count total number of settings"""
	var count = 0
	for section in config_data.values():
		count += section.size()
	return count
