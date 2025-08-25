extends RefCounted
class_name WorldGenerator

# =======================
#  CONFIGURACIÓN BÁSICA DE GENERACIÓN
# =======================
var terrain_noise: FastNoiseLite
var seed_value: int
var terrain_scale: float = 0.1

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
func generate_tile_at_position(world_pos: Vector2i) -> World.TileType:
	"""Genera un tile básico en la posición especificada"""
	
	# Obtener valor de ruido básico
	var noise_value = terrain_noise.get_noise_2d(world_pos.x, world_pos.y)
	
	# Mapear ruido a tipos de tile básicos
	if noise_value < -0.3:
		return World.TileType.WATER  # Agua en valores bajos
	elif noise_value < -0.1:
		return World.TileType.SAND   # Arena en valores medio-bajos
	elif noise_value < 0.2:
		return World.TileType.GRASS  # Pasto en valores medios
	elif noise_value < 0.4:
		return World.TileType.DIRT   # Tierra en valores medio-altos
	else:
		return World.TileType.STONE  # Piedra en valores altos

func generate_chunk_data(chunk_pos: Vector2i, chunk_size: Vector2i) -> Array:
	"""Genera datos para un chunk completo"""
	var chunk_data = []
	
	for y in chunk_size.y:
		for x in chunk_size.x:
			var world_pos = Vector2i(
				chunk_pos.x * chunk_size.x + x,
				chunk_pos.y * chunk_size.y + y
			)
			
			var tile_type = generate_tile_at_position(world_pos)
			
			chunk_data.append({
				"position": Vector2i(x, y),
				"world_position": world_pos,
				"tile_type": tile_type
			})
	
	return chunk_data

func get_terrain_height(world_pos: Vector2i) -> float:
	"""Obtiene la altura del terreno en una posición"""
	return terrain_noise.get_noise_2d(world_pos.x, world_pos.y)

# =======================
#  UTILIDADES
# =======================
func get_seed() -> int:
	return seed_value

func set_seed(new_seed: int):
	seed_value = new_seed
	setup_noise()

func set_scale(new_scale: float):
	terrain_scale = new_scale
	setup_noise()

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
		"tree_density": 0.01,
		"rock_density": 0.15
	},
	BiomeType.MOUNTAINS: {
		"name": "Mountains",
		"primary_tile": World.TileType.STONE,
		"secondary_tiles": [World.TileType.DIRT, World.TileType.ROCK],
		"tree_density": 0.1,
		"rock_density": 0.4
	},
	BiomeType.SWAMP: {
		"name": "Swamp",
		"primary_tile": World.TileType.WATER,
		"secondary_tiles": [World.TileType.DIRT, World.TileType.GRASS],
		"tree_density": 0.2,
		"rock_density": 0.1
	},
	BiomeType.TUNDRA: {
		"name": "Tundra",
		"primary_tile": World.TileType.DIRT,
		"secondary_tiles": [World.TileType.STONE, World.TileType.WATER],
		"tree_density": 0.05,
		"rock_density": 0.2
	}
}

# =======================
#  INICIALIZACIÓN
# =======================
func _init(world_seed: int = 0):
	seed_value = world_seed if world_seed != 0 else randi()
	_setup_noise_generators()
	print("WorldGenerator: Initialized with seed %d" % seed_value)

func _setup_noise_generators():
	"""Configura los diferentes generadores de ruido"""
	# Ruido de terreno base
	terrain_noise = FastNoiseLite.new()
	terrain_noise.seed = seed_value
	terrain_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	terrain_noise.frequency = terrain_scale
	
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

# =======================
#  GENERACIÓN PRINCIPAL
# =======================
func generate_tile_at_position(tile_position: Vector2i) -> World.TileType:
	"""Genera un tile en una posición específica usando múltiples capas de ruido"""
	
	# 1. Determinar bioma
	var biome = _get_biome_at_position(tile_position)
	var biome_config = biome_configs[biome]
	
	# 2. Verificar si es una cueva/hueco
	var cave_value = cave_noise.get_noise_2d(tile_position.x, tile_position.y)
	if cave_value > 0.4:  # Umbral para cuevas
		return World.TileType.WATER  # O un tile especial de cueva
	
	# 3. Generar terreno base según bioma
	var terrain_value = terrain_noise.get_noise_2d(tile_position.x, tile_position.y)
	var base_tile = _get_terrain_tile(terrain_value, biome_config)
	
	# 4. Verificar recursos especiales
	var resource_value = resource_noise.get_noise_2d(tile_position.x, tile_position.y)
	var special_tile = _get_special_feature(resource_value, biome_config, tile_position)
	
	return special_tile if special_tile != World.TileType.GRASS else base_tile

func _get_biome_at_position(tile_position: Vector2i) -> BiomeType:
	"""Determina el bioma en una posición"""
	var biome_value = biome_noise.get_noise_2d(tile_position.x, tile_position.y)
	var temperature = terrain_noise.get_noise_2d(tile_position.x * 0.5, tile_position.y * 0.5)
	var humidity = resource_noise.get_noise_2d(tile_position.x * 0.3, tile_position.y * 0.3)
	
	# Lógica de biomas basada en temperatura y humedad
	if temperature < -0.4:
		return BiomeType.TUNDRA
	elif temperature > 0.4:
		if humidity < -0.2:
			return BiomeType.DESERT
		else:
			return BiomeType.PLAINS
	else:
		if humidity > 0.3:
			return BiomeType.SWAMP
		elif humidity > 0.0:
			return BiomeType.FOREST
		elif biome_value > 0.2:
			return BiomeType.MOUNTAINS
		else:
			return BiomeType.PLAINS

func _get_terrain_tile(terrain_value: float, biome_config: Dictionary) -> World.TileType:
	"""Obtiene el tile de terreno base según el valor de ruido y bioma"""
	var primary_tile = biome_config["primary_tile"]
	var secondary_tiles = biome_config["secondary_tiles"]
	
	# Usar el ruido para variar entre tiles primarios y secundarios
	if terrain_value > 0.2:
		return primary_tile
	elif terrain_value > -0.2 and secondary_tiles.size() > 0:
		var index = int(abs(terrain_value) * secondary_tiles.size()) % secondary_tiles.size()
		return secondary_tiles[index]
	else:
		return primary_tile

func _get_special_feature(resource_value: float, biome_config: Dictionary, position: Vector2i) -> World.TileType:
	"""Determina si hay una característica especial (árbol, roca, etc.)"""
	var tree_density = biome_config["tree_density"]
	var rock_density = biome_config["rock_density"]
	
	# Usar hash de posición para distribución más uniforme
	var position_hash = _hash_position(position)
	
	# Verificar árboles
	if resource_value > (1.0 - tree_density) and position_hash % 100 < (tree_density * 100):
		return World.TileType.TREE
	
	# Verificar rocas
	if resource_value < -(1.0 - rock_density) and position_hash % 100 < (rock_density * 100):
		return World.TileType.ROCK
	
	return World.TileType.GRASS  # Sin característica especial

func _hash_position(position: Vector2i) -> int:
	"""Genera un hash de una posición para distribución determinística"""
	return abs((position.x * 73856093) ^ (position.y * 19349663)) % 1000000

# =======================
#  GENERACIÓN DE ESTRUCTURAS
# =======================
func should_place_structure_at(position: Vector2i) -> String:
	"""Determina si se debe colocar una estructura en esta posición"""
	var structure_noise = terrain_noise.get_noise_2d(position.x * 0.01, position.y * 0.01)
	var position_hash = _hash_position(position)
	
	# Verificar diferentes tipos de estructuras
	if structure_noise > 0.8 and position_hash % 1000 < 5:
		return "village"
	elif structure_noise < -0.8 and position_hash % 1000 < 3:
		return "dungeon"
	elif abs(structure_noise) < 0.1 and position_hash % 1000 < 2:
		return "shrine"
	
	return ""

# =======================
#  UTILIDADES
# =======================
func get_biome_name_at_position(tile_position: Vector2i) -> String:
	"""Obtiene el nombre del bioma en una posición"""
	var biome = _get_biome_at_position(tile_position)
	return biome_configs[biome]["name"]

func set_terrain_scale(new_scale: float):
	"""Cambia la escala del terreno"""
	terrain_scale = new_scale
	terrain_noise.frequency = terrain_scale

func set_cave_density(new_scale: float):
	"""Cambia la densidad de cuevas"""
	cave_scale = new_scale
	cave_noise.frequency = cave_scale

func regenerate_with_seed(new_seed: int):
	"""Regenera con nueva semilla"""
	seed_value = new_seed
	_setup_noise_generators()
	print("WorldGenerator: Regenerated with seed %d" % seed_value)

# =======================
#  DEBUG
# =======================
func debug_generation_info(position: Vector2i) -> Dictionary:
	"""Retorna información de debug sobre la generación en una posición"""
	var biome = _get_biome_at_position(position)
	return {
		"position": position,
		"biome": biome_configs[biome]["name"],
		"terrain_noise": terrain_noise.get_noise_2d(position.x, position.y),
		"cave_noise": cave_noise.get_noise_2d(position.x, position.y),
		"resource_noise": resource_noise.get_noise_2d(position.x, position.y),
		"biome_noise": biome_noise.get_noise_2d(position.x, position.y),
		"generated_tile": generate_tile_at_position(position)
	}
