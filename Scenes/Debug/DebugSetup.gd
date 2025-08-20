# DebugSetup.gd - Sistema consolidado de debug setup y testing
extends Node

# =======================
#  CONFIGURACIÓN
# =======================
@export var auto_show_debug_info: bool = true
@export var debug_test_hotkeys: bool = true

# Variables para testing automático
var test_timer: Timer
var auto_test_enabled: bool = false

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("DebugSetup: Configuring consolidated debug system...")
	
	# Esperar un frame para que los autoloads estén listos
	await get_tree().process_frame
	
	# Configurar debug system
	setup_debug_system()
	
	# Mostrar info si está habilitado
	if auto_show_debug_info:
		show_debug_welcome()
	
	# Configurar timer para tests automáticos si se necesita
	_setup_test_timer()

func setup_debug_system():
	"""Configura el sistema de debug consolidado"""
	
	# 1. Verificar DebugManager
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager:
		print("✅ DebugManager found and ready")
	else:
		print("❌ DebugManager not found!")
		return
	
	# 2. Buscar DebugConsole
	var debug_console = _find_debug_console()
	if not debug_console:
		print("⚠️ DebugConsole not found - debug console unavailable")
	
	# 3. Validar que todo funcione
	_validate_debug_system()

func _find_debug_console() -> Node:
	"""Busca DebugConsole en la escena"""
	var console = get_tree().current_scene.find_child("DebugConsole", true, false)
	if console:
		print("✅ DebugConsole found in scene")
		return console
	return null

func _validate_debug_system():
	"""Valida que el sistema de debug funcione"""
	print("🔍 Validating debug system...")
	
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager and debug_manager.has_method("log_to_console"):
		debug_manager.log_to_console("DebugSetup: System validation complete!", "green")
		print("✅ Debug system validation successful")
	else:
		print("⚠️ DebugManager missing log_to_console method")

func show_debug_welcome():
	"""Muestra mensaje de bienvenida del debug"""
	await get_tree().create_timer(0.5).timeout
	
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager and debug_manager.has_method("log_to_console"):
		debug_manager.log_to_console("=== DEBUG SYSTEM READY ===", "cyan")
		debug_manager.log_to_console("Press ` (tilde) to open console", "yellow")
		debug_manager.log_to_console("Press F1 for quick status", "white")
		debug_manager.log_to_console("Press F11 for quick test", "white")
		debug_manager.log_to_console("Press F12 to toggle debug mode", "white")

# =======================
#  TESTING SYSTEM (Consolidado de DebugTester)
# =======================
func _setup_test_timer():
	"""Configura timer para tests automáticos"""
	test_timer = Timer.new()
	test_timer.wait_time = 2.0
	test_timer.timeout.connect(_send_test_message)
	add_child(test_timer)

func _unhandled_input(event):
	"""Hotkeys para testing"""
	if not debug_test_hotkeys or not event is InputEventKey or not event.pressed:
		return
	
	match event.keycode:
		KEY_F9:  # Test managers
			test_managers_availability()
			get_viewport().set_input_as_handled()
		
		KEY_F8:  # Test debug commands
			test_debug_commands()
			get_viewport().set_input_as_handled()

func test_managers_availability():
	"""Prueba la disponibilidad de todos los managers"""
	_log_to_debug("Testing manager availability...", "yellow")
	
	var managers = [
		"ConfigManager",
		"InputManager", 
		"AudioManager",
		"GameStateManager",
		"GameManager",
		"DebugManager"
	]
	
	for manager_name in managers:
		var manager = get_node_or_null("/root/" + manager_name)
		if manager:
			var status = "FOUND"
			if manager.has_method("is_ready"):
				status += " (Ready: %s)" % manager.is_ready()
			_log_to_debug("%s: %s" % [manager_name, status], "green")
		else:
			_log_to_debug("%s: NOT FOUND" % manager_name, "red")

func test_debug_commands():
	"""Prueba algunos comandos de debug"""
	_log_to_debug("Testing debug commands...", "yellow")
	
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager and debug_manager.has_method("execute_command"):
		# Test comando status
		debug_manager.execute_command("status")
		
		await get_tree().create_timer(0.5).timeout
		
		# Test comando managers
		debug_manager.execute_command("managers")
		
		_log_to_debug("Debug commands test completed", "green")
	else:
		_log_to_debug("Cannot test commands - DebugManager not available", "red")

func run_complete_debug_test():
	"""Ejecuta test completo del sistema"""
	_log_to_debug("=== RUNNING COMPLETE DEBUG TEST ===", "cyan")
	
	# Test 1: Managers
	test_managers_availability()
	await get_tree().create_timer(1.0).timeout
	
	# Test 2: Comandos
	test_debug_commands()
	await get_tree().create_timer(1.0).timeout
	
	# Test 3: Player si existe
	_test_player_integration()
	
	_log_to_debug("=== COMPLETE DEBUG TEST FINISHED ===", "green")

func _test_player_integration():
	"""Prueba integración con player"""
	var player = _get_player()
	if player:
		if player.has_method("debug_info"):
			_log_to_debug("Player debug integration: AVAILABLE", "green")
		else:
			_log_to_debug("Player debug integration: LIMITED", "orange")
		_log_to_debug("Player Position: %s" % str(player.global_position), "white")
	else:
		_log_to_debug("Player: NOT FOUND", "orange")

# =======================
#  AUTO TESTING
# =======================
func start_auto_testing():
	"""Inicia testing automático cada 2 segundos"""
	if auto_test_enabled:
		return
	
	auto_test_enabled = true
	test_timer.start()
	_log_to_debug("Auto testing started", "green")

func stop_auto_testing():
	"""Para testing automático"""
	if not auto_test_enabled:
		return
	
	auto_test_enabled = false
	test_timer.stop()
	_log_to_debug("Auto testing stopped", "orange")

func _send_test_message():
	"""Envía mensaje de test automático"""
	var messages = [
		"Auto test: Checking system status...",
		"Auto test: Managers operational...", 
		"Auto test: Debug console active...",
		"Auto test: All systems nominal!"
	]
	
	var random_message = messages[randi() % messages.size()]
	_log_to_debug(random_message, "cyan")

# =======================
#  COMMAND INTERFACE (Para usar desde debug console)
# =======================
func debug_run_test(test_name: String = ""):
	"""Comando para ejecutar tests específicos desde consola"""
	match test_name:
		"managers":
			test_managers_availability()
		"commands":
			test_debug_commands()
		"complete":
			run_complete_debug_test()
		"auto_start":
			start_auto_testing()
		"auto_stop":
			stop_auto_testing()
		"player":
			_test_player_integration()
		_:
			_log_to_debug("Available tests: managers, commands, complete, player, auto_start, auto_stop", "yellow")

# =======================
#  UTILITIES
# =======================
func _get_player() -> Node:
	"""Obtiene referencia al player"""
	if _is_manager_available("GameManager"):
		return GameManager.get_player()
	
	var current_scene = get_tree().current_scene
	if current_scene:
		var player = current_scene.find_child("Player", true, false)
		if player:
			return player
		
		if current_scene.get_script() and current_scene.get_script().resource_path.ends_with("Player.gd"):
			return current_scene
	
	return null

func _is_manager_available(manager_name: String) -> bool:
	"""Verifica si un manager está disponible"""
	return get_node_or_null("/root/" + manager_name) != null

func _log_to_debug(message: String, color: String = "white"):
	"""Envía mensaje al sistema de debug"""
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager and debug_manager.has_method("log_to_console"):
		debug_manager.log_to_console("SETUP: " + message, color)
	else:
		print("SETUP: %s" % message)

# =======================
#  PUBLIC API
# =======================
func force_debug_refresh():
	"""Fuerza refrescar el sistema de debug"""
	setup_debug_system()

func is_debug_system_ready() -> bool:
	"""Verifica si el sistema de debug está listo"""
	var debug_manager = get_node_or_null("/root/DebugManager")
	return debug_manager != null and debug_manager.has_method("is_ready") and debug_manager.is_ready()

func get_debug_info() -> Dictionary:
	"""Obtiene información del sistema de debug"""
	var current_scene = get_tree().current_scene
	var scene_name = current_scene.name if current_scene else "Unknown"
	
	return {
		"debug_manager_ready": is_debug_system_ready(),
		"console_exists": _find_debug_console() != null,
		"scene_name": scene_name,
		"fps": Engine.get_frames_per_second(),
		"resolution": str(get_viewport().size),
		"auto_test_enabled": auto_test_enabled
	}

# =======================
#  CLEANUP
# =======================
func _exit_tree():
	if test_timer:
		test_timer.queue_free()
	print("DebugSetup: Cleanup complete")
