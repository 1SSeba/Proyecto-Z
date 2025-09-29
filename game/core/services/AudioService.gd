extends Node

const Log := preload("res://game/core/utils/Logger.gd")

# AudioService: centraliza control de volúmenes y opciones de audio para el juego.
# API esperada por SettingsMenu.gd:
# - set_master_volume(value: float)
# - set_music_volume(value: float)
# - set_sfx_volume(value: float)
# - get_master_volume() -> float, etc.
# - apply_volume_now(key, value)
# - apply_all_settings()
const BUS_MASTER_NAME := "Master"
const BUS_MUSIC_NAME := "Music"
const BUS_SFX_NAME := "SFX"

signal volume_changed(section: String, key: String, value)
signal settings_applied()

var service_name: String = "AudioService"
var master_volume: float = 1.0 # 0..1
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var spatial_audio_enabled: bool = false
var config_service: Node = null
var is_service_ready: bool = false

# Editable bus names (can be changed at runtime or in editor)
@export var bus_master_name: String = BUS_MASTER_NAME
@export var bus_music_name: String = BUS_MUSIC_NAME
@export var bus_sfx_name: String = BUS_SFX_NAME

# Internal: cached bus indices for faster access
var _bus_index_cache: Dictionary = {}

# For smooth transitions (optional)
var _ramp_targets: Dictionary = {}
var _ramp_speeds: Dictionary = {}

# Debug helper: centraliza logs a través del DebugService
func _dbg(level: String, message: String) -> void:
	var formatted := "AudioService: %s" % message
	match level.to_lower():
		"error":
			Log.error(formatted)
		"warn":
			Log.warn(formatted)
		"info":
			Log.info(formatted)
		_:
			Log.log(formatted)

func start_service() -> void:
	if is_service_ready:
		return
	_initialize_service()
	is_service_ready = true
	_dbg("info", "AudioService started")

func _ready():
	# Si el servicio no es gestionado por ServiceManager (por ejemplo, en escena suelta), inicializar manualmente.
	if Engine.is_editor_hint():
		return
	if not is_service_ready:
		start_service()

func _initialize_service() -> void:
	if AudioServer.get_bus_count() == 0:
		push_warning("AudioService: No audio buses detected in project. Buses will be refreshed later.")
	else:
		_dbg("info", "Detected %d audio buses" % AudioServer.get_bus_count())

	_refresh_bus_cache()

	var loaded_from_config := _load_from_config()
	if not loaded_from_config:
		_sync_from_server()

	apply_all_settings(0.0)
	set_process(true)
	_dbg("info", "AudioService ready: master=%.2f music=%.2f sfx=%.2f" % [master_volume, music_volume, sfx_volume])

func _refresh_bus_cache() -> void:
	_bus_index_cache.clear()
	for i in range(AudioServer.get_bus_count()):
		var busname = AudioServer.get_bus_name(i)
		_bus_index_cache[busname] = i
	_dbg("info", "Refreshed audio bus cache: %d entries" % _bus_index_cache.size())

func _sync_from_server() -> void:
	var idx = _find_bus_index(bus_master_name)
	if idx >= 0:
		master_volume = _db_to_linear(AudioServer.get_bus_volume_db(idx))
	idx = _find_bus_index(bus_music_name)
	if idx >= 0:
		music_volume = _db_to_linear(AudioServer.get_bus_volume_db(idx))

	idx = _find_bus_index(bus_sfx_name)
	if idx >= 0:
		sfx_volume = _db_to_linear(AudioServer.get_bus_volume_db(idx))
	_dbg("info", "Synced volumes from AudioServer: master=%.2f music=%.2f sfx=%.2f" % [master_volume, music_volume, sfx_volume])

func _load_from_config() -> bool:
	# Attempts to read audio settings from ConfigService (volumes stored as 0..100 in config)
	if ServiceManager:
		config_service = ServiceManager.get_config_service()
	if not config_service:
		return false

	var any_loaded = false

	var master = config_service.get_audio_setting("master_volume", null)
	if master != null:
		master_volume = _normalize_loaded_volume(master )
		any_loaded = true

	var music = config_service.get_audio_setting("music_volume", null)
	if music != null:
		music_volume = _normalize_loaded_volume(music)
		any_loaded = true

	var sfx = config_service.get_audio_setting("sfx_volume", null)
	if sfx != null:
		sfx_volume = _normalize_loaded_volume(sfx)
		any_loaded = true

	var spa = config_service.get_audio_setting("spatial_audio", null)
	if spa != null:
		spatial_audio_enabled = bool(spa)
		any_loaded = true

	return any_loaded

func _find_bus_index(bus_name: String) -> int:
	if _bus_index_cache.has(bus_name):
		return int(_bus_index_cache[bus_name])
	# attempt exact match
	for i in range(AudioServer.get_bus_count()):
		if AudioServer.get_bus_name(i) == bus_name:
			_bus_index_cache[bus_name] = i
			return i
	# fallback: case-insensitive
	var lower = bus_name.to_lower()
	for i in range(AudioServer.get_bus_count()):
		if AudioServer.get_bus_name(i).to_lower() == lower:
			_bus_index_cache[bus_name] = i
			return i
	return -1

func _linear_to_db(linear: float) -> float:
	# Convert 0..1 linear volume to decibels for AudioServer.
	linear = clamp(float(linear), 0.0, 1.0)
	if linear <= 0.0:
		return -80.0 # treat as muted (safe finite dB)
	# log10 not available; use natural log / ln(10)
	return 20.0 * (log(linear) / log(10.0))

func _db_to_linear(db: float) -> float:
	var linear = pow(10.0, float(db) / 20.0)
	return clamp(linear, 0.0, 1.0)

# Ramping helper: call every frame to approach targets smoothly
func _process(delta: float) -> void:
	if _ramp_targets.size() == 0:
		return
	var to_remove := []
	for key in _ramp_targets.keys():
		var target = float(_ramp_targets[key])
		var speed = float(_ramp_speeds.get(key, 1.0))
		var current = _get_volume_by_key(key)
		if current == null:
			to_remove.append(key)
			continue
		# compute lerp factor based on speed and delta (speed indicates seconds to reach)
		var t = 0.0
		if speed > 0.0:
			t = min(1.0, delta / speed)
		var next_val = lerp(current, target, t)
		_set_volume_by_key_immediate(key, next_val)
		if abs(next_val - target) < 0.001:
			_set_volume_by_key_immediate(key, target)
			to_remove.append(key)
	for k in to_remove:
		_ramp_targets.erase(k)
		_ramp_speeds.erase(k)

func _get_volume_by_key(key: String):
	if key == "master_volume":
		return master_volume
	elif key == "music_volume":
		return music_volume
	elif key == "sfx_volume":
		return sfx_volume
	else:
		return null

func _set_volume_by_key_immediate(key: String, value: float) -> void:
	var v = clamp(float(value), 0.0, 1.0)
	if key == "master_volume":
		master_volume = v
		_apply_bus_volume(bus_master_name, v)
	elif key == "music_volume":
		music_volume = v
		_apply_bus_volume(bus_music_name, v)
	elif key == "sfx_volume":
		sfx_volume = v
		_apply_bus_volume(bus_sfx_name, v)
	else:
		push_warning("AudioService: Unknown volume key in _set_volume_by_key_immediate: %s" % key)
		_dbg("warn", "Unknown volume key in _set_volume_by_key_immediate: %s" % key)
	emit_signal("volume_changed", "audio", key, v)
	_dbg("info", "Volume changed: %s -> %.2f" % [key, v])

# Public API with optional transition (seconds)
func set_master_volume(value: float, transition_seconds: float = 0.0) -> void:
	if transition_seconds > 0.0:
		_ramp_targets["master_volume"] = clamp(value, 0.0, 1.0)
		_ramp_speeds["master_volume"] = transition_seconds
	else:
		_set_volume_by_key_immediate("master_volume", value)

func set_music_volume(value: float, transition_seconds: float = 0.0) -> void:
	if transition_seconds > 0.0:
		_ramp_targets["music_volume"] = clamp(value, 0.0, 1.0)
		_ramp_speeds["music_volume"] = transition_seconds
	else:
		_set_volume_by_key_immediate("music_volume", value)

func set_sfx_volume(value: float, transition_seconds: float = 0.0) -> void:
	if transition_seconds > 0.0:
		_ramp_targets["sfx_volume"] = clamp(value, 0.0, 1.0)
		_ramp_speeds["sfx_volume"] = transition_seconds
	else:
		_set_volume_by_key_immediate("sfx_volume", value)

func get_master_volume() -> float:
	return master_volume

func get_music_volume() -> float:
	return music_volume

func get_sfx_volume() -> float:
	return sfx_volume

func set_spatial_audio_enabled(enabled: bool) -> void:
	spatial_audio_enabled = bool(enabled)
	# Hook for future implementation: could toggle audio effects or bus routing

func apply_all_settings(transition_seconds: float = 0.0) -> void:
	set_master_volume(master_volume, transition_seconds)
	set_music_volume(music_volume, transition_seconds)
	set_sfx_volume(sfx_volume, transition_seconds)
	emit_signal("settings_applied")

func save_to_config() -> void:
	if not config_service and ServiceManager:
		config_service = ServiceManager.get_config_service()
	if not config_service:
		push_warning("AudioService: No ConfigService available to save settings")
		return

	# ConfigService expects volumes in 0..100
	config_service.set_audio_setting("master_volume", master_volume * 100.0)
	config_service.set_audio_setting("music_volume", music_volume * 100.0)
	config_service.set_audio_setting("sfx_volume", sfx_volume * 100.0)
	config_service.set_audio_setting("spatial_audio", spatial_audio_enabled)
	# Persist
	if config_service.has_method("save_settings"):
		config_service.save_settings()
	elif config_service.has_method("save_config"):
		config_service.save_config()
	_dbg("info", "Saved audio settings to ConfigService")

func _apply_bus_volume(bus_name: String, linear_value: float) -> void:
	var idx = _find_bus_index(bus_name)
	if idx < 0:
		# If bus not found, fallback to master or print info
		if bus_name != BUS_MASTER_NAME:
			var master_idx = _find_bus_index(BUS_MASTER_NAME)
			if master_idx >= 0:
				AudioServer.set_bus_volume_db(master_idx, _linear_to_db(master_volume))
			else:
				push_warning("AudioService: No suitable bus found to apply volume for '%s'" % bus_name)
				_dbg("warn", "No suitable bus found to apply volume for '%s'" % bus_name)
		else:
			push_warning("AudioService: Master bus not found; cannot apply volume")
			_dbg("warn", "Master bus not found; cannot apply volume")

		return

	var db = _linear_to_db(linear_value)
	AudioServer.set_bus_volume_db(idx, db)
	_dbg("info", "Applied volume to bus '%s' (idx %d): linear=%.2f db=%.2f" % [bus_name, idx, linear_value, db])

func apply_volume_now(key: String, value) -> void:
	# Called by SettingsMenu._apply_audio_volume_now(key, value)
	if key == "master_volume":
		set_master_volume(float(value))
		_dbg("info", "apply_volume_now master_volume = %.2f" % float(value))

		return
	if key == "music_volume":
		set_music_volume(float(value))
		_dbg("info", "apply_volume_now music_volume = %.2f" % float(value))

		return
	if key == "sfx_volume":
		set_sfx_volume(float(value))
		_dbg("info", "apply_volume_now sfx_volume = %.2f" % float(value))

		return
	push_warning("AudioService: Unknown volume key: %s" % str(key))
	_dbg("warn", "apply_volume_now received unknown key: %s" % str(key))

func to_dict() -> Dictionary:
	return {
		"audio": {
			"master_volume": master_volume,
			"music_volume": music_volume,
			"sfx_volume": sfx_volume,
			"spatial_audio": spatial_audio_enabled
		}
	}

func _normalize_loaded_volume(value) -> float:
	# Accept either 0..1 or 0..100; return 0..1
	if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
		var v = float(value)
		if v > 1.0:
			v = clamp(v / 100.0, 0.0, 1.0)
		return clamp(v, 0.0, 1.0)
	return 1.0
