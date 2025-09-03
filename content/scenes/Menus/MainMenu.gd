extends Control

# MainMenu.gd - LEGACY STUB
# This file was replaced. Please use `MainMenuModular.tscn` and `MainMenuModular.gd`.

func _ready():
	print("Legacy MainMenu stub loaded — use MainMenuModular instead.")
# Sin StateMachine complicado, solo funcionalidad básica

# =======================
#  NODOS PRINCIPALES
# =======================
@onready var btn_start: Button = $BoxContainer/StartGame
@onready var btn_settings: Button = $BoxContainer/Settings
@onready var btn_quit: Button = $BoxContainer/Quit
@onready var settings_menu: Control = $SettingsMenu

# =======================
#  VARIABLES
# =======================
var is_initialized: bool = false

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
	print("MainMenu: Starting simple initialization...")
	
	# Esperar un frame
	await get_tree().process_frame
	
	# Configurar botones
	# DELETED: legacy MainMenu.gd - removed in favor of MainMenuModular.gd
	if not is_initialized:
		return
	
	if event.is_action_pressed("ui_accept"):  # ENTER
		_on_start_pressed()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("ui_cancel"):  # ESC
		if settings_menu and settings_menu.visible:
			_hide_settings()
		else:
			_on_quit_pressed()
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("menu"):  # TAB/M
		_on_settings_pressed()
		get_viewport().set_input_as_handled()

# =======================
#  BUTTON HANDLERS
# =======================
func _on_start_pressed():
	"""Iniciar el juego"""
	print("🎮 Starting game...")
	
	# Opción 1: Cambiar a escena de juego directamente
	var game_scene = "res://content/scenes/World/world.tscn"
	if ResourceLoader.exists(game_scene):
		get_tree().change_scene_to_file(game_scene)
	else:
		print("❌ Game scene not found: " + game_scene)
	
	# Opción 2: Usar GameManager si está disponible
	if GameManager and GameManager.has_method("start_new_game"):
		GameManager.start_new_game()

func _on_settings_pressed():
	"""Mostrar settings"""
	print("⚙️ Opening settings...")
	_show_settings()

func _on_quit_pressed():
	"""Salir del juego"""
	print("👋 Quitting game...")
	get_tree().quit()

# =======================
#  UI FUNCTIONS
# =======================
func _show_settings():
	"""Mostrar menú de settings"""
	if settings_menu:
		settings_menu.visible = true
		# Si settings tiene focus propio, usarlo
		if settings_menu.has_method("grab_initial_focus"):
			settings_menu.grab_initial_focus()
	else:
		print("❌ Settings menu not found")

func _hide_settings():
	"""Ocultar settings"""
	if settings_menu:
		settings_menu.visible = false
	
	# Volver focus a start button
	if btn_start:
		btn_start.grab_focus()

# =======================
#  DEBUG
# =======================
func _on_debug_info():
	"""Mostrar info de debug (F12)"""
	print("=== MAIN MENU DEBUG ===")
	print("Initialized: %s" % is_initialized)
	print("Start Button: %s" % (btn_start != null))
	print("Settings Button: %s" % (btn_settings != null))
	print("Quit Button: %s" % (btn_quit != null))
	print("Settings Menu: %s" % (settings_menu != null))
	
	print("\n=== CONTROLS ===")
	print("ENTER: Start Game")
	print("TAB/M: Settings")
	print("ESC: Back/Quit")
	print("F12: This debug info")
	print("=====================")

# Función que puede ser llamada desde input de debug
func _unhandled_key_input(event):
	if event.keycode == KEY_F12 and event.pressed:
		_on_debug_info()
