extends Node2D
class_name WorldTester

# =======================
#  REFERENCIAS
# =======================
@onready var world: World = $"../World"
var debug_visualizer: RoguelikeDebugVisualizer

# =======================
#  CONFIGURACIÓN DE TESTS
# =======================
var test_results: Dictionary = {}
var current_test_suite: String = ""

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("WorldTester: Initializing roguelike world tester...")
	
	# Esperar un frame para que World esté listo
	await get_tree().process_frame
	
	if not world:
		world = get_parent().get_node("World") as World
	
	if world:
		world.world_generated.connect(_on_world_generated)
		print("WorldTester: Connected to World system")
		
		# Configurar debug visualizer si existe
		_setup_debug_visualizer()
	else:
		push_error("WorldTester: World node not found!")

func _setup_debug_visualizer():
	"""Configura el debug visualizer"""
	debug_visualizer = world.get_node("RoguelikeDebugVisualizer") as RoguelikeDebugVisualizer
	if not debug_visualizer:
		# Crear debug visualizer si no existe
		debug_visualizer = RoguelikeDebugVisualizer.new()
		world.add_child(debug_visualizer)
		print("WorldTester: Created debug visualizer")

func _on_world_generated():
	"""Se ejecuta cuando se genera un mundo"""
	print("WorldTester: World generated, running automatic tests...")
	run_all_tests()

# =======================
#  INPUT HANDLING
# =======================
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F7:
				run_generation_benchmark()
			KEY_F8:
				test_different_sizes()
			KEY_F9:
				run_all_tests()
			KEY_F10:
				if debug_visualizer:
					debug_visualizer.toggle_debug()
			KEY_F11:
				world.regenerate_world()
			KEY_F12:
				print_detailed_dungeon_info()

# =======================
#  TEST SUITES
# =======================
func run_all_tests():
	"""Ejecuta todos los tests disponibles"""
	print("\n=== STARTING COMPREHENSIVE ROGUELIKE TESTS ===")
	current_test_suite = "Comprehensive"
	test_results.clear()
	
	# Tests básicos
	test_world_initialization()
	test_dungeon_generation()
	test_room_connectivity()
	test_room_types()
	
	# Tests de performance
	run_generation_benchmark()
	
	# Resumen final
	print_test_summary()

func test_world_initialization():
	"""Test de inicialización del mundo"""
	print("\n--- Testing World Initialization ---")
	var start_time = Time.get_unix_time_from_system()
	
	var tests = {
		"World node exists": world != null,
		"TileMapLayer exists": world.tilemap_layer != null,
		"TileSet assigned": world.tilemap_layer != null and world.tilemap_layer.tile_set != null,
		"Room generator exists": world.room_generator != null
	}
	
	for test_name in tests:
		var result = tests[test_name]
		var status = "✅ PASS" if result else "❌ FAIL"
		print("%s: %s" % [test_name, status])
		test_results[test_name] = result
	
	var elapsed = Time.get_unix_time_from_system() - start_time
	print("Initialization tests completed in %.3fs" % elapsed)

func test_dungeon_generation():
	"""Test de generación de dungeon"""
	print("\n--- Testing Dungeon Generation ---")
	var start_time = Time.get_unix_time_from_system()
	
	if not world or not world.room_generator:
		print("❌ Cannot test - World not properly initialized")
		return
	
	var dungeon_info = world.get_dungeon_info()
	
	var tests = {
		"Rooms generated": dungeon_info.get("room_count", 0) > 0,
		"Connections exist": dungeon_info.get("connection_count", 0) > 0,
		"Has start room": _has_room_type(RoomBasedWorldGenerator.RoomType.START),
		"Has boss room": _has_room_type(RoomBasedWorldGenerator.RoomType.BOSS),
		"Minimum room count": dungeon_info.get("room_count", 0) >= 8,
		"Reasonable room count": dungeon_info.get("room_count", 0) <= 50
	}
	
	for test_name in tests:
		var result = tests[test_name]
		var status = "✅ PASS" if result else "❌ FAIL"
		print("%s: %s" % [test_name, status])
		test_results[test_name] = result
	
	var elapsed = Time.get_unix_time_from_system() - start_time
	print("Generation tests completed in %.3fs" % elapsed)

func test_room_connectivity():
	"""Test de conectividad de rooms"""
	print("\n--- Testing Room Connectivity ---")
	var start_time = Time.get_unix_time_from_system()
	
	if not world.current_dungeon_data.has("rooms"):
		print("❌ Cannot test connectivity - No dungeon data")
		return
	
	var rooms = world.current_dungeon_data.rooms as Array[RoomBasedWorldGenerator.Room]
	var connectivity_tests = _analyze_connectivity(rooms)
	
	for test_name in connectivity_tests:
		var result = connectivity_tests[test_name]
		var status = "✅ PASS" if result else "❌ FAIL"
		print("%s: %s" % [test_name, status])
		test_results[test_name] = result
	
	var elapsed = Time.get_unix_time_from_system() - start_time
	print("Connectivity tests completed in %.3fs" % elapsed)

func test_room_types():
	"""Test de tipos de rooms"""
	print("\n--- Testing Room Types ---")
	var start_time = Time.get_unix_time_from_system()
	
	var dungeon_info = world.get_dungeon_info()
	var room_types = dungeon_info.get("room_types", {})
	
	var type_tests = {
		"Has START room": room_types.get("START", 0) == 1,
		"Has BOSS room": room_types.get("BOSS", 0) >= 1,
		"Has NORMAL rooms": room_types.get("NORMAL", 0) > 0,
		"Has variety": room_types.keys().size() >= 3
	}
	
	for test_name in type_tests:
		var result = type_tests[test_name]
		var status = "✅ PASS" if result else "❌ FAIL"
		print("%s: %s" % [test_name, status])
		test_results[test_name] = result
	
	print("Room type distribution: %s" % room_types)
	
	var elapsed = Time.get_unix_time_from_system() - start_time
	print("Room type tests completed in %.3fs" % elapsed)

func run_generation_benchmark():
	"""Benchmark de generación de mundos"""
	print("\n--- Running Generation Benchmark ---")
	var start_time = Time.get_unix_time_from_system()
	
	var benchmark_results = {}
	var sizes = [
		RoomBasedWorldGenerator.DungeonSize.SMALL,
		RoomBasedWorldGenerator.DungeonSize.MEDIUM,
		RoomBasedWorldGenerator.DungeonSize.LARGE
	]
	
	for size in sizes:
		var size_name = RoomBasedWorldGenerator.DungeonSize.keys()[size]
		print("Benchmarking %s dungeons..." % size_name)
		
		var total_time = 0.0
		var iterations = 3
		var room_counts = []
    
		for i in range(iterations):
			var gen_start = Time.get_unix_time_from_system()
			
			# Generar dungeon de tamaño específico
			world.dungeon_size = size
			world._setup_room_generator()
			world.generate_new_dungeon()
			
			var gen_end = Time.get_unix_time_from_system()
			var duration = gen_end - gen_start
			total_time += duration
			
			var info = world.get_dungeon_info()
			room_counts.append(info.get("room_count", 0))
			
			print("  Iteration %d: %.3fs, %d rooms" % [i + 1, duration, info.get("room_count", 0)])
		
		var avg_time = float(total_time) / float(iterations)
		var avg_rooms = float(room_counts.reduce(func(a, b): return a + b)) / float(iterations)
		
		benchmark_results[size_name] = {
			"avg_time": avg_time,
			"avg_rooms": avg_rooms,
			"total_time": total_time
		}
		
		print("%s average: %.3fs, %.1f rooms" % [size_name, avg_time, avg_rooms])
	
	# Restaurar tamaño original
	world.dungeon_size = RoomBasedWorldGenerator.DungeonSize.MEDIUM
	world._setup_room_generator()
	world.generate_new_dungeon()
	
	var elapsed = Time.get_unix_time_from_system() - start_time
	print("Benchmark completed in %.3fs" % elapsed)
	
	return benchmark_results

func test_different_sizes():
	"""Test de diferentes tamaños de dungeon"""
	print("\n--- Testing Different Dungeon Sizes ---")
	
	var original_size = world.dungeon_size
	
	# Test small
	print("Testing SMALL dungeon...")
	world.generate_small_dungeon()
	_print_size_info("SMALL")
	
	# Test medium
	print("Testing MEDIUM dungeon...")
	world.generate_medium_dungeon()
	_print_size_info("MEDIUM")
	
	# Test large
	print("Testing LARGE dungeon...")
	world.generate_large_dungeon()
	_print_size_info("LARGE")
	
	# Restaurar tamaño original
	world.dungeon_size = original_size
	world._setup_room_generator()
	world.generate_new_dungeon()

# =======================
#  HELPER FUNCTIONS
# =======================
func _has_room_type(room_type: RoomBasedWorldGenerator.RoomType) -> bool:
	"""Verifica si existe una room del tipo especificado"""
	if not world.current_dungeon_data.has("rooms"):
		return false
	
	var rooms = world.current_dungeon_data.rooms as Array[RoomBasedWorldGenerator.Room]
	for room in rooms:
		if room.type == room_type:
			return true
	return false

func _analyze_connectivity(rooms: Array[RoomBasedWorldGenerator.Room]) -> Dictionary:
	"""Analiza la conectividad del dungeon"""
	var results = {}
	
	# Verificar que todas las rooms tengan al menos una conexión
	var isolated_rooms = 0
	var total_connections = 0
	
	for room in rooms:
		if room.connections.size() == 0:
			isolated_rooms += 1
		total_connections += room.connections.size()
	
	results["No isolated rooms"] = isolated_rooms == 0
	results["Reasonable connectivity"] = (float(total_connections) / 2.0) >= (rooms.size() - 1)  # Dividir por 2 porque las conexiones se cuentan doble
	results["Has start room connections"] = _room_has_connections(rooms, RoomBasedWorldGenerator.RoomType.START)
	results["Has boss room connections"] = _room_has_connections(rooms, RoomBasedWorldGenerator.RoomType.BOSS)
	
	return results

func _room_has_connections(rooms: Array[RoomBasedWorldGenerator.Room], room_type: RoomBasedWorldGenerator.RoomType) -> bool:
	"""Verifica si una room de tipo específico tiene conexiones"""
	for room in rooms:
		if room.type == room_type:
			return room.connections.size() > 0
	return false

func _print_size_info(size_name: String):
	"""Imprime información de un tamaño de dungeon"""
	var info = world.get_dungeon_info()
	print("  %s: %d rooms, %d connections, map size %s" % [
		size_name,
		info.get("room_count", 0),
		info.get("connection_count", 0),
		info.get("map_size", Vector2i.ZERO)
	])

func print_test_summary():
	"""Imprime resumen de todos los tests"""
	print("\n=== TEST SUMMARY ===")
	var passed = 0
	var total = test_results.size()
	
	for test_name in test_results:
		var result = test_results[test_name]
		var status = "✅" if result else "❌"
		print("%s %s" % [status, test_name])
		if result:
			passed += 1
	
	var success_rate = (float(passed) / float(total)) * 100.0 if total > 0 else 0.0
	print("\nResults: %d/%d tests passed (%.1f%%)" % [passed, total, success_rate])
	
	if success_rate >= 90.0:
		print("🎉 Excellent! Roguelike system is working great!")
	elif success_rate >= 70.0:
		print("👍 Good! Minor issues detected.")
	else:
		print("⚠️ Warning! Significant issues found.")

func print_detailed_dungeon_info():
	"""Imprime información detallada del dungeon actual"""
	print("\n=== DETAILED DUNGEON INFO ===")
	
	if not world or world.current_dungeon_data.is_empty():
		print("No dungeon data available")
		return
	
	var info = world.get_dungeon_info()
	var data = world.current_dungeon_data
	
	print("Seed: %d" % info.get("seed", 0))
	print("Size: %s" % info.get("size", "Unknown"))
	print("Map dimensions: %s" % info.get("map_size", Vector2i.ZERO))
	print("Room count: %d" % info.get("room_count", 0))
	print("Connection count: %d" % info.get("connection_count", 0))
	print("Room types: %s" % info.get("room_types", {}))
	
	# Información de spawn
	var spawn_pos = world.get_player_spawn_position()
	print("Player spawn: %s" % spawn_pos)
	
	# Lista de rooms con detalles
	if data.has("rooms"):
		print("\nRoom details:")
		var rooms = data.rooms as Array[RoomBasedWorldGenerator.Room]
		for room in rooms:
			var type_name = RoomBasedWorldGenerator.RoomType.keys()[room.type]
			print("  Room %d (%s): %s, center %s, %d connections" % [
				room.id, type_name, room.rect, room.center, room.connections.size()
			])
	
	print("===========================")

# =======================
#  DEBUG COMMANDS
# =======================
func _ready_debug_commands():
	"""Configura comandos de debug"""
	print("\n=== ROGUELIKE WORLD TESTER CONTROLS ===")
	print("F7  - Run generation benchmark")
	print("F8  - Test different dungeon sizes")
	print("F9  - Run all tests")
	print("F10 - Toggle debug visualization")
	print("F11 - Regenerate current dungeon")
	print("F12 - Print detailed dungeon info")
	print("=======================================")

func _enter_tree():
	call_deferred("_ready_debug_commands")
	world.regenerate_world()
	return "World regenerated with new seed: %d" % world.get_current_seed()


static func clear_world() -> String:
	"""Limpia el mundo actual"""
	var found_world = _get_world()
	if not found_world:
		return "ERROR: No World found in scene"

	found_world.clear_world()
	return "World cleared"

static func benchmark_basic() -> String:
	"""Test básico de performance"""
	var found_world = _get_world()
	if not found_world:
		return "ERROR: No World found in scene"
	var target_world = found_world
	
	print("=== BASIC BENCHMARK ===")
	var start_time = Time.get_unix_time_from_system()
	
	# Test generation speed
	target_world.clear_world()
	target_world.regenerate_world()
	
	var end_time = Time.get_unix_time_from_system()
	var elapsed = end_time - start_time
	
	print("Generation time: ~%d seconds" % elapsed)
	print("Generated chunks: %d" % target_world.get_generated_chunks_count())
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
	var found = tree.current_scene.find_child("World", true, false)
	return found as World

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
#  COMANDOS AVANZADOS DE TESTING
# =======================
static var world_node: World

static func setup_world_testing():
	"""Configura el testing del mundo"""
	world_node = _get_world()
	if world_node:
		print("WorldTester: Connected to World node")
	else:
		print("WorldTester: WARNING - No World node found")

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
	print("Testing chunk loading at world position: %s" % str(world_pos))

static func test_biome_info(x: int = 0, y: int = 0):
	"""Test de información de biomas"""
	if not _check_world():
		return
	
	print("=== BIOME INFO TEST ===")
	var world_pos = Vector2i(x, y)
	var tile_type = world_node.get_tile_at_position(world_pos)
	
	print("Position: %s" % str(world_pos))
	print("Tile Type: %s" % tile_type)

static func test_seed_change(new_seed: int):
	"""Test de cambio de semilla"""
	if not _check_world():
		return
	
	print("=== SEED CHANGE TEST ===")
	print("Changing seed to: %d" % new_seed)
	world_node.world_generator.set_seed(new_seed)
	world_node.clear_world()
	world_node.generate_basic_world()

static func test_noise_scale(new_scale: float):
	"""Test de cambio de escala de ruido"""
	if not _check_world():
		return
	
	print("=== NOISE SCALE TEST ===")
	print("Changing noise scale to: %.3f" % new_scale)
	world_node.world_generator.set_scale(new_scale)
	world_node.clear_world()
	world_node.generate_basic_world()

static func test_performance(chunk_count: int = 10):
	"""Test de rendimiento generando múltiples chunks"""
	if not _check_world():
		return
	
	print("=== PERFORMANCE TEST ===")
	print("Generating %d chunks..." % chunk_count)
	
	var _start_time = Time.get_time_dict_from_system()
	
	for i in range(chunk_count):
		var _chunk_x = i % 5
		var _chunk_y = int(float(i) / 5.0)  # Explicit float division
		var chunk_pos = Vector2i(_chunk_x, _chunk_y)
		world_node.generate_basic_chunk(chunk_pos)
	
	var _end_time = Time.get_time_dict_from_system()
	print("Generation completed!")
	print("Chunks generated: %d" % world_node.generated_chunks.size())

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

static func show_advanced_help():
	"""Muestra comandos avanzados disponibles"""
	print("=== WORLD TESTER ADVANCED COMMANDS ===")
	print("WorldTester.test_regenerate() - Regenerate with new seed")
	print("WorldTester.test_chunk_loading(x, y) - Load chunks around position")
	print("WorldTester.test_biome_info(x, y) - Show biome info at position")
	print("WorldTester.test_seed_change(seed) - Change seed and regenerate")
	print("WorldTester.test_noise_scale(scale) - Change noise scale")
	print("WorldTester.test_performance(count) - Performance test")
	print("WorldTester.generate_test_pattern() - Generate test pattern")
	print("WorldTester.inspect_position(x, y) - Inspect specific position")
	print("WorldTester.show_advanced_help() - Show this help")
	print("=====================================")

# Inicialización automática
static func _static_init():
	setup_world_testing()
