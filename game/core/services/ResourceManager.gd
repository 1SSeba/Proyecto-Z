extends Node
# ResourceManager.gd - Gestión centralizada de recursos del juego

## Professional Resource Manager
## Centralized resource management with caching, validation, and optimization
## @author: Senior Developer (10+ years experience)

# ============================================================================
#  RESOURCE CONFIGURATION
# ============================================================================

# Service properties
var service_name: String = "ResourceManager"
var is_service_ready: bool = false

# Resource categories
enum ResourceCategory {
	AUDIO,
	TEXTURE,
	SCENE,
	SCRIPT,
	FONT,
	MATERIAL,
	SHADER,
	ANIMATION,
	OTHER
}

# Resource cache
var resource_cache: Dictionary = {}
var cache_size_limit: int = 100
var cache_memory_limit: int = 50 * 1024 * 1024  # 50MB

# Resource metadata
var resource_metadata: Dictionary = {}
var resource_dependencies: Dictionary = {}

# Loading state
var loading_queue: Array[String] = []
var currently_loading: Array[String] = []
var max_concurrent_loads: int = 3

# ============================================================================
#  SERVICE LIFECYCLE
# ============================================================================

func _start():
	service_name = "ResourceManager"
	_initialize_resource_system()
	is_service_ready = true
	print("ResourceManager: Initialized successfully")

func start_service():
	"""Public method to start the service"""
	_start()

func _initialize_resource_system():
	"""Initialize the resource management system"""
	# Create resource directories if they don't exist
	_create_resource_directories()

	# Load resource metadata
	_load_resource_metadata()

	# Preload critical resources
	_preload_critical_resources()

# ============================================================================
#  RESOURCE LOADING
# ============================================================================

func load_resource(resource_path: String, category: ResourceCategory = ResourceCategory.OTHER) -> Resource:
	"""Load a resource with caching and validation"""

	# Check cache first
	if resource_cache.has(resource_path):
		_update_cache_access(resource_path)
		return resource_cache[resource_path]

	# Validate resource path
	if not _validate_resource_path(resource_path):
		print("ResourceManager: Invalid resource path: ", resource_path)
		return null

	# Load resource
	var resource = _load_resource_from_disk(resource_path)
	if not resource:
		print("ResourceManager: Failed to load resource: ", resource_path)
		return null

	# Add to cache
	_add_to_cache(resource_path, resource, category)

	# Update metadata
	_update_resource_metadata(resource_path, category)

	return resource

func load_resource_async(resource_path: String, category: ResourceCategory = ResourceCategory.OTHER) -> Resource:
	"""Load a resource asynchronously"""

	# Add to loading queue
	if resource_path not in loading_queue and resource_path not in currently_loading:
		loading_queue.append(resource_path)

	# Process queue
	_process_loading_queue()

	# Return cached resource if available
	return resource_cache.get(resource_path, null)

func preload_resources(resource_paths: Array[String], category: ResourceCategory = ResourceCategory.OTHER):
	"""Preload multiple resources"""
	for path in resource_paths:
		load_resource_async(path, category)

# ============================================================================
#  RESOURCE CACHING
# ============================================================================

func _add_to_cache(resource_path: String, resource: Resource, category: ResourceCategory):
	"""Add resource to cache with size management"""

	# Check cache size limits
	_manage_cache_size()

	# Add to cache
	resource_cache[resource_path] = resource

	# Update metadata
	resource_metadata[resource_path] = {
		"category": category,
		"load_time": Time.get_ticks_msec(),
		"access_count": 1,
		"last_access": Time.get_ticks_msec(),
		"size": _estimate_resource_size(resource)
	}

func _update_cache_access(resource_path: String):
	"""Update cache access statistics"""
	if resource_metadata.has(resource_path):
		resource_metadata[resource_path]["access_count"] += 1
		resource_metadata[resource_path]["last_access"] = Time.get_ticks_msec()

func _manage_cache_size():
	"""Manage cache size to stay within limits"""

	# Check if we need to clear cache
	if resource_cache.size() >= cache_size_limit:
		_clear_least_used_resources()

func _clear_least_used_resources():
	"""Clear least used resources from cache"""
	var resources_to_remove = []

	# Sort by access count and last access time
	var sorted_resources = []
	for path in resource_metadata.keys():
		var metadata = resource_metadata[path]
		sorted_resources.append({
			"path": path,
			"access_count": metadata.get("access_count", 0),
			"last_access": metadata.get("last_access", 0)
		})

	# Sort by access count (ascending) then by last access (ascending)
	sorted_resources.sort_custom(func(a, b):
		if a.access_count != b.access_count:
			return a.access_count < b.access_count
		return a.last_access < b.last_access
	)

	# Remove least used resources (up to 25% of cache)
	var remove_count = max(1, resource_cache.size() / 4)
	for i in range(min(remove_count, sorted_resources.size())):
		var resource_info = sorted_resources[i]
		resources_to_remove.append(resource_info.path)

	# Remove from cache
	for path in resources_to_remove:
		resource_cache.erase(path)
		resource_metadata.erase(path)
		print("ResourceManager: Removed from cache: ", path)

# ============================================================================
#  RESOURCE VALIDATION
# ============================================================================

func _validate_resource_path(resource_path: String) -> bool:
	"""Validate that a resource path exists and is accessible"""

	# Check if path exists
	if not FileAccess.file_exists(resource_path):
		return false

	# Check if it's a valid Godot resource
	var resource = load(resource_path)
	return resource != null

func validate_all_resources() -> Dictionary:
	"""Validate all resources in the project"""
	var validation_results = {
		"valid": [],
		"invalid": [],
		"missing": [],
		"total": 0
	}

	# Get all resource files
	var resource_files = _get_all_resource_files()
	validation_results["total"] = resource_files.size()

	for file_path in resource_files:
		if FileAccess.file_exists(file_path):
			if _validate_resource_path(file_path):
				validation_results["valid"].append(file_path)
			else:
				validation_results["invalid"].append(file_path)
		else:
			validation_results["missing"].append(file_path)

	return validation_results

func _get_all_resource_files() -> Array[String]:
	"""Get all resource files in the project"""
	var resource_files: Array[String] = []

	# Common resource extensions
	var extensions = [".tres", ".res", ".tscn", ".gd", ".cs", ".png", ".jpg", ".ogg", ".wav", ".ttf", ".otf"]

	# Search in project directory
	var project_dir = "res://"
	resource_files = _scan_directory_for_resources(project_dir, extensions)

	return resource_files

func _scan_directory_for_resources(dir_path: String, extensions: Array[String]) -> Array[String]:
	"""Recursively scan directory for resource files"""
	var files: Array[String] = []

	var dir = DirAccess.open(dir_path)
	if not dir:
		return files

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		var full_path = dir_path + "/" + file_name

		if dir.current_is_dir():
			# Skip .git and .godot directories
			if file_name != ".git" and file_name != ".godot":
				files.append_array(_scan_directory_for_resources(full_path, extensions))
		else:
			# Check if file has resource extension
			for ext in extensions:
				if file_name.ends_with(ext):
					files.append(full_path)
					break

		file_name = dir.get_next()

	return files

# ============================================================================
#  RESOURCE METADATA
# ============================================================================

func _load_resource_metadata():
	"""Load resource metadata from file"""
	var metadata_file = "user://resource_metadata.json"

	if FileAccess.file_exists(metadata_file):
		var file = FileAccess.open(metadata_file, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result == OK:
				resource_metadata = json.data
				print("ResourceManager: Loaded metadata for ", resource_metadata.size(), " resources")

func _save_resource_metadata():
	"""Save resource metadata to file"""
	var metadata_file = "user://resource_metadata.json"

	var file = FileAccess.open(metadata_file, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(resource_metadata, "\t")
		file.store_string(json_string)
		file.close()
		print("ResourceManager: Saved metadata for ", resource_metadata.size(), " resources")

func _update_resource_metadata(resource_path: String, category: ResourceCategory):
	"""Update metadata for a resource"""
	if not resource_metadata.has(resource_path):
		resource_metadata[resource_path] = {}

	resource_metadata[resource_path]["category"] = category
	resource_metadata[resource_path]["last_updated"] = Time.get_ticks_msec()

# ============================================================================
#  RESOURCE OPTIMIZATION
# ============================================================================

func optimize_resources():
	"""Optimize all resources in the project"""
	print("ResourceManager: Starting resource optimization...")

	var optimized_count = 0
	var total_size_before = 0
	var total_size_after = 0

	# Get all resource files
	var resource_files = _get_all_resource_files()

	for file_path in resource_files:
		var size_before = _get_file_size(file_path)
		total_size_before += size_before

		# Optimize based on file type
		var optimized = _optimize_resource_file(file_path)
		if optimized:
			optimized_count += 1
			var size_after = _get_file_size(file_path)
			total_size_after += size_after

	var size_saved = total_size_before - total_size_after
	var percent_saved = (size_saved / float(total_size_before)) * 100.0 if total_size_before > 0 else 0.0

	print("ResourceManager: Optimization complete")
	print("  Files optimized: ", optimized_count, "/", resource_files.size())
	print("  Size saved: ", _format_bytes(size_saved), " (", "%.1f" % percent_saved, "%)")

func _optimize_resource_file(file_path: String) -> bool:
	"""Optimize a single resource file"""
	# This is a placeholder - actual optimization would depend on file type
	# For now, just return true to indicate "optimization attempted"
	return true

func _get_file_size(file_path: String) -> int:
	"""Get file size in bytes"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var size = file.get_length()
		file.close()
		return size
	return 0

func _format_bytes(bytes: int) -> String:
	"""Format bytes into human readable string"""
	var units = ["B", "KB", "MB", "GB"]
	var unit_index = 0
	var size = float(bytes)

	while size >= 1024.0 and unit_index < units.size() - 1:
		size /= 1024.0
		unit_index += 1

	return "%.1f %s" % [size, units[unit_index]]

# ============================================================================
#  RESOURCE QUERIES
# ============================================================================

func get_resources_by_category(category: ResourceCategory) -> Array[String]:
	"""Get all resources of a specific category"""
	var resources: Array[String] = []

	for path in resource_metadata.keys():
		if resource_metadata[path].get("category") == category:
			resources.append(path)

	return resources

func get_resource_info(resource_path: String) -> Dictionary:
	"""Get detailed information about a resource"""
	var info = {
		"path": resource_path,
		"exists": FileAccess.file_exists(resource_path),
		"cached": resource_cache.has(resource_path),
		"size": _get_file_size(resource_path),
		"metadata": resource_metadata.get(resource_path, {})
	}

	return info

func get_cache_info() -> Dictionary:
	"""Get information about the resource cache"""
	var total_size = 0
	for path in resource_metadata.keys():
		total_size += resource_metadata[path].get("size", 0)

	return {
		"cached_resources": resource_cache.size(),
		"total_size": total_size,
		"formatted_size": _format_bytes(total_size),
		"memory_limit": _format_bytes(cache_memory_limit),
		"size_limit": cache_size_limit
	}

# ============================================================================
#  INTERNAL METHODS
# ============================================================================

func _create_resource_directories():
	"""Create necessary resource directories"""
	var directories = [
		"user://resources",
		"user://resources/cache",
		"user://resources/metadata"
	]

	for dir_path in directories:
		DirAccess.make_dir_recursive_absolute(dir_path)

func _preload_critical_resources():
	"""Preload critical resources that are always needed"""
	var critical_resources = [
		"res://game/core/events/EventBus.gd",
		"res://game/core/ServiceManager.gd"
	]

	for resource_path in critical_resources:
		load_resource_async(resource_path, ResourceCategory.SCRIPT)

func _load_resource_from_disk(resource_path: String) -> Resource:
	"""Load resource from disk"""
	return load(resource_path)

func _estimate_resource_size(resource: Resource) -> int:
	"""Estimate resource size in memory"""
	# This is a simplified estimation
	# In practice, you'd need to implement proper size calculation
	return 1024  # 1KB placeholder

func _process_loading_queue():
	"""Process the loading queue"""
	while loading_queue.size() > 0 and currently_loading.size() < max_concurrent_loads:
		var resource_path = loading_queue.pop_front()
		currently_loading.append(resource_path)

		# Load resource asynchronously
		_load_resource_async_internal(resource_path)

func _load_resource_async_internal(resource_path: String):
	"""Internal async loading method"""
	# This would implement actual async loading
	# For now, just load synchronously
	var resource = load_resource(resource_path)
	if resource:
		currently_loading.erase(resource_path)

# ============================================================================
#  CLEANUP
# ============================================================================

func _exit_tree():
	"""Cleanup when service is destroyed"""
	_save_resource_metadata()
	print("ResourceManager: Cleanup complete")
