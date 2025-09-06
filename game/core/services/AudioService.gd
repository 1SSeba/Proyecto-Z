extends Node

var service_name: String = "AudioService"
var is_service_ready: bool = false

@export_group("Audio Settings")
@export var master_volume: float = 1.0: set = set_master_volume
@export var music_volume: float = 0.8: set = set_music_volume
@export var sfx_volume: float = 1.0: set = set_sfx_volume

@export_group("Advanced Audio Settings")
@export var spatial_audio_enabled: bool = true
@export var audio_quality: int = 1
@export var current_audio_device: String = "Default"

@export_group("Audio Resources")
@export var audio_library: Dictionary = {}

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var current_music_track: String = ""

const MAX_SFX_PLAYERS = 8

func _start():
	service_name = "AudioService"
	_setup_audio_players()
	_connect_event_bus()
	is_service_ready = true
	print("AudioService: Initialized successfully")

func start_service():
	_start()

func _setup_audio_players():
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)

	# SFX players pool
	for i in MAX_SFX_PLAYERS:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer_%d" % i
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)

func _connect_event_bus():
	pass
	if EventBus:
		EventBus.audio_play_sfx.connect(_on_play_sfx)
		EventBus.audio_play_music.connect(_on_play_music)
		# EventBus.audio_stop_music.connect(_on_stop_music)  # Signal commented out

#  MUSIC MANAGEMENT

func play_music(track_name: String, fade_in: bool = true):
	pass
	if track_name == current_music_track and music_player.playing:
		return

	var audio_stream = _get_audio_resource(track_name)
	if not audio_stream:
		print("AudioService: Music track not found: ", track_name)
		return

	if fade_in and music_player.playing:
		await _fade_out_music()

	music_player.stream = audio_stream
	music_player.play()
	current_music_track = track_name

	if fade_in:
		_fade_in_music()

func stop_music(fade_out: bool = true):
	pass
	if fade_out:
		await _fade_out_music()
	else:
		music_player.stop()

	current_music_track = ""

func _fade_in_music():
	pass
	music_player.volume_db = -60.0
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, 1.0)

func _fade_out_music():
	pass
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -60.0, 1.0)
	await tween.finished

#  SFX MANAGEMENT

func play_sfx(sound_name: String, volume_db: float = 0.0):
	pass
	var audio_stream = _get_audio_resource(sound_name)
	if not audio_stream:
		print("AudioService: SFX not found: ", sound_name)
		return

	var available_player = _get_available_sfx_player()
	if available_player:
		available_player.stream = audio_stream
		available_player.volume_db = volume_db
		available_player.play()

func _get_available_sfx_player() -> AudioStreamPlayer:
	pass
	for player in sfx_players:
		if not player.playing:
			return player

	# If all players are busy, use the first one
	return sfx_players[0] if sfx_players.size() > 0 else null

#  RESOURCE MANAGEMENT

func register_audio(audio_name: String, resource_path: String):
	pass
	var audio_resource = load(resource_path)
	if audio_resource:
		audio_library[audio_name] = audio_resource
		print("AudioService: Registered audio: ", audio_name)
	else:
		print("AudioService: Failed to load audio: ", resource_path)

func _get_audio_resource(audio_name: String) -> AudioStream:
	pass
	return audio_library.get(audio_name, null)

#  VOLUME CONTROL

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	_update_audio_volumes()

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	_update_audio_volumes()

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	_update_audio_volumes()

func _update_audio_volumes():
	pass
	var master_db = linear_to_db(master_volume)
	var music_db = linear_to_db(music_volume * master_volume)
	var sfx_db = linear_to_db(sfx_volume * master_volume)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_db)

#  EVENT HANDLERS

func _on_play_sfx(sound_name: String):
	pass
	play_sfx(sound_name)

func _on_play_music(track_name: String):
	pass
	play_music(track_name)

func _on_stop_music():
	pass
	stop_music()

#  ADVANCED AUDIO SETTINGS

func set_spatial_audio(enabled: bool):
	pass
	spatial_audio_enabled = enabled
	# Apply spatial audio settings to existing players
	for player in sfx_players:
		# This would configure 3D audio if using AudioStreamPlayer3D
		pass
	print("AudioService: Spatial audio ", "enabled" if enabled else "disabled")

func set_audio_quality(quality_index: int):
	pass
	audio_quality = quality_index
	match quality_index:
		0:
			print("AudioService: Audio quality set to Low")
		1:
			print("AudioService: Audio quality set to Medium")
		2:
			print("AudioService: Audio quality set to High")

func set_audio_device(device_name: String):
	pass
	current_audio_device = device_name
	print("AudioService: Audio device set to: ", device_name)
	# Note: Godot doesn't have direct API for changing audio devices during runtime
	# This would typically require engine restart or platform-specific code

func get_available_audio_devices() -> Array[String]:
	pass
	# This is a simplified implementation
	# In a real scenario, you'd query the system for available devices
	return ["Default Device", "Speakers", "Headphones", "USB Audio"]

#  SERVICE INFO

func get_audio_status() -> Dictionary:
	pass
	return {
		"current_music": current_music_track,
		"music_playing": music_player.playing if music_player else false,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"spatial_audio": spatial_audio_enabled,
		"audio_quality": audio_quality,
		"audio_device": current_audio_device,
		"registered_sounds": audio_library.size(),
		"available_devices": get_available_audio_devices()
	}
