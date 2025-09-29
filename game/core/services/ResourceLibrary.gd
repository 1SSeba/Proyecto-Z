extends Node
class_name ResourceLibrary

const Log := preload("res://game/core/utils/Logger.gd")

var service_name: String = "ResourceLibrary"
var is_service_ready: bool = false

enum ResourceCategory {
	AUDIO,
	TEXTURE,
	SCENE,
	SCRIPT,
	FONT,
	MATERIAL,
	SHADER,
	ANIMATION,
	UI,
	CHARACTER,
	ENVIRONMENT,
	EFFECTS,
	OTHER
}

# Resource types
enum ResourceType {
	IMAGE_PNG,
	IMAGE_JPG,
	AUDIO_OGG,
	AUDIO_WAV,
	SCENE_MAIN,
	SCENE_CHARACTER,
	SCENE_UI,
	SCRIPT_CORE,
	SCRIPT_ENTITY,
	SCRIPT_SYSTEM,
	FONT_TTF,
	FONT_OTF,
	MATERIAL_STANDARD,
	SHADER_CUSTOM,
	ANIMATION_SPRITE,
	OTHER
}

# Resource library data
var resource_catalog: Dictionary = {}
var resource_tags: Dictionary = {}
var resource_metadata: Dictionary = {}
var resource_dependencies: Dictionary = {}

# Search and filter data
var search_index: Dictionary = {}
var category_index: Dictionary = {}
var tag_index: Dictionary = {}

#  SERVICE LIFECYCLE

func _start():
	service_name = "ResourceLibrary"
	_initialize_library()
	is_service_ready = true
	_log_info("ResourceLibrary: Initialized successfully")

func start_service():
	_start()

func _initialize_library():
	# Create resource directories if they don't exist
	_create_library_directories()

	# Load existing resource data
	_load_resource_catalog()

	# Build search indexes
	_build_search_indexes()

	# Scan for new resources
	_scan_for_resources()

#  RESOURCE REGISTRATION

func register_resource(resource_path: String, category: ResourceCategory, resource_type: ResourceType, tags: Array[String] = [], metadata: Dictionary = {}):
	# Validate resource path
	if not _validate_resource_path(resource_path):
		_log_warn("ResourceLibrary: Invalid resource path: %s" % resource_path)
		return false

	# Create resource entry
	var resource_entry = {
		"path": resource_path,
		"category": category,
		"type": resource_type,
		"tags": tags,
		"metadata": metadata,
		"registered_at": Time.get_ticks_msec(),
		"last_accessed": 0,
		"access_count": 0,
		"size": _get_resource_size(resource_path),
		"hash": _calculate_resource_hash(resource_path)
	}

	# Add to catalog
	resource_catalog[resource_path] = resource_entry

	# Update indexes
	_update_category_index(resource_path, category)
	_update_tag_index(resource_path, tags)
	_update_search_index(resource_path, resource_entry)

	# Save catalog
	_save_resource_catalog()

	_log_info("ResourceLibrary: Registered resource: %s" % resource_path)
	return true

func unregister_resource(resource_path: String):
	if resource_catalog.has(resource_path):
		var entry = resource_catalog[resource_path]

		# Remove from indexes
		_remove_from_category_index(resource_path, entry.category)

		# Convert generic Array to Array[String] for type safety
		var tags_array: Array[String] = []
		for tag in entry.tags:
			tags_array.append(str(tag))

		_remove_from_tag_index(resource_path, tags_array)
		_remove_from_search_index(resource_path)

		# Remove from catalog
		resource_catalog.erase(resource_path)

		# Save catalog
		_save_resource_catalog()

		_log_info("ResourceLibrary: Unregistered resource: %s" % resource_path)
		return true

	return false

#  RESOURCE QUERIES

func get_resources_by_category(category: ResourceCategory) -> Array[String]:
	var resources: Array[String] = []
	var raw_array = category_index.get(category, [])
	for item in raw_array:
		resources.append(str(item))
	return resources

func get_resources_by_type(resource_type: ResourceType) -> Array[String]:
	var resources: Array[String] = []

	for path in resource_catalog.keys():
		if resource_catalog[path].type == resource_type:
			resources.append(path)

	return resources

func get_resources_by_tag(tag: String) -> Array[String]:
	var resources: Array[String] = []
	var raw_array = tag_index.get(tag, [])
	for item in raw_array:
		resources.append(str(item))
	return resources

func search_resources(query: String) -> Array[String]:
	var results: Array[String] = []
	var query_lower = query.to_lower()

	# Search in resource names, paths, and tags
	for path in resource_catalog.keys():
		var entry = resource_catalog[path]
		var searchable_text = (path + " " + str(entry.tags)).to_lower()

		if query_lower in searchable_text:
			results.append(path)

	# Sort by relevance (exact matches first)
	results.sort_custom(func(a, b):
		var a_exact = query_lower in a.to_lower()
		var b_exact = query_lower in b.to_lower()
		if a_exact != b_exact:
			return a_exact
		return a < b
	)

	return results

func get_resource_info(resource_path: String) -> Dictionary:
	if resource_catalog.has(resource_path):
		return resource_catalog[resource_path].duplicate()
	else:
		return {}

func get_resource_metadata(resource_path: String) -> Dictionary:
	if resource_catalog.has(resource_path):
		return resource_catalog[resource_path].metadata
	else:
		return {}

#  RESOURCE TAGS

func add_tag_to_resource(resource_path: String, tag: String):
	if resource_catalog.has(resource_path):
		var entry = resource_catalog[resource_path]
		if tag not in entry.tags:
			entry.tags.append(tag)

			# Convert to Array[String] for type safety
			var tags_array: Array[String] = []
			for t in entry.tags:
				tags_array.append(str(t))

			_update_tag_index(resource_path, tags_array)
			_save_resource_catalog()
			_log_info("ResourceLibrary: Added tag '%s' to resource: %s" % [tag, resource_path])

func remove_tag_from_resource(resource_path: String, tag: String):
	if resource_catalog.has(resource_path):
		var entry = resource_catalog[resource_path]
		if tag in entry.tags:
			entry.tags.erase(tag)

			# Convert to Array[String] for type safety
			var tags_array: Array[String] = []
			for t in entry.tags:
				tags_array.append(str(t))

			_update_tag_index(resource_path, tags_array)
			_save_resource_catalog()
			_log_info("ResourceLibrary: Removed tag '%s' from resource: %s" % [tag, resource_path])

func get_all_tags() -> Array[String]:
	var tags: Array[String] = []

	for path in resource_catalog.keys():
		var entry = resource_catalog[path]
		for tag in entry.tags:
			if tag not in tags:
				tags.append(tag)

	tags.sort()
	return tags

#  RESOURCE STATISTICS

func get_library_stats() -> Dictionary:
	var stats = {
		"total_resources": resource_catalog.size(),
		"categories": {},
		"types": {},
		"tags": {},
		"total_size": 0,
		"most_accessed": [],
		"recently_added": []
	}

	# Count by category
	for category in ResourceCategory.values():
		stats.categories[ResourceCategory.keys()[category]] = get_resources_by_category(category).size()

	# Count by type
	for type in ResourceType.values():
		stats.types[ResourceType.keys()[type]] = get_resources_by_type(type).size()

	# Count by tag
	var all_tags = get_all_tags()
	for tag in all_tags:
		stats.tags[tag] = get_resources_by_tag(tag).size()

	# Calculate total size
	for path in resource_catalog.keys():
		stats.total_size += resource_catalog[path].size

	# Get most accessed resources
	var access_counts = []
	for path in resource_catalog.keys():
		var entry = resource_catalog[path]
		access_counts.append({"path": path, "count": entry.access_count})

	access_counts.sort_custom(func(a, b): return a.count > b.count)
	stats.most_accessed = access_counts.slice(0, 10)

	# Get recently added resources
	var recent_resources = []
	for path in resource_catalog.keys():
		var entry = resource_catalog[path]
		recent_resources.append({"path": path, "added_at": entry.registered_at})

	recent_resources.sort_custom(func(a, b): return a.added_at > b.added_at)
	stats.recently_added = recent_resources.slice(0, 10)

	return stats

func get_category_stats(category: ResourceCategory) -> Dictionary:
	var resources = get_resources_by_category(category)
	var stats = {
		"count": resources.size(),
		"total_size": 0,
		"types": {},
		"tags": {}
	}

	# Calculate size and count by type
	for path in resources:
		var entry = resource_catalog[path]
		stats.total_size += entry.size

		var type_name = ResourceType.keys()[entry.type]
		if not stats.types.has(type_name):
			stats.types[type_name] = 0
		stats.types[type_name] += 1

		# Count tags
		for tag in entry.tags:
			if not stats.tags.has(tag):
				stats.tags[tag] = 0
			stats.tags[tag] += 1

	return stats

#  RESOURCE DEPENDENCIES

func add_dependency(resource_path: String, dependency_path: String):
	if not resource_dependencies.has(resource_path):
		resource_dependencies[resource_path] = []

	if dependency_path not in resource_dependencies[resource_path]:
		resource_dependencies[resource_path].append(dependency_path)
		_log_info("ResourceLibrary: Added dependency: %s -> %s" % [resource_path, dependency_path])

func remove_dependency(resource_path: String, dependency_path: String):
	if resource_dependencies.has(resource_path):
		resource_dependencies[resource_path].erase(dependency_path)
		_log_info("ResourceLibrary: Removed dependency: %s -> %s" % [resource_path, dependency_path])

func get_dependencies(resource_path: String) -> Array[String]:
	return resource_dependencies.get(resource_path, [])

func get_dependents(resource_path: String) -> Array[String]:
	var dependents: Array[String] = []

	for path in resource_dependencies.keys():
		if resource_path in resource_dependencies[path]:
			dependents.append(path)

	return dependents

#  RESOURCE ACCESS TRACKING

func track_resource_access(resource_path: String):
	if resource_catalog.has(resource_path):
		var entry = resource_catalog[resource_path]
		entry.last_accessed = Time.get_ticks_msec()
		entry.access_count += 1
		_save_resource_catalog()

func get_most_accessed_resources(limit: int = 10) -> Array[Dictionary]:
	var access_data = []

	for path in resource_catalog.keys():
		var entry = resource_catalog[path]
		access_data.append({
			"path": path,
			"access_count": entry.access_count,
			"last_accessed": entry.last_accessed
		})

	access_data.sort_custom(func(a, b): return a.access_count > b.access_count)
	return access_data.slice(0, limit)

#  INTERNAL METHODS

func _create_library_directories():
	var directories = [
		"user://resource_library",
		"user://resource_library/catalog",
		"user://resource_library/metadata"
	]

	for dir_path in directories:
		DirAccess.make_dir_recursive_absolute(dir_path)

func _load_resource_catalog():
	var catalog_file = "user://resource_library/catalog.json"

	if FileAccess.file_exists(catalog_file):
		var file = FileAccess.open(catalog_file, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result == OK:
				resource_catalog = json.data
				_log_info("ResourceLibrary: Loaded catalog with %d resources" % resource_catalog.size())

func _save_resource_catalog():
	var catalog_file = "user://resource_library/catalog.json"

	var file = FileAccess.open(catalog_file, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(resource_catalog, "\t")
		file.store_string(json_string)
		file.close()

func _build_search_indexes():
	# Clear existing indexes
	category_index.clear()
	tag_index.clear()
	search_index.clear()

	# Build indexes from catalog
	for path in resource_catalog.keys():
		var entry = resource_catalog[path]
		_update_category_index(path, entry.category)

		# Convert generic Array to Array[String] for type safety
		var tags_array: Array[String] = []
		for tag in entry.tags:
			tags_array.append(str(tag))

		_update_tag_index(path, tags_array)
		_update_search_index(path, entry)

func _update_category_index(resource_path: String, category: ResourceCategory):
	if not category_index.has(category):
		category_index[category] = []

	if resource_path not in category_index[category]:
		category_index[category].append(resource_path)

func _update_tag_index(resource_path: String, tags: Array[String]):
	for tag in tags:
		if not tag_index.has(tag):
			tag_index[tag] = []

		if resource_path not in tag_index[tag]:
			tag_index[tag].append(resource_path)

func _update_search_index(resource_path: String, entry: Dictionary):
	search_index[resource_path] = {
		"path": resource_path,
		"category": entry.category,
		"type": entry.type,
		"tags": entry.tags
	}

func _remove_from_category_index(resource_path: String, category: ResourceCategory):
	if category_index.has(category):
		category_index[category].erase(resource_path)

func _remove_from_tag_index(resource_path: String, tags: Array[String]):
	for tag in tags:
		if tag_index.has(tag):
			tag_index[tag].erase(resource_path)

func _remove_from_search_index(resource_path: String):
	search_index.erase(resource_path)

func _scan_for_resources():
	var resource_extensions = [".png", ".jpg", ".ogg", ".wav", ".tscn", ".tres", ".gd", ".cs", ".ttf", ".otf"]
	var project_dir = "res://"

	for ext in resource_extensions:
		var files = _scan_directory_for_resources(project_dir, [ext])
		for file_path in files:
			if not resource_catalog.has(file_path):
				_auto_register_resource(file_path)

func _scan_directory_for_resources(dir_path: String, extensions: Array[String]) -> Array[String]:
	var files: Array[String] = []

	var dir = DirAccess.open(dir_path)
	if not dir:
		return files

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		var full_path = dir_path + "/" + file_name

		if dir.current_is_dir():
			if file_name != ".git" and file_name != ".godot":
				files.append_array(_scan_directory_for_resources(full_path, extensions))
		else:
			for ext in extensions:
				if file_name.ends_with(ext):
					files.append(full_path)
					break

		file_name = dir.get_next()

	return files

func _auto_register_resource(resource_path: String):
	var category = _guess_category_from_path(resource_path)
	var type = _guess_type_from_extension(resource_path)
	var tags = _guess_tags_from_path(resource_path)

	register_resource(resource_path, category, type, tags)

func _guess_category_from_path(resource_path: String) -> ResourceCategory:
	if "audio" in resource_path.to_lower():
		return ResourceCategory.AUDIO
	elif "character" in resource_path.to_lower():
		return ResourceCategory.CHARACTER
	elif "ui" in resource_path.to_lower():
		return ResourceCategory.UI
	elif "scene" in resource_path.to_lower():
		return ResourceCategory.SCENE
	elif "texture" in resource_path.to_lower() or "sprite" in resource_path.to_lower():
		return ResourceCategory.TEXTURE
	else:
		return ResourceCategory.OTHER

func _guess_type_from_extension(resource_path: String) -> ResourceType:
	var ext = resource_path.get_extension().to_lower()

	match ext:
		"png":
			return ResourceType.IMAGE_PNG
		"jpg", "jpeg":
			return ResourceType.IMAGE_JPG
		"ogg":
			return ResourceType.AUDIO_OGG
		"wav":
			return ResourceType.AUDIO_WAV
		"tscn":
			return ResourceType.SCENE_MAIN
		"gd":
			return ResourceType.SCRIPT_CORE
		"ttf":
			return ResourceType.FONT_TTF
		"otf":
			return ResourceType.FONT_OTF
		_:
			return ResourceType.OTHER

func _guess_tags_from_path(resource_path: String) -> Array[String]:
	var tags: Array[String] = []
	var path_lower = resource_path.to_lower()

	# Common tag patterns
	var tag_patterns = {
		"player": ["player", "character"],
		"enemy": ["enemy", "monster"],
		"ui": ["ui", "interface", "menu"],
		"audio": ["audio", "sound", "music"],
		"texture": ["texture", "sprite", "image"],
		"scene": ["scene", "level", "world"]
	}

	for pattern in tag_patterns.keys():
		if pattern in path_lower:
			tags.append_array(tag_patterns[pattern])

	return tags

func _validate_resource_path(resource_path: String) -> bool:
	return FileAccess.file_exists(resource_path)

func _get_resource_size(resource_path: String) -> int:
	var file = FileAccess.open(resource_path, FileAccess.READ)
	if file:
		var size = file.get_length()
		file.close()
		return size
	return 0

func _calculate_resource_hash(resource_path: String) -> String:
	var file = FileAccess.open(resource_path, FileAccess.READ)
	if file:
		# Para archivos binarios, usar el tamaño y la fecha como hash simple
		var extension = resource_path.get_extension().to_lower()
		if extension in ["png", "jpg", "jpeg", "ogg", "wav"]:
			var size = file.get_length()
			file.close()
			return str(size.hash())
		else:
			var content = file.get_as_text()
			file.close()
			return str(content.hash())
	return ""

#  CLEANUP

func _exit_tree():
	_save_resource_catalog()
	_log_info("ResourceLibrary: Cleanup complete")

#  LOGGING HELPERS

func _log_info(message: String):
	Log.info(message)

func _log_warn(message: String):
	Log.warn(message)
	push_warning(message)

func _log_error(message: String):
	Log.error(message)
	push_error(message)
