extends Resource
class_name GameSettingsData

@export_group("Audio")
@export_range(0.0, 1.0, 0.01) var audio_master_volume: float = 0.8
@export_range(0.0, 1.0, 0.01) var audio_music_volume: float = 0.8
@export_range(0.0, 1.0, 0.01) var audio_sfx_volume: float = 0.9
@export var audio_spatial_audio: bool = false

@export_group("Video")
@export var video_resolution_index: int = 2
@export var video_window_mode_index: int = 0
@export var video_fps_index: int = 1
@export var video_vsync: bool = true

@export_group("Controls")
@export_range(0.1, 10.0, 0.1, "or_greater") var controls_mouse_sensitivity: float = 1.0
@export var controls_mouse_invert_x: bool = false
@export var controls_mouse_invert_y: bool = false

func to_dictionary() -> Dictionary:
	return {
		"audio": {
			"master_volume": audio_master_volume,
			"music_volume": audio_music_volume,
			"sfx_volume": audio_sfx_volume,
			"spatial_audio": audio_spatial_audio,
		},
		"video": {
			"resolution_index": video_resolution_index,
			"window_mode_index": video_window_mode_index,
			"fps_index": video_fps_index,
			"vsync": video_vsync,
		},
		"controls": {
			"mouse_sensitivity": controls_mouse_sensitivity,
			"mouse_invert_x": controls_mouse_invert_x,
			"mouse_invert_y": controls_mouse_invert_y,
		}
	}

func duplicate_settings():
	var duplicate_resource := duplicate(true)
	if duplicate_resource is Resource:
		return duplicate_resource
	return self

func update_from_dictionary(data: Dictionary) -> void:
	if data.has("audio"):
		var audio_data: Dictionary = data.get("audio", {})
		audio_master_volume = audio_data.get("master_volume", audio_master_volume)
		audio_music_volume = audio_data.get("music_volume", audio_music_volume)
		audio_sfx_volume = audio_data.get("sfx_volume", audio_sfx_volume)
		audio_spatial_audio = audio_data.get("spatial_audio", audio_spatial_audio)
	if data.has("video"):
		var video_data: Dictionary = data.get("video", {})
		video_resolution_index = video_data.get("resolution_index", video_resolution_index)
		video_window_mode_index = video_data.get("window_mode_index", video_window_mode_index)
		video_fps_index = video_data.get("fps_index", video_fps_index)
		video_vsync = video_data.get("vsync", video_vsync)
	if data.has("controls"):
		var controls_data: Dictionary = data.get("controls", {})
		controls_mouse_sensitivity = controls_data.get("mouse_sensitivity", controls_mouse_sensitivity)
		controls_mouse_invert_x = controls_data.get("mouse_invert_x", controls_mouse_invert_x)
		controls_mouse_invert_y = controls_data.get("mouse_invert_y", controls_mouse_invert_y)
