# DebugManager.gd - Sistema centralizado de debug optimizado
extends Node

# =======================
#  SEÑALES
# =======================
signal debug_command_executed(command: String, result: String)
signal debug_mode_changed(enabled: bool)
signal debug_console_message(message: String, color: String)

# =======================
#  VARIABLES
# =======================
var is_debug_enabled: bool = true
var is_debug_ui_visible: bool = false
var is_initialized: bool = false

# Variables para testing
var player_testing_mode: bool = false

# Historial de comandos
var command_history: Array[String] = []
var max_history: int = 50

# Referencia a la consola debug
var debug_console: Node = null

# =======================
#  INICIALIZACIÓN SIMPLIFICADA
# =======================
func _ready():
	print("DebugManager: Starting initialization...")
	
	# Configurar para que funcione siempre
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	await _wait_for_core_managers()
	
	# Buscar consola de debug
	_find_debug_console()
	
	is_initialized = true
	print("DebugManager: Initialization complete!")
	_print_welcome_message()

func _wait_for_core_managers():
	"""Espera solo a los managers críticos"""
	var core_managers = [
		"/root/ConfigManager",
		"/root/InputManager"
	]
	
	for manager_path in core_managers:
		var manager = get_node_or_null(manager_path)
		if manager and manager.has_method("is_ready"):
			while not manager.is_ready():
				await get_tree().process_frame
		print("DebugManager: %s ready" % manager_path.get_file())

func _find_debug_console():
	"""Busca y conecta con la consola de debug"""
	var current_scene = get_tree().current_scene
	if current_scene:
		debug_console = current_scene.find_child("DebugConsole", true, false)
		
		if debug_console:
			print("DebugManager: Found DebugConsole in scene")
			debug_console_message.connect(_send_to_console)
		else:
			print("DebugManager: No DebugConsole found in current scene")

func _send_to_console(message: String, color: String = "white"):
	"""Envía mensaje a la consola de debug"""
	if debug_console and debug_console.has_method("debug_log"):
		debug_console.debug_log(message, color)

func _print_welcome_message():
	print("========================================")
	print("DEBUG MANAGER READY")
	print("========================================")
	print("Press F12 to toggle debug mode")
	print("Press F1 for quick status")
	print("Press ` (tilde) for debug console")
	print("========================================")
	
	emit_signal("debug_console_message", "=== DEBUG MANAGER READY ===", "cyan")
	emit_signal("debug_console_message", "Type 'help' for available commands", "yellow")

# =======================
#  INPUT HANDLING OPTIMIZADO
# =======================
func _unhandled_input(event):
	"""Input handling simplificado"""
	if not is_debug_enabled or not is_initialized:
		return
	
	if not event is InputEventKey or not event.pressed:
		return
	
	match event.keycode:
		KEY_QUOTELEFT:  # ` (tilde)
			_handle_console_toggle()
			get_viewport().set_input_as_handled()
		
		KEY_F1:  # Quick Status
			cmd_status()
			get_viewport().set_input_as_handled()
		
		KEY_F2:  # Player Testing
			toggle_player_testing()
			get_viewport().set_input_as_handled()
		
		KEY_F11:  # Quick Test
			_handle_quick_test()
			get_viewport().set_input_as_handled()
		
		KEY_F12:  # Debug Mode Toggle
			toggle_debug_mode()
			get_viewport().set_input_as_handled()

func _handle_console_toggle():
	"""Maneja toggle de consola"""
	if debug_console and debug_console.has_method("toggle_console"):
		debug_console.toggle_console()
	else:
		emit_signal("debug_console_message", "Console not available", "orange")

func _handle_quick_test():
	"""Quick test optimizado"""
	emit_signal("debug_console_message", "=== QUICK TEST (F11) ===", "cyan")
	execute_command("status")

# =======================
#  DEBUG MODE CONTROL
# =======================
func toggle_debug_mode():
	is_debug_ui_visible = !is_debug_ui_visible
	debug_mode_changed.emit(is_debug_ui_visible)
	var status = "ON" if is_debug_ui_visible else "OFF"
	print("Debug mode: %s" % status)
	emit_signal("debug_console_message", "Debug mode: %s" % status, "yellow")

func toggle_player_testing():
	player_testing_mode = !player_testing_mode
	var status = "ON" if player_testing_mode else "OFF"
	print("Player testing mode: %s" % status)
	emit_signal("debug_console_message", "Player testing mode: %s" % status, "orange")

# =======================
#  COMMAND SYSTEM
# =======================
func execute_command(command: String) -> String:
	"""Ejecuta un comando de debug"""
	command = command.strip_edges().to_lower()
	
	if command.is_empty():
		return "Empty command"
	
	command_history.append(command)
	if command_history.size() > max_history:
		command_history.pop_front()
	
	var result = _process_command(command)
	debug_command_executed.emit(command, result)
	emit_signal("debug_console_message", result, "green")
	
	return result

func _process_command(command: String) -> String:
	var parts = command.split(" ")
	var main_cmd = parts[0]
	
	match main_cmd:
		"help":
			return cmd_help()
		"status":
			return cmd_status()
		"player":
			return cmd_player(parts.slice(1))
		"game":
			return cmd_game(parts.slice(1))
		"audio":
			return cmd_audio(parts.slice(1))
		"config":
			return cmd_config(parts.slice(1))
		"managers":
			return cmd_managers()
		"clear":
			return cmd_clear()
		"console":
			return cmd_console(parts.slice(1))
		_:
			return "Unknown command: " + command + ". Type 'help' for available commands."

# =======================
#  COMMAND IMPLEMENTATIONS OPTIMIZADAS
# =======================
func cmd_help() -> String:
	var help_text = """
DEBUG COMMANDS:
help - Show this help
status - Overall system status
player [info|damage|heal] - Player commands
game [info|room|enemy] - Game commands
audio [status|test] - Audio commands
config [info|reset] - Config commands
managers - Show all managers status
clear - Clear console
console [show|hide|test] - Console commands
"""
	print(help_text)
	return "Help displayed"

func cmd_status() -> String:
	var status_lines = []
	status_lines.append("=== SYSTEM STATUS ===")
	status_lines.append("Debug Enabled: %s" % is_debug_enabled)
	status_lines.append("Console Found: %s" % (debug_console != null))
	status_lines.append("")
	
	var managers = [
		["ConfigManager", "/root/ConfigManager"],
		["InputManager", "/root/InputManager"],
		["AudioManager", "/root/AudioManager"],
		["GameStateManager", "/root/GameStateManager"],
		["GameManager", "/root/GameManager"]
	]
	
	for manager_info in managers:
		var manager_name = manager_info[0]
		var path = manager_info[1]
		var manager = get_node_or_null(path)
		var status = "NOT FOUND"
		
		if manager:
			status = "READY" if (manager.has_method("is_ready") and manager.is_ready()) else "FOUND"
		
		status_lines.append("%s: %s" % [manager_name, status])
	
	var player = _get_player()
	status_lines.append("Player: %s" % ("FOUND" if player else "NOT FOUND"))
	
	if get_node_or_null("/root/GameStateManager"):
		var current_state = GameStateManager.get_current_state()
		status_lines.append("GameState: %s" % GameStateManager.GameState.keys()[current_state])
	
	status_lines.append("======================")
	
	for line in status_lines:
		print(line)
		var color = "green" if "READY" in line else ("red" if "NOT FOUND" in line else "white")
		emit_signal("debug_console_message", line, color)
	
	return "Status displayed"

func cmd_managers() -> String:
	print("=== MANAGERS STATUS ===")
	
	var manager_list = [
		["ConfigManager", "/root/ConfigManager"],
		["InputManager", "/root/InputManager"],
		["AudioManager", "/root/AudioManager"],
		["GameStateManager", "/root/GameStateManager"],
		["GameManager", "/root/GameManager"],
		["DebugManager", "/root/DebugManager"]
	]
	
	for manager_info in manager_list:
		var manager_name = manager_info[0]
		var path = manager_info[1]
		var manager = get_node_or_null(path)
		
		var status_line = ""
		if manager:
			status_line = "%s: FOUND" % manager_name
			if manager.has_method("is_ready"):
				status_line += " (Ready: %s)" % manager.is_ready()
		else:
			status_line = "%s: NOT FOUND" % manager_name
		
		print(status_line)
		var color = "green" if manager else "red"
		emit_signal("debug_console_message", status_line, color)
	
	print("========================")
	return "Managers status displayed"

func cmd_console(args: Array) -> String:
	"""Comandos específicos de la consola"""
	if args.is_empty():
		return "Console found: %s" % (debug_console != null)
	
	match args[0]:
		"show":
			if debug_console and debug_console.has_method("show_console"):
				debug_console.show_console()
			return "Console shown"
		"hide":
			if debug_console and debug_console.has_method("hide_console"):
				debug_console.hide_console()
			return "Console hidden"
		"test":
			emit_signal("debug_console_message", "Test message!", "yellow")
			emit_signal("debug_console_message", "Error test", "red")
			emit_signal("debug_console_message", "Success test", "green")
			return "Console test messages sent"
		_:
			return "Unknown console command: " + args[0]

func cmd_player(args: Array) -> String:
	var player = _get_player()
	if not player:
		return "Player not found"
	
	if args.is_empty():
		if player.has_method("debug_info"):
			player.debug_info()
		return "Player info displayed"
	
	match args[0]:
		"info":
			if player.has_method("debug_info"):
				player.debug_info()
			return "Player debug info"
		"damage":
			var amount = 25.0
			if args.size() > 1:
				amount = float(args[1])
			if player.has_method("debug_damage"):
				player.debug_damage(amount)
			return "Player damaged for " + str(amount)
		"heal":
			var amount = 25.0
			if args.size() > 1:
				amount = float(args[1])
			if player.has_method("debug_heal"):
				player.debug_heal(amount)
			return "Player healed for " + str(amount)
		_:
			return "Unknown player command: " + args[0]

func cmd_game(args: Array) -> String:
	if args.is_empty():
		if get_node_or_null("/root/GameManager"):
			GameManager.debug_game_info()
		return "Game info displayed"
	
	match args[0]:
		"info":
			if get_node_or_null("/root/GameManager"):
				GameManager.debug_game_info()
			return "Game debug info"
		"room":
			if get_node_or_null("/root/GameManager"):
				GameManager.debug_complete_room()
			return "Room completed"
		_:
			return "Unknown game command: " + args[0]

func cmd_audio(args: Array) -> String:
	if not get_node_or_null("/root/AudioManager"):
		return "AudioManager not available"
	
	if args.is_empty():
		AudioManager.debug_audio_status()
		return "Audio status displayed"
	
	match args[0]:
		"status":
			AudioManager.debug_audio_status()
			return "Audio debug status"
		"test":
			AudioManager.debug_test_roguelike_sounds()
			return "Audio test started"
		_:
			return "Unknown audio command: " + args[0]

func cmd_config(args: Array) -> String:
	if not get_node_or_null("/root/ConfigManager"):
		return "ConfigManager not available"
	
	if args.is_empty():
		ConfigManager.print_all_settings()
		return "Config settings displayed"
	
	match args[0]:
		"info":
			ConfigManager.debug_settings_info()
			return "Config debug info"
		"reset":
			ConfigManager.reset_to_defaults()
			return "Config reset to defaults"
		_:
			return "Unknown config command: " + args[0]

func cmd_clear() -> String:
	if debug_console and debug_console.has_method("clear_output"):
		debug_console.clear_output()
		return "Console cleared"
	return "Console not available for clearing"

# =======================
#  UTILIDADES SIMPLIFICADAS
# =======================
func _get_player() -> Node:
	"""Obtiene referencia al player"""
	if get_node_or_null("/root/GameManager"):
		return GameManager.get_player()
	
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.find_child("Player", true, false)
	
	return null

# =======================
#  FUNCIONES PÚBLICAS PARA OTROS SCRIPTS
# =======================
func log_to_console(message: String, color: String = "white"):
	"""Función pública para que otros scripts logueen a la consola"""
	emit_signal("debug_console_message", message, color)

func log_error(message: String):
	emit_signal("debug_console_message", "ERROR: " + message, "red")

func log_warning(message: String):
	emit_signal("debug_console_message", "WARNING: " + message, "orange")

func log_success(message: String):
	emit_signal("debug_console_message", "SUCCESS: " + message, "green")

func log_info(message: String):
	emit_signal("debug_console_message", "INFO: " + message, "cyan")

# =======================
#  PUBLIC API
# =======================
func is_ready() -> bool:
	return is_initialized

func get_command_history() -> Array[String]:
	return command_history.duplicate()

func get_debug_console() -> Node:
	return debug_console

# =======================
#  CLEANUP
# =======================
func _exit_tree():
	print("DebugManager: Cleanup complete")	
