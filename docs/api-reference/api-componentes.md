# Components API — Proyecto-Z

Clase base para todos los componentes del sistema. Proporciona la interfaz común y funcionalidades básicas.

Paths
- Base component: `res://game/core/components/Component.gd`
- Health: `res://game/core/components/HealthComponent.gd` (if present)
- Movement: `res://game/core/components/MovementComponent.gd` (if present)

Usage contract (short)
- Inputs: entity node (owner), exported properties via `@export`.
- Outputs: emits via `EventBus` (health_changed, entity_moved, etc.).
- Errors: push_error / return false on invalid usage.

Common methods

- initialize(entity: Node) -> void — attach/configure component for entity.
- cleanup() -> void — teardown resources and disconnect signals.
- is_component() -> bool — helper to validate a node is a component.

Components API — Resumen

> Nota
>
> Esta referencia es un resumen generado a partir del estado actual del repositorio. Si algún script no existe en `res://game/core/components/`, los apartados describen convenciones a implementar.

Rutas principales

- `res://game/core/components/Component.gd` — clase base.
- `res://game/core/components/HealthComponent.gd` — (convención: si existe).
- `res://game/core/components/MovementComponent.gd` — (convención: si existe).

Contrato de uso (resumen)

- Inputs: nodo entidad (owner), propiedades exportadas (`@export`).
- Outputs: emisiones via `EventBus` (ej.: `health_changed`, `entity_moved`).
- Errores: usar `push_error()` o retornar `false` en usos inválidos.

Métodos comunes

- `initialize(entity: Node) -> void` — adjunta/configura el componente para la entidad.
- `cleanup() -> void` — libera recursos y desconecta señales.
- `is_component() -> bool` — valida si un nodo es un componente.

Componentes típicos

HealthComponent

- Propiedades: `@export var max_health: int`, `@export var auto_regen: bool`.
- Métodos: `take_damage(amount)`, `heal(amount)`, `revive()`.
- Eventos: emite `EventBus.health_changed`, `EventBus.entity_died`.

MovementComponent

- Propiedades: `@export var speed: float`, `@export var acceleration: float`.
- Métodos: `move_towards(direction: Vector2)`, `stop_movement()`.
- Eventos: emite `EventBus.entity_moved`, `EventBus.movement_started`.

Utilidades

- `ComponentUtils.get_component(entity, "TypeName")` — retorna la instancia o `null`.

Ejemplo de uso

```gdscript
var hc = HealthComponent.new()
hc.max_health = 80
add_child(hc)
hc.initialize(self)

EventBus.health_changed.connect(_on_health_changed)

func _on_health_changed(entity, hp):
	if entity == self:
		print("HP:", hp)
```

---

Aviso

Mantenga esta referencia alineada con los scripts reales bajo `res://game/core/components/`. Si realize cambios en los nombres de clases o rutas, actualice este documento.

Última actualización: 2025-09-06

---

Contenido original:

```
<!-- Referencia de componentes: mantener alineada con res://game/core/components/ -->
```
