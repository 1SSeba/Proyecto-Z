# Documentación del proyecto

Esta documentación organiza la información del proyecto por áreas: arquitectura, desarrollo, guías para usuarios y referencia de API. Está dirigida tanto a desarrolladores como a colaboradores y usuarios interesados.

Estructura de la documentación

### Architecture (architecture/)
Material técnico sobre la arquitectura del proyecto, sistemas principales y patrones de diseño.

- Component Architecture: diseño del sistema de componentes (architecture/component-architecture.md).
- Service Layer: descripción de la capa de servicios y el `ServiceManager` (architecture/service-layer.md).
- Event System: diseño del `EventBus` y comunicación entre sistemas (architecture/event-system.md).
- Project Structure: organización de carpetas y convenciones (architecture/project-structure.md).

### Development (development/)
Guías para desarrolladores.


### User Guides (user-guides/)
Guías orientadas al usuario final.

- Installation: instrucciones de instalación y requisitos.
 Crear su primer componente siguiendo `development/desarrollo-componentes.md`.
- Settings Guide: opciones de configuración y explicaciones.
- Troubleshooting: problemas comunes y soluciones.

### API Reference (api-reference/)
Referencia técnica de clases, funciones y APIs.

- Components API: detalles técnicos de los componentes (api-reference/api-componentes.md).
- Services API: referencia de servicios disponibles (api-reference/services-api.md).
- EventBus API: eventos disponibles y uso (api-reference/eventbus-api.md).
- Utilities API: utilidades y helpers.

Inicio rápido

Para desarrolladores:

1. Consulte `development/getting-started.md`.
2. Revise `architecture/component-architecture.md` para comprender el patrón de componentes.
3. Cree su primer componente siguiendo `development/desarrollo-componentes.md`.

Para usuarios:

1. Consulte `user-guides/installation.md` para la instalación.
2. Revise `user-guides/game-controls.md` para los controles.

Para colaboradores:

1. Siga `development/coding-standards.md`.
2. Ejecute las pruebas descritas en `development/testing-guide.md`.

Estado de la documentación

| Categoría | Estado | Completitud | Última actualización |
|-----------|--------|-------------|---------------------|
| Architecture | Completada | 100% | 2025-09-06 |
| Development | Completada | 100% | 2025-09-06 |
| User Guides | Completada | 100% | 2025-09-06 |
| API Reference | Completada | 100% | 2025-09-06 |

Consejos de navegación

- Utilice la búsqueda del editor para localizar contenidos.
- Los enlaces en esta documentación son relativos al repositorio y deben abrirse desde su raíz.
- Cada documento incluye un índice y ejemplos cuando procede.

Mantenimiento

<!--
	docs/README.md — Índice principal de la documentación para Proyecto-Z
	Generado a partir del contenido del repositorio: estructura de `docs/`, autoloads en `project.godot` y código bajo `game/`.
	Formato: GitHub Flavored Markdown (GFM). Mantener formal y sin emojis.
-->

# Documentación — Proyecto-Z

Breve descripción
------------------
Esta carpeta contiene la documentación técnica y de usuario para Proyecto-Z. Los documentos están organizados por áreas: arquitectura, desarrollo, referencia de API y guías para usuarios.

> Nota importante
>
> Esta documentación se genera y mantiene en base al código presente en `game/`. Antes de modificar rutas o nombres de singletons (autoloads), confirme los cambios en `project.godot`.

Estado y cobertura
-------------------
| Área | Contenido | Notas |
|------|-----------|-------|
| Architecture | Diseño de sistemas, EventBus, ServiceManager y estructura de componentes | files: `architecture/` |
| Development | Guías de desarrollo, pruebas y plantillas | files: `development/` |
| API Reference | Referencias concisas de componentes y servicios | files: `api-reference/` |
| User Guides | Instalación, controles y ajustes | files: `user-guides/` |

Índice rápido
------------
- Architecture
	- `architecture/component-architecture.md` — Patrón de componentes.
	- `architecture/service-layer.md` — `ServiceManager` y servicios.
	- `architecture/event-system.md` — `EventBus` y eventos.
	- `architecture/project-structure.md` — Organización física de carpetas.
- Development
	- `development/getting-started.md` — Configuración del entorno.
	- `development/desarrollo-componentes.md` — Plantilla y ejemplo para nuevos componentes.
	- `development/service-development.md` — Cómo crear servicios.
	- `development/testing-guide.md` — Ejecutar y escribir pruebas.
- API Reference
	- `api-reference/api-componentes.md`
	- `api-reference/services-api.md`
	- `api-reference/eventbus-api.md`
- User Guides
	- `user-guides/installation.md`
	- `user-guides/game-controls.md`
	- `user-guides/settings-guide.md`

Captura rápida del proyecto (autoritativa)
---------------------------------------
Autoloads (según `project.godot`):

```ini
[autoload]
EventBus="*res://game/core/events/EventBus.gd"
ServiceManager="*res://game/core/ServiceManager.gd"
GameStateManager="*res://game/systems/game-state/GameStateManager.gd"
```

Main scene (ejecución por defecto):

```ini
run/main_scene = "res://game/scenes/menus/MainMenu.tscn"
```

Convenciones documentales
-------------------------
- Rutas internas Godot: usar `res://game/...` como prefijo canónico.
- Nombres de singletons/autoloads: `EventBus`, `ServiceManager`, `GameStateManager`.
- Idioma: español (formal). Formato Markdown (GFM).

Guía de uso rápido
------------------
Para empezar a trabajar en el proyecto (desarrollador):

1. Abrir el proyecto en Godot 4.4+.
2. Consultar `development/getting-started.md` para requisitos y configuraciones.
3. Revisar `architecture/component-architecture.md` para entender el patrón de componentes.

Para preparar documentación o contribuir:

- Añadir archivos en `docs/` o editar los existentes.
- Mantener enlaces relativos entre documentos.
- Actualizar la sección "Estado y cobertura" si agrega o elimina documentos.

<details>
<summary>Guía breve para contribuciones (expandir)</summary>

- Crear un branch con prefijo `docs/`.
- Incluir en el PR la lista de archivos modificados y un comentario breve del alcance.
- Actualizar `CHANGELOG.md` si el cambio afecta el uso del proyecto.
- Ejecutar una comprobación de enlaces locales antes de abrir el PR.

</details>

Verificación y mantenimiento (tareas sugeridas)
--------------------------------------------
- [ ] Ejecutar búsqueda para reemplazos de nombres antiguos y rutas no canónicas.
- [ ] Ejecutar verificación de enlaces internos en `docs/`.
- [ ] Alinear ejemplos de código en la documentación con implementaciones reales bajo `game/`.

> Aviso
>
> Use `res://game/...` como prefijo canónico en todos los documentos. Evite rutas absolutas de sistema.

Contribuciones
--------------
Siga las reglas del repositorio: crear PRs hacia la rama principal, documentar cambios en `CHANGELOG.md` y mantener las convenciones definidas arriba.

Recursos
--------
- Godot Engine: https://docs.godotengine.org/

Última actualización: 2025-09-06
