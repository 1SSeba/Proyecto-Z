@tool
extends EditorScript

# Script para verificar que el TileSet está bien configurado

func _run():
	print("=== TILESET VERIFICATION ===")
	
	# Verificar si existe el TileSet
	var tileset_path = "res://SimpleTileSet.tres"
	if ResourceLoader.exists(tileset_path):
		print("✅ SimpleTileSet.tres found")
		
		var tileset = load(tileset_path) as TileSet
		if tileset:
			print("✅ TileSet loaded successfully")
			print("   Sources count: %d" % tileset.get_source_count())
			
			# Verificar cada source
			for i in range(tileset.get_source_count()):
				var source_id = tileset.get_source_id(i)
				var source = tileset.get_source(source_id)
				print("   Source %d: %s" % [source_id, source.get_class()])
		else:
			print("❌ Failed to load TileSet")
	else:
		print("❌ SimpleTileSet.tres not found")
	
	# Verificar world.tscn
	var world_scene_path = "res://content/scenes/World/world.tscn"
	if ResourceLoader.exists(world_scene_path):
		print("✅ world.tscn found")
		
		var world_scene = load(world_scene_path) as PackedScene
		if world_scene:
			var world_instance = world_scene.instantiate()
			var tilemap_layer = world_instance.find_child("TileMapLayer")
			
			if tilemap_layer:
				print("✅ TileMapLayer found in world.tscn")
				if tilemap_layer.tile_set:
					print("✅ TileSet assigned to TileMapLayer")
				else:
					print("❌ NO TileSet assigned to TileMapLayer")
					print("   → You need to assign SimpleTileSet.tres")
			else:
				print("❌ TileMapLayer not found in world.tscn")
			
			world_instance.queue_free()
	else:
		print("❌ world.tscn not found")
	
	print("============================")
	print("If you see ❌, follow the setup steps again")
