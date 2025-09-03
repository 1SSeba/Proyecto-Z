@tool
extends RefCounted
class_name CreateBasicTileSet

# =======================
#  HERRAMIENTA PARA CREAR TILESET BÁSICO
# =======================

## Esta clase proporciona utilidades para crear un TileSet básico programáticamente
## Útil para desarrollo rápido y testing

static func create_basic_tileset() -> TileSet:
	"""Crea un TileSet básico con colores sólidos para testing"""
	var tileset = TileSet.new()
	
	# Crear fuente de tiles
	var tile_source = TileSetAtlasSource.new()
	tile_source.texture = _create_basic_texture()
	tile_source.texture_region_size = Vector2i(32, 32)
	
	# Configurar tiles básicos
	_setup_basic_tiles(tile_source)
	
	# Agregar la fuente al tileset
	tileset.add_source(tile_source, 0)
	
	print("CreateBasicTileSet: Basic TileSet created")
	return tileset

static func _create_basic_texture() -> ImageTexture:
	"""Crea una textura básica con colores para cada tipo de tile"""
	var image = Image.create(160, 32, false, Image.FORMAT_RGB8)
	
	# Colores para cada tipo de tile
	var colors = [
		Color.GREEN,     # GRASS
		Color(0.6, 0.4, 0.2),  # DIRT  
		Color.GRAY,      # STONE
		Color.BLUE,      # WATER
		Color.YELLOW     # SAND
	]
	
	# Pintar cada tile de 32x32
	for i in range(5):
		var color = colors[i]
		for x in range(32):
			for y in range(32):
				image.set_pixel(i * 32 + x, y, color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

static func _setup_basic_tiles(tile_source: TileSetAtlasSource):
	"""Configura los tiles básicos en la fuente"""
	for i in range(5):
		var atlas_coords = Vector2i(i, 0)
		tile_source.create_tile(atlas_coords)
		
		# Configurar propiedades básicas del tile
		var tile_data = tile_source.get_tile_data(atlas_coords, 0)
		if tile_data:
			# Configurar física básica
			match i:
				0: # GRASS
					pass  # Sin colisión
				1: # DIRT
					pass  # Sin colisión
				2: # STONE
					_setup_solid_collision(tile_data)
				3: # WATER
					pass  # Sin colisión por ahora
				4: # SAND
					pass  # Sin colisión

static func _setup_solid_collision(tile_data: TileData):
	"""Configura colisión sólida para un tile"""
	var physics_layer = 0
	tile_data.add_collision_polygon(physics_layer)
	
	# Crear polígono de colisión que cubre todo el tile
	var polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(32, 0), 
		Vector2(32, 32),
		Vector2(0, 32)
	])
	tile_data.set_collision_polygon_points(physics_layer, 0, polygon)

static func save_tileset_to_file(tileset: TileSet, path: String) -> bool:
	"""Guarda el TileSet en un archivo"""
	var result = ResourceSaver.save(tileset, path)
	if result == OK:
		print("CreateBasicTileSet: TileSet saved to %s" % path)
		return true
	else:
		print("CreateBasicTileSet: ERROR - Could not save TileSet to %s" % path)
		return false

# =======================
#  FUNCIÓN DE UTILIDAD PRINCIPAL
# =======================
static func create_and_save_basic_tileset(save_path: String = "res://basic_tileset.tres") -> TileSet:
	"""Crea y guarda un TileSet básico"""
	var tileset = create_basic_tileset()
	save_tileset_to_file(tileset, save_path)
	return tileset
