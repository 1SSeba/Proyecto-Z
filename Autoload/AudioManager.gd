# AudioManager.gd - Autoload para gestionar todo el audio del roguelike
extends Node

# =======================
#  SEÑALES
# =======================
signal audio_manager_ready
signal music_finished
signal music_changed(new_music: AudioStream)
signal volume_changed(bus_name: String, volume: float)

# =======================
#  CONSTANTES
# =======================
const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

# Sonidos específicos del roguelike (paths por defecto)
const DEFAULT_SOUNDS = {
	"ui_hover": "res://audio/ui/hover.ogg",
	"ui_click": "res://audio/ui/click.ogg",
	"ui_back": "res://audio/ui/back.ogg",
	"player_hurt": "res://audio/player/hurt.ogg",
	"player_death": "res://audio/player/death.ogg",
	"enemy_hit": "res://audio/enemies/hit.ogg",
	"enemy_death": "res://audio/enemies/death.ogg",
	"pickup": "res://audio/items/pickup.ogg",
	"room_clear": "res://audio/game/room_clear.ogg",
	"new_record": "res://audio/game/new_record.ogg",
	"pause": "res://audio/ui/pause.ogg",
	"unpause": "res://audio/ui/unpause.ogg"
}

# =======================
#  AUDIO PLAYERS
# =======================
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var ui_sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var ambient_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Players para múltiples SFX simultáneos
var sfx_players_pool: Array[AudioStreamPlayer] = []
var max_simultaneous_sfx: int = 8

# =======================
#  VARIABLES
# =======================
var current_music: AudioStream = null
var current_ambient: AudioStream = null
var music_fade_tween: Tween
var is_music_paused: bool = false
var is_initialized: bool = false

# Diccionario para cachear sonidos
var cached_sounds: Dictionary = {}

# Configuración de fade
var fade_duration: float = 1.0
var crossfade_duration: float = 2.0

# Variables de volumen
var current_volumes = {
	"master": 100.0,
	"music": 100.0,
	"sfx": 100.0
}

# Control de audio específico para roguelike
var mute_during_pause: bool = false
var enable_spatial_audio: bool = true

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("AudioManager: Starting initialization...")
	_setup_audio_players()
	_create_sfx_player_pool()
	
	# Verificar si ConfigManager está disponible
	if _is_config_manager_available():
		if ConfigManager.is_ready():
			_load_audio_settings()
			_finalize_initialization()
		else:
			print("AudioManager: Waiting for ConfigManager...")
			ConfigManager.config_loaded.connect(_on_config_manager_ready, CONNECT_ONE_SHOT)
	else:
		print("AudioManager: ConfigManager not found, using default volumes")
		_apply_default_volumes()
		_finalize_initialization()

func _on_config_manager_ready():
	print("AudioManager: ConfigManager ready, loading settings...")
	_load_audio_settings()
	_finalize_initialization()

func _finalize_initialization():
	# Precargar sonidos por defecto del roguelike
	_preload_default_sounds()
	
	# Conectar con GameStateManager si está disponible
	_connect_game_state_manager()
	
	is_initialized = true
	audio_manager_ready.emit()
	print("AudioManager: Initialization complete")

func _setup_audio_players():
	# Configurar reproductor de música
	music_player.bus = MUSIC_BUS
	music_player.autoplay = false
	music_player.finished.connect(_on_music_finished)
	add_child(music_player)
	
	# Configurar reproductores de efectos
	sfx_player.bus = SFX_BUS
	sfx_player.autoplay = false
	add_child(sfx_player)
	
	ui_sfx_player.bus = SFX_BUS
	ui_sfx_player.autoplay = false
	add_child(ui_sfx_player)
	
	# Configurar reproductor de ambiente
	ambient_player.bus = MUSIC_BUS  # Usar mismo bus que música
	ambient_player.autoplay = false
	add_child(ambient_player)
	
	print("AudioManager: Audio players setup complete")

func _create_sfx_player_pool():
	"""Crea pool de reproductores de SFX para sonidos simultáneos"""
	for i in range(max_simultaneous_sfx):
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		player.autoplay = false
		add_child(player)
		sfx_players_pool.append(player)
	
	print("AudioManager: Created SFX player pool with %d players" % max_simultaneous_sfx)

func _preload_default_sounds():
	"""Precarga sonidos por defecto del roguelike"""
	var loaded_count = 0
	for sound_name in DEFAULT_SOUNDS.keys():
		var path = DEFAULT_SOUNDS[sound_name]
		if FileAccess.file_exists(path):
			var sound = load(path)
			if sound:
				cached_sounds[sound_name] = sound
				loaded_count += 1
	
	print("AudioManager: Preloaded %d/%d default sounds" % [loaded_count, DEFAULT_SOUNDS.size()])

func _connect_game_state_manager():
	"""Conecta con GameStateManager para audio automático"""
	if not _is_game_state_manager_available():
		return
	
	GameStateManager.state_changed.connect(_on_game_state_changed)
	GameStateManager.new_best_time.connect(_on_new_best_time)
	print("AudioManager: Connected to GameStateManager")

func _apply_default_volumes():
	"""Aplica volúmenes por defecto"""
	set_master_volume(100)
	set_music_volume(100)
	set_sfx_volume(100)

func _load_audio_settings():
	if not _is_config_manager_available():
		_apply_default_volumes()
		return
	
	var master_vol = ConfigManager.get_setting("audio", "master_volume", 100)
	var music_vol = ConfigManager.get_setting("audio", "music_volume", 100)
	var sfx_vol = ConfigManager.get_setting("audio", "sfx_volume", 100)
	
	print("AudioManager: Loading volumes - Master: %d, Music: %d, SFX: %d" % [master_vol, music_vol, sfx_vol])
	
	set_master_volume(master_vol)
	set_music_volume(music_vol)
	set_sfx_volume(sfx_vol)

# =======================
#  VERIFICACIONES
# =======================
func _is_config_manager_available() -> bool:
	return get_node_or_null("/root/ConfigManager") != null

func _is_game_state_manager_available() -> bool:
	return get_node_or_null("/root/GameStateManager") != null

func is_ready() -> bool:
	return is_initialized

func wait_for_ready() -> void:
	if is_initialized:
		return
	await audio_manager_ready

# =======================
#  CONTROL DE VOLUMEN
# =======================
func set_master_volume(volume: float):
	volume = clamp(volume, 0, 100)
	current_volumes.master = volume
	_set_bus_volume(MASTER_BUS, volume)
	volume_changed.emit(MASTER_BUS, volume)
	
	if _is_config_manager_available():
		ConfigManager.set_setting("audio", "master_volume", volume, false)

func set_music_volume(volume: float):
	volume = clamp(volume, 0, 100)
	current_volumes.music = volume
	_set_bus_volume(MUSIC_BUS, volume)
	volume_changed.emit(MUSIC_BUS, volume)
	
	if _is_config_manager_available():
		ConfigManager.set_setting("audio", "music_volume", volume, false)

func set_sfx_volume(volume: float):
	volume = clamp(volume, 0, 100)
	current_volumes.sfx = volume
	_set_bus_volume(SFX_BUS, volume)
	volume_changed.emit(SFX_BUS, volume)
	
	if _is_config_manager_available():
		ConfigManager.set_setting("audio", "sfx_volume", volume, false)

func _set_bus_volume(bus_name: String, volume: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		var db_value = linear_to_db(volume / 100.0) if volume > 0 else -80
		AudioServer.set_bus_volume_db(bus_index, db_value)
	else:
		print("AudioManager: ERROR - Bus '%s' not found" % bus_name)

func get_master_volume() -> float:
	return current_volumes.master

func get_music_volume() -> float:
	return current_volumes.music

func get_sfx_volume() -> float:
	return current_volumes.sfx

# =======================
#  MÚSICA Y AMBIENTE
# =======================
func play_music(music: AudioStream, fade_in: bool = true, loop: bool = true):
	if not music:
		print("AudioManager: ERROR - Cannot play null music")
		return false
		
	if current_music == music and music_player.playing:
		return true
		
	if fade_in and music_player.playing:
		_crossfade_music(music, loop)
	else:
		_play_music_direct(music, fade_in, loop)
	
	return true

func _play_music_direct(music: AudioStream, fade_in: bool = true, loop: bool = true):
	current_music = music
	music_player.stream = music
	
	# Configurar loop si el stream lo soporta
	if music_player.stream and music_player.stream.has_method("set_loop"):
		music_player.stream.set_loop(loop)
	
	if fade_in:
		music_player.volume_db = -80
		music_player.play()
		_fade_music_in()
	else:
		music_player.volume_db = 0
		music_player.play()
	
	music_changed.emit(music)

func _crossfade_music(new_music: AudioStream, loop: bool = true):
	var old_player = music_player
	current_music = new_music
	
	# Crear nuevo reproductor para crossfade
	var new_player = AudioStreamPlayer.new()
	new_player.bus = MUSIC_BUS
	new_player.stream = new_music
	new_player.volume_db = -80
	new_player.finished.connect(_on_music_finished)
	
	# Configurar loop
	if new_player.stream and new_player.stream.has_method("set_loop"):
		new_player.stream.set_loop(loop)
	
	add_child(new_player)
	new_player.play()
	
	# Fade out música actual y fade in nueva música
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.set_parallel(true)
	music_fade_tween.tween_property(old_player, "volume_db", -80, crossfade_duration)
	music_fade_tween.tween_property(new_player, "volume_db", 0, crossfade_duration)
	
	await music_fade_tween.finished
	
	# Limpiar reproductor anterior
	old_player.stop()
	old_player.finished.disconnect(_on_music_finished)
	remove_child(old_player)
	old_player.queue_free()
	
	# Actualizar referencia
	music_player = new_player
	music_changed.emit(new_music)

func stop_music(fade_out: bool = true):
	if not music_player.playing:
		return
		
	if fade_out:
		_fade_music_out()
	else:
		music_player.stop()
		current_music = null

func pause_music():
	if music_player.playing and not is_music_paused:
		music_player.stream_paused = true
		is_music_paused = true

func resume_music():
	if is_music_paused:
		music_player.stream_paused = false
		is_music_paused = false

func _fade_music_in():
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(music_player, "volume_db", 0, fade_duration)

func _fade_music_out():
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(music_player, "volume_db", -80, fade_duration)
	
	await music_fade_tween.finished
	music_player.stop()
	current_music = null

# =======================
#  EFECTOS DE SONIDO MEJORADOS
# =======================
func play_sfx(sound: AudioStream, volume: float = 0.0, pitch_scale: float = 1.0) -> bool:
	if not sound:
		return false
	
	# Usar un reproductor del pool que esté libre
	var player = _get_free_sfx_player()
	if not player:
		return false
	
	player.stream = sound
	player.volume_db = volume
	player.pitch_scale = pitch_scale
	player.play()
	
	return true

func play_sfx_by_name(sound_name: String, volume: float = 0.0, pitch_scale: float = 1.0) -> bool:
	"""Reproduce un SFX por nombre desde cache"""
	var sound = get_cached_sound(sound_name)
	if sound:
		return play_sfx(sound, volume, pitch_scale)
	return false

func play_ui_sfx(sound: AudioStream, volume: float = 0.0) -> bool:
	if not sound:
		return false
		
	ui_sfx_player.stream = sound
	ui_sfx_player.volume_db = volume
	ui_sfx_player.play()
	
	return true

func play_ui_sfx_by_name(sound_name: String, volume: float = 0.0) -> bool:
	"""Reproduce un SFX de UI por nombre"""
	var sound = get_cached_sound(sound_name)
	if sound:
		return play_ui_sfx(sound, volume)
	return false

func _get_free_sfx_player() -> AudioStreamPlayer:
	"""Obtiene un reproductor de SFX libre del pool"""
	for player in sfx_players_pool:
		if not player.playing:
			return player
	
	# Si todos están ocupados, usar el primero (interrumpir)
	return sfx_players_pool[0]

func play_sfx_at_position(sound: AudioStream, position: Vector2, volume: float = 0.0, max_distance: float = 2000.0) -> AudioStreamPlayer2D:
	if not sound or not enable_spatial_audio:
		# Fallback a sonido normal si el audio espacial está deshabilitado
		play_sfx(sound, volume)
		return null
		
	# Para sonidos 2D posicionales
	var positional_player = AudioStreamPlayer2D.new()
	positional_player.bus = SFX_BUS
	positional_player.stream = sound
	positional_player.volume_db = volume
	positional_player.global_position = position
	positional_player.max_distance = max_distance
	positional_player.attenuation = 1.0
	
	get_tree().current_scene.add_child(positional_player)
	positional_player.play()
	
	# Eliminar el reproductor cuando termine
	positional_player.finished.connect(func(): positional_player.queue_free())
	
	return positional_player

# =======================
#  SONIDOS ESPECÍFICOS DEL ROGUELIKE
# =======================
func play_player_hurt():
	"""Reproduce sonido de jugador herido"""
	play_sfx_by_name("player_hurt", -5.0)

func play_player_death():
	"""Reproduce sonido de muerte del jugador"""
	play_sfx_by_name("player_death", 0.0)

func play_enemy_hit():
	"""Reproduce sonido de enemigo golpeado"""
	play_sfx_by_name("enemy_hit", -8.0)

func play_enemy_death():
	"""Reproduce sonido de muerte de enemigo"""
	play_sfx_by_name("enemy_death", -5.0)

func play_pickup():
	"""Reproduce sonido de recoger item"""
	play_sfx_by_name("pickup", -3.0)

func play_room_clear():
	"""Reproduce sonido de habitación completada"""
	play_sfx_by_name("room_clear", 2.0)

func play_new_record():
	"""Reproduce sonido de nuevo record"""
	play_sfx_by_name("new_record", 5.0)

func play_pause_sound():
	"""Reproduce sonido de pausa"""
	play_ui_sfx_by_name("pause", -10.0)

func play_unpause_sound():
	"""Reproduce sonido de reanudar"""
	play_ui_sfx_by_name("unpause", -10.0)

func play_ui_hover():
	"""Reproduce sonido de hover en UI"""
	play_ui_sfx_by_name("ui_hover", -15.0)

func play_ui_click():
	"""Reproduce sonido de click en UI"""
	play_ui_sfx_by_name("ui_click", -10.0)

func play_ui_back():
	"""Reproduce sonido de volver en UI"""
	play_ui_sfx_by_name("ui_back", -8.0)

# =======================
#  GESTIÓN DE CACHE
# =======================
func preload_sound(path: String, key: String = "") -> AudioStream:
	if not FileAccess.file_exists(path):
		print("AudioManager: Sound file not found: %s" % path)
		return null
		
	var sound = load(path)
	if not sound:
		print("AudioManager: Failed to load sound: %s" % path)
		return null
		
	var cache_key = key if key != "" else path
	cached_sounds[cache_key] = sound
	return sound

func get_cached_sound(key: String) -> AudioStream:
	return cached_sounds.get(key, null)

func has_cached_sound(key: String) -> bool:
	return cached_sounds.has(key)

func clear_sound_cache():
	var count = cached_sounds.size()
	cached_sounds.clear()
	print("AudioManager: Cleared %d cached sounds" % count)

# =======================
#  EVENTOS DE GAMESTATEMANAGER
# =======================
func _on_game_state_changed(old_state, new_state):
	"""Maneja cambios de estado del juego para audio"""
	match new_state:
		GameStateManager.GameState.MAIN_MENU:
			# Música de menú
			pass
		
		GameStateManager.GameState.PLAYING:
			# Música de gameplay
			if old_state == GameStateManager.GameState.PAUSED:
				resume_music()
		
		GameStateManager.GameState.PAUSED:
			# Pausar música si está configurado
			if mute_during_pause:
				pause_music()
			play_pause_sound()
		
		GameStateManager.GameState.RUN_COMPLETE:
			# Sonido de victoria
			play_room_clear()
		
		GameStateManager.GameState.RUN_FAILED:
			# Sonido de game over
			play_player_death()

func _on_new_best_time(time: float):
	"""Reproduce sonido de nuevo record"""
	play_new_record()

# =======================
#  CONFIGURACIÓN AVANZADA
# =======================
func set_fade_duration(duration: float):
	fade_duration = max(0.1, duration)

func set_crossfade_duration(duration: float):
	crossfade_duration = max(0.1, duration)

func mute_all():
	"""Silencia todo el audio"""
	_set_bus_volume(MASTER_BUS, 0)

func unmute_all():
	"""Restaura el volumen principal"""
	_set_bus_volume(MASTER_BUS, current_volumes.master)

func set_mute_during_pause(enabled: bool):
	"""Configura si mutear durante pausa"""
	mute_during_pause = enabled

func set_spatial_audio(enabled: bool):
	"""Configura audio espacial"""
	enable_spatial_audio = enabled

# =======================
#  UTILIDADES
# =======================
func is_music_playing() -> bool:
	return music_player.playing and not is_music_paused

func get_music_position() -> float:
	if music_player.playing:
		return music_player.get_playback_position()
	return 0.0

func get_current_music() -> AudioStream:
	return current_music

func _on_music_finished():
	music_finished.emit()
	current_music = null

# =======================
#  FUNCIONES DE DEBUG
# =======================
func debug_audio_status():
	print("=== AUDIO MANAGER DEBUG (ROGUELIKE) ===")
	print("Initialized: %s" % is_initialized)
	print("Music playing: %s" % is_music_playing())
	print("Current music: %s" % (current_music.resource_path if current_music else "None"))
	print("Music paused: %s" % is_music_paused)
	print("Cached sounds: %d" % cached_sounds.size())
	print("SFX Players pool: %d" % sfx_players_pool.size())
	print("Volumes - Master: %.1f, Music: %.1f, SFX: %.1f" % [current_volumes.master, current_volumes.music, current_volumes.sfx])
	print("Spatial Audio: %s" % enable_spatial_audio)
	print("Mute during pause: %s" % mute_during_pause)
	print("ConfigManager available: %s" % _is_config_manager_available())
	print("GameStateManager available: %s" % _is_game_state_manager_available())
	print("=======================================")

func debug_test_roguelike_sounds():
	"""Prueba todos los sonidos del roguelike"""
	print("AudioManager: Testing roguelike sounds...")
	
	await get_tree().create_timer(0.5).timeout
	play_ui_click()
	await get_tree().create_timer(0.5).timeout
	play_player_hurt()
	await get_tree().create_timer(0.5).timeout
	play_enemy_hit()
	await get_tree().create_timer(0.5).timeout
	play_pickup()
	await get_tree().create_timer(0.5).timeout
	play_room_clear()
	
	print("AudioManager: Roguelike sound test complete")

# =======================
#  CLEANUP
# =======================
func _exit_tree():
	if music_fade_tween:
		music_fade_tween.kill()
	
	# Guardar configuración final
	if _is_config_manager_available() and is_initialized:
		ConfigManager.save()
	
	print("AudioManager: Cleanup complete")
