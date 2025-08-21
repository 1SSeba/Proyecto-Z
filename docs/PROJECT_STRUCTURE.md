# Estructura del Proyecto 📁

Este documento describe la organización completa del proyecto Top-Down Game.

## 🗂️ Estructura de carpetas

```
topdown-game/
├── docs/                          # 📚 Documentación del proyecto
│   ├── README.md                  # Índice principal de documentación
│   ├── PROJECT_STRUCTURE.md       # Este archivo
│   ├── STATEMACHINE_STATUS.md     # Estado del State Machine
│   ├── STATEMACHINE_USAGE.md      # Guía de uso del State Machine
│   └── CORE_README.md             # Información del sistema Core
│
├── Assets/                        # 🎨 Recursos del juego
│   ├── Audio/
│   │   ├── Music/                 # Música de fondo
│   │   └── Sfx/                   # Efectos de sonido
│   ├── Characters/
│   │   └── Player/                # Sprites del jugador
│   │       ├── Attack1/           # Animaciones de ataque 1
│   │       ├── Attack2/           # Animaciones de ataque 2
│   │       ├── Idle/              # Animaciones de idle
│   │       └── Run/               # Animaciones de correr
│   ├── Fonts/                     # Fuentes del juego
│   ├── Icons/                     # Iconos e interfaz
│   └── Ui/                        # Elementos de UI
│
├── Autoload/                      # 🔄 Sistemas automáticos (Singletons)
│   ├── AudioManager.gd            # Gestión de audio
│   ├── ConfigManager.gd           # Configuración del juego
│   ├── DebugManager.gd            # Sistema de debug
│   ├── GameManager.gd             # Lógica general del juego
│   ├── GameStateManager.gd        # Estados del juego (legacy)
│   ├── InputManager.gd            # Manejo de input
│   └── ManagerUtils.gd            # Utilidades para managers
│
├── Core/                          # 🏗️ Sistemas centrales
│   ├── StateMachine/              # Sistema de máquina de estados
│   │   ├── StateMachine.gd        # Motor principal
│   │   ├── State.gd               # Clase base de estados
│   │   └── States/                # Estados específicos
│   │       ├── MainMenuState.gd   # Estado del menú principal
│   │       ├── GameplayState.gd   # Estado de juego
│   │       ├── PausedState.gd     # Estado de pausa
│   │       ├── SettingsState.gd   # Estado de configuración
│   │       └── LoadingState.gd    # Estado de carga
│   └── Events/
│       └── EventBus.gd            # Sistema de eventos global
│
├── Scenes/                        # 🎭 Escenas del juego
│   ├── Main.tscn                  # Escena principal
│   ├── Characters/
│   │   └── Player/                # Escenas del jugador
│   │       ├── Player.gd          # Lógica del jugador
│   │       └── Player.tscn        # Escena del jugador
│   ├── Debug/                     # Herramientas de debug
│   │   ├── DebugConsole.gd        # Consola de debug
│   │   ├── DebugConsole.tscn      # UI de la consola
│   │   └── DebugSetup.gd          # Configuración de debug
│   ├── MainMenu/                  # Menú principal
│   │   ├── MainMenu.gd            # Lógica del menú
│   │   ├── MainMenu.tscn          # UI del menú
│   │   └── SettingsMenu.gd        # Menú de configuración
│   └── Room/                      # Salas/Niveles del juego
│
├── Scripts/                       # 📜 Scripts auxiliares
├── UI/                           # 🖥️ Elementos de interfaz
├── Data/                         # 💾 Datos del juego
│
└── Archivos de configuración:
    ├── project.godot             # Configuración del proyecto Godot
    ├── default_bus_layout.tres   # Layout de audio
    └── icon.svg                  # Icono del proyecto
```

## 🔍 Descripción de componentes

### 📚 docs/
Contiene toda la documentación del proyecto en formato Markdown. Cada aspecto del juego está documentado aquí.

### 🎨 Assets/
Todos los recursos visuales y de audio del juego:
- **Characters/Player/**: Sprites organizados por tipo de animación
- **Audio/**: Música y efectos de sonido
- **UI/**: Elementos de interfaz de usuario

### 🔄 Autoload/ (Singletons)
Sistemas que se cargan automáticamente y están disponibles globalmente:
- **AudioManager**: Reproduce música y efectos
- **ConfigManager**: Guarda y carga configuraciones
- **InputManager**: Gestiona controles y input del usuario
- **GameManager**: Lógica central del juego
- **DebugManager**: Herramientas de desarrollo y debug

### 🏗️ Core/
Sistemas centrales y arquitectura del juego:
- **StateMachine/**: Sistema completo de máquina de estados
- **Events/**: Sistema de comunicación por eventos

### 🎭 Scenes/
Escenas organizadas por funcionalidad:
- **Main.tscn**: Punto de entrada del juego
- **Characters/**: Personajes jugables y NPCs
- **Debug/**: Herramientas de desarrollo
- **MainMenu/**: Interfaces de menú

## 🎯 Convenciones de nomenclatura

### Archivos GDScript:
- **PascalCase** para clases: `StateMachine.gd`, `PlayerController.gd`
- **camelCase** para métodos: `transition_to()`, `handle_input()`
- **SNAKE_CASE** para constantes: `MAX_HEALTH`, `DEFAULT_SPEED`

### Escenas:
- **PascalCase** para escenas: `MainMenu.tscn`, `Player.tscn`
- Mismo nombre que el script principal asociado

### Carpetas:
- **PascalCase** para categorías: `StateMachine/`, `Characters/`
- **lowercase** para subcategorías: `states/`, `audio/`

## 🔗 Dependencias entre sistemas

```
Main.tscn
    ↓
StateMachine ← States (MainMenu, Gameplay, etc.)
    ↓              ↓
EventBus ←→ Autoload Managers
    ↓              ↓
Player.tscn    Audio/Config/Input
```

## 🚀 Puntos de entrada

1. **project.godot** → Define autoloads y configuración
2. **Main.tscn** → Escena principal que carga el StateMachine
3. **StateMachine.gd** → Inicia con LoadingState
4. **LoadingState.gd** → Transición a MainMenuState

Esta estructura permite un desarrollo organizado y escalable del juego.

---
*Última actualización: Agosto 2025*
