extends Node

# =======================
#  SISTEMA DE CACHE DE NODOS OPTIMIZADO
# =======================

## Cache global para operaciones find_child() costosas
## Reduce búsquedas recursivas repetitivas de O(n) a O(1)

# =======================
#  CACHE GLOBAL
# =======================

static var cached_nodes: Dictionary = {}
static var cache_access_count: int = 0
static var cache_hit_count: int = 0
static var cache_size_limit: int = 1000

# =======================
#  API PRINCIPAL
# =======================

static func get_node_cached(parent: Node, node_name: String, recursive: bool = true, include_internal: bool = false) -> Node:
	"""Obtiene un nodo con cache optimizado"""
	if not parent:
		return null
	
	var key = _generate_cache_key(parent, node_name, recursive, include_internal)
	cache_access_count += 1
	
	# Verificar cache
	if cached_nodes.has(key):
		var cached_result = cached_nodes[key]
		# Verificar que el nodo sigue siendo válido
		if cached_result and is_instance_valid(cached_result):
			cache_hit_count += 1
			return cached_result
		else:
			# Nodo inválido, remover del cache
			cached_nodes.erase(key)
	
	# Cache miss - buscar nodo
	var found_node = parent.find_child(node_name, recursive, include_internal)
	
	# Guardar en cache si es válido
	if found_node:
		_store_in_cache(key, found_node)
	
	return found_node

static func get_world_cached(scene_root: Node = null) -> Node:
	"""Busca nodo World con cache específico"""
	if not scene_root:
		var tree = Engine.get_main_loop() as SceneTree
		if not tree or not tree.current_scene:
			return null
		scene_root = tree.current_scene
	
	return get_node_cached(scene_root, "World", true, false)

static func get_tilemap_layer_cached(parent: Node) -> TileMapLayer:
	"""Busca TileMapLayer con cache específico"""
	var node = get_node_cached(parent, "TileMapLayer", true, false)
	return node as TileMapLayer

static func get_player_cached(scene_root: Node = null) -> Node:
	"""Busca nodo Player con cache específico"""
	if not scene_root:
		var tree = Engine.get_main_loop() as SceneTree
		if not tree or not tree.current_scene:
			return null
		scene_root = tree.current_scene
	
	return get_node_cached(scene_root, "Player", true, false)

static func get_ui_element_cached(parent: Node, ui_name: String) -> Control:
	"""Busca elemento UI con cache específico"""
	var node = get_node_cached(parent, ui_name, true, false)
	return node as Control

# =======================
#  GESTIÓN DE CACHE
# =======================

static func clear_cache():
	"""Limpia todo el cache"""
	var old_size = cached_nodes.size()
	cached_nodes.clear()
	print("NodeCache: Cleared cache - was %d entries" % old_size)

static func clear_invalid_nodes():
	"""Limpia nodos inválidos del cache"""
	var keys_to_remove = []
	
	for key in cached_nodes.keys():
		var node = cached_nodes[key]
		if not node or not is_instance_valid(node):
			keys_to_remove.append(key)
	
	for key in keys_to_remove:
		cached_nodes.erase(key)
	
	if keys_to_remove.size() > 0:
		print("NodeCache: Removed %d invalid nodes" % keys_to_remove.size())

static func get_cache_stats() -> Dictionary:
	"""Retorna estadísticas del cache"""
	return {
		"cache_size": cached_nodes.size(),
		"cache_limit": cache_size_limit,
		"total_accesses": cache_access_count,
		"cache_hits": cache_hit_count,
		"hit_ratio": float(cache_hit_count) / max(1, cache_access_count),
		"cache_efficiency": "%.1f%%" % (float(cache_hit_count) / max(1, cache_access_count) * 100)
	}

# =======================
#  UTILIDADES PRIVADAS
# =======================

static func _generate_cache_key(parent: Node, node_name: String, recursive: bool, include_internal: bool) -> String:
	"""Genera clave única para el cache"""
	return "%d_%s_%s_%s" % [
		parent.get_instance_id(),
		node_name,
		"r" if recursive else "nr",
		"i" if include_internal else "ni"
	]

static func _store_in_cache(key: String, node: Node):
	"""Almacena nodo en cache con gestión de límites"""
	# Limpiar cache si está lleno
	if cached_nodes.size() >= cache_size_limit:
		_cleanup_cache()
	
	cached_nodes[key] = node

static func _cleanup_cache():
	"""Limpia el cache cuando está lleno"""
	# Estrategia simple: limpiar todo y dejar que se vuelva a llenar
	# En el futuro se podría implementar LRU (Least Recently Used)
	var old_size = cached_nodes.size()
	clear_invalid_nodes()
	
	# Si sigue lleno después de limpiar inválidos, hacer limpieza completa
	if cached_nodes.size() >= cache_size_limit:
		cached_nodes.clear()
		print("NodeCache: Full cleanup - was %d entries" % old_size)

# =======================
#  API DE CONVENIENCIA
# =======================

static func find_manager(manager_name: String) -> Node:
	"""Busca un manager específico en autoload"""
	var tree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null
	
	var root = tree.current_scene
	if not root:
		return null
	
	var manager = root.get_node_or_null("/root/" + manager_name)
	if manager:
		# Cache del manager encontrado
		var key = "manager_" + manager_name
		cached_nodes[key] = manager
	return manager

static func is_manager_available(manager_name: String) -> bool:
	"""Verifica si un manager está disponible"""
	return find_manager(manager_name) != null

# =======================
#  DEBUGGING
# =======================

static func print_cache_stats():
	"""Imprime estadísticas del cache"""
	var stats = get_cache_stats()
	print("=== NODE CACHE STATISTICS ===")
	print("Cache Size: %d/%d" % [stats.cache_size, stats.cache_limit])
	print("Total Accesses: %d" % stats.total_accesses)
	print("Cache Hits: %d" % stats.cache_hits)
	print("Hit Ratio: %s" % stats.cache_efficiency)
	print("============================")

static func debug_cache_contents():
	"""Debug: muestra contenido del cache"""
	print("=== CACHE CONTENTS ===")
	for key in cached_nodes.keys():
		var node = cached_nodes[key]
		var valid = node and is_instance_valid(node)
		print("%s: %s (%s)" % [key, node.name if valid else "INVALID", "✅" if valid else "❌"])
	print("=====================")
