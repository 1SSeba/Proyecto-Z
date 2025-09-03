extends RefCounted

# =======================
#  PACKED DATA STRUCTURES OPTIMIZADAS
# =======================

## Estructuras de datos optimizadas usando Packed Arrays para mejor performance de memoria

# =======================
#  TILE DATA OPTIMIZADO
# =======================

class_name PackedTileData

# Packed arrays para máxima eficiencia de memoria
var positions_x: PackedInt32Array
var positions_y: PackedInt32Array
var tile_types: PackedByteArray    # 0-255 tipos de tile
var heights: PackedFloat32Array     # Alturas de terreno
var flags: PackedByteArray         # Flags adicionales (visible, walkable, etc.)

# Configuración
var chunk_size: int = 256  # 16x16 tiles por chunk
var current_count: int = 0

# =======================
#  INICIALIZACIÓN
# =======================

func _init(initial_size: int = 256):
	"""Inicializa las estructuras packed con tamaño inicial"""
	_resize_arrays(initial_size)

func _resize_arrays(new_size: int):
	"""Redimensiona todos los arrays packed"""
	positions_x.resize(new_size)
	positions_y.resize(new_size)
	tile_types.resize(new_size)
	heights.resize(new_size)
	flags.resize(new_size)

# =======================
#  OPERACIONES OPTIMIZADAS
# =======================

func add_tile_data(pos_x: int, pos_y: int, tile_type: int, height: float = 0.0, tile_flags: int = 0):
	"""Añade datos de tile usando packed arrays"""
	# Expandir si es necesario
	if current_count >= positions_x.size():
		_resize_arrays(positions_x.size() * 2)
	
	# Agregar datos
	positions_x[current_count] = pos_x
	positions_y[current_count] = pos_y
	tile_types[current_count] = clamp(tile_type, 0, 255)
	heights[current_count] = height
	flags[current_count] = clamp(tile_flags, 0, 255)
	
	current_count += 1

func get_tile_data(index: int) -> Dictionary:
	"""Obtiene datos de tile por índice (más lento, usar solo para debug)"""
	if index < 0 or index >= current_count:
		return {}
	
	return {
		"position": Vector2i(positions_x[index], positions_y[index]),
		"tile_type": tile_types[index],
		"height": heights[index],
		"flags": flags[index]
	}

func bulk_set_tile_types(start_index: int, new_types: PackedByteArray):
	"""Establece tipos de tile en bloque (operación muy rápida)"""
	var end_index = min(start_index + new_types.size(), current_count)
	var count = end_index - start_index
	
	if count > 0:
		# Copia rápida de memoria
		for i in count:
			tile_types[start_index + i] = new_types[i]

func bulk_set_heights(start_index: int, new_heights: PackedFloat32Array):
	"""Establece alturas en bloque (operación muy rápida)"""
	var end_index = min(start_index + new_heights.size(), current_count)
	var count = end_index - start_index
	
	if count > 0:
		for i in count:
			heights[start_index + i] = new_heights[i]

# =======================
#  OPERACIONES BÚSQUEDA OPTIMIZADA
# =======================

func find_tiles_by_type(tile_type: int) -> PackedInt32Array:
	"""Encuentra todos los índices de tiles de un tipo específico"""
	var result: PackedInt32Array = PackedInt32Array()
	
	for i in current_count:
		if tile_types[i] == tile_type:
			result.append(i)
	
	return result

func find_tiles_in_range(min_x: int, max_x: int, min_y: int, max_y: int) -> PackedInt32Array:
	"""Encuentra tiles en un rango específico usando búsqueda optimizada"""
	var result: PackedInt32Array = PackedInt32Array()
	
	for i in current_count:
		var x = positions_x[i]
		var y = positions_y[i]
		
		if x >= min_x and x <= max_x and y >= min_y and y <= max_y:
			result.append(i)
	
	return result

func count_tiles_by_type() -> Dictionary:
	"""Cuenta tiles por tipo usando arrays optimizados"""
	var counts = {}
	
	for i in current_count:
		var tile_type = tile_types[i]
		counts[tile_type] = counts.get(tile_type, 0) + 1
	
	return counts

# =======================
#  OPERACIONES DE MEMORIA
# =======================

func compact():
	"""Compacta los arrays removiendo espacio no utilizado"""
	if current_count < positions_x.size():
		_resize_arrays(current_count)

func clear():
	"""Limpia todos los datos"""
	current_count = 0
	# Mantener arrays but reset count para reutilización

func get_memory_usage() -> Dictionary:
	"""Retorna uso de memoria de las estructuras packed"""
	var size_per_element = 4 + 4 + 1 + 4 + 1  # int32 + int32 + byte + float32 + byte
	var allocated_memory = positions_x.size() * size_per_element
	var used_memory = current_count * size_per_element
	
	return {
		"allocated_bytes": allocated_memory,
		"used_bytes": used_memory,
		"efficiency": float(used_memory) / float(allocated_memory) if allocated_memory > 0 else 0.0,
		"element_count": current_count,
		"allocated_capacity": positions_x.size()
	}

# =======================
#  BATCH OPERATIONS PARA CHUNKS
# =======================

func create_chunk_data(chunk_x: int, chunk_y: int, size: Vector2i) -> void:
	"""Crea datos de chunk completo usando operaciones batch"""
	var total_tiles = size.x * size.y
	
	# Pre-allocar espacio
	if current_count + total_tiles >= positions_x.size():
		_resize_arrays(current_count + total_tiles + 100)  # Buffer extra
	
	# Generar datos en batch
	for y in size.y:
		for x in size.x:
			var world_x = chunk_x * size.x + x
			var world_y = chunk_y * size.y + y
			
			positions_x[current_count] = world_x
			positions_y[current_count] = world_y
			tile_types[current_count] = 0  # Grass por defecto
			heights[current_count] = 0.0
			flags[current_count] = 1  # Walkable por defecto
			
			current_count += 1

func export_chunk_to_arrays(start_index: int, count: int) -> Dictionary:
	"""Exporta un chunk como arrays optimizados para serialización"""
	var end_index = min(start_index + count, current_count)
	var actual_count = end_index - start_index
	
	if actual_count <= 0:
		return {}
	
	# Crear subarrays usando slice (operación optimizada)
	return {
		"positions_x": positions_x.slice(start_index, end_index),
		"positions_y": positions_y.slice(start_index, end_index),
		"tile_types": tile_types.slice(start_index, end_index),
		"heights": heights.slice(start_index, end_index),
		"flags": flags.slice(start_index, end_index),
		"count": actual_count
	}

# =======================
#  STATISTICS Y DEBUG
# =======================

func get_performance_stats() -> Dictionary:
	"""Retorna estadísticas de performance"""
	var memory = get_memory_usage()
	
	return {
		"memory_efficiency": "%.1f%%" % (memory.efficiency * 100),
		"total_tiles": current_count,
		"memory_kb": memory.allocated_bytes / 1024.0,
		"compression_ratio": float(current_count * 20) / float(memory.allocated_bytes) if memory.allocated_bytes > 0 else 0.0  # vs Dictionary approach
	}

func benchmark_operations(iterations: int = 1000) -> Dictionary:
	"""Benchmark de operaciones para validar performance"""
	var start_time = Time.get_time_dict_from_system()
	
	# Test add operations
	for i in iterations:
		add_tile_data(i % 100, i % 100, i % 5, randf() * 10.0, 1)
	
	var add_time = Time.get_time_dict_from_system().seconds - start_time.seconds
	
	# Test search operations
	start_time = Time.get_time_dict_from_system()
	for i in 100:
		find_tiles_by_type(i % 5)
	var search_time = Time.get_time_dict_from_system().seconds - start_time.seconds
	
	return {
		"add_operations_per_second": iterations / max(add_time, 0.001),
		"search_operations_per_second": 100 / max(search_time, 0.001),
		"memory_efficiency": get_memory_usage().efficiency
	}
