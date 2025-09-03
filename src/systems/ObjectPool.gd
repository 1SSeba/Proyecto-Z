extends Node

# =======================
#  SISTEMA DE OBJECT POOLING OPTIMIZADO
# =======================

## Reutiliza objetos temporales para evitar garbage collection
## Mejora performance reduciendo allocations/deallocations

# =======================
#  POOLS GLOBALES
# =======================

static var tile_data_pool: Array[Dictionary] = []
static var vector2_pool: Array[Vector2] = []
static var vector2i_pool: Array[Vector2i] = []
static var color_pool: Array[Color] = []

static var pool_stats: Dictionary = {
	"tile_data_requests": 0,
	"tile_data_hits": 0,
	"vector2_requests": 0,
	"vector2_hits": 0,
	"vector2i_requests": 0,
	"vector2i_hits": 0,
	"color_requests": 0,
	"color_hits": 0
}

# =======================
#  CONFIGURACIÓN DE POOL
# =======================

const MAX_POOL_SIZE: int = 200
const MIN_POOL_SIZE: int = 50

# =======================
#  API DE TILE DATA
# =======================

static func get_tile_data() -> Dictionary:
	"""Obtiene un Dictionary para TileData del pool"""
	pool_stats.tile_data_requests += 1
	
	if tile_data_pool.size() > 0:
		pool_stats.tile_data_hits += 1
		var tile_data = tile_data_pool.pop_back()
		# Limpiar datos previos
		tile_data.clear()
		return tile_data
	
	# Pool vacío, crear nuevo
	return {}

static func return_tile_data(tile_data: Dictionary):
	"""Retorna un TileData al pool"""
	if tile_data_pool.size() < MAX_POOL_SIZE:
		tile_data.clear()
		tile_data_pool.push_back(tile_data)

static func get_tile_data_batch(count: int) -> Array[Dictionary]:
	"""Obtiene múltiples TileData del pool"""
	var batch: Array[Dictionary] = []
	batch.resize(count)
	
	for i in count:
		batch[i] = get_tile_data()
	
	return batch

static func return_tile_data_batch(batch: Array[Dictionary]):
	"""Retorna múltiples TileData al pool"""
	for tile_data in batch:
		return_tile_data(tile_data)

# =======================
#  API DE VECTOR2
# =======================

static func get_vector2(x: float = 0.0, y: float = 0.0) -> Vector2:
	"""Obtiene un Vector2 del pool"""
	pool_stats.vector2_requests += 1
	
	if vector2_pool.size() > 0:
		pool_stats.vector2_hits += 1
		var vec = vector2_pool.pop_back()
		vec.x = x
		vec.y = y
		return vec
	
	# Pool vacío, crear nuevo
	return Vector2(x, y)

static func return_vector2(vec: Vector2):
	"""Retorna un Vector2 al pool"""
	if vector2_pool.size() < MAX_POOL_SIZE:
		vector2_pool.push_back(vec)

# =======================
#  API DE VECTOR2I
# =======================

static func get_vector2i(x: int = 0, y: int = 0) -> Vector2i:
	"""Obtiene un Vector2i del pool"""
	pool_stats.vector2i_requests += 1
	
	if vector2i_pool.size() > 0:
		pool_stats.vector2i_hits += 1
		var vec = vector2i_pool.pop_back()
		vec.x = x
		vec.y = y
		return vec
	
	# Pool vacío, crear nuevo
	return Vector2i(x, y)

static func return_vector2i(vec: Vector2i):
	"""Retorna un Vector2i al pool"""
	if vector2i_pool.size() < MAX_POOL_SIZE:
		vector2i_pool.push_back(vec)

# =======================
#  API DE COLOR
# =======================

static func get_color(r: float = 1.0, g: float = 1.0, b: float = 1.0, a: float = 1.0) -> Color:
	"""Obtiene un Color del pool"""
	pool_stats.color_requests += 1
	
	if color_pool.size() > 0:
		pool_stats.color_hits += 1
		var color = color_pool.pop_back()
		color.r = r
		color.g = g
		color.b = b
		color.a = a
		return color
	
	# Pool vacío, crear nuevo
	return Color(r, g, b, a)

static func return_color(color: Color):
	"""Retorna un Color al pool"""
	if color_pool.size() < MAX_POOL_SIZE:
		color_pool.push_back(color)

# =======================
#  GESTIÓN DE POOLS
# =======================

static func warm_up_pools():
	"""Pre-llena los pools para evitar allocations iniciales"""
	print("ObjectPool: Warming up pools...")
	
	# Llenar pool de tile_data
	for i in MIN_POOL_SIZE:
		tile_data_pool.push_back({})
	
	# Llenar pool de Vector2
	for i in MIN_POOL_SIZE:
		vector2_pool.push_back(Vector2())
	
	# Llenar pool de Vector2i
	for i in MIN_POOL_SIZE:
		vector2i_pool.push_back(Vector2i())
	
	# Llenar pool de Color
	for i in MIN_POOL_SIZE:
		color_pool.push_back(Color())
	
	print("ObjectPool: Warm-up complete - %d objects per pool" % MIN_POOL_SIZE)

static func clear_pools():
	"""Limpia todos los pools"""
	tile_data_pool.clear()
	vector2_pool.clear()
	vector2i_pool.clear()
	color_pool.clear()
	
	# Reset stats
	for key in pool_stats.keys():
		pool_stats[key] = 0
	
	print("ObjectPool: All pools cleared")

static func trim_pools():
	"""Reduce el tamaño de pools si están muy grandes"""
	var trimmed = false
	
	if tile_data_pool.size() > MAX_POOL_SIZE:
		tile_data_pool.resize(MAX_POOL_SIZE)
		trimmed = true
	
	if vector2_pool.size() > MAX_POOL_SIZE:
		vector2_pool.resize(MAX_POOL_SIZE)
		trimmed = true
	
	if vector2i_pool.size() > MAX_POOL_SIZE:
		vector2i_pool.resize(MAX_POOL_SIZE)
		trimmed = true
	
	if color_pool.size() > MAX_POOL_SIZE:
		color_pool.resize(MAX_POOL_SIZE)
		trimmed = true
	
	if trimmed:
		print("ObjectPool: Pools trimmed to max size %d" % MAX_POOL_SIZE)

# =======================
#  ESTADÍSTICAS
# =======================

static func get_pool_stats() -> Dictionary:
	"""Retorna estadísticas de eficiencia de pools"""
	var stats = {}
	
	# Calcular hit ratios
	stats["tile_data_hit_ratio"] = float(pool_stats.tile_data_hits) / max(1, pool_stats.tile_data_requests)
	stats["vector2_hit_ratio"] = float(pool_stats.vector2_hits) / max(1, pool_stats.vector2_requests)
	stats["vector2i_hit_ratio"] = float(pool_stats.vector2i_hits) / max(1, pool_stats.vector2i_requests)
	stats["color_hit_ratio"] = float(pool_stats.color_hits) / max(1, pool_stats.color_requests)
	
	# Tamaños de pools
	stats["tile_data_pool_size"] = tile_data_pool.size()
	stats["vector2_pool_size"] = vector2_pool.size()
	stats["vector2i_pool_size"] = vector2i_pool.size()
	stats["color_pool_size"] = color_pool.size()
	
	# Stats raw
	stats["raw_stats"] = pool_stats.duplicate()
	
	return stats

static func print_pool_stats():
	"""Imprime estadísticas de pools"""
	var stats = get_pool_stats()
	
	print("=== OBJECT POOL STATISTICS ===")
	print("TileData Hit Ratio: %.1f%%" % (stats.tile_data_hit_ratio * 100))
	print("Vector2 Hit Ratio: %.1f%%" % (stats.vector2_hit_ratio * 100))
	print("Vector2i Hit Ratio: %.1f%%" % (stats.vector2i_hit_ratio * 100))
	print("Color Hit Ratio: %.1f%%" % (stats.color_hit_ratio * 100))
	print("Pool Sizes: TD=%d, V2=%d, V2i=%d, C=%d" % [
		stats.tile_data_pool_size,
		stats.vector2_pool_size, 
		stats.vector2i_pool_size,
		stats.color_pool_size
	])
	print("==============================")

# =======================
#  UTILIDADES DE CONVENIENCIA
# =======================

static func create_tile_data_from_pool(position: Vector2i, tile_type: int) -> Dictionary:
	"""Crea un TileData completo desde el pool"""
	var tile_data = get_tile_data()
	tile_data["position"] = position
	tile_data["tile_type"] = tile_type
	return tile_data

static func get_temp_rect(x: float, y: float, w: float, h: float) -> Rect2:
	"""Obtiene un Rect2 temporal usando vectors del pool"""
	var pos = get_vector2(x, y)
	var size = get_vector2(w, h)
	return Rect2(pos, size)

static func return_temp_rect(rect: Rect2):
	"""Retorna los vectors de un Rect2 temporal al pool"""
	return_vector2(rect.position)
	return_vector2(rect.size)
