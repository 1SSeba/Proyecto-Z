extends Control
class_name BackgroundManager

## Background Manager - Professional Procedural Backgrounds
## Manages animated backgrounds with performance optimization
## @author: Senior Graphics Developer (10+ years experience)

# ============================================================================
#  BACKGROUND TYPES
# ============================================================================

enum BackgroundType {
	STARFIELD,
	NEBULA,
	COSMIC,
	MINIMAL,
	CUSTOM
}

# ============================================================================
#  CONFIGURATION
# ============================================================================

@export var background_type: BackgroundType = BackgroundType.STARFIELD
@export var auto_performance_adjust: bool = true
@export var target_fps: int = 60
@export var enable_dynamic_colors: bool = true
@export var color_cycle_speed: float = 1.0

# ============================================================================
#  PERFORMANCE SETTINGS
# ============================================================================

var performance_mode: bool = false
var fps_samples: Array[float] = []
var fps_sample_count: int = 60
var last_fps_check: float = 0.0

# ============================================================================
#  SHADER PROPERTIES
# ============================================================================

var background_rect: ColorRect
var shader_material: ShaderMaterial

# Preset configurations
var presets: Dictionary = {}

# ============================================================================
#  INITIALIZATION
# ============================================================================

func _ready():
	_initialize_background()
	_setup_presets()
	_apply_background_type(background_type)
	
	if auto_performance_adjust:
		set_process(true)

func _initialize_background():
	"""Initialize background rendering"""
	# Create background rect that covers the entire screen
	background_rect = ColorRect.new()
	background_rect.name = "ProceduralBackground"
	background_rect.anchors_preset = Control.PRESET_FULL_RECT
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Load shader material
	var material_path = "res://game/ui/materials/MenuBackground.tres"
	shader_material = load(material_path)
	
	if not shader_material:
		push_error("BackgroundManager: Failed to load shader material")
		return
	
	# Create instance of material to avoid shared modifications
	shader_material = shader_material.duplicate()
	background_rect.material = shader_material
	
	# Add as first child (background layer)
	add_child(background_rect)
	move_child(background_rect, 0)
	
	print("BackgroundManager: Procedural background initialized")

func _setup_presets():
	"""Setup background presets"""
	# Starfield preset
	presets["starfield"] = {
		"time_scale": 1.0,
		"star_count": 800.0,
		"star_speed": 1.0,
		"nebula_intensity": 0.1,
		"nebula_color": Vector3(0.1, 0.1, 0.3),
		"star_color": Vector3(1.0, 1.0, 0.9),
		"gradient_top": Vector3(0.05, 0.05, 0.15),
		"gradient_bottom": Vector3(0.1, 0.05, 0.15),
		"enable_parallax": true,
		"enable_nebula": true,
		"enable_twinkle": true
	}
	
	# Nebula preset
	presets["nebula"] = {
		"time_scale": 0.5,
		"star_count": 400.0,
		"star_speed": 0.5,
		"nebula_intensity": 0.6,
		"nebula_color": Vector3(0.3, 0.1, 0.4),
		"star_color": Vector3(0.9, 0.9, 1.0),
		"gradient_top": Vector3(0.1, 0.05, 0.2),
		"gradient_bottom": Vector3(0.2, 0.1, 0.3),
		"enable_parallax": true,
		"enable_nebula": true,
		"enable_twinkle": true
	}
	
	# Cosmic preset
	presets["cosmic"] = {
		"time_scale": 1.5,
		"star_count": 1200.0,
		"star_speed": 1.5,
		"nebula_intensity": 0.4,
		"nebula_color": Vector3(0.2, 0.3, 0.1),
		"star_color": Vector3(1.0, 0.8, 0.6),
		"gradient_top": Vector3(0.05, 0.1, 0.05),
		"gradient_bottom": Vector3(0.15, 0.2, 0.1),
		"enable_parallax": true,
		"enable_nebula": true,
		"enable_twinkle": true
	}
	
	# Minimal preset (performance)
	presets["minimal"] = {
		"time_scale": 0.8,
		"star_count": 300.0,
		"star_speed": 0.8,
		"nebula_intensity": 0.0,
		"nebula_color": Vector3(0.1, 0.1, 0.1),
		"star_color": Vector3(0.8, 0.8, 0.8),
		"gradient_top": Vector3(0.02, 0.02, 0.05),
		"gradient_bottom": Vector3(0.05, 0.05, 0.1),
		"enable_parallax": false,
		"enable_nebula": false,
		"enable_twinkle": false
	}

# ============================================================================
#  BACKGROUND MANAGEMENT
# ============================================================================

func _apply_background_type(type: BackgroundType):
	"""Apply background type preset"""
	if not shader_material:
		return
	
	var preset_name = ""
	match type:
		BackgroundType.STARFIELD:
			preset_name = "starfield"
		BackgroundType.NEBULA:
			preset_name = "nebula"
		BackgroundType.COSMIC:
			preset_name = "cosmic"
		BackgroundType.MINIMAL:
			preset_name = "minimal"
		_:
			preset_name = "starfield"
	
	apply_preset(preset_name)

func apply_preset(preset_name: String):
	"""Apply a shader preset"""
	if not presets.has(preset_name) or not shader_material:
		return
	
	var preset = presets[preset_name]
	
	for property in preset:
		shader_material.set_shader_parameter(property, preset[property])
	
	print("BackgroundManager: Applied preset '%s'" % preset_name)

func set_shader_parameter(param_name: String, value):
	"""Set individual shader parameter"""
	if shader_material:
		shader_material.set_shader_parameter(param_name, value)

func get_shader_parameter(param_name: String):
	"""Get shader parameter value"""
	if shader_material:
		return shader_material.get_shader_parameter(param_name)
	return null

# ============================================================================
#  PERFORMANCE MONITORING
# ============================================================================

func _process(_delta):
	"""Monitor performance and adjust settings"""
	if not auto_performance_adjust:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Sample FPS every 0.5 seconds
	if current_time - last_fps_check > 0.5:
		var current_fps = Engine.get_frames_per_second()
		fps_samples.append(current_fps)
		
		if fps_samples.size() > fps_sample_count:
			fps_samples.pop_front()
		
		last_fps_check = current_time
		
		# Check if performance adjustment needed
		_check_performance()

func _check_performance():
	"""Check performance and adjust settings if needed"""
	if fps_samples.size() < 10:
		return
	
	# Calculate average FPS
	var avg_fps = 0.0
	for fps in fps_samples:
		avg_fps += fps
	avg_fps /= fps_samples.size()
	
	# Performance mode activation
	if avg_fps < target_fps * 0.8 and not performance_mode:
		_enable_performance_mode()
	elif avg_fps > target_fps * 0.95 and performance_mode:
		_disable_performance_mode()

func _enable_performance_mode():
	"""Enable performance mode"""
	performance_mode = true
	apply_preset("minimal")
	print("BackgroundManager: Performance mode enabled (FPS optimization)")

func _disable_performance_mode():
	"""Disable performance mode"""
	performance_mode = false
	_apply_background_type(background_type)
	print("BackgroundManager: Performance mode disabled (normal quality)")

# ============================================================================
#  DYNAMIC EFFECTS
# ============================================================================

func start_color_cycle():
	"""Start dynamic color cycling"""
	if not enable_dynamic_colors:
		return
	
	var tween = create_tween()
	tween.set_loops()
	
	# Cycle through different color variations
	var colors = [
		Vector3(0.2, 0.1, 0.4),  # Purple
		Vector3(0.1, 0.2, 0.4),  # Blue  
		Vector3(0.1, 0.4, 0.2),  # Green
		Vector3(0.4, 0.2, 0.1),  # Orange
	]
	
	for color in colors:
		tween.tween_method(_update_nebula_color, get_shader_parameter("nebula_color"), color, 2.0 / color_cycle_speed)

func _update_nebula_color(color: Vector3):
	"""Update nebula color smoothly"""
	set_shader_parameter("nebula_color", color)

# ============================================================================
#  PUBLIC API
# ============================================================================

func set_background_type(type: BackgroundType):
	"""Change background type"""
	background_type = type
	_apply_background_type(type)

func set_animation_speed(speed: float):
	"""Set animation speed multiplier"""
	set_shader_parameter("time_scale", speed)

func set_star_density(density: float):
	"""Set star density (100-2000)"""
	set_shader_parameter("star_count", clamp(density, 100.0, 2000.0))

func set_nebula_intensity(intensity: float):
	"""Set nebula intensity (0.0-1.0)"""
	set_shader_parameter("nebula_intensity", clamp(intensity, 0.0, 1.0))

func is_performance_mode() -> bool:
	"""Check if performance mode is active"""
	return performance_mode
