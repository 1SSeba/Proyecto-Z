extends Node
class_name TransitionManager

## TransitionManager - Simple transition system for UI elements

# ============================================================================
#  PROPERTIES
# ============================================================================

var service_name: String = "TransitionService"

# ============================================================================
#  ENUMS
# ============================================================================

enum TransitionType {
	FADE_IN,
	FADE_OUT,
	SCALE_IN,
	SCALE_OUT,
	SLIDE_IN,
	SLIDE_OUT
}

enum EasingType {
	EASE_IN,
	EASE_OUT,
	EASE_IN_OUT,
	LINEAR
}

# ============================================================================
#  SIGNALS
# ============================================================================

signal transition_completed(node: Control, config: Dictionary)

# ============================================================================
#  PROPERTIES
# ============================================================================

var active_transitions: Dictionary = {}

# ============================================================================
#  TRANSITION CONFIG
# ============================================================================

func create_custom_config() -> Dictionary:
	"""Create a custom transition configuration"""
	return {
		"type": TransitionType.FADE_IN,
		"duration": 0.3,
		"easing": EasingType.EASE_OUT,
		"scale_start": Vector2.ONE,
		"scale_end": Vector2.ONE,
		"alpha_start": 1.0,
		"alpha_end": 1.0,
		"position_start": Vector2.ZERO,
		"position_end": Vector2.ZERO
	}

# ============================================================================
#  MAIN TRANSITION METHODS
# ============================================================================

func start_transition(node: Control, config: Dictionary):
	"""Start a transition on a node"""
	if not node or not is_instance_valid(node):
		return
	
	# Cancel any existing transition on this node
	if active_transitions.has(node):
		active_transitions[node].kill()
	
	var tween = create_tween()
	active_transitions[node] = tween
	
	# Setup transition based on type
	match config.get("type", TransitionType.FADE_IN):
		TransitionType.FADE_IN:
			_fade_in(node, config, tween)
		TransitionType.FADE_OUT:
			_fade_out(node, config, tween)
		TransitionType.SCALE_IN:
			_scale_in(node, config, tween)
		TransitionType.SCALE_OUT:
			_scale_out(node, config, tween)
		_:
			_fade_in(node, config, tween)
	
	# Connect completion signal
	tween.finished.connect(_on_transition_finished.bind(node, config))

func transition_in(node: Control, _transition_name: String):
	"""Quick transition in with preset"""
	var config = create_custom_config()
	config.type = TransitionType.FADE_IN
	config.duration = 0.3
	start_transition(node, config)

func transition_out(node: Control, _transition_name: String):
	"""Quick transition out with preset"""
	var config = create_custom_config()
	config.type = TransitionType.FADE_OUT
	config.duration = 0.3
	start_transition(node, config)

# ============================================================================
#  TRANSITION IMPLEMENTATIONS
# ============================================================================

func _fade_in(node: Control, config: Dictionary, tween: Tween):
	"""Fade in transition"""
	var duration = config.get("duration", 0.3)
	var easing_type = config.get("easing", EasingType.EASE_OUT)
	
	node.modulate.a = 0.0
	node.visible = true
	
	var easing = _get_tween_easing(easing_type)
	tween.tween_property(node, "modulate:a", 1.0, duration).set_ease(easing.ease).set_trans(easing.trans)

func _fade_out(node: Control, config: Dictionary, tween: Tween):
	"""Fade out transition"""
	var duration = config.get("duration", 0.3)
	var easing_type = config.get("easing", EasingType.EASE_IN)
	
	node.modulate.a = 1.0
	
	var easing = _get_tween_easing(easing_type)
	tween.tween_property(node, "modulate:a", 0.0, duration).set_ease(easing.ease).set_trans(easing.trans)

func _scale_in(node: Control, config: Dictionary, tween: Tween):
	"""Scale in transition"""
	var duration = config.get("duration", 0.3)
	var easing_type = config.get("easing", EasingType.EASE_OUT)
	var scale_start = config.get("scale_start", Vector2(0.8, 0.8))
	var scale_end = config.get("scale_end", Vector2.ONE)
	
	node.scale = scale_start
	node.visible = true
	
	var easing = _get_tween_easing(easing_type)
	tween.tween_property(node, "scale", scale_end, duration).set_ease(easing.ease).set_trans(easing.trans)

func _scale_out(node: Control, config: Dictionary, tween: Tween):
	"""Scale out transition"""
	var duration = config.get("duration", 0.3)
	var easing_type = config.get("easing", EasingType.EASE_IN)
	var scale_start = config.get("scale_start", Vector2.ONE)
	var scale_end = config.get("scale_end", Vector2(0.8, 0.8))
	
	node.scale = scale_start
	
	var easing = _get_tween_easing(easing_type)
	tween.tween_property(node, "scale", scale_end, duration).set_ease(easing.ease).set_trans(easing.trans)

# ============================================================================
#  UTILITIES
# ============================================================================

func _get_tween_easing(easing_type: EasingType) -> Dictionary:
	"""Get Tween easing values"""
	match easing_type:
		EasingType.EASE_IN:
			return {"ease": Tween.EASE_IN, "trans": Tween.TRANS_CUBIC}
		EasingType.EASE_OUT:
			return {"ease": Tween.EASE_OUT, "trans": Tween.TRANS_CUBIC}
		EasingType.EASE_IN_OUT:
			return {"ease": Tween.EASE_IN_OUT, "trans": Tween.TRANS_CUBIC}
		EasingType.LINEAR:
			return {"ease": Tween.EASE_IN_OUT, "trans": Tween.TRANS_LINEAR}
		_:
			return {"ease": Tween.EASE_OUT, "trans": Tween.TRANS_CUBIC}

func _on_transition_finished(node: Control, config: Dictionary):
	"""Handle transition completion"""
	if active_transitions.has(node):
		active_transitions.erase(node)
	
	# Hide node if it was a fade out transition
	if config.get("type") == TransitionType.FADE_OUT:
		if is_instance_valid(node):
			node.visible = false
	
	# Emit completion signal
	transition_completed.emit(node, config)

# ============================================================================
#  CLEANUP
# ============================================================================

func stop_all_transitions():
	"""Stop all active transitions"""
	for node in active_transitions.keys():
		if active_transitions[node]:
			active_transitions[node].kill()
	active_transitions.clear()

func stop_transition(node: Control):
	"""Stop transition for a specific node"""
	if active_transitions.has(node):
		active_transitions[node].kill()
		active_transitions.erase(node)
