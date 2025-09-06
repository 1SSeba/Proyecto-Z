extends Node

# Audio Events
signal audio_play_sfx(sfx_name: String, volume: float)
signal audio_play_music(music_name: String, volume: float, fade_in: bool)
signal audio_stop_music()

# Scene Events
signal scene_changing(from_scene: String, to_scene: String)
signal scene_changed(scene_name: String)

# UI Events
signal ui_element_focused(element: Control)
signal ui_button_pressed(button_name: String)
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)

# Input Events
signal input_action_pressed(action: String)
signal input_action_released(action: String)

# Room Events (Roguelike specific)
signal room_entered(room_id: String)
signal room_cleared(room_id: String)
signal enemy_spawned(enemy: Node)
signal enemy_defeated(enemy: Node)

# Item/Inventory Events
signal item_collected(item_name: String, quantity: int)
signal item_used(item_name: String)
signal inventory_updated()

# System Events
signal system_pause_requested()
signal system_resume_requested()
signal config_changed(setting: String, value: Variant)

# Event management
var event_history: Array[Dictionary] = []
var max_history_size: int = 100

func emit_event(event_name: String, data: Dictionary = {}):
	var event_data = {
		"name": event_name,
		"data": data,
		"timestamp": Time.get_ticks_msec()
	}

	_add_to_history(event_data)

	if has_signal(event_name):
		emit_signal(event_name, data)

func _add_to_history(event_data: Dictionary):
	event_history.append(event_data)

	if event_history.size() > max_history_size:
		event_history.pop_front()

func get_recent_events(count: int = 10) -> Array[Dictionary]:
	var recent_count = min(count, event_history.size())
	return event_history.slice(-recent_count)

func clear_history():
	event_history.clear()

# Convenience methods
func request_scene_change(scene_path: String):
	emit_event("scene_change_requested", {"scene_path": scene_path})

func notify_player_action(action: String, data: Dictionary = {}):
	emit_event("player_action", {"action": action, "data": data})

func notify_ui_interaction(ui_element: String, interaction_type: String):
	emit_event("ui_interaction", {
		"element": ui_element,
		"type": interaction_type
	})

func request_audio(audio_type: String, audio_name: String, volume: float = 1.0):
	match audio_type:
		"sfx":
			audio_play_sfx.emit(audio_name, volume)
		"music":
			audio_play_music.emit(audio_name, volume, false)
		_:
			print("EventBus: Unknown audio type: ", audio_type)
