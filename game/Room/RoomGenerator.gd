extends RefCounted
class_name WorldGenerator

# =======================
#  CONFIGURACIÓN BÁSICA DE GENERACIÓN
# =======================
var terrain_noise: FastNoiseLite
var seed_value: int
var terrain_scale: float = 0.1

# Tipos de tile locales para este generador (no dependen de World.TileType)
enum TerrainTileType {
	WATER,
	SAND,
	GRASS,
	DIRT,
	STONE
}

# Cache de optimización de ruido
var noise_cache: Dictionary = {}
var cache_size_limit: int = 5000
var cache_hits: int = 0
var cache_misses: int = 0

# =======================
#  INICIALIZACIÓN
# =======================
func _init(p_seed: int = 0):
	seed_value = p_seed if p_seed != 0 else randi()
	setup_noise()

func setup_noise():
	# Configurar ruido básico para terreno
	terrain_noise = FastNoiseLite.new()
	terrain_noise.seed = seed_value
	terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	terrain_noise.frequency = terrain_scale
	terrain_noise.fractal_octaves = 3
	terrain_noise.fractal_gain = 0.5
	terrain_noise.fractal_lacunarity = 2.0
	
	print("WorldGenerator: Setup with seed %d" % seed_value)

# =======================
#  GENERACIÓN BÁSICA
# =======================
func generate_tile_at_position(world_pos: Vector2i) -> int:
	"""Genera un tile básico en la posición especificada"""
	
	# Obtener valor de ruido básico con cache
	var noise_value = get_cached_noise(world_pos)
	
	# Mapear ruido a tipos de tile básicos
	if noise_value < -0.3:
		return TerrainTileType.WATER  # Agua en valores bajos
	elif noise_value < -0.1:
		return TerrainTileType.SAND   # Arena en valores medio-bajos
	elif noise_value < 0.2:
		return TerrainTileType.GRASS  # Pasto en valores medios
	elif noise_value < 0.4:
		return TerrainTileType.DIRT   # Tierra en valores medio-altos
	else:
		return TerrainTileType.STONE  # Piedra en valores altos

func get_cached_noise(pos: Vector2i) -> float:
	"""Obtiene valor de ruido con cache para optimización"""
	var key = "%d,%d" % [pos.x, pos.y]
	
	if noise_cache.has(key):
		cache_hits += 1
		return noise_cache[key]
	
	# Cache miss - calcular y guardar
	cache_misses += 1
	var noise_value = terrain_noise.get_noise_2d(pos.x, pos.y)
	
	# Limpiar cache si está lleno
	if noise_cache.size() >= cache_size_limit:
		clear_noise_cache()
	
	noise_cache[key] = noise_value
	return noise_value

func clear_noise_cache():
	"""Limpia el cache de ruido manteniendo estadísticas"""
	var old_size = noise_cache.size()
	noise_cache.clear()
	print("WorldGenerator: Cache cleared - was %d entries, hits: %d, misses: %d" % [old_size, cache_hits, cache_misses])

func generate_chunk_data(chunk_pos: Vector2i, chunk_size: Vector2i) -> Array:
	"""Genera datos para un chunk completo optimizado"""
	var chunk_data = []
	chunk_data.resize(chunk_size.x * chunk_size.y)
	
	var index = 0
	for y in range(chunk_size.y):
		for x in range(chunk_size.x):
			var world_pos = Vector2i(
				chunk_pos.x * chunk_size.x + x,
				chunk_pos.y * chunk_size.y + y
			)
			
			var tile_type = generate_tile_at_position(world_pos)
			
			# Crear tile_data optimizado (reutilizamos Dictionary simple por ahora)
			chunk_data[index] = {
				"position": Vector2i(x, y),
				"world_position": world_pos,
				"tile_type": tile_type
			}
			index += 1
	
	return chunk_data

func get_terrain_height(world_pos: Vector2i) -> float:
	"""Obtiene la altura del terreno en una posición"""
	return get_cached_noise(world_pos)

func get_cache_stats() -> Dictionary:
	"""Retorna estadísticas del cache para debugging"""
	return {
		"cache_size": noise_cache.size(),
		"cache_limit": cache_size_limit,
		"cache_hits": cache_hits,
		"cache_misses": cache_misses,
		"hit_ratio": float(cache_hits) / max(1, cache_hits + cache_misses)
	}

# =======================
#  UTILIDADES
# =======================
func get_seed() -> int:
	return seed_value

func set_seed(new_seed: int):
	seed_value = new_seed
	setup_noise()
	# Limpiar cache cuando cambia la semilla
	clear_noise_cache()

func set_scale(new_scale: float):
	terrain_scale = new_scale
	setup_noise()
	# Limpiar cache cuando cambia la escala
	clear_noise_cache()

# =======================
#  DEBUG
# =======================
func get_noise_info() -> Dictionary:
	"""Información del ruido para debugging"""
	return {
		"seed": seed_value,
		"scale": terrain_scale,
		"type": "Perlin",
		"octaves": 3
	}

# =======================
#  CONFIGURACIÓN AVANZADA
# =======================
# Variables adicionales para generación compleja
var cave_noise: FastNoiseLite
var resource_noise: FastNoiseLite
var biome_noise: FastNoiseLite

var cave_scale: float = 0.3
var resource_scale: float = 0.2
var biome_scale: float = 0.05

# Tipos de biomas
enum BiomeType {
	PLAINS,
	FOREST,
	DESERT,
	MOUNTAINS,
	SWAMP,
	TUNDRA
}

# Configuración de biomas
var biome_configs = {
	BiomeType.PLAINS: {
		"name": "Plains",
		"primary_tile": TerrainTileType.GRASS,
		"secondary_tiles": [TerrainTileType.DIRT],
		"tree_density": 0.05,
		"rock_density": 0.1
	},
	BiomeType.FOREST: {
		"name": "Forest",
		"primary_tile": TerrainTileType.GRASS,
		"secondary_tiles": [TerrainTileType.DIRT],
		"tree_density": 0.3,
		"rock_density": 0.05
	},
	BiomeType.DESERT: {
		"name": "Desert",
		"primary_tile": TerrainTileType.SAND,
		"secondary_tiles": [TerrainTileType.STONE],
		"tree_density": 0.01,
		"rock_density": 0.15
	},
	BiomeType.MOUNTAINS: {
		"name": "Mountains",
		"primary_tile": TerrainTileType.STONE,
		"secondary_tiles": [TerrainTileType.DIRT],
		"tree_density": 0.1,
		"rock_density": 0.4
	},
	BiomeType.SWAMP: {
		"name": "Swamp",
		"primary_tile": TerrainTileType.WATER,
		"secondary_tiles": [TerrainTileType.DIRT, TerrainTileType.GRASS],
		"tree_density": 0.2,
		"rock_density": 0.1
	},
	BiomeType.TUNDRA: {
		"name": "Tundra",
		"primary_tile": TerrainTileType.DIRT,
		"secondary_tiles": [TerrainTileType.STONE, TerrainTileType.WATER],
		"tree_density": 0.05,
		"rock_density": 0.2
	}
}

func setup_advanced_noise():
	"""Configura generadores de ruido adicionales"""
	# Ruido para cuevas/huecos
	cave_noise = FastNoiseLite.new()
	cave_noise.seed = seed_value + 1000
	cave_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	cave_noise.frequency = cave_scale
	
	# Ruido para recursos
	resource_noise = FastNoiseLite.new()
	resource_noise.seed = seed_value + 2000
	resource_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	resource_noise.frequency = resource_scale
	
	# Ruido para biomas
	biome_noise = FastNoiseLite.new()
	biome_noise.seed = seed_value + 3000
	biome_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	biome_noise.frequency = biome_scale
