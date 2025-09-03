# 🏗️ Core Architecture - State Machine System

## 📁 Estructura Reorganizada

```
Core/
├── StateMachine/
│   ├── StateMachine.gd           # Máquina de estados base
│   ├── State.gd                  # Clase base para estados
│   └── States/
│       ├── LoadingState.gd       # Estado de carga inicial
│       ├── MainMenuState.gd      # Estado del menú principal
│       ├── GameplayState.gd      # Estado de juego activo
│       ├── PausedState.gd        # Estado de pausa
│       └── SettingsState.gd      # Estado de configuraciones
└── CentralizedGameStateManager.gd # Manager centralizado
```

## 🎯 Sistema de Estado Centralizado

### StateMachine
- **Propósito**: Controlador base para transiciones de estado
- **Características**: 
  - Registro automático de estados hijos
  - Delegación de eventos (input, update, physics)
  - Debug integrado
  - Señales para notificación de cambios

### State (Clase Base)
- **Métodos Virtuales**:
  - `enter()` - Al entrar al estado
  - `exit()` - Al salir del estado
  - `update()` - Cada frame
  - `handle_input()` - Eventos de input
  - `physics_update()` - Physics frame

### CentralizedGameStateManager
- **Autoload**: Disponible globalmente como `CentralizedGameStateManager`
- **API Pública**:
  ```gdscript
  CentralizedGameStateManager.start_game(1)
  CentralizedGameStateManager.pause_game()
  CentralizedGameStateManager.open_settings("MainMenu")
  ```

## 🔄 Flujo de Estados

```
Loading → MainMenu → Gameplay ⟷ Paused
    ↓         ↓         ↓         ↓
Settings ← Settings ← Settings ← Settings
```

## 🚀 Ventajas del Sistema

### 1. **Centralización**
- Un solo punto de control para todos los estados del juego
- Fácil debugging y monitoreo
- Consistencia en transiciones

### 2. **Escalabilidad** 
- Fácil agregar nuevos estados
- Estados independientes y modulares
- Reutilización de componentes

### 3. **Mantenibilidad**
- Código organizado por responsabilidades
- Fácil localización de bugs
- Testing individual de estados

### 4. **Flexibilidad**
- Transiciones dinámicas con datos
- Estados pueden comunicarse entre sí
- Fácil modificación de flujos

## 🔧 Uso Práctico

### Crear un Nuevo Estado
```gdscript
extends "res://src/systems/StateMachine/State.gd"
class_name MyCustomState

func enter(_previous_state: Node = null) -> void:
    print("Entering MyCustomState")
    # Configuración inicial

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed("some_action"):
        transition_to("AnotherState")

func exit() -> void:
    print("Exiting MyCustomState")
    # Limpieza
```

### Registrar el Estado
```gdscript
# En CentralizedGameStateManager._create_states()
var my_state = MyCustomStateClass.new()
my_state.name = "MyCustom"
main_state_machine.add_child(my_state)
```

### Usar desde Cualquier Parte
```gdscript
# Desde cualquier script
CentralizedGameStateManager.get_state_machine().transition_to("MyCustom")
```

## 🐛 Debug y Monitoreo

### Comandos de Debug
```gdscript
# Información del estado actual
CentralizedGameStateManager.print_state_info()

# Habilitar debug detallado
CentralizedGameStateManager.get_state_machine().enable_debug(true)

# Verificar estado actual
if CentralizedGameStateManager.is_in_state("Gameplay"):
    print("In gameplay!")
```

### Señales Disponibles
```gdscript
# Conectar a cambios de estado
CentralizedGameStateManager.game_state_changed.connect(_on_game_state_changed)

func _on_game_state_changed(from_state, to_state):
    print("Game state: %s → %s" % [from_state, to_state])
```

## 🎮 Integración con Sistema Existente

El sistema mantiene compatibilidad con:
- ✅ **ConfigManager** - Para configuraciones persistentes
- ✅ **InputManager** - Para contextos de input automáticos  
- ✅ **AudioManager** - Para efectos de sonido en transiciones
- ✅ **GameStateManager** original - Coexiste para funcionalidades específicas

## 💡 Mejores Prácticas

1. **Estados Pequenos y Enfocados**: Cada estado debe tener una responsabilidad clara
2. **Datos de Transición**: Usar el diccionario de datos para pasar información entre estados
3. **Cleanup en exit()**: Siempre limpiar recursos en el método exit()
4. **Input Context**: Cambiar contexto de input según el estado
5. **Error Handling**: Validar transiciones antes de ejecutarlas
