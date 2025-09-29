extends Object

static var _cached_debug_service: Node = null

static func _get_debug_service() -> Node:
	if _cached_debug_service and is_instance_valid(_cached_debug_service):
		return _cached_debug_service
	if ServiceManager and ServiceManager.has_service("DebugService"):
		_cached_debug_service = ServiceManager.get_service("DebugService")
	else:
		_cached_debug_service = null
	return _cached_debug_service

static func reset_cache() -> void:
	_cached_debug_service = null

static func log(message: String) -> void:
	_logger_dispatch("log", message)

static func info(message: String) -> void:
	_logger_dispatch("info", message)

static func warn(message: String) -> void:
	_logger_dispatch("warn", message)

static func error(message: String) -> void:
	_logger_dispatch("error", message)

static func dump(value, prefix: String = "") -> void:
	var service := _get_debug_service()
	if service and service.has_method("dump"):
		service.dump(value)
		return

	var serialized := JSON.stringify(value)
	if prefix != "":
		print("[%s][DUMP] %s" % [prefix, serialized])
	else:
		print("[DUMP] %s" % serialized)

static func _logger_dispatch(method: String, message: String) -> void:
	var service := _get_debug_service()
	if service and service.has_method(method):
		service.call(method, message)
	else:
		var level := method.to_upper()
		print("[%s] %s" % [level, message])
