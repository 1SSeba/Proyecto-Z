extends RefCounted

# =======================
#  MEMORY POOLS ESPECIALIZADOS
# =======================

## Sistema de memory pools especializados por tipo para máxima eficiencia

class_name MemoryPools

# =======================
#  POOLS ESPECIALIZADOS
# =======================

# Pool para Node2D instances
class Node2DPool extends RefCounted:
	var available_nodes: Array[Node2D] = []
	var active_nodes: Array[Node2D] = []
	var scene_template: PackedScene
	var max_pool_size: int = 100
	var created_count: int = 0
	
	func _init(template: PackedScene, max_size: int = 100):
		scene_template = template
		max_pool_size = max_size
	
	func get_node() -> Node2D:
		if available_nodes.size() > 0:
			var node = available_nodes.pop_back()
			active_nodes.append(node)
			return node
		else:
			# Crear nuevo si no hay disponibles
			if scene_template:
				var node = scene_template.instantiate() as Node2D
				if node:
					active_nodes.append(node)
					created_count += 1
					return node
		return null
	
	func return_node(node: Node2D):
		var index = active_nodes.find(node)
		if index >= 0:
			active_nodes.remove_at(index)
			
			# Reset node state
			node.position = Vector2.ZERO
			node.rotation = 0.0
			node.scale = Vector2.ONE
			node.visible = true
			
			# Return to pool if not full
			if available_nodes.size() < max_pool_size:
				available_nodes.append(node)
			else:
				# Destroy excess nodes
				node.queue_free()

# Pool para AudioStreamPlayer instances
class AudioPlayerPool extends RefCounted:
	var available_players: Array[AudioStreamPlayer] = []
	var active_players: Array[AudioStreamPlayer] = []
	var max_pool_size: int = 20
	var parent_node: Node
	
	func _init(parent: Node, max_size: int = 20):
		parent_node = parent
		max_pool_size = max_size
		_warm_up_pool()
	
	func _warm_up_pool():
		for i in int(max_pool_size / 2.0):
			var player = AudioStreamPlayer.new()
			player.finished.connect(_on_player_finished.bind(player))
			parent_node.add_child(player)
			available_players.append(player)
	
	func get_player() -> AudioStreamPlayer:
		if available_players.size() > 0:
			var player = available_players.pop_back()
			active_players.append(player)
			return player
		else:
			# Create new if pool is empty
			var player = AudioStreamPlayer.new()
			player.finished.connect(_on_player_finished.bind(player))
			parent_node.add_child(player)
			active_players.append(player)
			return player
	
	func _on_player_finished(player: AudioStreamPlayer):
		return_player(player)
	
	func return_player(player: AudioStreamPlayer):
		var index = active_players.find(player)
		if index >= 0:
			active_players.remove_at(index)
			
			# Reset player state
			player.stop()
			player.stream = null
			player.volume_db = 0.0
			
			# Return to pool
			if available_players.size() < max_pool_size:
				available_players.append(player)

# Pool para partículas
class ParticlePool extends RefCounted:
	var available_particles: Array[GPUParticles2D] = []
	var active_particles: Array[GPUParticles2D] = []
	var particle_material: ParticleProcessMaterial
	var max_pool_size: int = 50
	var parent_node: Node
	
	func _init(parent: Node, material: ParticleProcessMaterial, max_size: int = 50):
		parent_node = parent
		particle_material = material
		max_pool_size = max_size
		_warm_up_pool()
	
	func _warm_up_pool():
		for i in int(max_pool_size / 3.0):  # Warm up 1/3 of pool
			var particles = GPUParticles2D.new()
			particles.process_material = particle_material
			particles.emitting = false
			particles.finished.connect(_on_particles_finished.bind(particles))
			parent_node.add_child(particles)
			available_particles.append(particles)
	
	func get_particles() -> GPUParticles2D:
		if available_particles.size() > 0:
			var particles = available_particles.pop_back()
			active_particles.append(particles)
			return particles
		else:
			# Create new if needed
			var particles = GPUParticles2D.new()
			particles.process_material = particle_material
			particles.finished.connect(_on_particles_finished.bind(particles))
			parent_node.add_child(particles)
			active_particles.append(particles)
			return particles
	
	func _on_particles_finished(particles: GPUParticles2D):
		return_particles(particles)
	
	func return_particles(particles: GPUParticles2D):
		var index = active_particles.find(particles)
		if index >= 0:
			active_particles.remove_at(index)
			
			# Reset particles
			particles.emitting = false
			particles.position = Vector2.ZERO
			particles.rotation = 0.0
			
			# Return to pool
			if available_particles.size() < max_pool_size:
				available_particles.append(particles)

# =======================
#  MANAGER GLOBAL
# =======================

# Pools específicos
static var node2d_pools: Dictionary = {}
static var audio_player_pool: AudioPlayerPool = null
static var particle_pools: Dictionary = {}

# Estadísticas globales
static var total_allocations: int = 0
static var total_deallocations: int = 0
static var pool_hits: int = 0
static var pool_misses: int = 0

# =======================
#  API PARA NODE2D POOLS
# =======================

static func register_node2d_pool(pool_name: String, scene_template: PackedScene, max_size: int = 100):
	"""Registra un pool de Node2D con template específico"""
	if not node2d_pools.has(pool_name):
		node2d_pools[pool_name] = Node2DPool.new(scene_template, max_size)
		print("MemoryPools: Registered Node2D pool '%s' with max size %d" % [pool_name, max_size])

static func get_node2d(pool_name: String) -> Node2D:
	"""Obtiene un Node2D del pool especificado"""
	if node2d_pools.has(pool_name):
		total_allocations += 1
		var node = node2d_pools[pool_name].get_node()
		if node:
			pool_hits += 1
		else:
			pool_misses += 1
		return node
	
	push_warning("MemoryPools: Pool '%s' not found" % pool_name)
	pool_misses += 1
	return null

static func return_node2d(pool_name: String, node: Node2D):
	"""Retorna un Node2D al pool especificado"""
	if node2d_pools.has(pool_name):
		node2d_pools[pool_name].return_node(node)
		total_deallocations += 1
	else:
		push_warning("MemoryPools: Pool '%s' not found for return" % pool_name)

# =======================
#  API PARA AUDIO POOLS
# =======================

static func initialize_audio_pool(parent: Node, max_size: int = 20):
	"""Inicializa el pool global de AudioStreamPlayer"""
	if not audio_player_pool:
		audio_player_pool = AudioPlayerPool.new(parent, max_size)
		print("MemoryPools: Initialized audio player pool with max size %d" % max_size)

static func get_audio_player() -> AudioStreamPlayer:
	"""Obtiene un AudioStreamPlayer del pool"""
	if audio_player_pool:
		total_allocations += 1
		var player = audio_player_pool.get_player()
		if player:
			pool_hits += 1
		else:
			pool_misses += 1
		return player
	
	push_warning("MemoryPools: Audio pool not initialized")
	pool_misses += 1
	return null

static func return_audio_player(player: AudioStreamPlayer):
	"""Retorna un AudioStreamPlayer al pool"""
	if audio_player_pool:
		audio_player_pool.return_player(player)
		total_deallocations += 1

# =======================
#  API PARA PARTICLE POOLS
# =======================

static func register_particle_pool(pool_name: String, parent: Node, material: ParticleProcessMaterial, max_size: int = 50):
	"""Registra un pool de partículas con material específico"""
	if not particle_pools.has(pool_name):
		particle_pools[pool_name] = ParticlePool.new(parent, material, max_size)
		print("MemoryPools: Registered particle pool '%s' with max size %d" % [pool_name, max_size])

static func get_particles(pool_name: String) -> GPUParticles2D:
	"""Obtiene partículas del pool especificado"""
	if particle_pools.has(pool_name):
		total_allocations += 1
		var particles = particle_pools[pool_name].get_particles()
		if particles:
			pool_hits += 1
		else:
			pool_misses += 1
		return particles
	
	push_warning("MemoryPools: Particle pool '%s' not found" % pool_name)
	pool_misses += 1
	return null

static func return_particles(pool_name: String, particles: GPUParticles2D):
	"""Retorna partículas al pool especificado"""
	if particle_pools.has(pool_name):
		particle_pools[pool_name].return_particles(particles)
		total_deallocations += 1

# =======================
#  BULK OPERATIONS
# =======================

static func warm_up_all_pools():
	"""Pre-llena todos los pools registrados"""
	print("MemoryPools: Warming up all pools...")
	
	for pool_name in node2d_pools.keys():
		var _pool = node2d_pools[pool_name]
		# Los Node2D pools se llenan bajo demanda para evitar problemas de escena
	
	# Audio pools ya se llenan en init
	# Particle pools ya se llenan en init
	
	print("MemoryPools: All pools warmed up")

static func cleanup_all_pools():
	"""Limpia todos los pools liberando memoria"""
	print("MemoryPools: Cleaning up all pools...")
	
	# Cleanup Node2D pools
	for pool_name in node2d_pools.keys():
		var pool = node2d_pools[pool_name]
		for node in pool.available_nodes:
			if is_instance_valid(node):
				node.queue_free()
		for node in pool.active_nodes:
			if is_instance_valid(node):
				node.queue_free()
		pool.available_nodes.clear()
		pool.active_nodes.clear()
	
	# Reset statistics
	total_allocations = 0
	total_deallocations = 0
	pool_hits = 0
	pool_misses = 0
	
	print("MemoryPools: All pools cleaned up")

# =======================
#  STATISTICS Y MONITORING
# =======================

static func get_pool_statistics() -> Dictionary:
	"""Retorna estadísticas detalladas de todos los pools"""
	var stats = {
		"global": {
			"total_allocations": total_allocations,
			"total_deallocations": total_deallocations,
			"pool_hits": pool_hits,
			"pool_misses": pool_misses,
			"hit_ratio": float(pool_hits) / max(1, pool_hits + pool_misses)
		},
		"node2d_pools": {},
		"audio_pool": {},
		"particle_pools": {}
	}
	
	# Node2D pool stats
	for pool_name in node2d_pools.keys():
		var pool = node2d_pools[pool_name]
		stats.node2d_pools[pool_name] = {
			"available": pool.available_nodes.size(),
			"active": pool.active_nodes.size(),
			"created_total": pool.created_count,
			"max_size": pool.max_pool_size
		}
	
	# Audio pool stats
	if audio_player_pool:
		stats.audio_pool = {
			"available": audio_player_pool.available_players.size(),
			"active": audio_player_pool.active_players.size(),
			"max_size": audio_player_pool.max_pool_size
		}
	
	# Particle pool stats
	for pool_name in particle_pools.keys():
		var pool = particle_pools[pool_name]
		stats.particle_pools[pool_name] = {
			"available": pool.available_particles.size(),
			"active": pool.active_particles.size(),
			"max_size": pool.max_pool_size
		}
	
	return stats

static func print_pool_statistics():
	"""Imprime estadísticas de pools en formato legible"""
	var stats = get_pool_statistics()
	
	print("=== MEMORY POOLS STATISTICS ===")
	print("Global Stats:")
	print("  Allocations: %d, Deallocations: %d" % [stats.global.total_allocations, stats.global.total_deallocations])
	print("  Pool Hits: %d, Misses: %d (%.1f%% hit rate)" % [stats.global.pool_hits, stats.global.pool_misses, stats.global.hit_ratio * 100])
	
	print("Node2D Pools:")
	for pool_name in stats.node2d_pools.keys():
		var pool_stats = stats.node2d_pools[pool_name]
		print("  %s: %d available, %d active, %d/%d capacity" % [pool_name, pool_stats.available, pool_stats.active, pool_stats.available + pool_stats.active, pool_stats.max_size])
	
	if stats.audio_pool.size() > 0:
		print("Audio Pool: %d available, %d active, %d max" % [stats.audio_pool.available, stats.audio_pool.active, stats.audio_pool.max_size])
	
	print("Particle Pools:")
	for pool_name in stats.particle_pools.keys():
		var pool_stats = stats.particle_pools[pool_name]
		print("  %s: %d available, %d active, %d max" % [pool_name, pool_stats.available, pool_stats.active, pool_stats.max_size])
	
	print("==============================")

# =======================
#  PROFILING Y BENCHMARKS
# =======================

static func benchmark_pool_performance(iterations: int = 1000) -> Dictionary:
	"""Benchmarka la performance de los pools"""
	var results = {}
	
	# Solo benchmark si hay pools de audio inicializados
	if audio_player_pool:
		var start_time = Time.get_time_dict_from_system()
		
		# Test allocation/deallocation cycles
		for i in iterations:
			var player = get_audio_player()
			if player:
				return_audio_player(player)
		
		var duration = Time.get_time_dict_from_system().seconds - start_time.seconds
		results["audio_pool"] = {
			"iterations": iterations,
			"duration": duration,
			"ops_per_second": iterations / max(duration, 0.001)
		}
	
	return results

static func get_memory_usage_estimate() -> Dictionary:
	"""Estima el uso de memoria de los pools"""
	var usage = {
		"total_estimated_kb": 0.0,
		"breakdown": {}
	}
	
	# Estimar Node2D pools (aproximado)
	for pool_name in node2d_pools.keys():
		var pool = node2d_pools[pool_name]
		var estimated_kb = (pool.available_nodes.size() + pool.active_nodes.size()) * 0.5  # ~0.5KB por Node2D
		usage.breakdown[pool_name] = estimated_kb
		usage.total_estimated_kb += estimated_kb
	
	# Estimar audio pool
	if audio_player_pool:
		var estimated_kb = (audio_player_pool.available_players.size() + audio_player_pool.active_players.size()) * 0.2  # ~0.2KB por AudioStreamPlayer
		usage.breakdown["audio_pool"] = estimated_kb
		usage.total_estimated_kb += estimated_kb
	
	# Estimar particle pools
	for pool_name in particle_pools.keys():
		var pool = particle_pools[pool_name]
		var estimated_kb = (pool.available_particles.size() + pool.active_particles.size()) * 1.0  # ~1KB por GPUParticles2D
		usage.breakdown[pool_name + "_particles"] = estimated_kb
		usage.total_estimated_kb += estimated_kb
	
	return usage
