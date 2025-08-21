# 🎮 State Machine Simple y Funcional

## Sistema de Estados Necesario para tu Proyecto Top-Down

### 📁 Estructura Simplificada

```
Core/
├── StateMachine/
│   ├── StateMachine.gd          # Motor principal (simplificado)
│   ├── State.gd                 # Clase base para estados  
│   └── States/                  # Estados específicos del juego
│       ├── MainMenuState.gd     # Menú principal
│       ├── GameplayState.gd     # Juego principal
│       ├── PausedState.gd       # Juego pausado
│       └── SettingsState.gd     # Configuración
└── Events/
    └── EventBus.gd              # Sistema de eventos simple
```

---

## 🚀 Uso Básico

### 1. Configurar el State Machine

```gdscript
# En tu escena principal
extends Node

@onready var state_machine: Node = $StateMachine

func _ready():
    # Configuración básica
    state_machine.debug_mode = true
    state_machine.auto_register_children = true
    
    # Iniciar con un estado específico
    state_machine.start("MainMenuState")
```

### 2. Crear Estados Personalizados

```gdscript
extends "res://Core/StateMachine/State.gd"
class_name MiEstado

func enter(_previous_state: State = null):
    print("Entrando a MiEstado")
    # Tu lógica de inicialización

func exit():
    print("Saliendo de MiEstado")
    # Limpieza necesaria

func handle_input(event: InputEvent):
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_ESCAPE:
                transition_to("MenuPrincipal")
```

### 3. Usar el EventBus

```gdscript
# Publicar eventos
EventBus.publish("player_died")
EventBus.publish_player_health_changed(50.0, 100.0)

# Suscribirse a eventos
EventBus.subscribe("player_died", _on_player_died)

func _on_player_died(data: Dictionary):
    print("¡El jugador murió!")
```

---

## 🎯 Características Incluidas

### ✅ State Machine
- **Estados simples**: Fáciles de crear y mantener
- **Transiciones automáticas**: Con datos opcionales
- **Auto-registro**: Registra estados hijos automáticamente
- **Debug mode**: Logs útiles para desarrollo

### ✅ EventBus
- **Eventos tipados**: Métodos de conveniencia incluidos
- **Historial**: Para debugging y análisis
- **Sistema simple**: Sin complejidad innecesaria

### ✅ Estados Básicos Incluidos
- **MainMenuState**: Menú principal con navegación
- **GameplayState**: Estado principal del juego
- **PausedState**: Pausa del juego
- **SettingsState**: Configuración

---

## 🔧 API Simplificada

### StateMachine

```gdscript
# Métodos principales
state_machine.start("EstadoInicial")
state_machine.transition_to("NuevoEstado", {"data": "valor"})
state_machine.get_current_state_name()
state_machine.is_in_state("EstadoEspecifico")

# Configuración
state_machine.debug_mode = true
state_machine.auto_register_children = true
```

### EventBus

```gdscript
# Publicar eventos
EventBus.publish("evento_custom", {"key": "value"})
EventBus.publish_game_paused()
EventBus.publish_player_died()

# Suscripciones
EventBus.subscribe("evento", callback_function)
EventBus.unsubscribe("evento", callback_function)

# Debugging
EventBus.print_debug_info()
EventBus.get_recent_events(5)
```

---

## 🎮 Ejemplo Práctico

### Configuración Completa en una Escena

```gdscript
# MainScene.gd
extends Node

@onready var state_machine = $StateMachine

func _ready():
    # Configurar debugging
    state_machine.debug_mode = true
    EventBus.enable_debug(true)
    
    # Conectar eventos globales
    EventBus.subscribe("game_paused", _on_game_paused)
    EventBus.subscribe("game_resumed", _on_game_resumed)
    
    # Iniciar con el menú principal
    state_machine.start("MainMenuState")

func _on_game_paused(_data: Dictionary):
    get_tree().paused = true

func _on_game_resumed(_data: Dictionary):
    get_tree().paused = false
```

---

## 🔍 Debugging

### Hotkeys de Desarrollo

En modo debug, puedes usar:
- **Debug Mode**: Logs detallados de transiciones
- **Event History**: Historial de eventos recientes
- **State Info**: Información del estado actual

### Logs de Ejemplo

```
🔄 StateMachine initialized
📋 Added state: MainMenuState
🚀 StateMachine started with state: MainMenuState
🔄 State changed: MainMenuState → GameplayState
📡 EventBus: Published player_health_changed with 1 listeners
```

---

## 💡 Consejos de Uso

### 1. Organización de Estados
- Un archivo por estado
- Nombres descriptivos y específicos
- Lógica enfocada en una responsabilidad

### 2. Manejo de Eventos
- Usar eventos para comunicación entre estados
- No abusar del EventBus para todo
- Mantener eventos simples y claros

### 3. Debugging
- Activar debug_mode durante desarrollo
- Usar EventBus.print_debug_info() para troubleshooting
- Monitorear el historial de eventos

---

Este sistema te da **todo lo necesario** para manejar estados en tu juego top-down sin complejidad innecesaria. Es:

- ✅ **Simple de usar**
- ✅ **Fácil de mantener** 
- ✅ **Suficientemente potente**
- ✅ **Bien documentado**
- ✅ **Con debugging incluido**

¡Perfecto para proyectos reales sin sobre-ingeniería! 🎯
