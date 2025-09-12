extends Node
class_name DebugService
# DebugService.gd - Servicio de depuración global
# Proporciona helpers para logging, prints asíncronos y utilidades de timing.

signal debug_message_emitted(level: String, message: String)

var service_name: String = "DebugService"
var is_initialized: bool = false

func _ready():
    # No hacer prints excesivos en _ready; está bien para debug
    print("DebugService: ready")

func start_service():
    is_initialized = true
    print("DebugService: started")

func stop_service():
    is_initialized = false
    print("DebugService: stopped")

func is_service_available() -> bool:
    return is_initialized

func get_service_status() -> Dictionary:
    return {"initialized": is_initialized}

# Logging helpers
func log(message: String) -> void:
    _emit_and_print("LOG", message)

func info(message: String) -> void:
    _emit_and_print("INFO", message)

func warn(message: String) -> void:
    _emit_and_print("WARN", message)

func error(message: String) -> void:
    _emit_and_print("ERROR", message)

func _emit_and_print(level: String, message: String) -> void:
    var formatted = "[%s] %s" % [level, message]
    print(formatted)
    emit_signal("debug_message_emitted", level, message)

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
func measure_time(callable_func) -> float:
    # Use high-resolution ticks (microseconds) and Callable.call()
    var start = Time.get_ticks_usec()
    var _result = callable_func.call()
    var elapsed = (Time.get_ticks_usec() - start) / 1000000.0
    return elapsed

# Quick helper para imprimir estructuras de forma legible
func dump(var_value) -> void:
    var dumped = JSON.stringify(var_value)
    print(dumped)

# Ejemplo de uso (poner en cualquier script):
# var dbg = ServiceManager.get_service("DebugService")
# dbg.info("Hello from game")
# await dbg.wait_frames(2)
# dbg.print_after_frames("Printed after 2 frames", 2)
