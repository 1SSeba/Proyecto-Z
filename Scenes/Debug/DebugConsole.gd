# DebugConsole.gd - Consola de debug interactiva para roguelike
extends Control

# =======================
#  NODOS UI
# =======================
@onready var console_panel: Panel = $Panel
@onready var output_text: RichTextLabel = $Panel/VBox/OutputText
@onready var input_line: LineEdit = $Panel/VBox/InputLine

# =======================
#  VARIABLES
# =======================
var is_console_visible: bool = false
var command_history: Array[String] = []
var history_index: int = -1
var max_output_lines: int = 300

# Variables para 960x540
var default_size: Vector2 = Vector2(800, 350)
var default_position: Vector2 = Vector2(80, 50)

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("DebugConsole: Initializing for 960x540...")
	
	# Configurar para que funcione siempre
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Configurar UI para 960x540
	setup_console_ui()
	
	# Conectar señales
	if input_line:
		input_line.text_submitted.connect(_on_command_submitted)
	else:
		print("DebugConsole: ERROR - InputLine not found!")
	
	# Conectar resize para responsividad
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	# Conectar con DebugManager (con delay para asegurar que esté listo)
	get_tree().create_timer(0.1).timeout.connect(_connect_with_debug_manager)
	
	# Empezar oculta
	hide_console()
	
	print("DebugConsole: Ready for 960x540")

func _connect_with_debug_manager():
	"""Conecta con DebugManager para recibir mensajes"""
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager:
		if debug_manager.has_signal("debug_console_message"):
			debug_manager.debug_console_message.connect(_on_debug_message_received)
			add_output("[color=green]Connected to DebugManager[/color]")
		else:
			add_output("[color=orange]DebugManager found but no debug_console_message signal[/color]")
	else:
		add_output("[color=orange]DebugManager not found - Local commands only[/color]")

func _on_debug_message_received(message: String, color: String):
	"""Recibe mensajes del DebugManager"""
	debug_log(message, color)

func setup_console_ui():
	"""Configura la interfaz de la consola para 960x540"""
	if not console_panel:
		print("DebugConsole: ERROR - Panel not found!")
		return
	
	# Panel principal - Optimizado para 960x540
	console_panel.size = default_size
	console_panel.position = default_position
	
	# Estilo del panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.85)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color.CYAN
	console_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Configurar output text
	if output_text:
		output_text.bbcode_enabled = true
		output_text.scroll_following = true
	
	# Configurar input
	if input_line:
		input_line.placeholder_text = "Comando... (Esc para cerrar)"
	
	# Mensaje de bienvenida
	add_output("[color=cyan]DEBUG CONSOLE [960x540][/color]")
	add_output("Type 'help' for commands, Esc to close")
	add_output("Up/Down for history, ` to toggle")
	add_output("=====================================")

func _on_viewport_resized():
	"""Ajusta la consola cuando cambia el tamaño de ventana"""
	var viewport_size = get_viewport().size
	if viewport_size == Vector2(960, 540):
		# Mantener configuración optimizada
		if console_panel:
			console_panel.size = default_size
			console_panel.position = default_position
	else:
		# Escalar proporcionalmente
		var scale_x = viewport_size.x / 960.0
		var scale_y = viewport_size.y / 540.0
		var scale = min(scale_x, scale_y)
		
		if console_panel:
			console_panel.size = default_size * scale
			console_panel.position = default_position * scale

# =======================
#  CONTROL DE VISIBILIDAD
# =======================
func _unhandled_input(event):
	"""Procesa input cuando la consola NO está visible"""
	if is_console_visible:
		return  # Si está visible, usar _input normal
	
	# Solo tecla ` (tilde) para abrir cuando está cerrada
	if event is InputEventKey and event.pressed and event.keycode == KEY_QUOTELEFT:
		toggle_console()
		get_viewport().set_input_as_handled()

func _input(event):
	"""Procesa input cuando la consola SÍ está visible"""
	if not is_console_visible:
		return  # Si no está visible, usar _unhandled_input
	
	# ESC para cerrar cuando está visible
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide_console()
		get_viewport().set_input_as_handled()
		return
	
	# Historial de comandos (solo cuando consola visible e input tiene foco)
	if input_line and input_line.has_focus():
		if event.is_action_pressed("ui_up"):
			navigate_history(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			navigate_history(1)
			get_viewport().set_input_as_handled()

func toggle_console():
	"""Alterna visibilidad de la consola"""
	if is_console_visible:
		hide_console()
	else:
		show_console()

func show_console():
	"""Muestra la consola"""
	is_console_visible = true
	visible = true
	if input_line:
		input_line.grab_focus()
	add_output("[color=yellow]Console opened[/color]")

func hide_console():
	"""Oculta la consola"""
	is_console_visible = false
	visible = false
	if input_line:
		input_line.clear()
	history_index = -1

# =======================
#  MANEJO DE COMANDOS
# =======================
func _on_command_submitted(command: String):
	"""Maneja cuando se envía un comando"""
	if command.strip_edges().is_empty():
		return
	
	# Mostrar comando en output
	add_output("[color=white]> " + command + "[/color]")
	
	# Agregar al historial
	command_history.append(command)
	if command_history.size() > 50:  # Limitar historial
		command_history.pop_front()
	history_index = -1
	
	# Ejecutar comando
	execute_command(command)
	
	# Limpiar input
	if input_line:
		input_line.clear()

func execute_command(command: String):
	"""Ejecuta un comando y muestra resultado"""
	var result = ""
	
	# Si DebugManager existe, usar sus comandos
	var debug_manager = get_node_or_null("/root/DebugManager")
	if debug_manager and debug_manager.has_method("execute_command"):
		result = debug_manager.execute_command(command)
		# El resultado ya se mostrará via signal debug_console_message
	else:
		# Comandos básicos locales
		result = execute_local_command(command)
		add_output("[color=yellow]" + result + "[/color]")

func execute_local_command(command: String) -> String:
	"""Comandos básicos cuando no hay DebugManager"""
	var parts = command.strip_edges().to_lower().split(" ")
	var main_cmd = parts[0]
	
	match main_cmd:
		"help":
			add_output("Available commands (960x540):")
			add_output("clear - Clear console")
			add_output("exit - Close console")  
			add_output("echo [text] - Echo text")
			add_output("scene - Current scene info")
			add_output("player - Find player")
			add_output("fps - Show FPS")
			add_output("res - Show resolution")
			add_output("pos - Console position")
			return "Help displayed"
		
		"clear":
			clear_output()
			return "Console cleared"
		
		"exit":
			hide_console()
			return "Console closed"
		
		"echo":
			if parts.size() > 1:
				var text = command.substr(5)  # Remove "echo "
				return text
			return "Echo: (empty)"
		
		"scene":
			var scene = get_tree().current_scene
			if scene:
				return "Current scene: " + scene.name
			return "No current scene"
		
		"player":
			var current_scene = get_tree().current_scene
			if not current_scene:
				return "No current scene available"
				
			var player = current_scene
			if player and player.get_script() and player.get_script().resource_path.ends_with("Player.gd"):
				return "Player found: " + str(player.global_position)
			
			# Buscar hijo Player
			var found_player = current_scene.find_child("Player", true, false)
			if found_player:
				return "Player child: " + str(found_player.global_position)
			
			return "No player found"
		
		"fps":
			return "FPS: " + str(Engine.get_frames_per_second())
		
		"res":
			var size = get_viewport().size
			return "Resolution: " + str(size.x) + "x" + str(size.y)
		
		"pos":
			if console_panel:
				return "Console pos: " + str(console_panel.position) + " size: " + str(console_panel.size)
			return "Console panel not found"
		
		_:
			return "Unknown: " + command + ". Type 'help'"

# =======================
#  GESTIÓN DE OUTPUT
# =======================
func add_output(text: String):
	"""Agrega texto al output de la consola"""
	if not output_text:
		print("DebugConsole: ERROR - OutputText not found!")
		return
	
	output_text.append_text(text + "\n")
	
	# Limitar líneas para evitar lag
	var lines = output_text.get_parsed_text().split("\n")
	if lines.size() > max_output_lines:
		clear_output()
		add_output("[color=orange]Output cleared (too many lines)[/color]")
		add_output(text)
	
	# Auto-scroll al final
	await get_tree().process_frame
	output_text.scroll_to_line(output_text.get_line_count())

func clear_output():
	"""Limpia el output de la consola"""
	if output_text:
		output_text.clear()
		add_output("[color=cyan]Console cleared[/color]")

# =======================
#  HISTORIAL DE COMANDOS
# =======================
func navigate_history(direction: int):
	"""Navega por el historial de comandos"""
	if command_history.is_empty() or not input_line:
		return
	
	history_index += direction
	history_index = clamp(history_index, -1, command_history.size() - 1)
	
	if history_index == -1:
		input_line.text = ""
	else:
		input_line.text = command_history[history_index]
		input_line.caret_column = input_line.text.length()

# =======================
#  UTILIDADES PÚBLICAS
# =======================
func debug_log(message: String, color: String = "white"):
	"""Función pública para loggear desde otros scripts"""
	add_output("[color=" + color + "]" + message + "[/color]")

func debug_log_error(message: String):
	"""Log de error"""
	debug_log("ERROR: " + message, "red")

func debug_log_warning(message: String):
	"""Log de warning"""
	debug_log("WARNING: " + message, "orange")

func debug_log_success(message: String):
	"""Log de éxito"""
	debug_log("SUCCESS: " + message, "green")

func debug_log_info(message: String):
	"""Log de información"""
	debug_log("INFO: " + message, "cyan")

# =======================
#  CONFIGURACIÓN PARA 960x540
# =======================
func set_console_size(width: int, height: int):
	"""Cambia el tamaño de la consola"""
	if console_panel:
		console_panel.size = Vector2(width, height)

func set_console_position(x: int, y: int):
	"""Cambia la posición de la consola"""
	if console_panel:
		console_panel.position = Vector2(x, y)

func set_small_mode():
	"""Modo compacto para 960x540"""
	if console_panel:
		console_panel.size = Vector2(750, 300)
		console_panel.position = Vector2(105, 80)

func set_large_mode():
	"""Modo grande para 960x540"""
	if console_panel:
		console_panel.size = Vector2(850, 400) 
		console_panel.position = Vector2(55, 30)

func center_console():
	"""Centra la consola en pantalla 960x540"""
	if console_panel:
		var screen_size = Vector2(960, 540)
		var console_size = console_panel.size
		var center_pos = Vector2(
			(screen_size.x - console_size.x) / 2,
			(screen_size.y - console_size.y) / 2
		)
		console_panel.position = center_pos

# =======================
#  FUNCIONES DE DEBUG
# =======================
func debug_console_info():
	"""Debug info de la consola"""
	print("=== DEBUG CONSOLE INFO ===")
	print("Visible: %s" % is_console_visible)
	print("Panel found: %s" % (console_panel != null))
	print("OutputText found: %s" % (output_text != null))
	print("InputLine found: %s" % (input_line != null))
	if console_panel:
		print("Panel pos: %s" % str(console_panel.position))
		print("Panel size: %s" % str(console_panel.size))
	print("History size: %d" % command_history.size())
	print("==========================")

# =======================
#  CLEANUP
# =======================
func _exit_tree():
	print("DebugConsole: Cleanup complete")
