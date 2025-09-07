# 🏗️ Arquitectura de Componentes
<!--
    component-architecture.md
    Clean, repo-driven component architecture for Proyecto-Z.
-->

# Arquitectura de Componentes — Proyecto-Z

> Resumen: el juego usa un sistema de componentes (no ECS completo). Cada entidad compone funcionalidades mediante nodos "Component" reutilizables.

---

## Índice

- [Visión general](#visión-general)
- [Principios de diseño](#principios-de-diseño)
- [Clase base y ubicación](#clase-base-y-ubicación)
- [Patrones de uso](#patrones-de-uso)
- [Ciclo de vida](#ciclo-de-vida)
- [Ejemplo mínimo](#ejemplo-mínimo)
- [Buenas prácticas](#buenas-prácticas)

---

## Visión general

El código de Proyecto-Z está organizado con componentes GDScript que encapsulan responsabilidades (salud, movimiento, UI, etc.). La comunicación entre componentes se realiza mediante `EventBus` y servicios cuando aplica.

## Principios de diseño

- Separación de responsabilidades — un componente = una responsabilidad.
- Composición sobre herencia — las entidades agregan componentes como hijos.
- Comunicación desacoplada vía `EventBus`.
- Configuración por `@export` para exponer propiedades en el editor.

## Clase base y ubicación

- Clase base: `Component` (res://game/core/components/Component.gd)

```gdscript
class_name Component
extends Node

func initialize(entity: Node) -> void: pass
func cleanup() -> void: pass
```

Usar esta clase como plantilla para componentes concretos (Health, Movement, Menu, etc.).

## Patrones de uso

- Componentes de juego (Health, Movement, Resource, etc.) se ubican en `res://game/core/components/`.
- Servicios (Audio, Config, Input) se exponen via `ServiceManager`.
- Ejemplo de comunicación:

```gdscript
# emitir
EventBus.health_changed.emit(entity, new_health)

# escuchar
EventBus.health_changed.connect(_on_health_changed)
```

## Ciclo de vida

1. Instanciación: `var c = HealthComponent.new()` → `parent.add_child(c)`
2. Inicialización: `c.initialize(parent)` (puede ser automática en `_ready`).
3. Uso: responder eventos, actualizar estado.
4. Limpieza: `c.cleanup()` o se llama en `_exit_tree()`.

## Ejemplo mínimo

```gdscript
var h = HealthComponent.new()
h.max_health = 100
add_child(h)
```

## Buenas prácticas

- Evitar dependencias circulares entre componentes.
- Preferir señales y `EventBus` antes que referencias directas.
- Documentar `@export` y valores esperados.
- Añadir tests unitarios (Gut) para lógica compleja.

---

*Última actualización: 2025-09-06*
