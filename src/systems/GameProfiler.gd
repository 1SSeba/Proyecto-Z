extends RefCounted

# =======================
#  INTEGRATED PROFILING SYSTEM
# =======================

## Sistema de profiling integrado para monitoreo en tiempo real de performance

class_name GameProfiler

# =======================
#  ESTRUCTURAS DE DATOS
# =======================

class ProfileSection extends RefCounted:
	var name: String
	var start_time: float
	var total_time: float = 0.0
	var call_count: int = 0
	var max_time: float = 0.0
	var min_time: float = INF
	var is_active: bool = false
	
	func _init(section_name: String):
		name = section_name
	
	func start():
		if is_active:
			push_warning("ProfileSection '%s' already active" % name)
			return
		start_time = Time.get_time_dict_from_system().seconds
		is_active = true
	
	func end():
		if not is_active:
			push_warning("ProfileSection '%s' not active" % name)
			return
		
		var duration = Time.get_time_dict_from_system().seconds - start_time
		total_time += duration
		call_count += 1
		max_time = max(max_time, duration)
		min_time = min(min_time, duration)
		is_active = false
	
	func get_average_time() -> float:
		return total_time / max(1, call_count)
	
	func reset():
		total_time = 0.0
		call_count = 0
		max_time = 0.0
		min_time = INF
		is_active = false

class FrameProfileData extends RefCounted:
	var frame_number: int
	var frame_time: float
	var sections: Dictionary = {}
	var timestamp: float
	
	func _init(frame_num: int, frame_duration: float):
		frame_number = frame_num
		frame_time = frame_duration
		timestamp = Time.get_time_dict_from_system().seconds

# =======================
#  PROFILER GLOBAL
# =======================

# Estado del profiler
static var is_enabled: bool = false
static var is_recording: bool = false
static var current_frame: int = 0

# Secciones de profiling
static var sections: Dictionary = {}
static var section_stack: Array[String] = []

# Datos de frames
static var frame_history: Array[FrameProfileData] = []
static var max_frame_history: int = 1000
static var current_frame_data: FrameProfileData

# Estadísticas generales
static var total_frames_profiled: int = 0
static var session_start_time: float = 0.0

# Thresholds para alertas
static var slow_frame_threshold: float = 0.033  # 30fps
static var very_slow_frame_threshold: float = 0.050  # 20fps

# =======================
#  API DE CONTROL
# =======================

static func enable_profiling():
	"""Habilita el sistema de profiling"""
	is_enabled = true
	session_start_time = Time.get_time_dict_from_system().seconds
	print("GameProfiler: Profiling enabled")

static func disable_profiling():
	"""Deshabilita el sistema de profiling"""
	is_enabled = false
	print("GameProfiler: Profiling disabled")

static func start_recording():
	"""Inicia la grabación de datos de profiling"""
	if not is_enabled:
		push_warning("GameProfiler: Cannot start recording - profiling not enabled")
		return
	
	is_recording = true
	frame_history.clear()
	current_frame = 0
	total_frames_profiled = 0
	print("GameProfiler: Recording started")

static func stop_recording():
	"""Detiene la grabación de datos de profiling"""
	is_recording = false
	print("GameProfiler: Recording stopped - %d frames recorded" % frame_history.size())

static func clear_data():
	"""Limpia todos los datos de profiling"""
	frame_history.clear()
	for section_name in sections.keys():
		sections[section_name].reset()
	current_frame = 0
	total_frames_profiled = 0
	print("GameProfiler: All profiling data cleared")

# =======================
#  API DE PROFILING
# =======================

static func start_section(section_name: String):
	"""Inicia el profiling de una sección"""
	if not is_enabled:
		return
	
	# Crear sección si no existe
	if not sections.has(section_name):
		sections[section_name] = ProfileSection.new(section_name)
	
	sections[section_name].start()
	section_stack.push_back(section_name)

static func end_section(section_name: String):
	"""Termina el profiling de una sección"""
	if not is_enabled:
		return
	
	if not sections.has(section_name):
		push_warning("GameProfiler: Section '%s' not found" % section_name)
		return
	
	sections[section_name].end()
	
	# Remover del stack
	var index = section_stack.rfind(section_name)
	if index >= 0:
		section_stack.remove_at(index)

static func profile_function(section_name: String, callable: Callable):
	"""Perfiles una función completa"""
	start_section(section_name)
	var result = callable.call()
	end_section(section_name)
	return result

static func start_frame():
	"""Inicia el profiling de un frame"""
	if not is_enabled or not is_recording:
		return
	
	current_frame += 1
	current_frame_data = FrameProfileData.new(current_frame, 0.0)

static func end_frame():
	"""Termina el profiling de un frame"""
	if not is_enabled or not is_recording or not current_frame_data:
		return
	
	# Calcular duración del frame
	var frame_duration = Time.get_time_dict_from_system().seconds - current_frame_data.timestamp
	current_frame_data.frame_time = frame_duration
	
	# Copiar datos de secciones
	for section_name in sections.keys():
		var section = sections[section_name]
		current_frame_data.sections[section_name] = {
			"total_time": section.total_time,
			"call_count": section.call_count,
			"average_time": section.get_average_time()
		}
	
	# Añadir a historial
	frame_history.append(current_frame_data)
	total_frames_profiled += 1
	
	# Limpiar historial si está lleno
	if frame_history.size() > max_frame_history:
		frame_history.pop_front()
	
	# Detectar frames lentos
	if frame_duration > slow_frame_threshold:
		_alert_slow_frame(current_frame_data)

static func _alert_slow_frame(frame_data: FrameProfileData):
	"""Alerta sobre frames lentos"""
	var severity = "SLOW" if frame_data.frame_time < very_slow_frame_threshold else "VERY SLOW"
	print("GameProfiler: %s FRAME detected - Frame %d: %.3fs" % [severity, frame_data.frame_number, frame_data.frame_time])

# =======================
#  ANÁLISIS DE DATOS
# =======================

static func get_section_statistics(section_name: String) -> Dictionary:
	"""Obtiene estadísticas de una sección específica"""
	if not sections.has(section_name):
		return {}
	
	var section = sections[section_name]
	return {
		"name": section.name,
		"total_time": section.total_time,
		"call_count": section.call_count,
		"average_time": section.get_average_time(),
		"max_time": section.max_time,
		"min_time": section.min_time if section.min_time != INF else 0.0,
		"calls_per_second": section.call_count / max(1, Time.get_time_dict_from_system().seconds - session_start_time)
	}

static func get_all_section_statistics() -> Dictionary:
	"""Obtiene estadísticas de todas las secciones"""
	var stats = {}
	for section_name in sections.keys():
		stats[section_name] = get_section_statistics(section_name)
	return stats

static func get_frame_statistics(last_n_frames: int = 100) -> Dictionary:
	"""Obtiene estadísticas de frames"""
	if frame_history.is_empty():
		return {}
	
	var frame_count = min(last_n_frames, frame_history.size())
	var frames_to_analyze = frame_history.slice(-frame_count)
	
	var total_time = 0.0
	var min_frame_time = INF
	var max_frame_time = 0.0
	var slow_frames = 0
	
	for frame_data in frames_to_analyze:
		total_time += frame_data.frame_time
		min_frame_time = min(min_frame_time, frame_data.frame_time)
		max_frame_time = max(max_frame_time, frame_data.frame_time)
		
		if frame_data.frame_time > slow_frame_threshold:
			slow_frames += 1
	
	var average_time = total_time / frame_count
	var target_fps = 60.0
	var actual_fps = 1.0 / average_time if average_time > 0 else 0.0
	
	return {
		"frames_analyzed": frame_count,
		"average_frame_time": average_time,
		"min_frame_time": min_frame_time if min_frame_time != INF else 0.0,
		"max_frame_time": max_frame_time,
		"target_fps": target_fps,
		"actual_fps": actual_fps,
		"fps_ratio": actual_fps / target_fps,
		"slow_frames": slow_frames,
		"slow_frame_percentage": (float(slow_frames) / frame_count) * 100.0
	}

static func find_performance_bottlenecks() -> Array[Dictionary]:
	"""Identifica los principales cuellos de botella de performance"""
	var bottlenecks: Array[Dictionary] = []
	
	for section_name in sections.keys():
		var stats = get_section_statistics(section_name)
		var severity = 0
		var reasons = []
		
		# Detectar tiempo total alto
		if stats.total_time > 1.0:  # Más de 1 segundo total
			severity += 3
			reasons.append("High total time: %.3fs" % stats.total_time)
		
		# Detectar tiempo promedio alto
		if stats.average_time > 0.016:  # Más de 16ms promedio
			severity += 2
			reasons.append("High average time: %.3fs" % stats.average_time)
		
		# Detectar llamadas muy frecuentes
		if stats.calls_per_second > 100:  # Más de 100 llamadas/seg
			severity += 1
			reasons.append("High call frequency: %.1f calls/sec" % stats.calls_per_second)
		
		# Detectar máximos extremos
		if stats.max_time > 0.1:  # Más de 100ms en una llamada
			severity += 3
			reasons.append("Extreme max time: %.3fs" % stats.max_time)
		
		if severity > 0:
			bottlenecks.append({
				"section": section_name,
				"severity": severity,
				"reasons": reasons,
				"stats": stats
			})
	
	# Ordenar por severidad
	bottlenecks.sort_custom(func(a, b): return a.severity > b.severity)
	
	return bottlenecks

# =======================
#  REPORTING
# =======================

static func generate_report() -> String:
	"""Genera un reporte completo de profiling"""
	var report = []
	
	report.append("=== GAME PROFILER REPORT ===")
	report.append("Session Duration: %.1fs" % (Time.get_time_dict_from_system().seconds - session_start_time))
	report.append("Total Frames Profiled: %d" % total_frames_profiled)
	report.append("")
	
	# Frame statistics
	var frame_stats = get_frame_statistics()
	if frame_stats.size() > 0:
		report.append("FRAME PERFORMANCE:")
		report.append("  Average FPS: %.1f (target: %.1f)" % [frame_stats.actual_fps, frame_stats.target_fps])
		report.append("  Frame Time: %.3fs avg, %.3fs min, %.3fs max" % [frame_stats.average_frame_time, frame_stats.min_frame_time, frame_stats.max_frame_time])
		report.append("  Slow Frames: %d (%.1f%%)" % [frame_stats.slow_frames, frame_stats.slow_frame_percentage])
		report.append("")
	
	# Section statistics
	var section_stats = get_all_section_statistics()
	if section_stats.size() > 0:
		report.append("SECTION PERFORMANCE:")
		
		# Ordenar por tiempo total
		var sorted_sections = []
		for section_name in section_stats.keys():
			sorted_sections.append([section_name, section_stats[section_name]])
		sorted_sections.sort_custom(func(a, b): return a[1].total_time > b[1].total_time)
		
		for section_data in sorted_sections:
			var name = section_data[0]
			var stats = section_data[1]
			report.append("  %s:" % name)
			report.append("    Total: %.3fs, Calls: %d, Avg: %.3fs" % [stats.total_time, stats.call_count, stats.average_time])
			report.append("    Range: %.3fs - %.3fs" % [stats.min_time, stats.max_time])
		report.append("")
	
	# Bottlenecks
	var bottlenecks = find_performance_bottlenecks()
	if bottlenecks.size() > 0:
		report.append("PERFORMANCE BOTTLENECKS:")
		for i in min(5, bottlenecks.size()):  # Top 5
			var bottleneck = bottlenecks[i]
			report.append("  %d. %s (severity: %d)" % [i + 1, bottleneck.section, bottleneck.severity])
			for reason in bottleneck.reasons:
				report.append("     - %s" % reason)
		report.append("")
	
	report.append("==========================")
	
	return "\n".join(report)

static func print_report():
	"""Imprime el reporte de profiling"""
	print(generate_report())

static func save_report_to_file(file_path: String = "user://profiling_report.txt"):
	"""Guarda el reporte a un archivo"""
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(generate_report())
		file.close()
		print("GameProfiler: Report saved to %s" % file_path)
	else:
		push_error("GameProfiler: Failed to save report to %s" % file_path)

# =======================
#  MACROS DE CONVENIENCIA
# =======================

static func profile_block(section_name: String, block: Callable):
	"""Macro para perfilar un bloque de código"""
	start_section(section_name)
	var result = block.call()
	end_section(section_name)
	return result

# Auto-profiling para funciones comunes del engine
static func auto_profile_process(delta: float, process_func: Callable):
	"""Auto-profiling para _process"""
	start_section("_process")
	var result = process_func.call(delta)
	end_section("_process")
	return result

static func auto_profile_physics_process(delta: float, physics_func: Callable):
	"""Auto-profiling para _physics_process"""
	start_section("_physics_process")
	var result = physics_func.call(delta)
	end_section("_physics_process")
	return result

# =======================
#  INTEGRATION HELPERS
# =======================

static func setup_auto_profiling():
	"""Configura profiling automático en managers principales"""
	enable_profiling()
	start_recording()
	print("GameProfiler: Auto-profiling setup complete")

static func get_quick_stats() -> Dictionary:
	"""Obtiene estadísticas rápidas para debugging"""
	var frame_stats = get_frame_statistics(60)  # Últimos 60 frames
	var quick_stats = {}
	
	if frame_stats.size() > 0:
		quick_stats["fps"] = frame_stats.actual_fps
		quick_stats["frame_time"] = frame_stats.average_frame_time
		quick_stats["performance"] = "Good" if frame_stats.actual_fps > 55 else "Poor"
	
	quick_stats["sections_active"] = sections.size()
	quick_stats["frames_recorded"] = frame_history.size()
	
	return quick_stats
