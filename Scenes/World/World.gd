extends Node2D
class_name World

# =======================
#  SEÑALES
# =======================
signal world_generated
signal chunk_loaded(chunk_position: Vector2i)

# =======================
#  CONFIGURACIÓN BÁSICA
# =======================
@export_group("World Settings")
@export var world_size: Vector2i = Vector2i(50, 50)    # Tamaño del mundo en chunks (reducido)
@export var chunk_size: Vector2i = Vector2i(16, 16)    # Tamaño de cada chunk en tiles
@export var tile_size: int = 32                        # Tamaño de cada tile en pixels

@export_group("Generation Settings")
@export var seed_value: int = 0                        # Semilla para generación
@export var noise_scale: float = 0.1                  # Escala del ruido
@export var auto_generate: bool = true                 # Generar automáticamente al iniciar

# =======================
#  REFERENCIAS DE NODOS
# =======================
@onready var tilemap_layer: TileMapLayer = $TileMapLayer

# =======================
#  VARIABLES DE GENERACIÓN
# =======================
var world_generator: WorldGenerator
var generated_chunks: Dictionary = {}  # Chunks ya generados
var current_seed: int
var is_generating: bool = false

# =======================
#  TIPOS DE TILE BÁSICOS
# =======================
enum TileType {
	GRASS = 0,    # Pasto básico
	DIRT = 1,     # Tierra
	STONE = 2,    # Piedra
	WATER = 3,    # Agua
	SAND = 4      # Arena
}

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("World: Initializing basic world system...")
	
	# Configurar generador básico
	_setup_basic_generator()
	
	# Configurar el tilemap
	_setup_tilemap()
	
	# Generar mundo inicial si está habilitado
	if auto_generate:
		generate_basic_world()
	
	print("World: Basic world ready!")

func _setup_basic_generator():
	"""Configura el generador básico de mundo"""
	# Usar semilla específica o generar una aleatoria
	if seed_value == 0:
		current_seed = randi()
	else:
		current_seed = seed_value
	
	# Crear el generador básico
	world_generator = WorldGenerator.new(current_seed)
	world_generator.set_scale(noise_scale)
	
func _setup_tilemap():
	"""Configura el TileMapLayer básico"""
	if not tilemap_layer:
		print("World: ERROR - TileMapLayer not found!")
		return
	
	# Verificar si existe TileSet asignado
	if not tilemap_layer.tile_set:
		print("World: WARNING - No TileSet assigned to TileMapLayer")
		print("World: You need to assign a TileSet resource in the editor")
		return
	
	print("World: TileMapLayer configured with TileSet")

# =======================
#  GENERACIÓN BÁSICA DE MUNDO
# =======================
func generate_basic_world():
	"""Genera un mundo básico simple"""
	if is_generating:
		print("World: Already generating...")
		return
	
	if not tilemap_layer.tile_set:
		print("World: Cannot generate - No TileSet assigned!")
		return
	
	print("World: Starting basic world generation...")
	is_generating = true
	
	# Generar un área pequeña alrededor del centro
	var center_chunk = Vector2i(0, 0)
	var radius = 3  # Generar 7x7 chunks alrededor del centro
	
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var chunk_pos = center_chunk + Vector2i(x, y)
			generate_basic_chunk(chunk_pos)
	
	is_generating = false
	world_generated.emit()
	print("World: Basic world generation complete!")

func generate_basic_chunk(chunk_pos: Vector2i):
	"""Genera un chunk básico"""
	if generated_chunks.has(chunk_pos):
		return  # Ya generado
	
	# Obtener datos del chunk desde el generador
	var chunk_data = world_generator.generate_chunk_data(chunk_pos, chunk_size)
	
	# Colocar tiles en el TileMapLayer
	for tile_data in chunk_data:
		var local_pos = tile_data.position
		var world_pos = tile_data.world_position
		var tile_type = tile_data.tile_type
		
		# Calcular posición en el tilemap
		var tilemap_pos = Vector2i(
			chunk_pos.x * chunk_size.x + local_pos.x,
			chunk_pos.y * chunk_size.y + local_pos.y
		)
		
		# Colocar tile (source_id corresponde al TileType)
		tilemap_layer.set_cell(0, tilemap_pos, tile_type, Vector2i(0, 0))
	
	# Marcar chunk como generado
	generated_chunks[chunk_pos] = true
	chunk_loaded.emit(chunk_pos)

# =======================
#  UTILIDADES BÁSICAS
# =======================
func get_tile_at_position(world_pos: Vector2i) -> TileType:
	"""Obtiene el tipo de tile en una posición específica"""
	return world_generator.generate_tile_at_position(world_pos)

func regenerate_world():
	"""Regenera el mundo con una nueva semilla"""
	clear_world()
	current_seed = randi()
	world_generator.set_seed(current_seed)
	generate_basic_world()

func clear_world():
	"""Limpia el mundo actual"""
	tilemap_layer.clear()
	generated_chunks.clear()
# =======================
#  GETTERS Y INFORMACIÓN
# =======================
func get_world_size() -> Vector2i:
	"""Obtiene el tamaño del mundo en chunks"""
	return world_size

func get_chunk_size() -> Vector2i:
	"""Obtiene el tamaño de chunk en tiles"""
	return chunk_size

func get_current_seed() -> int:
	"""Obtiene la semilla actual"""
	return current_seed

func get_generated_chunks_count() -> int:
	"""Obtiene la cantidad de chunks generados"""
	return generated_chunks.size()

func is_chunk_generated(chunk_pos: Vector2i) -> bool:
	"""Verifica si un chunk ya fue generado"""
	return generated_chunks.has(chunk_pos)

# =======================
#  DEBUG Y TESTING
# =======================
func debug_info():
	"""Muestra información de debug del mundo"""
	print("=== WORLD DEBUG INFO ===")
	print("World Size: %s" % world_size)
	print("Chunk Size: %s" % chunk_size)
	print("Current Seed: %d" % current_seed)
	print("Generated Chunks: %d" % generated_chunks.size())
	print("Is Generating: %s" % is_generating)
	print("TileSet Assigned: %s" % (tilemap_layer.tile_set != null))
	print("========================")
