extends Node
# DevTools.gd - Herramientas de desarrollo para facilitar el testing

signal quick_export_requested

func _ready():
	print("🔧 DevTools loaded - Development shortcuts available")
	if OS.has_feature("editor"):
		print("  F6: Quick export for testing video settings")
		print("  F7: Toggle fullscreen (basic)")

func _input(event):
	if not OS.has_feature("editor"):
		return
		
	# Solo procesar en modo editor para desarrollo
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F6:
				_quick_export()
			KEY_F7:
				_toggle_basic_fullscreen()

func _quick_export():
	print("🚀 Quick Export initiated...")
	
	# Verificar si hay presets de exportación configurados
	var export_path = "builds/debug/"
	if not DirAccess.dir_exists_absolute(export_path):
		var dir = DirAccess.open(".")
		if dir:
			dir.make_dir_recursive(export_path)
	
	# Mostrar mensaje al usuario
	var export_message = "🚀 Quick Export - Check builds/debug/ folder when complete"
	if get_node_or_null("/root/Main/UI/StatusLabel"):
		get_node("/root/Main/UI/StatusLabel").text = export_message
	
	print(export_message)
	
	# Emit signal para que otros nodos puedan reaccionar
	quick_export_requested.emit()

func _toggle_basic_fullscreen():
	# Fullscreen básico que SÍ funciona en editor (aunque limitado)
	var current_mode = DisplayServer.window_get_mode()
	
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		print("🖥️ Switched to fullscreen (basic)")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		print("🪟 Switched to windowed mode")

# Función para notificar cambios de configuración de video
func notify_video_settings_changed(setting_name: String, old_value, new_value):
	if OS.has_feature("editor"):
		print("🎮 %s changed: %s -> %s (Export to test fully)" % [setting_name, old_value, new_value])
