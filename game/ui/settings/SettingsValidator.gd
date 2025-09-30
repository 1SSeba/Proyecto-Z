## SettingsValidator - Validation System for Settings
##
## Provides validation for all settings values to ensure data integrity
## and prevent invalid configurations.
##
## @author: Professional Refactor
## @version: 2.0

extends RefCounted

# ============================================================================
# VALIDATION RULES
# ============================================================================

## Audio validation rules
const AUDIO_RULES := {
	"master_volume": {"type": TYPE_FLOAT, "min": 0.0, "max": 1.0},
	"music_volume": {"type": TYPE_FLOAT, "min": 0.0, "max": 1.0},
	"sfx_volume": {"type": TYPE_FLOAT, "min": 0.0, "max": 1.0},
	"spatial_audio": {"type": TYPE_BOOL}
}

## Video validation rules
const VIDEO_RULES := {
	"vsync": {"type": TYPE_BOOL},
	"resolution_index": {"type": TYPE_INT, "min": 0, "max": 4},
	"window_mode_index": {"type": TYPE_INT, "min": 0, "max": 3},
	"fps_index": {"type": TYPE_INT, "min": 0, "max": 6}
}

## Controls validation rules
const CONTROLS_RULES := {
	"mouse_sensitivity": {"type": TYPE_FLOAT, "min": 0.1, "max": 5.0},
	"mouse_invert_x": {"type": TYPE_BOOL},
	"mouse_invert_y": {"type": TYPE_BOOL}
}

## All validation rules by section
const SECTION_RULES := {
	"audio": AUDIO_RULES,
	"video": VIDEO_RULES,
	"controls": CONTROLS_RULES
}

# ============================================================================
# VALIDATION METHODS
# ============================================================================

## Validate a complete settings dictionary
## Returns: { "valid": bool, "errors": Array[String] }
static func validate_settings(settings: Dictionary) -> Dictionary:
	var errors: Array[String] = []

	for section in settings.keys():
		if not SECTION_RULES.has(section):
			errors.append("Unknown settings section: %s" % section)
			continue

		var section_errors := validate_section(section, settings[section])
		errors.append_array(section_errors)

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

## Validate an entire section
static func validate_section(section: String, section_data: Dictionary) -> Array[String]:
	var errors: Array[String] = []

	if not SECTION_RULES.has(section):
		errors.append("Unknown section: %s" % section)
		return errors

	var rules: Dictionary = SECTION_RULES[section]

	for key in section_data.keys():
		if not rules.has(key):
			errors.append("Unknown key '%s' in section '%s'" % [key, section])
			continue

		var value = section_data[key]
		var error := validate_value(section, key, value)
		if not error.is_empty():
			errors.append(error)

	return errors

## Validate a single value
## Returns: Empty string if valid, error message if invalid
static func validate_value(section: String, key: String, value) -> String:
	if not SECTION_RULES.has(section):
		return "Unknown section: %s" % section

	var rules: Dictionary = SECTION_RULES[section]
	if not rules.has(key):
		return "Unknown key '%s' in section '%s'" % [key, section]

	var rule: Dictionary = rules[key]

	# Type validation
	var expected_type: int = rule.get("type", TYPE_NIL)
	if expected_type != TYPE_NIL and typeof(value) != expected_type:
		return "Invalid type for %s.%s: expected %s, got %s" % [
			section, key,
			_type_to_string(expected_type),
			_type_to_string(typeof(value))
		]

	# Range validation for numeric types
	if expected_type in [TYPE_INT, TYPE_FLOAT]:
		if rule.has("min") and value < rule.min:
			return "Value for %s.%s is below minimum: %s < %s" % [
				section, key, value, rule.min
			]

		if rule.has("max") and value > rule.max:
			return "Value for %s.%s exceeds maximum: %s > %s" % [
				section, key, value, rule.max
			]

	return ""

## Clamp a value to its valid range
static func clamp_value(section: String, key: String, value):
	if not SECTION_RULES.has(section):
		return value

	var rules: Dictionary = SECTION_RULES[section]
	if not rules.has(key):
		return value

	var rule: Dictionary = rules[key]
	var expected_type: int = rule.get("type", TYPE_NIL)

	# Only clamp numeric types
	if expected_type not in [TYPE_INT, TYPE_FLOAT]:
		return value

	var min_val = rule.get("min", -INF)
	var max_val = rule.get("max", INF)

	if expected_type == TYPE_INT:
		return clampi(int(value), int(min_val), int(max_val))
	else:
		return clampf(float(value), float(min_val), float(max_val))

## Get the default value for a key if validation fails
static func get_safe_default(section: String, key: String):
	match section:
		"audio":
			match key:
				"master_volume", "music_volume", "sfx_volume": return 0.8
				"spatial_audio": return false
		"video":
			match key:
				"vsync": return true
				"resolution_index": return 2 # 1920x1080
				"window_mode_index": return 0 # Windowed
				"fps_index": return 1 # 60 FPS
		"controls":
			match key:
				"mouse_sensitivity": return 1.0
				"mouse_invert_x", "mouse_invert_y": return false

	return null

## Check if a section exists in validation rules
static func has_section(section: String) -> bool:
	return SECTION_RULES.has(section)

## Check if a key exists in a section's validation rules
static func has_key(section: String, key: String) -> bool:
	return SECTION_RULES.has(section) and SECTION_RULES[section].has(key)

## Get validation rule for a specific key
static func get_rule(section: String, key: String) -> Dictionary:
	if not has_key(section, key):
		return {}
	return SECTION_RULES[section][key]

# ============================================================================
# HELPER METHODS
# ============================================================================

## Convert type constant to readable string
static func _type_to_string(type: int) -> String:
	match type:
		TYPE_NIL: return "null"
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "String"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR2I: return "Vector2i"
		TYPE_RECT2: return "Rect2"
		TYPE_VECTOR3: return "Vector3"
		TYPE_TRANSFORM2D: return "Transform2D"
		TYPE_VECTOR4: return "Vector4"
		TYPE_PLANE: return "Plane"
		TYPE_QUATERNION: return "Quaternion"
		TYPE_AABB: return "AABB"
		TYPE_BASIS: return "Basis"
		TYPE_TRANSFORM3D: return "Transform3D"
		TYPE_PROJECTION: return "Projection"
		TYPE_COLOR: return "Color"
		TYPE_STRING_NAME: return "StringName"
		TYPE_NODE_PATH: return "NodePath"
		TYPE_RID: return "RID"
		TYPE_OBJECT: return "Object"
		TYPE_CALLABLE: return "Callable"
		TYPE_SIGNAL: return "Signal"
		TYPE_DICTIONARY: return "Dictionary"
		TYPE_ARRAY: return "Array"
		TYPE_PACKED_BYTE_ARRAY: return "PackedByteArray"
		TYPE_PACKED_INT32_ARRAY: return "PackedInt32Array"
		TYPE_PACKED_INT64_ARRAY: return "PackedInt64Array"
		TYPE_PACKED_FLOAT32_ARRAY: return "PackedFloat32Array"
		TYPE_PACKED_FLOAT64_ARRAY: return "PackedFloat64Array"
		TYPE_PACKED_STRING_ARRAY: return "PackedStringArray"
		TYPE_PACKED_VECTOR2_ARRAY: return "PackedVector2Array"
		TYPE_PACKED_VECTOR3_ARRAY: return "PackedVector3Array"
		TYPE_PACKED_COLOR_ARRAY: return "PackedColorArray"
		_: return "Unknown(%d)" % type
