# ConfigManager.gd - Autoload optimizado para gestionar configuración del roguelike
extends Node

# =======================
#  CONSTANTES Y SEÑALES
# =======================
const CONFIG_PATH := "user://Data/Settings.cfg"
signal config_loaded
signal setting_changed(section: String, key: String, value)
signal config_validated(success: bool, errors: Array)

# =======================
#  VARIABLES
# =======================
var is_new_player: bool = false
var config := ConfigFile.new()
var is_initialized: bool = false

# Configuración en memoria para acceso rápido
var settings = {
	"audio": {
		"master_volume": 100, 
		"music_volume": 100, 
		"sfx_volume": 100
	},
	"video": {
		"screen_mode": 0, 
		"resolution": 0, 
		"vsync": true
	},
	"controls": {
		"custom_inputs": {}
	},
	"game_progress": {
		"best_time": 0.0,
		"total_completed": 0,
		"total_failed": 0,
		"total_started": 0,
		"best_streak": 0,
		"total_time_played": 0.0,
		"fastest_completion": 0.0,
		"average_completion_time": 0.0
	},
	"gameplay": {
		"show_timer": true,
		"show_fps": false,
		"particles_enabled": true,
		"screen_shake": true,
		"damage_numbers": true
	},
	"meta": {
		"config_version": 2,
		"last_save_time": "",
		"total_launches": 0
	}
}

# =======================
#  INICIALIZACIÓN SIMPLIFICADA
# =======================
func _ready():
	print("ConfigManager: Starting initialization...")
	ManagerUtils.log_to_debug("ConfigManager: Starting initialization...", "cyan")
	check_or_create_config()

func check_or_create_config():
	# Asegurar que el directorio existe
	_ensure_directory_exists()
	
	var err = config.load(CONFIG_PATH)
	if err != OK:
		is_new_player = true
		print("ConfigManager: Creating default config file... (Error: %d)" % err)
		ManagerUtils.log_to_debug("ConfigManager: Creating default config file (New player)", "yellow")
		create_default_config()
		save()
	else:
		is_new_player = false
		print("ConfigManager: Loading existing config file...")
		ManagerUtils.log_to_debug("ConfigManager: Loading existing config file", "green")
		load_settings_from_file()
	
	# Migrar configuración si es necesario
	migrate_config_if_needed()
	
	# Incrementar contador de lanzamientos
	_increment_launch_counter()
	
	is_initialized = true
	config_loaded.emit()
	print("ConfigManager: Initialization complete - New player: %s" % is_new_player)
	ManagerUtils.log_to_debug("ConfigManager: Initialization complete", "green")

func _ensure_directory_exists():
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("Data"):
			var err = dir.make_dir_recursive("Data")
			if err == OK:
				print("ConfigManager: Created Data directory")
				ManagerUtils.log_to_debug("ConfigManager: Created Data directory", "green")
			else:
				print("ConfigManager: ERROR creating Data directory: %d" % err)
				ManagerUtils.log_error("ConfigManager: ERROR creating Data directory: %d" % err)
	else:
		print("ConfigManager: ERROR accessing user:// directory")
		ManagerUtils.log_error("ConfigManager: ERROR accessing user:// directory")

func create_default_config():
	for section in settings.keys():
		for key in settings[section].keys():
			config.set_value(section, key, settings[section][key])
	print("ConfigManager: Default config created")

func load_settings_from_file():
	for section in settings.keys():
		# Asegurar que la sección existe en settings
		if not settings.has(section):
			settings[section] = {}
		
		# Cargar todas las claves de la sección desde el archivo
		var section_keys = config.get_section_keys(section)
		for key in section_keys:
			var loaded_value = config.get_value(section, key)
			settings[section][key] = loaded_value
		
		# Verificar que las claves por defecto están presentes
		var default_section = _get_default_settings().get(section, {})
		for key in default_section.keys():
			if not settings[section].has(key):
				settings[section][key] = default_section[key]
				print("ConfigManager: Added missing key %s:%s with default value" % [section, key])
	
	print("ConfigManager: Settings loaded from file")

func _increment_launch_counter():
	"""Incrementa el contador de lanzamientos"""
	var launches = get_setting("meta", "total_launches", 0)
	set_setting("meta", "total_launches", launches + 1, false)
	set_setting("meta", "last_save_time", Time.get_datetime_string_from_system(), false)

# =======================
#  GUARDADO Y CARGA
# =======================
func save() -> bool:
	if not is_initialized:
		print("ConfigManager: WARNING - Attempting to save before initialization")
		ManagerUtils.log_warning("ConfigManager: Attempting to save before initialization")
		return false
	
	# Actualizar timestamp
	set_setting("meta", "last_save_time", Time.get_datetime_string_from_system(), false)
	
	# Guardar todas las configuraciones actuales
	for section in settings.keys():
		for key in settings[section].keys():
			config.set_value(section, key, settings[section][key])
	
	var err = config.save(CONFIG_PATH)
	if err == OK:
		print("ConfigManager: Settings saved successfully")
		ManagerUtils.log_success("ConfigManager: Settings saved successfully")
		return true
	else:
		print("ConfigManager: ERROR saving settings: %d" % err)
		ManagerUtils.log_error("ConfigManager: ERROR saving settings: %d" % err)
		return false

func reload_config():
	"""Recarga la configuración desde el archivo"""
	if not is_initialized:
		return false
		
	var err = config.load(CONFIG_PATH)
	if err == OK:
		load_settings_from_file()
		config_loaded.emit()
		print("ConfigManager: Config reloaded successfully")
		ManagerUtils.log_success("ConfigManager: Config reloaded successfully")
		return true
	else:
		print("ConfigManager: ERROR reloading config: %d" % err)
		ManagerUtils.log_error("ConfigManager: ERROR reloading config: %d" % err)
		return false

# =======================
#  ACCESO A CONFIGURACIÓN
# =======================
func is_ready() -> bool:
	return is_initialized

func is_new() -> bool:
	return is_new_player

func get_setting(section: String, key: String, default_value = null):
	if not is_initialized:
		print("ConfigManager: WARNING - Accessing settings before initialization")
		return default_value
	
	if settings.has(section) and settings[section].has(key):
		return settings[section][key]
	
	if default_value != null:
		print("ConfigManager: Setting not found - %s:%s, using default: %s" % [section, key, str(default_value)])
		return default_value
	
	print("ConfigManager: WARNING - Setting not found - %s:%s" % [section, key])
	return null

func set_setting(section: String, key: String, value, auto_save: bool = true) -> bool:
	if not is_initialized:
		print("ConfigManager: WARNING - Setting values before initialization")
		return false
	
	if not settings.has(section):
		print("ConfigManager: Creating new section - %s" % section)
		settings[section] = {}
	
	var old_value = settings[section].get(key, null)
	settings[section][key] = value
	
	var success = true
	if auto_save:
		success = save()
	
	if success:
		setting_changed.emit(section, key, value)
		print("ConfigManager: Setting updated - %s:%s = %s (was: %s)" % [section, key, str(value), str(old_value)])
		ManagerUtils.log_success("ConfigManager: %s:%s updated" % [section, key])
	
	return success

func has_setting(section: String, key: String) -> bool:
	return settings.has(section) and settings[section].has(key)

func get_section(section: String) -> Dictionary:
	"""Obtiene toda una sección de configuración"""
	if settings.has(section):
		return settings[section].duplicate()
	return {}

func set_section(section: String, section_data: Dictionary, auto_save: bool = true):
	"""Establece toda una sección de configuración"""
	settings[section] = section_data.duplicate()
	if auto_save:
		save()
	print("ConfigManager: Section '%s' updated with %d keys" % [section, section_data.size()])
	ManagerUtils.log_success("ConfigManager: Section '%s' updated" % section)

# =======================
#  CONFIGURACIÓN POR DEFECTO
# =======================
func reset_to_defaults(section: String = ""):
	"""Resetea configuración a valores por defecto"""
	if section == "":
		# Resetear todo (excepto meta)
		var temp_meta = settings.get("meta", {}).duplicate()
		settings = _get_default_settings().duplicate(true)
		settings["meta"] = temp_meta  # Preservar metadatos
		save()
		print("ConfigManager: All settings reset to defaults")
		ManagerUtils.log_warning("ConfigManager: All settings reset to defaults")
	else:
		# Resetear sección específica
		var default_settings = _get_default_settings()
		if default_settings.has(section):
			settings[section] = default_settings[section].duplicate()
			save()
			print("ConfigManager: Section '%s' reset to defaults" % section)
			ManagerUtils.log_warning("ConfigManager: Section '%s' reset to defaults" % section)

func _get_default_settings() -> Dictionary:
	"""Retorna la configuración por defecto"""
	return {
		"audio": {
			"master_volume": 100, 
			"music_volume": 100, 
			"sfx_volume": 100
		},
		"video": {
			"screen_mode": 0, 
			"resolution": 0, 
			"vsync": true
		},
		"controls": {
			"custom_inputs": {}
		},
		"game_progress": {
			"best_time": 0.0,
			"total_completed": 0,
			"total_failed": 0,
			"total_started": 0,
			"best_streak": 0,
			"total_time_played": 0.0,
			"fastest_completion": 0.0,
			"average_completion_time": 0.0
		},
		"gameplay": {
			"show_timer": true,
			"show_fps": false,
			"particles_enabled": true,
			"screen_shake": true,
			"damage_numbers": true
		},
		"meta": {
			"config_version": 2,
			"last_save_time": "",
			"total_launches": 0
		}
	}

# =======================
#  VALIDACIÓN
# =======================
func validate_config() -> bool:
	"""Valida que la configuración sea consistente"""
	var errors = []
	
	# Validar rangos de audio
	for audio_key in ["master_volume", "music_volume", "sfx_volume"]:
		var value = get_setting("audio", audio_key)
		if value != null and (value < 0 or value > 100):
			errors.append("Audio %s out of range: %s" % [audio_key, value])
	
	# Validar configuración de video
	var screen_mode = get_setting("video", "screen_mode")
	if screen_mode != null and (screen_mode < 0 or screen_mode > 2):
		errors.append("Invalid screen_mode: %s" % screen_mode)
	
	# Validar progreso del juego
	var best_time = get_setting("game_progress", "best_time")
	if best_time != null and best_time < 0:
		errors.append("Invalid best_time: %s" % best_time)
	
	# Validar versión de configuración
	var config_version = get_setting("meta", "config_version")
	if config_version != null and config_version < 1:
		errors.append("Invalid config_version: %s" % config_version)
	
	var is_valid = errors.size() == 0
	
	if not is_valid:
		print("ConfigManager: Validation errors found:")
		for error in errors:
			print("  - %s" % error)
			ManagerUtils.log_error("Config validation error: %s" % error)
	else:
		ManagerUtils.log_success("Config validation: PASSED")
	
	config_validated.emit(is_valid, errors)
	return is_valid

# =======================
#  MIGRACIÓN Y COMPATIBILIDAD
# =======================
func migrate_config_if_needed():
	"""Migra configuración de versiones anteriores si es necesario"""
	var config_version = get_setting("meta", "config_version", 1)
	var current_version = 2
	
	if config_version < current_version:
		print("ConfigManager: Migrating config from version %d to %d" % [config_version, current_version])
		ManagerUtils.log_info("ConfigManager: Migrating config v%d -> v%d" % [config_version, current_version])
		
		# Migración v1 -> v2: Agregar nuevas secciones para roguelike
		if config_version == 1:
			print("ConfigManager: Adding roguelike sections...")
			var defaults = _get_default_settings()
			
			# Agregar game_progress si no existe
			if not settings.has("game_progress"):
				settings["game_progress"] = defaults["game_progress"].duplicate()
			
			# Agregar gameplay si no existe
			if not settings.has("gameplay"):
				settings["gameplay"] = defaults["gameplay"].duplicate()
			
			# Agregar meta si no existe
			if not settings.has("meta"):
				settings["meta"] = defaults["meta"].duplicate()
		
		# Establecer nueva versión
		set_setting("meta", "config_version", current_version, false)
		save()
		print("ConfigManager: Migration completed")
		ManagerUtils.log_success("ConfigManager: Migration completed successfully")

# =======================
#  FUNCIONES DE DEBUG OPTIMIZADAS
# =======================
func debug_settings_info():
	"""Información de debug optimizada"""
	print("=== ROGUELIKE CONFIG DEBUG ===")
	print("Game Progress:")
	var progress = get_section("game_progress")
	for key in progress.keys():
		print("  %s: %s" % [key, str(progress[key])])
	print("")
	print("Gameplay Settings:")
	var gameplay = get_section("gameplay")
	for key in gameplay.keys():
		print("  %s: %s" % [key, str(gameplay[key])])
	print("")
	print("Meta Information:")
	var meta = get_section("meta")
	for key in meta.keys():
		print("  %s: %s" % [key, str(meta[key])])
	print("==============================")

func get_debug_summary() -> Dictionary:
	"""Retorna resumen para debug"""
	return {
		"initialized": is_initialized,
		"new_player": is_new_player,
		"config_version": get_setting("meta", "config_version", 1),
		"total_launches": get_setting("meta", "total_launches", 0),
		"last_save": get_setting("meta", "last_save_time", "Never"),
		"sections_count": settings.size(),
		"file_exists": FileAccess.file_exists(CONFIG_PATH),
		"backup_exists": FileAccess.file_exists(CONFIG_PATH.replace(".cfg", "_backup.cfg"))
	}

# =======================
#  CLEANUP
# =======================
func _exit_tree():
	"""Guardar configuración al salir"""
	if is_initialized:
		save()
	print("ConfigManager: Final save completed")
	ManagerUtils.log_success("ConfigManager: Final save completed")
