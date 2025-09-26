# Proyecto-Z

Un proyecto de juego tipo RougeLike desarrollado en Godot 4.5.

## Descripción

Este es un juego base que incluye un sistema completo de estados, gestión de servicios, componentes modulares y una arquitectura escalable para proyectos de juegos.

## Características Principales

- **Sistema de Estados Completo**: StateMachine profesional con estados Loading, MainMenu, Playing, Paused, RunComplete, RunFailed
- **Gestión de Servicios**: AudioService, ConfigService, DebugService, InputService, ResourceLibrary
- **Componentes Modulares**: HealthComponent, MovementComponent, MenuComponent
- **Sistema de Eventos**: EventBus centralizado para comunicación entre sistemas
- **Arquitectura Escalable**: Diseño modular que facilita la expansión del proyecto

## Estructura del Proyecto

```text
game/
├── assets/          # Recursos del juego (audio, texturas, etc.)
├── core/           # Sistemas centrales
│   ├── components/ # Componentes reutilizables
│   ├── events/     # Sistema de eventos
│   ├── services/   # Servicios del juego
│   └── systems/    # Sistemas principales (StateMachine, SceneController)
├── entities/       # Entidades del juego (Player, Room)
├── scenes/         # Escenas del juego
│   ├── menus/      # Menús del juego
│   ├── gameplay/   # Escenas de gameplay
│   └── hud/        # Interfaz de usuario
└── ui/             # Componentes de UI
```

## Instalación

1. Clona el repositorio
2. Abre el proyecto en Godot 4.5
3. Ejecuta la escena principal

## Uso

### Sistema de Estados

El juego utiliza un StateMachine robusto que maneja los diferentes estados:

- **LoadingState**: Estado de carga inicial
- **MenuState**: Estados de menús (principal, configuración)
- **PlayingState**: Estado de juego activo
- **PausedState**: Estado de pausa

### Servicios Disponibles

- **AudioService**: Gestión de audio y música
- **ConfigService**: Configuración del juego
- **DebugService**: Herramientas de debug
- **InputService**: Gestión de entrada del usuario
- **ResourceLibrary**: Carga y gestión de recursos

### Componentes

- **HealthComponent**: Gestión de vida de entidades
- **MovementComponent**: Manejo de movimiento
- **MenuComponent**: Funcionalidad de menús

## Arquitectura

### Core Systems

#### ServiceManager

Gestiona todos los servicios del juego de forma centralizada.

#### EventBus

Sistema de eventos global para comunicación desacoplada.

#### StateMachine

Máquina de estados flexible y extensible.

### Game Flow

#### GameStateManager

Controla el flujo principal del juego.

#### SceneController

Gestiona la carga y transición entre escenas.

### UI Systems

#### BackgroundManager

Gestiona fondos dinámicos de menús.

#### TransitionManager

Maneja transiciones visuales entre escenas.

## Desarrollo

Para contribuir al proyecto:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Tasks Disponibles

### Quick Export Debug

```bash
godot --headless --export-debug "Linux/X11" builds/debug/game_debug
```

### Run Game - Graphic Mode

```bash
godot --resolution 1280x720
```

### Test Game - Simple Settings

```bash
godot --resolution 1280x720
```

## Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Estado del Proyecto

**Versión**: pre-alpha_V0.0.1

**Características Implementadas**:

- Sistema de estados base
- Servicios principales
- Componentes básicos
- UI y menús base

**En Desarrollo**:

- Mecánicas de gameplay
- Sistema de inventario
- Sistema de combate
- Generación procedural

**Planificado**:

- Multijugador
- Sistema de logros
- Personalización de personajes
- Más tipos de enemigos

---

Desarrollado con ❤️ en Godot 4.5
