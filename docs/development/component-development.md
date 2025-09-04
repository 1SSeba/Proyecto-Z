# 🧩 Desarrollo de Componentes

## 📋 **Índice**
- [Conceptos Fundamentales](#conceptos-fundamentales)
- [Crear Componentes Básicos](#crear-componentes-básicos)
- [Componentes Avanzados](#componentes-avanzados)
- [Integración con EventBus](#integración-con-eventbus)
- [Testing de Componentes](#testing-de-componentes)
- [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 **Conceptos Fundamentales**

### **¿Qué es un Componente?**
Un componente es una clase que encapsula una funcionalidad específica y puede ser reutilizada en múltiples entidades. Sigue el principio de **responsabilidad única**.

### **Características de Componentes**
- ✅ **Independientes**: No dependen directamente de otros componentes
- ✅ **Reutilizables**: Pueden usarse en múltiples entidades
- ✅ **Configurables**: Usan @export para configuración
- ✅ **Comunicativos**: Usan EventBus para comunicación
- ✅ **Limpios**: Manejan su propia inicialización y limpieza

---

## 🔨 **Crear Componentes Básicos**

### **Plantilla Base**
```gdscript
# /src/core/components/MyComponent.gd
class_name MyComponent
extends Component

# Configuración exportada
@export var property_example: int = 10
@export var enabled: bool = true

# Estado interno
var internal_state: Dictionary = {}
var entity: Node

func initialize(entity_node: Node) -> void:
    entity = entity_node
    
    # Validación de entidad requerida
    if not entity:
        push_error("MyComponent requires a valid entity")
        return
    
    # Configuración inicial
    setup_component()
    
    # Conectar eventos si es necesario
    connect_events()
    
    print("MyComponent initialized for: ", entity.name)

func cleanup() -> void:
    # Desconectar eventos
    disconnect_events()
    
    # Limpiar estado
    internal_state.clear()
    
    print("MyComponent cleaned up")

func setup_component() -> void:
    # Configuración específica del componente
    internal_state["initialized"] = true

func connect_events() -> void:
    # Conectar a eventos relevantes
    # EventBus.some_event.connect(_on_some_event)
    pass

func disconnect_events() -> void:
    # Desconectar eventos
    # if EventBus.some_event.is_connected(_on_some_event):
    #     EventBus.some_event.disconnect(_on_some_event)
    pass

# Funcionalidad específica del componente
func do_component_action() -> void:
    if not enabled:
        return
    
    # Lógica del componente
    internal_state["action_count"] = internal_state.get("action_count", 0) + 1
    
    # Emitir evento
    EventBus.component_action.emit(entity, "my_component", "action_performed")
```

---

## 🚀 **Componentes Avanzados**

### **Componente con Timer**
```gdscript
class_name TimedComponent
extends Component

@export var interval: float = 1.0
@export var auto_start: bool = true

var timer: Timer

func initialize(entity_node: Node) -> void:
    entity = entity_node
    
    # Crear y configurar timer
    timer = Timer.new()
    timer.wait_time = interval
    timer.timeout.connect(_on_timer_timeout)
    add_child(timer)
    
    if auto_start:
        timer.start()

func cleanup() -> void:
    if timer:
        timer.queue_free()

func start_timer() -> void:
    if timer:
        timer.start()

func stop_timer() -> void:
    if timer:
        timer.stop()

func _on_timer_timeout() -> void:
    # Lógica ejecutada cada intervalo
    EventBus.timed_action.emit(entity, interval)
```

### **Componente con Estado**
```gdscript
class_name StatefulComponent
extends Component

enum State { IDLE, ACTIVE, COOLDOWN }

@export var initial_state: State = State.IDLE
@export var cooldown_time: float = 2.0

var current_state: State
var state_timer: Timer

func initialize(entity_node: Node) -> void:
    entity = entity_node
    current_state = initial_state
    
    # Timer para cambios de estado
    state_timer = Timer.new()
    state_timer.timeout.connect(_on_state_timer_timeout)
    add_child(state_timer)
    
    # Conectar eventos
    EventBus.state_change_requested.connect(_on_state_change_requested)

func change_state(new_state: State) -> void:
    if current_state == new_state:
        return
    
    # Salir del estado actual
    exit_state(current_state)
    
    # Cambiar estado
    var previous_state = current_state
    current_state = new_state
    
    # Entrar al nuevo estado
    enter_state(current_state)
    
    # Emitir evento
    EventBus.component_state_changed.emit(entity, previous_state, current_state)

func enter_state(state: State) -> void:
    match state:
        State.IDLE:
            # Lógica para entrar a IDLE
            pass
        State.ACTIVE:
            # Lógica para entrar a ACTIVE
            pass
        State.COOLDOWN:
            # Iniciar cooldown
            state_timer.wait_time = cooldown_time
            state_timer.start()

func exit_state(state: State) -> void:
    match state:
        State.IDLE:
            # Lógica para salir de IDLE
            pass
        State.ACTIVE:
            # Lógica para salir de ACTIVE
            pass
        State.COOLDOWN:
            # Detener timer si es necesario
            state_timer.stop()

func _on_state_timer_timeout() -> void:
    if current_state == State.COOLDOWN:
        change_state(State.IDLE)

func _on_state_change_requested(target_entity: Node, requested_state: State) -> void:
    if target_entity == entity:
        change_state(requested_state)
```

### **Componente con Recursos**
```gdscript
class_name ResourceComponent
extends Component

@export var max_resource: int = 100
@export var resource_name: String = "energy"
@export var regen_rate: float = 1.0
@export var regen_interval: float = 1.0

var current_resource: int
var regen_timer: Timer

func initialize(entity_node: Node) -> void:
    entity = entity_node
    current_resource = max_resource
    
    # Timer para regeneración
    regen_timer = Timer.new()
    regen_timer.wait_time = regen_interval
    regen_timer.timeout.connect(_on_regen_timer_timeout)
    add_child(regen_timer)
    regen_timer.start()
    
    # Eventos
    EventBus.resource_consume_requested.connect(_on_resource_consume_requested)
    EventBus.resource_add_requested.connect(_on_resource_add_requested)

func consume_resource(amount: int) -> bool:
    if current_resource >= amount:
        current_resource -= amount
        EventBus.resource_changed.emit(entity, resource_name, current_resource, max_resource)
        
        if current_resource <= 0:
            EventBus.resource_depleted.emit(entity, resource_name)
        
        return true
    
    return false

func add_resource(amount: int) -> void:
    var old_resource = current_resource
    current_resource = min(max_resource, current_resource + amount)
    
    if current_resource != old_resource:
        EventBus.resource_changed.emit(entity, resource_name, current_resource, max_resource)

func get_resource_percentage() -> float:
    return float(current_resource) / float(max_resource)

func _on_regen_timer_timeout() -> void:
    if current_resource < max_resource:
        add_resource(int(regen_rate))

func _on_resource_consume_requested(target_entity: Node, resource_type: String, amount: int) -> void:
    if target_entity == entity and resource_type == resource_name:
        consume_resource(amount)

func _on_resource_add_requested(target_entity: Node, resource_type: String, amount: int) -> void:
    if target_entity == entity and resource_type == resource_name:
        add_resource(amount)
```

---

## 📡 **Integración con EventBus**

### **Eventos Específicos de Componentes**
```gdscript
# En EventBus.gd - añadir eventos específicos de componentes

# Eventos genéricos de componentes
signal component_added(entity: Node, component_type: String)
signal component_removed(entity: Node, component_type: String)
signal component_state_changed(entity: Node, old_state: Variant, new_state: Variant)

# Eventos de recursos
signal resource_changed(entity: Node, resource_name: String, current: int, max: int)
signal resource_depleted(entity: Node, resource_name: String)
signal resource_consume_requested(entity: Node, resource_name: String, amount: int)
signal resource_add_requested(entity: Node, resource_name: String, amount: int)

# Eventos de tiempo
signal timed_action(entity: Node, interval: float)
signal cooldown_started(entity: Node, duration: float)
signal cooldown_finished(entity: Node)
```

### **Patrón de Comunicación entre Componentes**
```gdscript
# Componente A emite evento
class_name ComponentA
extends Component

func do_action():
    EventBus.action_performed.emit(entity, "component_a", "special_action")

# Componente B responde al evento
class_name ComponentB
extends Component

func _ready():
    EventBus.action_performed.connect(_on_action_performed)

func _on_action_performed(source_entity: Node, component: String, action: String):
    if source_entity == entity and action == "special_action":
        # Responder a la acción de ComponentA
        react_to_action()

func react_to_action():
    print("ComponentB reacting to ComponentA action")
```

---

## 🧪 **Testing de Componentes**

### **Setup de Test Básico**
```gdscript
# /tests/components/TestMyComponent.gd
extends GutTest

var component: MyComponent
var test_entity: Node2D

func before_each():
    # Crear entidad de prueba
    test_entity = Node2D.new()
    add_child(test_entity)
    
    # Crear componente
    component = MyComponent.new()
    test_entity.add_child(component)

func after_each():
    # Limpiar
    if test_entity:
        test_entity.queue_free()

func test_component_initialization():
    # Verificar que el componente se inicializa correctamente
    assert_not_null(component)
    assert_eq(component.entity, test_entity)
    assert_true(component.internal_state.has("initialized"))

func test_component_action():
    # Probar funcionalidad específica
    var initial_count = component.internal_state.get("action_count", 0)
    component.do_component_action()
    var final_count = component.internal_state.get("action_count", 0)
    
    assert_eq(final_count, initial_count + 1)

func test_event_emission():
    # Verificar que el componente emite eventos correctamente
    watch_signals(EventBus)
    component.do_component_action()
    assert_signal_emitted(EventBus, "component_action")
```

### **Test de Componente con Mock**
```gdscript
extends GutTest

var health_component: HealthComponent
var mock_entity: Node2D

func before_each():
    mock_entity = Node2D.new()
    mock_entity.add_to_group("test_entity")
    add_child(mock_entity)
    
    health_component = HealthComponent.new()
    health_component.max_health = 100
    mock_entity.add_child(health_component)

func test_damage_calculation():
    # Estado inicial
    assert_eq(health_component.current_health, 100)
    
    # Aplicar daño
    health_component.take_damage(25)
    assert_eq(health_component.current_health, 75)
    
    # Verificar evento
    watch_signals(EventBus)
    health_component.take_damage(10)
    assert_signal_emitted_with_parameters(
        EventBus,
        "health_changed",
        [mock_entity, 65]
    )

func test_death_condition():
    watch_signals(EventBus)
    
    # Daño letal
    health_component.take_damage(150)
    
    # Verificar estado
    assert_eq(health_component.current_health, 0)
    assert_signal_emitted(EventBus, "entity_died")
```

---

## 🎯 **Mejores Prácticas**

### **1. Diseño de Componentes**
```gdscript
# ✅ Bueno: Responsabilidad única
class HealthComponent:
    func take_damage()
    func heal()
    func get_health_percentage()

# ❌ Malo: Múltiples responsabilidades
class PlayerController:
    func take_damage()
    func move()
    func shoot()
    func manage_inventory()
```

### **2. Configuración Externa**
```gdscript
# ✅ Bueno: Configuración flexible
@export var max_health: int = 100
@export var damage_multiplier: float = 1.0
@export var immune_to_damage_types: Array[String] = []

# ❌ Malo: Valores hardcodeados
const MAX_HEALTH = 100
const DAMAGE_MULTIPLIER = 1.0
```

### **3. Validación Robusta**
```gdscript
# ✅ Bueno: Validación completa
func initialize(entity_node: Node) -> void:
    if not entity_node:
        push_error("Entity cannot be null")
        return
    
    if not entity_node.has_method("get_groups"):
        push_error("Entity must be a Node with groups support")
        return
    
    entity = entity_node
    setup_component()

# ❌ Malo: Sin validación
func initialize(entity_node: Node) -> void:
    entity = entity_node
```

### **4. Gestión de Estado Limpia**
```gdscript
# ✅ Bueno: Estado claro y mantenible
enum ComponentState { INACTIVE, ACTIVE, DISABLED, ERROR }

var current_state: ComponentState = ComponentState.INACTIVE

func set_state(new_state: ComponentState) -> void:
    if current_state != new_state:
        var old_state = current_state
        current_state = new_state
        _on_state_changed(old_state, new_state)

# ❌ Malo: Estado inconsistente
var is_active: bool = false
var is_disabled: bool = false
var has_error: bool = false  # Estados conflictivos
```

### **5. Documentación Clara**
```gdscript
## Un componente que maneja la salud de una entidad
## 
## Características:
## - Salud máxima configurable
## - Regeneración automática opcional
## - Inmunidad a tipos específicos de daño
## - Eventos de cambio de salud y muerte
##
## Uso:
## [codeblock]
## var health = HealthComponent.new()
## health.max_health = 150
## health.auto_regen = true
## entity.add_child(health)
## [/codeblock]
class_name HealthComponent
extends Component
```

---

## 📊 **Patrones Comunes**

### **Observer Pattern**
```gdscript
# Componente que observa eventos específicos
class_name ObserverComponent
extends Component

var watched_events: Array[String] = []

func initialize(entity_node: Node) -> void:
    entity = entity_node
    for event_name in watched_events:
        EventBus.connect(event_name, _on_watched_event.bind(event_name))

func _on_watched_event(event_name: String, args: Array = []) -> void:
    # Procesar evento observado
    handle_observed_event(event_name, args)
```

### **State Machine Component**
```gdscript
class_name StateMachineComponent
extends Component

var states: Dictionary = {}
var current_state: String = ""

func add_state(state_name: String, state_logic: Callable) -> void:
    states[state_name] = state_logic

func transition_to(state_name: String) -> void:
    if state_name in states:
        current_state = state_name
        states[state_name].call()
```

---

**🧩 ¡Componentes modulares para arquitectura escalable!**

*Última actualización: Septiembre 4, 2025*
