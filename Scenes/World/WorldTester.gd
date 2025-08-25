extends RefCounted
class_name WorldTester

# =======================
#  COMANDOS BÁSICOS DE TESTING
# =======================

static func help() -> String:
	"""Muestra comandos disponibles para testing básico"""
	print("=== WORLD TESTER - BASIC COMMANDS ===")
	print("WorldTester.help()                    - Show this help")
	print("WorldTester.test_basic_generation()   - Test basic world generation")
	print("WorldTester.show_world_info()         - Show world information")
	print("WorldTester.regenerate_world()        - Regenerate world with new seed")
	print("WorldTester.clear_world()             - Clear current world")
	print("WorldTester.benchmark_basic()         - Basic performance test")
	print("=====================================")
	return "Help displayed in console"

static func test_basic_generation() -> String:
	"""Test básico de generación de mundo"""
	var world = _get_world()
	if not world:
		return "ERROR: No World found in scene"
	
	print("=== TESTING BASIC GENERATION ===")
	world.regenerate_world()
	
	await Engine.get_main_loop().process_frame
	
	print("Generated chunks: %d" % world.get_generated_chunks_count())
	print("World seed: %d" % world.get_current_seed())
	print("================================")
	return "Basic generation test completed"

static func show_world_info() -> String:
	"""Muestra información del mundo actual"""
	var world = _get_world()
	if not world:
		return "ERROR: No World found in scene"
	
	world.debug_info()
	return "World info displayed in console"

static func regenerate_world() -> String:
	"""Regenera el mundo con nueva semilla"""
	var world = _get_world()
	if not world:
		return "ERROR: No World found in scene"
	
	print("Regenerating world...")
	world.regenerate_world()
	return "World regenerated with new seed: %d" % world.get_current_seed()

static func clear_world() -> String:
	"""Limpia el mundo actual"""
	var world = _get_world()
	if not world:
		return "ERROR: No World found in scene"
	
	world.clear_world()
	return "World cleared"

static func benchmark_basic() -> String:
	"""Test básico de performance"""
	var world = _get_world()
	if not world:
		return "ERROR: No World found in scene"
	
	print("=== BASIC BENCHMARK ===")
	var start_time = Time.get_time_dict_from_system()
	
	# Test generation speed
	world.clear_world()
	world.regenerate_world()
	
	var end_time = Time.get_time_dict_from_system()
	var elapsed = (end_time.hour * 3600 + end_time.minute * 60 + end_time.second) - \
	              (start_time.hour * 3600 + start_time.minute * 60 + start_time.second)
	
	print("Generation time: ~%d seconds" % elapsed)
	print("Generated chunks: %d" % world.get_generated_chunks_count())
	print("FPS: %d" % Engine.get_frames_per_second())
	print("======================")
	return "Benchmark completed"

# =======================
#  UTILIDADES
# =======================
static func _get_world() -> World:
	"""Obtiene referencia al World en la escena"""
	var tree = Engine.get_main_loop() as SceneTree
	if not tree or not tree.current_scene:
		return null
	
	# Buscar World en la escena actual
	var world = tree.current_scene.find_child("World", true, false)
	return world as World

static func _find_world_recursive(node: Node) -> World:
	"""Busca recursivamente un nodo World"""
	if node is World:
		return node
	
	for child in node.get_children():
		var result = _find_world_recursive(child)
		if result:
			return result
	
	return null

# =======================
#  COMANDOS DE TESTING
# =======================
static func test_basic_generation():
	"""Test básico de generación"""
	if not _check_world():
		return
	
	print("=== BASIC GENERATION TEST ===")
	world_node.debug_info()
	world_node.generate_world()

static func test_regenerate():
	"""Test de regeneración con nueva semilla"""
	if not _check_world():
		return
	
	print("=== REGENERATION TEST ===")
	var old_seed = world_node.current_seed
	world_node.regenerate_world()
	print("Regenerated: %d -> %d" % [old_seed, world_node.current_seed])

static func test_chunk_loading(x: int = 0, y: int = 0):
	"""Test de carga de chunks específicos"""
	if not _check_world():
		return
	
	print("=== CHUNK LOADING TEST ===")
	var world_pos = Vector2(x * 100, y * 100)  # Posición en el mundo
	world_node.load_chunks_around_position(world_pos)
	print("Loaded chunks around world position: %s" % str(world_pos))

static func test_biome_info(x: int = 0, y: int = 0):
	"""Test de información de biomas"""
	if not _check_world():
		return
	
	print("=== BIOME INFO TEST ===")
	var world_pos = Vector2(x, y)
	var biome = world_node.get_biome_at_position(world_pos)
	var gen_info = world_node.get_generation_info_at_position(world_pos)
	
	print("Position: %s" % str(world_pos))
	print("Biome: %s" % biome)
	print("Generation Info:")
	for key in gen_info.keys():
		print("  %s: %s" % [key, str(gen_info[key])])

static func test_seed_change(new_seed: int):
	"""Test de cambio de semilla"""
	if not _check_world():
		return
	
	print("=== SEED CHANGE TEST ===")
	print("Changing seed to: %d" % new_seed)
	world_node.set_seed(new_seed)
	world_node.clear_world()
	world_node.generate_world()

static func test_noise_scale(new_scale: float):
	"""Test de cambio de escala de ruido"""
	if not _check_world():
		return
	
	print("=== NOISE SCALE TEST ===")
	print("Changing noise scale to: %.3f" % new_scale)
	world_node.set_noise_scale(new_scale)
	world_node.clear_world()
	world_node.generate_world()

static func test_cave_density(density: float):
	"""Test de cambio de densidad de cuevas"""
	if not _check_world():
		return
	
	print("=== CAVE DENSITY TEST ===")
	print("Changing cave density to: %.3f" % density)
	world_node.set_cave_density(density)
	world_node.clear_world()
	world_node.generate_world()

static func test_performance(chunk_count: int = 10):
	"""Test de rendimiento generando múltiples chunks"""
	if not _check_world():
		return
	
	print("=== PERFORMANCE TEST ===")
	print("Generating %d chunks..." % chunk_count)
	
	var start_time = Time.get_time_dict_from_system()
	
	for i in range(chunk_count):
		var chunk_pos = Vector2i(i % 5, i / 5)
		world_node.generate_chunk(chunk_pos)
	
	var end_time = Time.get_time_dict_from_system()
	print("Generation completed!")
	print("Chunks generated: %d" % world_node.generated_chunks.size())

static func clear_world():
	"""Limpia el mundo actual"""
	if not _check_world():
		return
	
	print("=== CLEARING WORLD ===")
	world_node.clear_world()
	print("World cleared!")

# =======================
#  COMANDOS DE DEBUG VISUAL
# =======================
static func generate_test_pattern():
	"""Genera un patrón de test"""
	if not _check_world():
		return
	
	print("=== GENERATING TEST PATTERN ===")
	world_node.clear_world()
	
	# Generar patrón específico para visualizar diferentes tiles
	for x in range(-5, 6):
		for y in range(-5, 6):
			var chunk_pos = Vector2i(x, y)
			world_node.generate_chunk(chunk_pos)
	
	print("Test pattern generated!")

static func inspect_position(x: int, y: int):
	"""Inspecciona una posición específica"""
	if not _check_world():
		return
	
	print("=== POSITION INSPECTION ===")
	var world_pos = Vector2(x, y)
	var tile_pos = world_node.tilemap_layer.local_to_map(world_pos)
	var chunk_pos = world_node.world_position_to_chunk(world_pos)
	
	print("World Position: %s" % str(world_pos))
	print("Tile Position: %s" % str(tile_pos))
	print("Chunk Position: %s" % str(chunk_pos))
	print("Chunk Generated: %s" % world_node.is_chunk_generated(chunk_pos))
	
	if world_node.tilemap_layer.get_cell_source_id(tile_pos) != -1:
		var source_id = world_node.tilemap_layer.get_cell_source_id(tile_pos)
		var atlas_coords = world_node.tilemap_layer.get_cell_atlas_coords(tile_pos)
		print("Tile Data - Source: %d, Atlas: %s" % [source_id, str(atlas_coords)])
	else:
		print("No tile at this position")

# =======================
#  UTILIDADES
# =======================
static func _check_world() -> bool:
	"""Verifica que el mundo esté disponible"""
	if not world_node:
		setup_world_testing()
	
	if not world_node:
		print("ERROR: No World node available for testing")
		return false
	
	return true

static func help():
	"""Muestra comandos disponibles"""
	print("=== WORLD TESTER COMMANDS ===")
	print("WorldTester.test_basic_generation() - Generate world")
	print("WorldTester.test_regenerate() - Regenerate with new seed")
	print("WorldTester.test_chunk_loading(x, y) - Load chunks around position")
	print("WorldTester.test_biome_info(x, y) - Show biome info at position")
	print("WorldTester.test_seed_change(seed) - Change seed and regenerate")
	print("WorldTester.test_noise_scale(scale) - Change noise scale")
	print("WorldTester.test_cave_density(density) - Change cave density")
	print("WorldTester.test_performance(count) - Performance test")
	print("WorldTester.generate_test_pattern() - Generate test pattern")
	print("WorldTester.inspect_position(x, y) - Inspect specific position")
	print("WorldTester.clear_world() - Clear current world")
	print("WorldTester.help() - Show this help")
	print("=============================")

# Inicialización automática
func _ready():
	setup_world_testing()
