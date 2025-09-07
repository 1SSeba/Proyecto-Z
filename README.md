# Proyecto-Z (Topdown Game)

[![License](https://img.shields.io/github/license/1SSeba/Proyecto-Z)](LICENSE)
[![Release](https://img.shields.io/github/v/release/1SSeba/Proyecto-Z)](https://github.com/1SSeba/Proyecto-Z/releases)
[![Issues](https://img.shields.io/github/issues/1SSeba/Proyecto-Z)](https://github.com/1SSeba/Proyecto-Z/issues)

Proyecto-Z (nombre operativo: Topdown Game) es un juego de tipo top-down desarrollado con Godot 4.4. El proyecto emplea una arquitectura modular basada en componentes, servicios centralizados para funcionalidades globales y un EventBus para comunicación desacoplada entre sistemas.

Contenido relevante

- Motor: Godot 4.4+
- Licencia: MIT (ver `LICENSE`)
- Repositorio: https://github.com/1SSeba/Proyecto-Z
- Carpeta principal del juego: `game/`

Estructura resumida del repositorio

```
topdown-game/
├─ project.godot
├─ README.md
├─ docs/
├─ game/
│  ├─ core/        # Componentes, servicios, events
│  ├─ entities/    # Entidades (Player, NPCs, Room...)
│  ├─ scenes/      # Escenas (.tscn)
│  └─ assets/      # Recursos (texturas, audio, sprites)
├─ builds/
├─ config/
└─ .vscode/
```

Inicio rápido (desarrollo local)

Requisitos

- Godot Engine 4.4 o superior
- Git (opcional)

Abrir el proyecto

1. Clonar el repositorio (si procede):

```
git clone https://github.com/1SSeba/Proyecto-Z.git
cd Proyecto-Z
```

2. Abrir `project.godot` desde el editor Godot.

Tareas y utilidades (VSCode)

- "Run Game - Graphic Mode": tarea para ejecutar Godot en modo gráfico con resolución 1280x720.
- "Quick Export Debug": tarea para exportar un build de debug Linux/X11 a `builds/debug/game_debug`.

Compruebe `.vscode/tasks.json` para ver y ajustar estas tareas.

Desarrollo

- La lógica central se organiza en `game/core/` (componentes, servicios y sistema de eventos).
- Los sistemas de juego se encuentran en `game/systems/`.
- Las entidades reutilizan componentes (por ejemplo: `HealthComponent`, `MovementComponent`).

Comandos de desarrollo (si existen scripts en `tools/scripts`)

```
./tools/scripts/dev.sh          # script de desarrollo/hot-reload (si está disponible)
./tools/scripts/check_syntax.sh # comprobación de sintaxis
./tools/scripts/build.sh        # build local para pruebas
```

Documentación

La documentación del proyecto reside en `docs/`. Contiene secciones de arquitectura, guía de desarrollo y referencia de API.

- Estructura del proyecto: `docs/architecture/project-structure.md`
- Arquitectura y patrones: `docs/architecture/`
- Guías de desarrollo: `docs/development/`

Contribución

Siga el flujo estándar para contribuciones:

1. Cree una rama para la funcionalidad: `git checkout -b feature/mi-cambio`
2. Asegúrese de que la documentación relevante está actualizada en `docs/`
3. Realice commits pequeños y descriptivos
4. Abra un Pull Request hacia `master` cuando la rama esté lista

Consulte `CONTRIBUTING.md` para normas y estándares de codificación.

Estado actual y notas rápidas

- Implementado: sistema de componentes, `ServiceManager`, `EventBus`, HUD y menús básicos.
- En desarrollo: mejoras en `RoomsSystem`, componentes de enemigo, inventario y sistema de combate.

Mantenimiento y contacto

Para dudas o problemas técnicos, abra un issue en el repositorio: https://github.com/1SSeba/Proyecto-Z/issues

Última actualización: 2025-09-06
- Licencia: MIT (ver `LICENSE`)
