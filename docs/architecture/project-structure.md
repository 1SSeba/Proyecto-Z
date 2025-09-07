# 📂 Estructura del Proyecto

## 📋 **Índice**
- [Visión General](#visión-general)
- [Estructura de Directorios](#estructura-de-directorios)
- [Convenciones de Nombres](#convenciones-de-nombres)
- [Organización del Código](#organización-del-código)
- [Gestión de Recursos](#gestión-de-recursos)
- [Configuración del Proyecto](#configuración-del-proyecto)

---

## 🎯 **Visión General**

El proyecto sigue una **arquitectura modular** que separa claramente el código fuente, contenido, herramientas y documentación. Esta estructura facilita el desarrollo colaborativo y el mantenimiento a largo plazo.

### **Principios de Organización**
- ✅ **Separación src/content**: Código vs. recursos del juego
- ✅ **Modularidad**: Cada sistema en su propio directorio
- ✅ **Escalabilidad**: Estructura preparada para crecimiento
- ✅ **Claridad**: Nombres descriptivos y organización lógica

---

## 🗂️ **Estructura de Directorios**

```
topdown-game/                          # 🎮 ROOT - Proyecto principal
├── 📁 src/                             # 💻 CÓDIGO FUENTE
│   └── 📁 core/                        # 🏗️ Arquitectura base
│       ├── 📁 components/              # 🧩 Sistema de componentes
│       │   ├── Component.gd            # 📄 Clase base de componentes
│       │   ├── HealthComponent.gd      # ❤️ Componente de salud
│       │   ├── MovementComponent.gd    # 🏃 Componente de movimiento
│       │   └── MenuComponent.gd        # 📋 Componente de menús
│       │
│       ├── 📁 services/                # ⚙️ Servicios globales
│       │   ├── GameService.gd          # 📄 Clase base de servicios
│       │   ├── ConfigService.gd        # ⚙️ Gestión de configuración
│       │   ├── AudioService.gd         # 🎵 Gestión de audio
│       │   └── InputService.gd         # 🎮 Gestión de input
│       │
│       ├── 📁 events/                  # 📡 Sistema de eventos
│       │   └── EventBus.gd             # 🚌 Bus central de eventos
│       │
│       └── ServiceManager.gd           # 🎯 Coordinador de servicios
│
├── 📁 src/entities/                    # 🎭 ENTIDADES DEL JUEGO
│   └── Player.gd                       # 👤 Entidad del jugador
│
├── 📁 src/systems/                     # 🏗️ SISTEMAS CENTRALES
│   ├── StateMachine/                   # 🔄 Máquina de estados
│   │   ├── StateMachine.gd             # 🔄 Motor principal
│   │   ├── State.gd                    # 📄 Clase base de estados
│   │   └── States/                     # 📁 Estados específicos
│   │       ├── LoadingState.gd         # ⏳ Estado de carga
│   │       ├── MainMenuState.gd        # 📋 Estado menú principal
│   │       └── SettingsState.gd        # ⚙️ Estado de configuración
│   │
│   ├── RoomsSystem.gd                  # � Sistema de habitaciones
│   ├── RoomGenerator.gd                # 🏠 Generador de salas
│   └── CorridorGenerator.gd            # 🚪 Generador de pasillos
│
├── 📁 content/                         # 🎨 CONTENIDO DEL JUEGO
│   ├── 📁 assets/                      # 🎨 Recursos visuales/audio
│   │   ├── Audio/                      # 🎵 Música y sonidos
│   │   ├── Characters/                 # 👤 Sprites de personajes
│   │   ├── Maps/                       # 🗺️ Texturas de mapas
│   │   └── Ui/                         # 🖼️ Elementos de interfaz
│   │
│   ├── 📁 scenes/                      # 🎭 Escenas del juego
│   │   ├── Main.tscn                   # 🚪 Escena principal
│   │   ├── Main.gd                     # 📄 Script de escena principal
│   │   ├── Characters/                 # 👤 Escenas de personajes
│   │   │   └── Player/                 # 👤 Jugador
│   │   ├── Menus/                      # 📋 Menús del juego
│   │   │   └── MainMenu.tscn           # 📋 Menú principal
│   │   └── World/                      # 🌍 Sistema de mundo
│
│   └── 📁 data/                        # 💾 Datos de contenido
│       └── Data/                       # 📊 Datos del juego
│
├── 📁 config/                          # ⚙️ CONFIGURACIONES
│   ├── default_bus_layout.tres         # 🎵 Layout de audio
│   └── export_presets.cfg              # 📦 Presets de exportación
│
├── 📁 docs/                            # 📚 DOCUMENTACIÓN
│   ├── README.md                       # 📖 Índice principal
│   ├── 📁 architecture/                # 🏗️ Documentación técnica
│   │   ├── component-architecture.md   # 🧩 Arquitectura de componentes
│   │   ├── service-layer.md            # ⚙️ Capa de servicios
│   │   ├── event-system.md             # 📡 Sistema de eventos
│   │   └── project-structure.md        # 📂 Este documento
│   │
│   ├── 📁 development/                 # 👨‍💻 Guías de desarrollo
│   │   ├── getting-started.md          # 🚀 Primeros pasos
│   │   └── desarrollo-componentes.md    # 🧩 Desarrollo de componentes
│   │
│   ├── 📁 user-guides/                 # 👥 Guías de usuario
│   │   └── installation.md             # 💿 Instalación
│   │
│   └── 📁 api-reference/               # 📋 Referencia de API
│       └── api-componentes.md           # 🧩 API de componentes
│
├── 📁 builds/                          # 🏗️ BUILDS DEL PROYECTO
│   └── debug/                          # 🐛 Builds de debug
│       └── logs/                       # 📝 Logs de construcción
│
└── 📄 ARCHIVOS ROOT                    # 🗂️ CONFIGURACIÓN PRINCIPAL
    ├── project.godot                   # ⚙️ Configuración de Godot
    ├── icon.svg                        # 🖼️ Icono del proyecto
    ├── README.md                       # 📖 README principal
    ├── LICENSE                         # 📜 Licencia del proyecto
    ├── CHANGELOG.md                    # 📅 Historial de cambios
    ├── CONTRIBUTING.md                 # 🤝 Guía de contribución
    └── DEVELOPMENT.md                  # 🛠️ Guía de desarrollo
```

---

## 📝 **Convenciones de Nombres**

### **Archivos y Carpetas**
```bash
# Carpetas: PascalCase para categorías principales
src/core/components/
content/scenes/Characters/

# Archivos GDScript: PascalCase + extensión
HealthComponent.gd
ServiceManager.gd
Player.gd

# Escenas: PascalCase + extensión
MainMenu.tscn
Player.tscn

# Recursos: descriptive-kebab-case
player-sprite.png
background-music.ogg

# Documentación: kebab-case
component-architecture.md
getting-started.md
```

### **Código GDScript**
```gdscript
# Clases: PascalCase
class_name HealthComponent
class_name ServiceManager

# Variables: snake_case
var max_health: int
var current_position: Vector2

# Constantes: SCREAMING_SNAKE_CASE
const MAX_PLAYERS: int = 4
const DEFAULT_SPEED: float = 100.0

# Funciones: snake_case
func take_damage(amount: int) -> void
func get_health_percentage() -> float

# Señales: snake_case
signal health_changed(entity: Node, health: int)
signal player_moved(position: Vector2)
```

### **Nodos y Escenas**
```gdscript
# Nodos en escenas: PascalCase
Player
HealthComponent
MainMenuButton

# Grupos: kebab-case
add_to_group("player-entities")
add_to_group("ui-elements")

# Identificadores únicos: descriptivos
player_health_bar
main_menu_background
settings_panel_audio
```

---

## 💻 **Organización del Código**

### **src/core/ - Arquitectura Base**
```
core/
├── components/          # Componentes reutilizables
├── services/           # Servicios globales
├── events/             # Sistema de eventos
└── ServiceManager.gd   # Coordinador principal
```

**Propósito:** Contiene la arquitectura fundamental del proyecto. Todo componente o servicio core va aquí.

**Reglas:**
- Solo código de arquitectura base
- Máxima reutilización entre proyectos
- API estable y bien documentada
- Testing exhaustivo requerido

### **src/entities/ - Entidades del Juego**
```
entities/
├── Player.gd           # Jugador principal
├── Enemy.gd            # Enemigos base
└── NPC.gd              # NPCs interactivos
```

**Propósito:** Entidades específicas del juego que combinan componentes.

**Reglas:**
- Una clase por archivo
- Usar composición de componentes
- Evitar lógica hardcodeada
- Configuración por @export

### **src/systems/ - Sistemas del Juego**
```
systems/
├── StateMachine/       # Gestión de estados
├── WorldGenerator/     # Generación procedural
└── Combat/             # Sistema de combate
```

**Propósito:** Sistemas complejos que coordinan múltiples componentes.

**Reglas:**
- Un sistema por carpeta
- Interfaz clara con otros sistemas
- Documentación de dependencias
- Configuración centralizada

---

## 🎨 **Gestión de Recursos**

### **content/assets/ - Recursos del Juego**
```
assets/
├── Audio/
│   ├── Music/          # Música de fondo (.ogg)
│   └── Sfx/            # Efectos de sonido (.wav)
├── Characters/
│   ├── Player/         # Sprites del jugador
│   └── Enemies/        # Sprites de enemigos
├── Maps/
│   ├── Textures/       # Texturas de terreno
│   └── Tilesets/       # TileSets para mapas
└── Ui/
    ├── Icons/          # Iconos de interfaz
    ├── Fonts/          # Fuentes personalizadas
    └── Panels/         # Paneles de UI
```

### **Convenciones de Recursos**
```bash
# Texturas: formato-descripcion-resolucion
texture-grass-64x64.png
sprite-player-idle-32x32.png

# Audio: tipo-nombre-calidad
music-background-loop-44khz.ogg
sfx-explosion-16bit.wav

# Fuentes: nombre-estilo-tamaño
font-roboto-regular-16pt.ttf
font-pixel-bold-8pt.fnt
```

### **content/scenes/ - Escenas del Juego**
```
scenes/
├── Main.tscn           # Punto de entrada
├── Characters/         # Personajes instanciables
├── Menus/              # Interfaces de usuario
├── World/              # Elementos del mundo
└── Effects/            # Efectos visuales
```

### **Reglas de Escenas**
- Una escena por funcionalidad
- Scripts asociados con mismo nombre
- Uso de componentes en lugar de lógica inline
- Configuración por nodos instanciados

---

## ⚙️ **Configuración del Proyecto**

### **project.godot - Configuración Principal**
```ini
[application]
config/name="Topdown Roguelike"
run/main_scene="res://content/scenes/Main.tscn"
config/features=PackedStringArray("4.4")
config/icon="res://icon.svg"

[autoload]
ServiceManager="*res://game/core/ServiceManager.gd"
EventBus="*res://game/core/events/EventBus.gd"

[input]
# Mapeo de controles personalizados

[rendering]
# Configuración de renderizado
```

### **Autoloads del Proyecto**
```gdscript
# Orden de carga (importante para dependencias)
1. EventBus          # Sistema de eventos (sin dependencias)
2. ServiceManager    # Coordinador de servicios (usa EventBus)

# Los servicios se cargan internamente por ServiceManager
# No son autoloads directos para mantener control del lifecycle
```

### **export_presets.cfg - Configuración de Export**
```ini
[preset.0]
name="Linux/X11"
platform="Linux/X11"
runnable=true
export_filter="all_resources"

[preset.1]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
export_filter="all_resources"
```

---

## 📋 **Flujo de Dependencias**

### **Nivel 1: Fundación**
```
EventBus ← Todas las comunicaciones
    ↑
ServiceManager ← Coordinación de servicios
```

### **Nivel 2: Servicios**
```
ConfigService ← Configuración global
AudioService ← Gestión de audio
InputService ← Gestión de input
```

### **Nivel 3: Core Components**
```
Component (base) ← Clase base
    ↑
HealthComponent, MovementComponent, etc.
```

### **Nivel 4: Game Systems**
```
StateMachine ← Gestión de estados
RoomsSystem ← Sistema de habitaciones
Generators ← Generación procedural
```

### **Nivel 5: Game Content**
```
Player, Enemies ← Entidades del juego
Scenes ← Contenido instanciable
UI Components ← Interfaces
```

---

## 🎯 **Mejores Prácticas de Estructura**

### **1. Separación Clara de Responsabilidades**
```bash
# ✅ Bueno: Separación clara
src/core/components/HealthComponent.gd    # Lógica de salud
content/assets/Characters/health-bar.png  # Recurso visual
content/scenes/UI/HealthBar.tscn          # Escena de UI

# ❌ Malo: Mezclado
src/player/PlayerHealthBarWithLogic.gd    # Todo mezclado
```

### **2. Dependencias Claras**
```gdscript
# ✅ Bueno: Dependencias explícitas
class_name HealthComponent
extends Component

func _ready():
    # Dependencia clara del EventBus
    EventBus.health_changed.connect(_on_health_changed)

# ❌ Malo: Dependencias ocultas
func some_function():
    SomeGlobalVariable.do_something()  # ¿De dónde viene?
```

### **3. Configuración Centralizada**
```gdscript
# ✅ Bueno: Configuración por @export
@export var max_health: int = 100
@export var regen_rate: float = 1.0

# ❌ Malo: Valores hardcodeados
const MAX_HEALTH = 100  # No configurable
var regen_rate = 1.0    # Sin export
```

### **4. Naming Consistente**
```bash
# ✅ Bueno: Naming consistente
HealthComponent.gd
MovementComponent.gd
MenuComponent.gd

# ❌ Malo: Naming inconsistente
health_comp.gd
move_system.gd
MenuLogic.gd
```

---

**📂 ¡Estructura organizada para desarrollo escalable!**

*Última actualización: Septiembre 4, 2025*
