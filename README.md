# Proyecto-Z

Un proyecto de juego tipo Roguelike desarrollado en Godot 4.5.

## Descripción

Este repositorio contiene una base de roguelite construida sobre Godot 4.5 actualmente en plena refactorización para adoptar flujos **data-driven + MVCS**. La meta es ofrecer una base ligera y extensible con servicios mínimos, escenas limpias y herramientas de edición enfocadas en datos.

## Características Principales

- **Máquina de estados**: flujo principal gestionado por `GameFlowController` + `GameStateManager`.
- **Servicios Autoload mínimos**: `DebugService`, `ConfigService`, `InputService`, `GameFlowController`.
- **Sistema de eventos ligero**: `EventBus` centralizado con eventos esenciales.
- **Menús reactivos**: `SettingsMenu` reescrito con sliders normalizados y aplicación inmediata.
- **Base data-driven en progreso**: assets agrupados en recursos `.res` y plan de migración a `Resource` personalizados.
- **Jugador modular**: `Player.tscn` utiliza componentes `Movement`, `Animation` y `Health` reutilizables.

## Estructura del Proyecto

```text
game/
├── assets/          # Recursos del juego (audio, texturas, etc.)
├── core/           # Sistemas centrales
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

- **ConfigService**: Persistencia de configuración del usuario apoyada en recursos data-driven.
- **DataService**: Abstracción para cargar `Resource` declarativos (settings, flujo de juego, catálogos).
- **DebugService**: Logging estructurado y utilidades de depuración.
- **InputService**: Gestión de entradas a alto nivel.
- **AudioService**: Mixer centralizado de música/efectos.
- **ResourceLibrary**: Índice de recursos taggeados disponible para entidades y sistemas.
- **GameFlowController**: Arranque y control de estados principales.

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

### Convenciones clave

- El proyecto incluye un `.editorconfig` que define tabulaciones para GDScript y evita espacios en blanco innecesarios. Activa su soporte en tu editor antes de commitear.
- Para sincronizarte con servicios globales usa los helpers `ServiceManager.wait_for_service(s)` en lugar de escribir bucles manuales con `await get_tree().process_frame`.

## Cómo Probar Rápido

### Validación headless

```bash
godot --headless --quit
```

### Export debug (task VS Code "Quick Export Debug")

```bash
godot --headless --export-debug "Linux/X11" builds/debug/game_debug
```

### Ejecución local con ventana

```bash
godot --resolution 1280x720
```

## Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Estado del Proyecto

**Versión**: pre-alpha_V0.0.1

**Características Implementadas**:

- Flujo de estados base y menús principales.
- Servicios mínimos para configuración, debug y entrada.
- Menú de opciones reconstruido.

**En Refactor**:

- Migración data-driven (`GameSettingsData`, `DataService`).
- Adopción de MVCS en menús y gameplay.
- Catálogos de assets y validadores automáticos.

**Planificado**:

- Editor plugin para gestionar datos.
- Sistema de enemigos configurable vía resources.
- Perfilado y automatización de builds.

---

Desarrollado con ❤️ en Godot 4.5
