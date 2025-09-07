# Desarrollo de Componentes

Este documento explica cómo diseñar, implementar y probar componentes en Proyecto-Z. Mantenga la responsabilidad única y use `EventBus` para la comunicación.

Índice

- Conceptos fundamentales
- Crear componentes básicos
- Componentes avanzados
- Integración con EventBus
- Testing de componentes
- Mejores prácticas

---

Conceptos fundamentales

¿Qué es un componente?
Un componente encapsula una funcionalidad específica y se aplica a entidades. Debe seguir el principio de responsabilidad única.

Características recomendadas

- Independientes
- Reutilizables
- Configurables vía `@export`
- Comunicativos mediante `EventBus`
- Limpios en inicialización y limpieza

---

Crear componentes básicos

Plantilla base (ejemplo)

```gdscript
# /game/core/components/MyComponent.gd
class_name MyComponent
extends Component

@export var property_example: int = 10
@export var enabled: bool = true

var internal_state: Dictionary = {}
var entity: Node

func initialize(entity_node: Node) -> void:
	entity = entity_node
	if not entity:
		push_error("MyComponent requires a valid entity")
		return
	setup_component()
	connect_events()

func cleanup() -> void:
	disconnect_events()
	internal_state.clear()

func do_component_action() -> void:
	if not enabled:
		return
	internal_state["action_count"] = internal_state.get("action_count", 0) + 1
	EventBus.component_action.emit(entity, "my_component", "action_performed")
```

---

Componentes avanzados

TimedComponent — ejemplo con Timer

```gdscript
class_name TimedComponent
extends Component

@export var interval: float = 1.0
@export var auto_start: bool = true

var timer: Timer

func initialize(entity_node: Node) -> void:
	entity = entity_node
	timer = Timer.new()
	timer.wait_time = interval
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	if auto_start:
		timer.start()

func cleanup() -> void:
	if timer:
		timer.queue_free()

func _on_timer_timeout() -> void:
	EventBus.timed_action.emit(entity, interval)
```

---

Integración con EventBus

Documente las señales nuevas que añada al `EventBus` en `game/core/events/EventBus.gd` y mantenga nombres descriptivos.

---

Testing de componentes

Ejemplo: test básico con Gut

```gdscript
# /tests/components/TestMyComponent.gd
extends GutTest

func before_each():
	# Crear entidad y añadir componente
	pass

func test_component_initialization():
	# Aserciones de inicialización
	pass
```

---

Mejores prácticas

- Diseñar componentes con responsabilidad única.
- Validar entradas en `initialize()` y usar `push_error()` cuando sea necesario.
- Limpiar conexiones en `cleanup()` o `_exit_tree()`.

---

Última actualización: Septiembre 4, 2025
