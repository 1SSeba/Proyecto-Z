extends Control
class_name BackgroundManager

@export var default_background_color: Color = Color(0.05, 0.05, 0.1, 1)
@export var enable_parallax: bool = false
@export var parallax_speed: float = 0.1

var current_background: Control = null
var is_transitioning: bool = false

func _ready():
	name = "BackgroundManager"
	_setup_default_background()

# Background management
func _setup_default_background():
	var bg_rect = ColorRect.new()
	bg_rect.name = "DefaultBackground"
	bg_rect.color = default_background_color
	bg_rect.anchors_preset = Control.PRESET_FULL_RECT
	add_child(bg_rect)
	current_background = bg_rect

func set_background_color(color: Color):
	if current_background and current_background.has_method("set_color"):
		current_background.color = color

func change_background(new_background: Control, transition_duration: float = 0.5):
	if is_transitioning:
		return

	is_transitioning = true

	add_child(new_background)
	new_background.modulate.a = 0.0

	var tween = create_tween()
	tween.parallel().tween_property(new_background, "modulate:a", 1.0, transition_duration)

	if current_background:
		tween.parallel().tween_property(current_background, "modulate:a", 0.0, transition_duration)

	await tween.finished

	if current_background:
		current_background.queue_free()

	current_background = new_background
	is_transitioning = false

# Parallax effects
func enable_parallax_effect(enable: bool):
	enable_parallax = enable

func _process(_delta):
	if enable_parallax and current_background:
		# Simple parallax effect based on mouse position
		var mouse_pos = get_global_mouse_position()
		var viewport_size = get_viewport().get_visible_rect().size
		var offset = (mouse_pos - viewport_size * 0.5) * parallax_speed

		if current_background.has_method("set_position"):
			current_background.position = offset
