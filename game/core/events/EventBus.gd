extends Node

## Central Event Bus
## Professional event system for component communication
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  EVENT DEFINITIONS
# ============================================================================

# Audio Events (actively used by UI)
# Audio signals - Active
signal audio_play_sfx(sfx_name: String, volume: float)
signal audio_play_music(music_name: String, volume: float, fade_in: bool)
# signal audio_stop_music(fade_out: bool)  # TODO: Implement if needed

# Audio signals - Placeholder (ready for future implementation)
# signal audio_stop_sfx(sfx_name: String)
# signal audio_set_master_volume(volume: float)
# signal audio_set_sfx_volume(volume: float)
# signal audio_set_music_volume(volume: float)

# Future Implementation Events (ready for when needed)
# Uncomment these signals when implementing the corresponding features:

# Game State Events
# signal game_started()
# signal game_paused()
# signal game_resumed()
# signal game_over()

# Scene Events
# signal scene_changing(from_scene: String, to_scene: String)
# signal scene_changed(scene_name: String)

# Player Events  
# signal player_spawned(player: Node)
# signal player_died(player: Node)
# signal player_health_changed(current: int, maximum: int)

# UI Events
# signal ui_element_focused(element: Control)
# signal ui_button_pressed(button_name: String)
# signal menu_opened(menu_name: String)
# signal menu_closed(menu_name: String)

# Audio Events (extended)
# signal audio_stop_music()

# Input Events
# signal input_action_pressed(action: String)
# signal input_action_released(action: String)

# Room Events (Roguelike specific)
# signal room_entered(room_id: String)
# signal room_cleared(room_id: String)
# signal enemy_spawned(enemy: Node)
# signal enemy_defeated(enemy: Node)

# ============================================================================
#  EVENT MANAGEMENT
# ============================================================================

var event_history: Array[Dictionary] = []
var max_history_size: int = 100

func emit_event(event_name: String, data: Dictionary = {}):
	"""Emit a custom event with data"""
	var event_data = {
		"name": event_name,
		"data": data,
		"timestamp": Time.get_ticks_msec()
	}
	
	_add_to_history(event_data)
	
	# Emit the signal if it exists
	if has_signal(event_name):
		emit_signal(event_name, data)

func _add_to_history(event_data: Dictionary):
	"""Add event to history for debugging"""
	event_history.append(event_data)
	
	if event_history.size() > max_history_size:
		event_history.pop_front()

func get_recent_events(count: int = 10) -> Array[Dictionary]:
	"""Get recent events from history"""
	var recent_count = min(count, event_history.size())
	return event_history.slice(-recent_count)

func clear_history():
	"""Clear event history"""
	event_history.clear()

# ============================================================================
#  CONVENIENCE METHODS
# ============================================================================

func request_scene_change(scene_path: String):
	"""Request a scene change"""
	emit_event("scene_change_requested", {"scene_path": scene_path})

func notify_player_action(action: String, data: Dictionary = {}):
	"""Notify of player action"""
	emit_event("player_action", {"action": action, "data": data})

func notify_ui_interaction(ui_element: String, interaction_type: String):
	"""Notify of UI interaction"""
	emit_event("ui_interaction", {
		"element": ui_element, 
		"type": interaction_type
	})

func request_audio(audio_type: String, audio_name: String):
	"""Request audio playback"""
	match audio_type:
		"sfx":
			audio_play_sfx.emit(audio_name)
		"music":
			audio_play_music.emit(audio_name)
		_:
			print("EventBus: Unknown audio type: ", audio_type)
