extends "res://game/core/services/BaseService.gd"

const AudioUtils := preload("res://game/core/utils/AudioUtils.gd")
const ValueRamper := preload("res://game/core/utils/ValueRamper.gd")

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

var master_volume: float = 1.0 # 0..1
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var spatial_audio_enabled: bool = false
var config_service: Node = null

# Editable bus names (can be changed at runtime or in editor)
@export var bus_master_name: String = BUS_MASTER_NAME
@export var bus_music_name: String = BUS_MUSIC_NAME
@export var bus_sfx_name: String = BUS_SFX_NAME

# For smooth transitions
var _volume_ramper: ValueRamper = null

func _ready() -> void:
	super._ready()
	service_name = "AudioService"
	_volume_ramper = ValueRamper.new()

func start_service() -> void:
	super.start_service()
	_initialize_service()
	_logger.log_info("Audio service started with %d buses detected" % AudioServer.get_bus_count())

func _initialize_service() -> void:
	if AudioServer.get_bus_count() == 0:
		_logger.log_warn("No audio buses detected in project. Buses will be refreshed later.")

	var loaded_from_config := _load_from_config()
	if not loaded_from_config:
		_sync_from_server()

	apply_all_settings(0.0)
	set_process(true)
	_logger.log_info("Ready: master=%.2f music=%.2f sfx=%.2f" % [master_volume, music_volume, sfx_volume])

func _sync_from_server() -> void:
	var vol := AudioUtils.get_bus_volume(bus_master_name)
	if vol >= 0.0:
		master_volume = vol

	vol = AudioUtils.get_bus_volume(bus_music_name)
	if vol >= 0.0:
		music_volume = vol

	vol = AudioUtils.get_bus_volume(bus_sfx_name)
	if vol >= 0.0:
		sfx_volume = vol

	_logger.log_info("Synced volumes from AudioServer: master=%.2f music=%.2f sfx=%.2f" % [master_volume, music_volume, sfx_volume])

func _load_from_config() -> bool:
	# Attempts to read audio settings from ConfigService (volumes stored as 0..100 in config)
	if ServiceManager:
		config_service = ServiceManager.get_config_service()
	if not config_service:
		return false

	var any_loaded = false

	var master = config_service.get_audio_setting("master_volume", null)
	if master != null:
		master_volume = AudioUtils.normalize_volume(master )
		any_loaded = true

	var music = config_service.get_audio_setting("music_volume", null)
	if music != null:
		music_volume = AudioUtils.normalize_volume(music)
		any_loaded = true

	var sfx = config_service.get_audio_setting("sfx_volume", null)
	if sfx != null:
		sfx_volume = AudioUtils.normalize_volume(sfx)
		any_loaded = true

	var spa = config_service.get_audio_setting("spatial_audio", null)
	if spa != null:
		spatial_audio_enabled = bool(spa)
		any_loaded = true

	return any_loaded

# Ramping helper: call every frame to approach targets smoothly
func _process(delta: float) -> void:
	if not _volume_ramper or not _volume_ramper.is_active():
		return

	var changes := _volume_ramper.process(delta)
	for key in changes:
		_set_volume_by_key_immediate(key, changes[key])

func _set_volume_by_key_immediate(key: String, value: float) -> void:
	var v = clampf(value, 0.0, 1.0)
	if key == "master_volume":
		master_volume = v
		AudioUtils.set_bus_volume(bus_master_name, v)
	elif key == "music_volume":
		music_volume = v
		AudioUtils.set_bus_volume(bus_music_name, v)
	elif key == "sfx_volume":
		sfx_volume = v
		AudioUtils.set_bus_volume(bus_sfx_name, v)
	else:
		_logger.log_warn("Unknown volume key: %s" % key)
		return

	emit_signal("volume_changed", "audio", key, v)

# Public API with optional transition (seconds)
func set_master_volume(value: float, transition_seconds: float = 0.0) -> void:
	if transition_seconds > 0.0:
		_volume_ramper.set_current("master_volume", master_volume)
		_volume_ramper.set_target("master_volume", clampf(value, 0.0, 1.0), transition_seconds)
	else:
		_set_volume_by_key_immediate("master_volume", value)

func set_music_volume(value: float, transition_seconds: float = 0.0) -> void:
	if transition_seconds > 0.0:
		_volume_ramper.set_current("music_volume", music_volume)
		_volume_ramper.set_target("music_volume", clampf(value, 0.0, 1.0), transition_seconds)
	else:
		_set_volume_by_key_immediate("music_volume", value)

func set_sfx_volume(value: float, transition_seconds: float = 0.0) -> void:
	if transition_seconds > 0.0:
		_volume_ramper.set_current("sfx_volume", sfx_volume)
		_volume_ramper.set_target("sfx_volume", clampf(value, 0.0, 1.0), transition_seconds)
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
		_logger.log_warn("No ConfigService available to save settings")
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
	_logger.log_info("Saved audio settings to ConfigService")

func apply_volume_now(key: String, value) -> void:
	# Called by SettingsMenu._apply_audio_volume_now(key, value)
	var float_val := float(value)

	if key == "master_volume":
		set_master_volume(float_val)
		return
	if key == "music_volume":
		set_music_volume(float_val)
		return
	if key == "sfx_volume":
		set_sfx_volume(float_val)
		return

	_logger.log_warn("Unknown volume key: %s" % str(key))

func to_dict() -> Dictionary:
	return {
		"audio": {
			"master_volume": master_volume,
			"music_volume": music_volume,
			"sfx_volume": sfx_volume,
			"spatial_audio": spatial_audio_enabled
		}
	}
