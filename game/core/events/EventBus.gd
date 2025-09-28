extends Node

# High-level menu events actively used by the game flow
signal game_start_requested()
signal multiplayer_requested()
signal quit_requested()

# Input events raised by the input service for interested listeners
signal input_action_pressed(action: String)
signal input_action_released(action: String)

var event_history: Array[Dictionary] = []
var max_history_size: int = 50

func emit_event(event_name: String, data: Dictionary = {}):
	var event_data = {
		"name": event_name,
		"data": data,
		"timestamp": Time.get_ticks_msec()
	}

	_add_to_history(event_data)

	match event_name:
		"game_start_requested":
			game_start_requested.emit()
		"multiplayer_requested":
			multiplayer_requested.emit()
		"quit_requested":
			quit_requested.emit()
		_:
			print_debug("EventBus: Unhandled event '%s'" % event_name)

func _add_to_history(event_data: Dictionary):
	event_history.append(event_data)

	if event_history.size() > max_history_size:
		event_history.pop_front()

func get_recent_events(count: int = 10) -> Array[Dictionary]:
	var recent_count = min(count, event_history.size())
	return event_history.slice(-recent_count)

func clear_history():
	event_history.clear()
