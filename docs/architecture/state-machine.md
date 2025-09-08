# 🎛️ Sistema de State Machine - RougeLike Base

El sistema de State Machine (Máquina de Estados) es uno de los componentes centrales del proyecto, proporcionando una arquitectura robusta para gestionar los diferentes estados del juego de manera organizada y predecible.

## 🧭 Conceptos Fundamentales

### ¿Qué es una State Machine?

Una **State Machine** (Máquina de Estados) es un patrón de diseño que permite que un objeto modifique su comportamiento cuando cambia su estado interno. En términos de videojuegos:

- **Estado**: Una condición específica del juego (Menu Principal, Jugando, Pausado, Game Over)
- **Transición**: El cambio de un estado a otro
- **Condiciones**: Reglas que determinan cuándo ocurren las transiciones

### Arquitectura del Sistema

```
GameStateManager (Global)
    │
    ├── StateMachine (Core)
    │   ├── State (Base Class)
    │   └── States/
    │       ├── MainMenuState
    │       ├── LoadingState
    │       ├── GameplayState
    │       ├── PausedState
    │       ├── GameOverState
    │       └── SettingsState
    │
    └── GameState (Enum)
        ├── MAIN_MENU
        ├── LOADING
        ├── PLAYING
        ├── PAUSED
        ├── GAME_OVER
        └── SETTINGS
```

## 🏗️ Arquitectura Técnica

### GameStateManager (Singleton)

El `GameStateManager` es el controlador principal que gestiona los estados globales del juego:

```gdscript
# game/core/systems/game-state/GameStateManager.gd
extends Node

enum GameState {
    MAIN_MENU,    # Estado del menú principal
    LOADING,      # Estado de carga
    PLAYING,      # Estado de juego activo
    PAUSED,       # Estado de pausa
    GAME_OVER,    # Estado de fin de juego
    SETTINGS      # Estado de configuraciones
}

var current_state: GameState = GameState.MAIN_MENU
var previous_state: GameState = GameState.MAIN_MENU
var is_initialized: bool = false
var state_machine: Node = null

# Señales para comunicación entre sistemas
signal state_changed(old_state: GameState, new_state: GameState)
signal game_started
signal game_paused
signal game_resumed
signal player_died
```

#### Métodos Principales

```gdscript
# Cambiar estado del juego
func change_state(new_state: GameState):
    if new_state == current_state:
        return

    var old_state = current_state
    previous_state = current_state
    current_state = new_state

    # Emitir señal de cambio de estado
    state_changed.emit(old_state, new_state)

    # Ejecutar lógica específica del estado
    match new_state:
        GameState.PLAYING:
            game_started.emit()
        GameState.PAUSED:
            game_paused.emit()

# Métodos de conveniencia
func is_playing() -> bool:
    return current_state == GameState.PLAYING

func start_game():
    change_state(GameState.PLAYING)

func pause_game():
    if current_state == GameState.PLAYING:
        change_state(GameState.PAUSED)

func on_player_died():
    player_died.emit()
    change_state(GameState.GAME_OVER)
```

### StateMachine (Core)

La `StateMachine` es el motor que gestiona las transiciones y la lógica de estados específicos:

```gdscript
# game/core/systems/game-state/StateMachine/StateMachine.gd
extends Node

# Señales para comunicación detallada
signal state_changed(from_state: String, to_state: String)
signal state_entered(state_name: String)
signal state_exited(state_name: String)

# Estado actual y anterior
var current_state: Node  # Instancia de State
var previous_state: Node # Instancia de State anterior

# Diccionario de estados disponibles
var states: Dictionary = {}

# Datos que se pueden pasar entre estados
var transition_data: Dictionary = {}

# Configuración
@export var debug_mode: bool = false
@export var auto_register_children: bool = true
```

#### Métodos de Gestión de Estados

```gdscript
# Agregar un estado al sistema
func add_state(state_name: String, state: Node):
    if state_name in states:
        push_warning("State '%s' already exists, overwriting..." % state_name)

    states[state_name] = state
    state.state_machine = self

    if debug_mode:
        print("📋 Added state: %s" % state_name)

# Transición entre estados
func transition_to(state_name: String, data: Dictionary = {}):
    if state_name not in states:
        push_error("Cannot transition to unknown state: %s" % state_name)
        return

    if current_state and current_state.name == state_name:
        if debug_mode:
            print("⚠️ Already in state: %s" % state_name)
        return

    transition_data = data
    _change_state(state_name)

# Cambio interno de estado
func _change_state(new_state_name: String):
    var old_state_name = ""

    # Salir del estado actual
    if current_state:
        old_state_name = current_state.name
        current_state.exit()
        state_exited.emit(old_state_name)
        previous_state = current_state

    # Entrar al nuevo estado
    current_state = states[new_state_name]
    current_state.enter(previous_state)

    # Emitir señales de cambio
    state_entered.emit(new_state_name)
    state_changed.emit(old_state_name, new_state_name)

    if debug_mode:
        print("🔄 State changed: %s → %s" % [old_state_name, new_state_name])
```

### State (Clase Base)

La clase `State` es la base para todos los estados específicos:

```gdscript
# game/core/systems/game-state/StateMachine/State.gd
class_name State
extends Node

# Referencias comunes
var state_machine: Node  # Referencia a StateMachine
var game_manager: Node   # Referencia opcional a GameManager

# Métodos virtuales que cada estado debe implementar
func enter(_previous_state: State = null) -> void:
    # Lógica de entrada al estado
    pass

func exit() -> void:
    # Lógica de salida del estado
    pass

func update(_delta: float) -> void:
    # Lógica de frame del estado
    pass

func handle_input(_event: InputEvent) -> void:
    # Manejo de input específico del estado
    pass

func physics_update(_delta: float) -> void:
    # Lógica de física del estado
    pass

# Método de utilidad para transiciones
func transition_to(state_name: String, data: Dictionary = {}) -> void:
    if state_machine:
        state_machine.transition_to(state_name, data)
    else:
        push_error("No state machine reference found in state: " + name)
```

## 🎮 Estados Implementados

### 1. MainMenuState

Estado del menú principal del juego:

```gdscript
# game/core/systems/game-state/StateMachine/States/MainMenuState.gd
extends State

var main_menu_scene: Node = null
var is_menu_connected: bool = false

func enter(_previous_state: State = null) -> void:
    print("🏠 Entering MainMenuState")

    # Cargar escena del menú principal
    await _ensure_main_menu_scene()

    # Configurar contexto de input
    _setup_input_context()

    # Conectar señales del menú
    _connect_menu_signals()

    print("MainMenuState: ✅ Ready and active")

func _ensure_main_menu_scene():
    var current_scene = get_tree().current_scene

    # Si ya estamos en MainMenu, usar la escena actual
    if current_scene and current_scene.has_signal("start_game_requested"):
        main_menu_scene = current_scene
        print("MainMenuState: Using current MainMenu scene")
        return

    # Si no, cargar la escena del menú principal
    var main_menu_path = "res://game/scenes/menus/MainMenu.tscn"
    if ResourceLoader.exists(main_menu_path):
        print("MainMenuState: Loading MainMenu scene")
        get_tree().change_scene_to_file(main_menu_path)
        await get_tree().process_frame
        main_menu_scene = get_tree().current_scene

func _connect_menu_signals():
    if main_menu_scene and main_menu_scene.has_signal("start_game_requested"):
        # Conectar señales del menú
        main_menu_scene.start_game_requested.connect(_on_start_game_requested)
        main_menu_scene.settings_requested.connect(_on_settings_requested)
        main_menu_scene.quit_requested.connect(_on_quit_requested)

# Manejadores de señales
func _on_start_game_requested():
    print("MainMenuState: Start game requested")
    if state_machine:
        state_machine.transition_to("LoadingState")

func _on_settings_requested():
    print("MainMenuState: Settings requested")
    if state_machine:
        state_machine.transition_to("SettingsState")

func handle_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_ENTER, KEY_SPACE:
                _start_game()
            KEY_S:
                _open_settings()
            KEY_Q:
                if event.ctrl_pressed:
                    _quit_game()
```

### 2. LoadingState

Estado de carga del juego:

```gdscript
# game/core/systems/game-state/StateMachine/States/LoadingState.gd
extends State
class_name LoadingState

var loading_progress: float = 0.0

func enter(_previous_state: State = null) -> void:
    if state_machine and state_machine.debug_mode:
        print("🔄 Entering LoadingState")

    loading_progress = 0.0
    _start_loading()

func _start_loading():
    # Simular carga de recursos
    await get_tree().create_timer(1.0).timeout
    loading_progress = 1.0

    if state_machine and state_machine.debug_mode:
        print("✅ Loading completed")

    # Transición al juego
    transition_to("GameplayState")

func update(_delta: float) -> void:
    # Actualizar progreso de carga si es necesario
    pass

func exit() -> void:
    if state_machine and state_machine.debug_mode:
        print("🔄 Exiting LoadingState")
```

### 3. SettingsState

Estado de configuraciones:

```gdscript
# game/core/systems/game-state/StateMachine/States/SettingsState.gd
extends State

var settings_scene: PackedScene
var settings_node: Node
var return_state: String = "MainMenuState"

func enter(_previous_state: State = null) -> void:
    print("⚙️ Entering SettingsState")

    # Obtener estado de retorno
    var data = state_machine.get_transition_data()
    if "return_state" in data:
        return_state = data["return_state"]

    # Cargar escena de configuraciones
    _load_settings_scene()

func _load_settings_scene():
    settings_scene = load("res://game/scenes/menus/SettingsMenu.tscn")

    if settings_scene:
        settings_node = settings_scene.instantiate()
        var current_scene = get_tree().current_scene

        if current_scene:
            current_scene.add_child(settings_node)
            _connect_settings_signals()
        else:
            print("❌ No current scene available for settings")
    else:
        print("❌ Could not load settings scene")
        transition_to(return_state)

func _connect_settings_signals():
    if settings_node:
        if settings_node.has_signal("settings_closed"):
            settings_node.settings_closed.connect(_on_settings_closed)
        if settings_node.has_signal("back_requested"):
            settings_node.back_requested.connect(_on_back_requested)

func _on_settings_closed():
    transition_to(return_state)

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        # ESC vuelve al estado anterior
        transition_to(return_state)

func exit() -> void:
    print("⚙️ Exiting SettingsState")

    # Limpiar escena de configuraciones
    if settings_node:
        settings_node.queue_free()
        settings_node = null
```

## 🔄 Flujo de Estados

### Diagrama de Transiciones

```
MAIN_MENU ←→ SETTINGS
    ↓
LOADING
    ↓
PLAYING ←→ PAUSED
    ↓
GAME_OVER → MAIN_MENU
```

### Transiciones Típicas

```gdscript
# Inicio del juego
MainMenuState → LoadingState → GameplayState

# Pausa durante el juego
GameplayState → PausedState → GameplayState

# Configuraciones desde menú
MainMenuState → SettingsState → MainMenuState

# Muerte del jugador
GameplayState → GameOverState → MainMenuState

# Configuraciones durante juego
GameplayState → SettingsState → GameplayState
```

## 📝 Cómo Crear un Nuevo Estado

### 1. Crear la Clase del Estado

```gdscript
# game/core/systems/game-state/StateMachine/States/MiNuevoState.gd
extends State
class_name MiNuevoState

# Variables específicas del estado
var state_data: Dictionary = {}
var timer: float = 0.0

func enter(_previous_state: State = null) -> void:
    print("🎯 Entering MiNuevoState")

    # Obtener datos de transición
    var transition_data = state_machine.get_transition_data()
    if "custom_data" in transition_data:
        state_data = transition_data["custom_data"]

    # Configurar el estado
    _setup_state()

func _setup_state():
    # Lógica de configuración específica
    timer = 0.0

func update(delta: float) -> void:
    # Lógica de frame
    timer += delta

    # Ejemplo: transición automática después de 5 segundos
    if timer >= 5.0:
        transition_to("MainMenuState")

func handle_input(event: InputEvent) -> void:
    # Manejo de input específico
    if event.is_action_pressed("ui_cancel"):
        transition_to("MainMenuState")

func exit() -> void:
    print("🎯 Exiting MiNuevoState")

    # Limpiar recursos específicos del estado
    state_data.clear()
```

### 2. Registrar el Estado

```gdscript
# En GameStateManager.gd o donde inicialices la StateMachine
func _register_states():
    var mi_nuevo_state = MiNuevoState.new()
    mi_nuevo_state.name = "MiNuevoState"

    state_machine.add_state("MiNuevoState", mi_nuevo_state)
```

### 3. Usar el Nuevo Estado

```gdscript
# Desde cualquier parte del código
state_machine.transition_to("MiNuevoState", {
    "custom_data": {"nivel": 3, "puntuacion": 1500}
})

# O usando GameStateManager si tienes enum correspondiente
GameStateManager.change_state(GameState.MI_NUEVO_ESTADO)
```

## 🎛️ Gestión de Datos Entre Estados

### Pasar Datos en Transiciones

```gdscript
# Estado origen
func transition_to_gameplay():
    var gameplay_data = {
        "level": 1,
        "player_name": "Hero",
        "difficulty": "normal",
        "score": 0
    }

    transition_to("GameplayState", gameplay_data)

# Estado destino
func enter(_previous_state: State = null) -> void:
    var data = state_machine.get_transition_data()

    if "level" in data:
        current_level = data["level"]
    if "player_name" in data:
        player_name = data["player_name"]
    if "difficulty" in data:
        difficulty = data["difficulty"]
```

### Persistencia de Datos

```gdscript
# Para datos que deben persistir entre estados
class_name GameSession extends RefCounted

static var instance: GameSession
static var player_data: Dictionary = {}
static var game_settings: Dictionary = {}
static var current_run: Dictionary = {}

static func get_instance() -> GameSession:
    if not instance:
        instance = GameSession.new()
    return instance

static func save_player_data(data: Dictionary):
    player_data = data

static func get_player_data() -> Dictionary:
    return player_data
```

## 🐛 Debug y Troubleshooting

### Habilitar Debug Mode

```gdscript
# En la StateMachine
@export var debug_mode: bool = true

# O en runtime
state_machine.debug_mode = true
```

### Comandos de Debug Útiles

```gdscript
# Ver estado actual
print("Current state: %s" % state_machine.get_current_state_name())

# Ver estados disponibles
print("Available states: %s" % state_machine.get_state_list())

# Ver datos de transición
print("Transition data: %s" % state_machine.get_transition_data())

# Información completa
state_machine.print_state_info()
```

### Errores Comunes y Soluciones

#### Error: "Cannot transition to unknown state"

**Problema**: El estado no está registrado en la StateMachine.

**Solución**:
```gdscript
# Verificar que el estado esté registrado
func _verify_states():
    print("Registered states:")
    for state_name in state_machine.get_state_list():
        print("  - %s" % state_name)

# Registrar el estado si falta
if not state_machine.has_state("MiEstado"):
    var mi_estado = MiEstado.new()
    state_machine.add_state("MiEstado", mi_estado)
```

#### Error: "No state machine reference found"

**Problema**: El estado no tiene referencia a la StateMachine.

**Solución**:
```gdscript
# En la StateMachine, al agregar estados
func add_state(state_name: String, state: Node):
    states[state_name] = state
    state.state_machine = self  # Importante: establecer referencia
```

#### Estados que no cambian

**Problema**: Las transiciones no ocurren como se espera.

**Solución**:
```gdscript
# Verificar orden de inicialización
func _ready():
    # Asegurar que StateMachine esté lista
    await get_tree().process_frame

    # Luego hacer transiciones
    state_machine.start("MainMenuState")
```

## 🎯 Mejores Prácticas

### 1. **Organización Clara**

```gdscript
# ✅ Buena organización
States/
├── MainMenuState.gd
├── LoadingState.gd
├── GameplayState.gd
├── PausedState.gd
├── GameOverState.gd
└── SettingsState.gd

# ❌ Mala organización
game_states.gd  # Todo en un archivo
```

### 2. **Nombres Descriptivos**

```gdscript
# ✅ Buenos nombres
"MainMenuState"      # Claro y específico
"CharacterSelection" # Describe la función
"BossIntroduction"   # Específico del contexto

# ❌ Malos nombres
"State1"             # No descriptivo
"Menu"               # Muy genérico
"GameState"          # Confuso con el enum
```

### 3. **Separación de Responsabilidades**

```gdscript
# ✅ Estado enfocado
class_name PausedState extends State

func enter(_previous_state: State = null):
    # Solo lógica de pausa
    Engine.time_scale = 0.0
    _show_pause_menu()

# ❌ Estado sobrecargado
class_name PausedState extends State

func enter(_previous_state: State = null):
    # Demasiadas responsabilidades
    Engine.time_scale = 0.0
    _show_pause_menu()
    _save_game()
    _update_statistics()
    _check_achievements()
    _send_analytics()
```

### 4. **Manejo de Errores**

```gdscript
# ✅ Manejo robusto de errores
func transition_to_gameplay():
    if not state_machine:
        push_error("StateMachine not available")
        return

    if not state_machine.has_state("GameplayState"):
        push_error("GameplayState not registered")
        return

    state_machine.transition_to("GameplayState")

# ❌ Sin manejo de errores
func transition_to_gameplay():
    state_machine.transition_to("GameplayState")  # Puede fallar
```

### 5. **Documentación**

```gdscript
## Estado del menú principal del juego.
##
## Gestiona la interfaz del menú principal, incluyendo:
## - Navegación por opciones
## - Transiciones a otros estados
## - Configuración inicial del juego
##
## Estados válidos de entrada: LoadingState, GameOverState, SettingsState
## Estados válidos de salida: LoadingState, SettingsState
class_name MainMenuState extends State
```

---

**El sistema de State Machine proporciona una base sólida y escalable para gestionar la complejidad de estados en el juego.** Con esta arquitectura, es fácil agregar nuevos estados, modificar comportamientos y mantener el código organizado.

**Recuerda**: Un buen diseño de State Machine hace que el flujo del juego sea predecible y debuggeable. Invierte tiempo en planificar las transiciones antes de implementar.

*Siguiente: [Sistema de Componentes](components-system.md)*

*Última actualización: Septiembre 7, 2025*
