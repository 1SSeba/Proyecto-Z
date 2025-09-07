Propuesta de reorganización y renombrado — Proyecto-Z

Resumen

Este documento propone nombres canónicos y una estructura limpia para la carpeta `docs/`. No aplicaré cambios destructivos automáticamente; aquí tienes la propuesta para revisar y aprobar.

Objetivos

- Unificar duplicados.
- Usar convenciones: carpetas en kebab-case, archivos en kebab-case en español.
- Mantener un índice principal claro en `docs/README.md`.
- Evitar eliminación automática: se propondrán movimientos y fusiones.

Convenciones propuestas

- Carpetas: kebab-case (ej. `api-reference`, `user-guides`, `development`).
- Archivos: kebab-case y en español cuando el contenido esté en español (ej. `desarrollo-componentes.md`).
- Prefijo canónico para rutas Godot: usar `res://game/...` dentro de ejemplos.
- Idioma principal: español (salvo que el documento sea referencia API en inglés, en cuyo caso indicar idioma en título).

Propuesta de estructura (alto nivel)

docs/
- README.md                         -> índice principal (español)
- REFERENCE.md                       -> breve guía sobre cómo mantener la documentación
- architecture/
    - component-architecture.md      -> arquitectura de componentes (mantener)
    - event-system.md               -> sistema de eventos (mantener)
    - service-layer.md              -> capa de servicios (mantener)
    - project-structure.md          -> estructura física del proyecto (mantener, eliminar duplicado)
- development/
    - getting-started.md            -> inicio y entorno (mantener)
    - desarrollo-componentes.md     -> guía para crear componentes (español)
    - service-development.md        -> desarrollo de servicios
    - testing-guide.md              -> guía de testing
    - coding-standards.md           -> normas de codificación (crear si falta)
- api-reference/
    - api-componentes.md           -> referencia de componentes (español)
    - resource-manager-api.md       -> API del resource manager
- user-guides/
    - installation.md               -> instalación
    - game-controls.md              -> controles
    - settings-guide.md             -> ajustes
- troubleshooting/
    - debugging-resources.md
    - performance-tips.md
    - resource-issues.md
- analysis/ (archivos de análisis y reporte)

Renombrados / fusiones sugeridas (lista concreta)

1) `docs/PROJECT_STRUCTURE.md` -> merge con `docs/architecture/project-structure.md` (mantener solo `docs/architecture/project-structure.md` y eliminar el duplicado raíz).
   - Razón: hay un `architecture/project-structure.md` ya canónico.

2) `docs/development/component-development.md` -> proponer `docs/development/desarrollo-componentes.md` o `component-development.md` según idioma del contenido.
   - Acción sugerida: mover y estandarizar título y metadatos.

3) `docs/api-reference/components-api.md` -> `docs/api-reference/api-componentes.md` o `api-componentes.md`.

4) Agregar `docs/CONTRIBUTING_DOCS.md` con reglas de naming y workflow para docs (opcional).

Pasos recomendados para aplicar (procedimiento)

- Crear un branch `docs/restructure`.
- Añadir estos archivos propuestos (`README_PROPOSED.md`) y `rename-proposal.md` (ya creado y actualizado).
- Revisar y hacer PR con la lista de movimientos.
- Actualizar enlaces internos con script (se puede automatizar con grep/sed) antes de mergear.

Notas

- No realizaré movimientos automáticos sin tu confirmación.
- Si autorizas, puedo aplicar los renombres propuestos y actualizar los enlaces relativos en los documentos.

Fecha: 2025-09-06
