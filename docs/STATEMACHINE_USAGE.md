# Ejemplo de uso del State Machine simplificado
# Este archivo muestra cómo implementar el sistema en tu juego

## 1. Configuración básica en tu escena principal (Main.tscn)

# En Main.gd:
extends Node

@onload var state_machine = StateMachine.new()

func _ready():
	# Configurar debug si necesitas
	state_machine.debug_mode = true
	
	# Agregar al árbol de nodos
	add_child(state_machine)
	
	# Crear e instanciar estados
	var main_menu_state = MainMenuState.new()
	var gameplay_state = GameplayState.new()
	var paused_state = PausedState.new()
	var settings_state = SettingsState.new()
	
	# Agregar estados al state machine
	state_machine.add_child(main_menu_state)
	state_machine.add_child(gameplay_state)
	state_machine.add_child(paused_state)
	state_machine.add_child(settings_state)
	
	# Iniciar con el menú principal
	state_machine.start("MainMenuState")

## 2. Transiciones típicas

# Desde cualquier estado, puedes hacer transición:
# state_machine.transition_to("GameplayState")
# state_machine.transition_to("PausedState", {"pause_reason": "user_input"})

## 3. Estados disponibles y sus transiciones típicas:

# MainMenuState:
#   → GameplayState (cuando se presiona "Jugar")
#   → SettingsState (cuando se presiona "Configuración")

# GameplayState:
#   → PausedState (cuando se presiona ESC/P)
#   → MainMenuState (cuando se muere/completa nivel)

# PausedState:
#   → GameplayState (cuando se reanuda)
#   → MainMenuState (cuando se sale)

# SettingsState:
#   → MainMenuState (cuando se guarda/cancela)

## 4. Eventos del EventBus

# El EventBus se puede usar para comunicación entre estados:
# EventBus.subscribe("game_started", _on_game_started)
# EventBus.publish_game_started()

## 5. Verificaciones útiles

# func _on_some_event():
#     if state_machine.is_in_state("GameplayState"):
#         # Solo hacer algo si estamos jugando
#         pass
#     
#     var current = state_machine.get_current_state_name()
#     print("Estado actual: ", current)

## 6. Datos de transición

# Pasar datos entre estados:
# state_machine.transition_to("GameplayState", {"level": 2, "lives": 3})

# En el estado de destino (GameplayState.enter):
# func enter(previous_state: State = null):
#     var data = state_machine.get_transition_data()
#     var level = data.get("level", 1)
#     var lives = data.get("lives", 3)
