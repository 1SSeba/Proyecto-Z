extends "res://game/core/services/BaseService.gd"
class_name DebugService
# DebugService.gd - Servicio de depuración global
# Proporciona helpers para logging, prints asíncronos y utilidades de timing.

signal debug_message_emitted(level: String, message: String)

enum LogLevel {
    LOG,
    INFO,
    WARN,
    ERROR
}

const _LEVEL_TO_INT: Dictionary = {
    "LOG": LogLevel.LOG,
    "INFO": LogLevel.INFO,
    "WARN": LogLevel.WARN,
    "ERROR": LogLevel.ERROR
}

const _INT_TO_LEVEL: Array[String] = ["LOG", "INFO", "WARN", "ERROR"]

var _level_threshold: int = LogLevel.LOG

func _ready():
    super._ready()
    service_name = "DebugService"

func start_service():
    super.start_service()
    _logger.log_info("Debug service started")

func stop_service():
    _logger.log_info("Debug service stopped")
    super.stop_service()

func get_service_status() -> Dictionary:
    var status := super.get_service_status()
    status["log_level"] = get_level()
    status["log_threshold"] = _level_threshold
    return status

# Logging helpers
func log(message: String) -> void:
    _emit_and_print("LOG", message)

func info(message: String) -> void:
    _emit_and_print("INFO", message)

func warn(message: String) -> void:
    _emit_and_print("WARN", message)

func error(message: String) -> void:
    _emit_and_print("ERROR", message)

func set_level(level_name: String) -> void:
    var upper := level_name.to_upper()
    if _LEVEL_TO_INT.has(upper):
        _level_threshold = _LEVEL_TO_INT[upper]
        _emit_and_print("LOG", "Log level set to %s" % upper, true)
    else:
        _emit_and_print("WARN", "Unknown log level '%s'" % level_name, true)

func get_level() -> String:
    return _INT_TO_LEVEL[_level_threshold]

func _emit_and_print(level: String, message: String, force: bool = false) -> void:
    var normalized: String = level.to_upper()
    var level_index: int = int(_LEVEL_TO_INT.get(normalized, LogLevel.LOG))
    if not force and level_index < _level_threshold:
        return

    var timestamp := Time.get_datetime_string_from_system(true)
    var formatted: String = "[%s][%s] %s" % [timestamp, normalized, message]
    print(formatted)
    emit_signal("debug_message_emitted", normalized, message)

# Async convenience: print message after N frames
func print_after_frames(message: String, frames: int) -> void:
    if frames <= 0:
        print(message)
        return

    # Call top-level async helper
    _delayed_print_async(frames, message)

# Awaitable helper to wait N frames (useful in tests and coroutines)
func wait_frames(frames: int):
    # Await N frames; callers should use 'await debug_service.wait_frames(n)'
    for i in range(frames):
        await get_tree().process_frame

# Top-level async helpers (nested async funcs are not supported in GDScript)
func _delayed_print_async(frames_to_wait: int, msg: String):
    for i in range(frames_to_wait):
        await get_tree().process_frame
    print(msg)

# Note: no separate _wait_async needed; wait_frames implements the awaitable behavior.

# Timing helper: execute function and return elapsed seconds
func measure_time(callable_func: Callable) -> float:
    # Use high-resolution ticks (microseconds) and Callable.call()
    var start_time: int = Time.get_ticks_usec()
    callable_func.call()
    var elapsed: float = (Time.get_ticks_usec() - start_time) / 1000000.0
    return elapsed

# Quick helper para imprimir estructuras de forma legible
func dump(var_value) -> void:
    var dumped: String = JSON.stringify(var_value)
    print(dumped)

# Ejemplo de uso (poner en cualquier script):
# var dbg = ServiceManager.get_service("DebugService")
# dbg.info("Hello from game")
# await dbg.wait_frames(2)
# dbg.print_after_frames("Printed after 2 frames", 2)
