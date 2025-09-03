extends "res://src/systems/StateMachine/State.gd"
class_name PausedState_simple

# =======================
#  ESTADO SIMPLE DE PAUSA
# =======================

## Implementación simple de un estado de pausa
## Ejemplo básico para entender el sistema de states

# =======================
#  PROPIEDADES DEL ESTADO
# =======================

var was_paused_before: bool = false
var pause_start_time: float = 0.0

# =======================
#  MÉTODOS DEL STATE
# =======================

func enter(_previous_state: State = null):
	"""Entrada al estado de pausa"""
	print("PausedState: Game paused")
	
	# Guardar el tiempo de inicio de pausa
	pause_start_time = Time.get_time_dict_from_system().second
	
	# Pausar el juego
	Engine.time_scale = 0.0
	was_paused_before = true
	
	# Mostrar UI de pausa si existe
	_show_pause_ui()

func exit(_next_state: State = null):
	"""Salida del estado de pausa"""
	print("PausedState: Game resumed")
	
	# Restaurar tiempo del juego
	Engine.time_scale = 1.0
	was_paused_before = false
	
	# Ocultar UI de pausa
	_hide_pause_ui()
	
	# Calcular tiempo pausado
	var pause_duration = Time.get_time_dict_from_system().second - pause_start_time
	print("PausedState: Was paused for ~%d seconds" % pause_duration)

func handle_input(event: InputEvent):
	"""Maneja input durante la pausa"""
	# Permitir reanudar con la misma tecla de pausa
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		# Señalar que queremos salir del estado de pausa
		if state_machine and state_machine.has_method("resume_game"):
			state_machine.resume_game()
		else:
			# Método alternativo si no hay state machine específica
			_request_resume()

func update(_delta: float):
	"""Update durante la pausa (normalmente vacío)"""
	# En pausa normalmente no actualizamos lógica del juego
	# Pero podemos actualizar animaciones de UI de pausa
	pass

# =======================
#  MÉTODOS PRIVADOS
# =======================

func _show_pause_ui():
	"""Muestra la interfaz de pausa"""
	# Buscar y mostrar menú de pausa
	var pause_menu = _find_pause_menu()
	if pause_menu:
		pause_menu.visible = true
		print("PausedState: Pause menu shown")
	else:
		print("PausedState: No pause menu found")

func _hide_pause_ui():
	"""Oculta la interfaz de pausa"""
	var pause_menu = _find_pause_menu()
	if pause_menu:
		pause_menu.visible = false
		print("PausedState: Pause menu hidden")

func _find_pause_menu() -> Control:
	"""Busca el menú de pausa en la escena"""
	var scene_tree = Engine.get_main_loop() as SceneTree
	if scene_tree and scene_tree.current_scene:
		# Buscar nodo con nombre "PauseMenu" o similar
		var pause_menu = scene_tree.current_scene.find_child("PauseMenu", true, false)
		if pause_menu:
			return pause_menu as Control
		
		# Buscar UI con método alternativo
		var ui_layer = scene_tree.current_scene.find_child("UI", true, false)
		if ui_layer:
			var pause_ui = ui_layer.find_child("PauseMenu", true, false)
			return pause_ui as Control
	
	return null

func _request_resume():
	"""Solicita reanudar el juego usando EventBus"""
	# Usar el EventBus del proyecto si está disponible
	if Engine.has_singleton("EventBus"):
		var event_bus = Engine.get_singleton("EventBus")
		if event_bus.has_method("emit_signal"):
			event_bus.emit_signal("game_resumed")
	else:
		# Método alternativo: cambiar directamente
		print("PausedState: Resuming game directly")
		exit()

# =======================
#  UTILIDADES PÚBLICAS
# =======================

func is_paused() -> bool:
	"""Verifica si actualmente está pausado"""
	return was_paused_before and Engine.time_scale == 0.0

func get_pause_duration() -> float:
	"""Obtiene la duración actual de la pausa"""
	if was_paused_before:
		return Time.get_time_dict_from_system().second - pause_start_time
	return 0.0

# =======================
#  EJEMPLO DE USO
# =======================

static func create_simple_pause_state() -> PausedState_simple:
	"""Crea una instancia simple del estado de pausa"""
	var pause_state = PausedState_simple.new()
	print("PausedState_simple: Created simple pause state")
	return pause_state

static func demo_pause_functionality():
	"""Demuestra la funcionalidad básica de pausa"""
	print("=== SIMPLE PAUSE STATE DEMO ===")
	
	var pause_state = create_simple_pause_state()
	
	print("Entering pause state...")
	pause_state.enter()
	
	print("Game should be paused now")
	print("Time scale: %f" % Engine.time_scale)
	
	# Simular un poco de tiempo pausado
	await Engine.get_main_loop().process_frame
	
	print("Exiting pause state...")
	pause_state.exit()
	
	print("Game should be resumed now")
	print("Time scale: %f" % Engine.time_scale)
	
	print("=== DEMO COMPLETE ===")
