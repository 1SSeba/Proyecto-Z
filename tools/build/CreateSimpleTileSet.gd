@tool
extends RefCounted
class_name CreateSimpleTileSet

# =======================
#  HERRAMIENTA SIMPLE PARA TILESET
# =======================

## Versión simplificada para crear TileSets básicos
## Enfocada en prototipado rápido

static func create_simple_colored_tileset() -> TileSet:
	"""Crea un TileSet simple con colores básicos"""
	var tileset = TileSet.new()
	
	# Crear atlas source
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = _create_simple_texture()
	atlas_source.texture_region_size = Vector2i(16, 16)  # Tiles más pequeños
	
	# Configurar tiles simples
	_configure_simple_tiles(atlas_source)
	
	# Agregar al tileset
	tileset.add_source(atlas_source, 0)
	
	return tileset

static func _create_simple_texture() -> ImageTexture:
	"""Crea textura simple 3x2 con 6 tiles básicos"""
	var image = Image.create(48, 32, false, Image.FORMAT_RGB8)
	
	# Colores simples
	var tile_colors = [
		Color.GREEN,           # 0: Grass
		Color(0.5, 0.3, 0.1),  # 1: Dirt
		Color.GRAY,            # 2: Stone
		Color.BLUE,            # 3: Water
		Color.YELLOW,          # 4: Sand
		Color.RED              # 5: Lava/Special
	]
	
	# Pintar tiles de 16x16
	for tile_index in range(6):
		var tile_x = tile_index % 3
		var tile_y = int(float(tile_index) / 3.0)  # Explicit float division
		var color = tile_colors[tile_index]
		
		for x in range(16):
			for y in range(16):
				image.set_pixel(tile_x * 16 + x, tile_y * 16 + y, color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

static func _configure_simple_tiles(atlas_source: TileSetAtlasSource):
	"""Configura tiles simples"""
	for tile_index in range(6):
		var tile_x = tile_index % 3
		var tile_y = int(float(tile_index) / 3.0)  # Explicit float division
		var atlas_coords = Vector2i(tile_x, tile_y)
		
		atlas_source.create_tile(atlas_coords)
		
		# Configuración básica por tipo
		var tile_data = atlas_source.get_tile_data(atlas_coords, 0)
		if tile_data:
			match tile_index:
				2, 5: # Stone y Lava - sólidos
					_add_simple_collision(tile_data)

static func _add_simple_collision(tile_data: TileData):
	"""Agrega colisión simple al tile"""
	var physics_layer = 0
	tile_data.add_collision_polygon(physics_layer)
	
	# Rectángulo completo
	var points = PackedVector2Array([
		Vector2(0, 0), Vector2(16, 0), 
		Vector2(16, 16), Vector2(0, 16)
	])
	tile_data.set_collision_polygon_points(physics_layer, 0, points)

# =======================
#  UTILIDADES RÁPIDAS
# =======================
static func quick_create_and_save(path: String = "res://simple_tileset.tres") -> bool:
	"""Crea y guarda rápidamente un tileset simple"""
	var tileset = create_simple_colored_tileset()
	var result = ResourceSaver.save(tileset, path)
	
	if result == OK:
		print("CreateSimpleTileSet: Saved to %s" % path)
		return true
	else:
		print("CreateSimpleTileSet: Error saving to %s" % path)
		return false
