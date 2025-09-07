# 🛠️ Guía de Desarrollo - Topdown Game

Esta guía está dirigida a desarrolladores que quieren contribuir al proyecto o entender su arquitectura técnica.

## 🚀 Configuración del Entorno de Desarrollo

### Requisitos Previos
- **Godot Engine 4.4+** ([Descargar aquí](https://godotengine.org/download))
- **Git** para control de versiones
- **Editor de código** (VS Code recomendado con extensión de GDScript)

### Configuración Inicial
```bash
# Clonar repositorio
git clone https://github.com/1SSeba/topdown-game.git
cd topdown-game

# Abrir en Godot
godot project.godot

# O usar script de desarrollo
chmod +x dev.sh
./dev.sh
```

### Estructura de Desarrollo
```
📁 Archivos clave para desarrollo:
├── project.godot           # Configuración principal
├── dev.sh                  # Script de desarrollo rápido
├── quick_export.sh         # Export rápido para testing
├── scripts/
│   ├── check_syntax.sh     # Verificación de sintaxis
│   └── clean_project.sh    # Limpieza de archivos temporales
└── tools/
    ├── clean_cache.sh      # Limpiar caché de Godot
    └── quick_export.sh     # Export de builds debug
```

## 🏗️ Arquitectura del Código

### Patrón de Diseño Principal
El proyecto utiliza el patrón **Manager + StateMachine** con las siguientes características:

#### 1. Autoload Managers (Singletons)
```gdscript
# Orden de carga en project.godot:
ConfigManager     # Configuración persistente (PRIMERO)
InputManager      # Manejo de input
GameStateManager  # Estados del juego + StateMachine
GameManager       # Lógica de gameplay
AudioManager      # Gestión de audio
DebugManager      # Herramientas de desarrollo (ÚLTIMO)
EventBus          # Sistema de eventos (Core)
```

#### 2. Core Systems
```gdscript
Core/
├── StateMachine/           # Sistema de estados
│   ├── StateMachine.gd     # Motor principal
│   ├── State.gd            # Clase base para estados
│   └── States/             # Estados específicos del juego
└── Events/
    └── EventBus.gd         # Sistema de comunicación por eventos
```

#### 3. Scene Organization
```gdscript
Scenes/
├── Main.tscn              # Punto de entrada (GameStateManager aquí)
├── Menus/                 # UI y menús
├── Characters/            # Jugador y NPCs
├── World/                 # Sistema de mundo procedural
└── Debug/                 # Herramientas de desarrollo
```

## 🔧 Workflows de Desarrollo

### Desarrollo Diario
```bash
# 1. Iniciar desarrollo
./dev.sh                   # Godot con hot-reload

# 2. Verificar sintaxis
./scripts/check_syntax.sh  # Revisar errores GDScript

# 3. Testing rápido
./quick_export.sh          # Build y test

# 4. Limpiar al final
./scripts/clean_project.sh # Limpiar temporales
```

### Testing y Debug
```bash
# Abrir con debug console
godot project.godot
# Presionar F3 para Debug Console

# Comandos útiles en Debug Console:
help                       # Ayuda general
status                     # Estado de managers
gamestate                  # Estado actual del juego
managers                   # Status detallado de managers

# Testing de generación de mundo
WorldTester.help()
WorldTester.test_basic_generation()
WorldTester.generate_test_world()
```

## 📝 Convenciones de Código

### Naming Conventions
```gdscript
# Clases: PascalCase
class_name StateMachine
class_name GameStateManager

# Métodos: snake_case
func transition_to(state_name: String):
func get_current_state() -> GameState:

# Variables: snake_case
var current_state: GameState
var is_initialized: bool

# Constantes: UPPER_SNAKE_CASE
const MAX_HEALTH: int = 100
const DEFAULT_SPEED: float = 150.0

# Señales: snake_case con contexto
signal state_changed(old_state, new_state)
signal player_spawned(player_node)
```

### Estructura de Archivos GDScript
```gdscript
# Template estándar para nuevos archivos:
# NombreClase.gd - Descripción breve
extends NodoBase

# =======================
#  SEÑALES
# =======================
signal mi_señal(parametro: Type)

# =======================
#  CONSTANTES
# =======================
const MI_CONSTANTE: int = 100

# =======================
#  VARIABLES EXPORTADAS
# =======================
@export var mi_variable: String = "default"

# =======================
#  VARIABLES PRIVADAS
# =======================
var _variable_privada: bool = false

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
    print("NombreClase: Initialization...")
    _setup()

# =======================
#  MÉTODOS PÚBLICOS
# =======================
func metodo_publico():
    pass

# =======================
#  MÉTODOS PRIVADOS
# =======================
func _setup():
    pass
```

### Manejo de Errores
```gdscript
# Siempre verificar dependencias
func _connect_to_manager():
    if not ManagerUtils.is_config_manager_available():
        print("ERROR: ConfigManager not available")
        return false

    var config_manager = ManagerUtils.get_config_manager()
    # ... resto del código

# Logging consistente
print("ManagerName: Mensaje informativo")
ManagerUtils.log_error("Mensaje de error")
ManagerUtils.log_success("Operación exitosa")
```

## 🧪 Testing y Quality Assurance

### Testing Manual
```bash
# Verificar estados del juego
1. Iniciar → Main Menu ✓
2. Settings → Configurar audio/video ✓
3. Play → Iniciar gameplay ✓
4. Pause → ESC durante gameplay ✓
5. Debug Console → F3 en cualquier momento ✓

# Testing de mundo procedural
1. Abrir Debug Console (F3)
2. WorldTester.generate_test_world()
3. Verificar diferentes biomas
4. Test de performance con WorldTester.benchmark_generation()
```

### Scripts de Verificación
```bash
# Sintaxis completa
./scripts/check_syntax.sh

# Verificar managers
godot --headless --quit-after 1 --check-only

# Testing automático de estados
# (En Debug Console)
GameStateManager.debug_info()
```

## 🔄 Sistema de Estados - Guía de Desarrollo

### Crear Nuevo Estado
```gdscript
# 1. Crear archivo en Core/StateMachine/States/
# MiNuevoState.gd
extends State

func enter(data: Dictionary = {}):
    print("Entrando a MiNuevoState")
    # Lógica de entrada

func exit():
    print("Saliendo de MiNuevoState")
    # Lógica de salida

func handle_input(event: InputEvent):
    # Manejo de input específico del estado
    pass

func update(delta: float):
    # Lógica de frame del estado
    pass
```

```gdscript
# 2. Registrar en GameStateManager.gd
func _register_state_machine_states():
    # ... estados existentes ...

    var MiNuevoStateClass = load("res://game/systems/StateMachine/States/MiNuevoState.gd")
    var mi_nuevo_state = MiNuevoStateClass.new()
    mi_nuevo_state.name = "MiNuevoState"

    state_machine.add_child(mi_nuevo_state)
    state_machine.add_state("MiNuevoState", mi_nuevo_state)
```

### Transiciones de Estado
```gdscript
# Desde cualquier parte del código:
GameStateManager.change_state(GameState.MI_NUEVO_ESTADO)

# O directamente con StateMachine:
var state_machine = GameStateManager.get_state_machine()
state_machine.transition_to("MiNuevoState", {"data": "value"})
```

## 🎨 Sistema de Mundo - Extensión

### Añadir Nuevo Bioma
```gdscript
# En WorldGenerator.gd
enum BiomeType {
    # ... biomas existentes ...
    MI_NUEVO_BIOMA
}

# En biome_configs:
BiomeType.MI_NUEVO_BIOMA: {
    "name": "Mi Bioma",
    "tile_id": 10,  # Nuevo ID único
    "temperature": 0.5,
    "humidity": 0.7,
    "elevation": 0.3,
    "color": Color(1.0, 0.5, 0.0)  # Color único
}
```

### Añadir Nuevo Tipo de Tile
```gdscript
# En World.gd
enum TileType {
    # ... tiles existentes ...
    MI_NUEVO_TILE = 10
}

# Asegurar que el TileSet tiene el nuevo tile con ID 10
```

## 🐛 Debug y Troubleshooting

### Console Commands Útiles
```bash
# Estado general
status                     # Todo el sistema
gamestate                 # Estado del juego
managers                  # Status de managers

# Estados específicos
GameStateManager.debug_info()           # Info completa de estados
GameStateManager.debug_complete_run()   # Forzar completar run
GameStateManager.debug_fail_run()       # Forzar fallar run

# Mundo procedural
WorldTester.help()                      # Comandos disponibles
WorldTester.show_biome_info()          # Info de biomas
WorldTester.benchmark_generation()     # Test de performance
```

### Errores Comunes y Soluciones

#### "Cannot start with unknown state"
```gdscript
# Problema: Estado no registrado en StateMachine
# Solución: Verificar _register_state_machine_states() en GameStateManager.gd

# Debug:
print("Estados registrados:")
for state_name in state_machine.get_state_names():
    print("  - %s" % state_name)
```

#### "Manager not ready"
```gdscript
# Problema: Orden de inicialización de managers
# Solución: Usar await para esperar dependencies

func _wait_for_dependencies():
    if ManagerUtils.is_config_manager_available():
        while not ConfigManager.is_ready():
            await ConfigManager.config_loaded
```

#### "TileSet not assigned"
```gdscript
# Problema: TileMapLayer sin TileSet asignado
# Solución:
# 1. Crear TileSet manualmente en Godot Editor
# 2. Asignar en Inspector del TileMapLayer
# 3. O crear dinámicamente:

func _create_basic_tileset():
    var tileset = TileSet.new()
    # ... configurar tiles ...
    tile_map_layer.tile_set = tileset
```

## 📦 Build y Deploy

### Build Development
```bash
# Build rápido para testing
./quick_export.sh

# Build manual
godot --headless --export-debug "Linux/X11" builds/debug/game_debug
```

### Build Production
```bash
# Configurar en export_presets.cfg primero
godot --headless --export-release "Linux/X11" builds/release/game_release

# Verificar build
./builds/release/game_release
```

## 🤝 Contribuciones

### Pull Request Workflow
1. **Fork** del repositorio
2. **Branch** para feature: `git checkout -b feature/mi-nueva-feature`
3. **Develop** siguiendo estas convenciones
4. **Test** con scripts de verificación
5. **Commit** con mensajes descriptivos
6. **Pull Request** con descripción detallada

### Code Review Checklist
- [ ] Sintaxis verificada con `check_syntax.sh`
- [ ] Convenciones de naming seguidas
- [ ] Documentación actualizada si es necesario
- [ ] Testing manual realizado
- [ ] No errores en consola de Godot
- [ ] Performance acceptable

## 📊 Performance y Optimización

### Profiling
```gdscript
# En Debug Console:
Engine.get_frames_per_second()          # FPS actual
get_viewport().get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_STAT_DRAW_CALLS)  # Draw calls

# Benchmark de generación:
WorldTester.benchmark_generation()
```

### Optimización de Mundo
```gdscript
# Configurar parámetros en World.gd:
@export var chunk_size: int = 64        # Reducir para mejor performance
@export var render_distance: int = 3    # Distancia de renderizado
@export var max_chunks_per_frame: int = 1  # Limitar chunks por frame
```

---

**¡Happy coding! 🎮**

*Esta guía se actualiza con cada nueva característica del proyecto.*
