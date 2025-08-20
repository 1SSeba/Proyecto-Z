# ManagerUtils.gd - Utilidades estáticas para managers (elimina duplicación)
class_name ManagerUtils

# =======================
#  VERIFICACIONES DE MANAGERS
# =======================
static func is_config_manager_available() -> bool:
	return _get_manager("ConfigManager") != null

static func is_input_manager_available() -> bool:
	return _get_manager("InputManager") != null

static func is_audio_manager_available() -> bool:
	return _get_manager("AudioManager") != null

static func is_game_state_manager_available() -> bool:
	return _get_manager("GameStateManager") != null

static func is_game_manager_available() -> bool:
	return _get_manager("GameManager") != null

static func is_debug_manager_available() -> bool:
	return _get_manager("DebugManager") != null

# =======================
#  ACCESO DIRECTO A MANAGERS
# =======================
static func get_config_manager() -> Node:
	return _get_manager("ConfigManager")

static func get_input_manager() -> Node:
	return _get_manager("InputManager")

static func get_audio_manager() -> Node:
	return _get_manager("AudioManager")

static func get_game_state_manager() -> Node:
	return _get_manager("GameStateManager")

static func get_game_manager() -> Node:
	return _get_manager("GameManager")

static func get_debug_manager() -> Node:
	return _get_manager("DebugManager")

# =======================
#  VERIFICACIÓN DE ESTADO
# =======================
static func is_manager_ready(manager_name: String) -> bool:
	"""Verifica si un manager está listo"""
	var manager = _get_manager(manager_name)
	if not manager:
		return false
	
	if manager.has_method("is_ready"):
		return manager.is_ready()
	
	return true  # Si no tiene is_ready(), asumimos que está listo

static func get_manager_status(manager_name: String) -> String:
	"""Obtiene el estado de un manager"""
	var manager = _get_manager(manager_name)
	if not manager:
		return "NOT_FOUND"
	
	if manager.has_method("is_ready"):
		return "READY" if manager.is_ready() else "LOADING"
	
	return "FOUND"

# =======================
#  LOGGING CENTRALIZADO
# =======================
static func log_to_debug(message: String, color: String = "white"):
	"""Función centralizada para logging a debug"""
	var debug_manager = _get_manager("DebugManager")
	if debug_manager and debug_manager.has_method("log_to_console"):
		debug_manager.log_to_console(message, color)

static func log_error(message: String):
	log_to_debug("ERROR: " + message, "red")

static func log_warning(message: String):
	log_to_debug("WARNING: " + message, "orange")

static func log_success(message: String):
	log_to_debug("SUCCESS: " + message, "green")

static func log_info(message: String):
	log_to_debug("INFO: " + message, "cyan")

# =======================
#  UTILIDADES DE ESPERA
# =======================
static func wait_for_manager(manager_name: String, max_wait_time: float = 5.0) -> bool:
	"""Espera a que un manager esté listo con timeout"""
	var manager = _get_manager(manager_name)
	if not manager:
		return false
	
	if not manager.has_method("is_ready"):
		return true  # Si no tiene is_ready(), ya está listo
	
	var wait_time = 0.0
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		return false
	
	while not manager.is_ready() and wait_time < max_wait_time:
		await tree.process_frame
		wait_time += 0.016  # Approximate frame time (60 FPS)
	
	return manager.is_ready()

static func wait_for_managers(manager_names: Array[String], max_wait_time: float = 10.0) -> bool:
	"""Espera a múltiples managers con timeout total"""
	var start_time = Time.get_time_dict_from_system()["unix"]
	
	for manager_name in manager_names:
		var current_time = Time.get_time_dict_from_system()["unix"]
		var elapsed = current_time - start_time
		var remaining_time = max_wait_time - elapsed
		
		if remaining_time <= 0:
			return false
		
		if not await wait_for_manager(manager_name, remaining_time):
			return false
	
	return true

# =======================
#  INFORMACIÓN DE SISTEMA
# =======================
static func get_all_managers_status() -> Dictionary:
	"""Obtiene el estado de todos los managers"""
	var managers = [
		"ConfigManager",
		"InputManager", 
		"AudioManager",
		"GameStateManager",
		"GameManager",
		"DebugManager"
	]
	
	var status = {}
	for manager_name in managers:
		status[manager_name] = get_manager_status(manager_name)
	
	return status

static func get_system_info() -> Dictionary:
	"""Obtiene información general del sistema"""
	return {
		"managers_status": get_all_managers_status(),
		"fps": Engine.get_frames_per_second(),
		"resolution": _get_viewport_size(),
		"scene": _get_current_scene_name(),
		"tree_paused": _is_tree_paused()
	}

# =======================
#  FUNCIONES HELPER PRIVADAS
# =======================
static func _get_manager(manager_name: String) -> Node:
	"""Obtiene referencia a un manager"""
	var tree = Engine.get_main_loop() as SceneTree
	if not tree or not tree.root:
		return null
	
	return tree.root.get_node_or_null("/root/" + manager_name)

static func _get_viewport_size() -> Vector2:
	"""Obtiene el tamaño del viewport"""
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		return Vector2.ZERO
	
	var viewport = tree.get_root()
	return viewport.size if viewport else Vector2.ZERO

static func _get_current_scene_name() -> String:
	"""Obtiene el nombre de la escena actual"""
	var tree = Engine.get_main_loop() as SceneTree
	if not tree or not tree.current_scene:
		return "Unknown"
	
	return tree.current_scene.name

static func _is_tree_paused() -> bool:
	"""Verifica si el árbol está pausado"""
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		return false
	
	return tree.paused

# =======================
#  FUNCIONES DE DEBUG
# =======================
static func debug_print_all_managers():
	"""Debug: imprime estado de todos los managers"""
	print("=== MANAGER UTILS DEBUG ===")
	var status = get_all_managers_status()
	
	for manager_name in status.keys():
		var manager_status = status[manager_name]
		print("%s: %s" % [manager_name, manager_status])
	
	print("===========================")

static func debug_test_manager_access():
	"""Debug: prueba acceso a todos los managers"""
	print("=== TESTING MANAGER ACCESS ===")
	
	var managers_to_test = [
		"ConfigManager",
		"InputManager",
		"AudioManager", 
		"GameStateManager",
		"GameManager",
		"DebugManager"
	]
	
	for manager_name in managers_to_test:
		var manager = _get_manager(manager_name)
		var status = "✅ ACCESSIBLE" if manager else "❌ NOT FOUND"
		print("%s: %s" % [manager_name, status])
	
	print("===============================")
