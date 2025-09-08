# 🧩 Sistema de Componentes - RougeLike Base

El Sistema de Componentes es una arquitectura modular que permite crear entidades complejas combinando pequeños bloques de funcionalidad reutilizables. Este enfoque facilita el mantenimiento, testing y extensibilidad del código.

## 🎯 Conceptos Fundamentales

### ¿Qué es un Componente?

Un **Componente** es una unidad de funcionalidad específica que puede ser agregada a cualquier entidad del juego. Cada componente tiene una responsabilidad bien definida:

- **HealthComponent**: Gestiona vida y daño
- **MovementComponent**: Controla movimiento y física
- **AttackComponent**: Maneja ataques y combate
- **InventoryComponent**: Gestiona items y equipamiento

### Filosofía de Diseño

```
🎮 ENTIDAD = Base (Node) + Componentes
🧩 COMPONENTE = Funcionalidad específica + Estado + Comportamiento
🔗 COMUNICACIÓN = Señales + EventBus + Referencias directas
```

### Ventajas del Sistema

- **✅ Modularidad**: Funcionalidades independientes y reutilizables
- **✅ Composición**: Crear entidades complejas combinando componentes
- **✅ Testabilidad**: Cada componente se puede testear de forma aislada
- **✅ Escalabilidad**: Fácil agregar nuevas funcionalidades
- **✅ Mantenimiento**: Cambios localizados sin afectar otros sistemas

## 🏗️ Arquitectura del Sistema

### Jerarquía de Clases

```
Component (Base)
├── HealthComponent
├── MovementComponent
├── AttackComponent
├── InventoryComponent
├── MenuComponent
└── [Futuros Componentes...]
```

### Clase Base Component

```gdscript
# game/core/components/Component.gd
class_name Component
extends Node

## Clase base para todos los componentes del juego.
##
## Proporciona funcionalidad común como inicialización,
## activación/desactivación, y comunicación con otros componentes.

# Identificación del componente
@export var component_id: String = ""
@export var enabled: bool = true

# Estado del componente
var is_component_ready: bool = false
var owner_entity: Node = null

# Señales comunes
signal component_enabled()
signal component_disabled()
signal component_ready()

func _ready():
    # Establecer owner entity
    owner_entity = get_parent()

    # Configurar ID si no está establecido
    if component_id.is_empty():
        component_id = get_script().get_global_name()

    # Marcar como listo
    is_component_ready = true
    component_ready.emit()

    print("Component '%s' ready on entity '%s'" % [component_id, owner_entity.name])

## Activar/desactivar el componente
func set_enabled(value: bool):
    if enabled != value:
        enabled = value

        if enabled:
            _on_component_enabled()
            component_enabled.emit()
        else:
            _on_component_disabled()
            component_disabled.emit()

## Métodos virtuales para override
func _on_component_enabled():
    # Override en clases derivadas
    pass

func _on_component_disabled():
    # Override en clases derivadas
    pass

## Obtener la entidad propietaria
func get_entity() -> Node:
    return owner_entity

## Obtener otro componente de la misma entidad
func get_component(component_type: String) -> Component:
    if not owner_entity:
        return null

    for child in owner_entity.get_children():
        if child is Component and child.component_id == component_type:
            return child

    return null

## Verificar si la entidad tiene un componente
func has_component(component_type: String) -> bool:
    return get_component(component_type) != null

## Debug info
func debug_info():
    print("=== %s DEBUG INFO ===" % component_id)
    print("Enabled: %s" % enabled)
    print("Ready: %s" % is_component_ready)
    print("Owner: %s" % (owner_entity.name if owner_entity else "None"))
    print("========================")
```

## 🔧 Componentes Implementados

### 1. HealthComponent

Gestiona la salud, daño y regeneración de entidades:

```gdscript
# game/core/components/HealthComponent.gd
extends Component
class_name HealthComponent

## Componente de salud para entidades del juego.
##
## Gestiona vida, daño, curación y regeneración automática.
## Integra con EventBus para notificar eventos importantes.

# Señales específicas
signal health_changed(current: int, maximum: int)
signal health_depleted(entity: Node)
signal damage_taken(damage: int, source: Node)
signal healed(amount: int)

# Configuración exportada
@export var max_health: int = 100: set = set_max_health
@export var regeneration_rate: float = 0.0
@export var regeneration_delay: float = 3.0
@export var invulnerable: bool = false

# Estado actual
var current_health: int = 100
var is_alive: bool = true
var last_damage_time: float = 0.0

# Referencias internas
var regeneration_timer: Timer

func _ready():
    super()
    component_id = "HealthComponent"
    _initialize_component()

func _initialize_component():
    # Configurar salud inicial
    current_health = max_health
    is_alive = true

    # Configurar timer de regeneración
    if regeneration_rate > 0.0:
        regeneration_timer = Timer.new()
        add_child(regeneration_timer)
        regeneration_timer.wait_time = 1.0
        regeneration_timer.timeout.connect(_regenerate_health)
        regeneration_timer.start()

## Aplicar daño a la entidad
func take_damage(amount: int, source: Node = null) -> bool:
    if not is_alive or invulnerable or amount <= 0:
        return false

    var old_health = current_health
    current_health = max(0, current_health - amount)
    last_damage_time = Time.get_time_dict_from_system()["unix"]

    # Emitir eventos
    damage_taken.emit(amount, source)
    health_changed.emit(current_health, max_health)

    # Verificar muerte
    if current_health <= 0 and old_health > 0:
        _handle_health_depleted()

    return true

## Curar la entidad
func heal(amount: int) -> bool:
    if not is_alive or amount <= 0:
        return false

    if current_health >= max_health:
        return false

    current_health = min(max_health, current_health + amount)

    healed.emit(amount)
    health_changed.emit(current_health, max_health)

    return true

## Regeneración automática
func _regenerate_health():
    if regeneration_rate > 0.0 and is_alive:
        var current_time = Time.get_time_dict_from_system()["unix"]
        if current_time - last_damage_time >= regeneration_delay:
            heal(int(regeneration_rate))

## Manejo de muerte
func _handle_health_depleted():
    is_alive = false
    health_depleted.emit(get_entity())

    # Notificar a EventBus si está disponible
    if EventBus:
        var entity = get_entity()
        if entity and entity.has_method("get_entity_type"):
            var entity_type = entity.get_entity_type()
            if entity_type == "player":
                EventBus.player_died.emit()
            elif entity_type == "enemy":
                EventBus.enemy_defeated.emit(entity)

## Setter para max_health
func set_max_health(value: int):
    max_health = max(1, value)
    if current_health > max_health:
        current_health = max_health

## Getters de utilidad
func get_health_percentage() -> float:
    return float(current_health) / float(max_health)

func is_low_health(threshold: float = 0.25) -> bool:
    return get_health_percentage() <= threshold

func is_full_health() -> bool:
    return current_health >= max_health
```

### 2. MovementComponent

Controla el movimiento y la física de entidades:

```gdscript
# game/core/components/MovementComponent.gd
extends Component
class_name MovementComponent

## Componente de movimiento para entidades del juego.
##
## Gestiona velocidad, aceleración, fricción y límites de movimiento.
## Funciona con CharacterBody2D y RigidBody2D.

# Señales específicas
signal movement_started()
signal movement_stopped()
signal direction_changed(new_direction: Vector2)

# Configuración exportada
@export var max_speed: float = 150.0
@export var acceleration: float = 500.0
@export var friction: float = 300.0
@export var can_move: bool = true

# Estado actual
var velocity: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false

# Referencias
var physics_body: Node2D

func _ready():
    super()
    component_id = "MovementComponent"
    _initialize_component()

func _initialize_component():
    # Buscar physics body en el parent
    physics_body = owner_entity

    if not (physics_body is CharacterBody2D or physics_body is RigidBody2D):
        push_error("MovementComponent requires CharacterBody2D or RigidBody2D")

## Mover en una dirección específica
func move_in_direction(direction: Vector2, delta: float):
    if not can_move:
        return

    direction = direction.normalized()

    # Detectar cambio de dirección
    if direction != last_direction:
        last_direction = direction
        direction_changed.emit(direction)

    # Aplicar movimiento
    if direction.length() > 0:
        # Acelerar hacia la dirección objetivo
        velocity = velocity.move_toward(direction * max_speed, acceleration * delta)

        if not is_moving:
            is_moving = true
            movement_started.emit()
    else:
        # Aplicar fricción
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

        if is_moving and velocity.length() < 1.0:
            is_moving = false
            velocity = Vector2.ZERO
            movement_stopped.emit()

## Aplicar el movimiento al physics body
func apply_movement():
    if physics_body is CharacterBody2D:
        physics_body.velocity = velocity
        physics_body.move_and_slide()
    elif physics_body is RigidBody2D:
        physics_body.linear_velocity = velocity

## Teleportar a una posición
func teleport_to(position: Vector2):
    if physics_body:
        physics_body.global_position = position
        velocity = Vector2.ZERO

## Detener movimiento inmediatamente
func stop_movement():
    velocity = Vector2.ZERO
    if is_moving:
        is_moving = false
        movement_stopped.emit()

## Getters de utilidad
func get_speed() -> float:
    return velocity.length()

func get_normalized_velocity() -> Vector2:
    return velocity.normalized()

func is_moving_towards(target_position: Vector2) -> bool:
    if velocity.length() == 0:
        return false

    var direction_to_target = (target_position - physics_body.global_position).normalized()
    var movement_direction = velocity.normalized()

    return direction_to_target.dot(movement_direction) > 0.5
```

### 3. MenuComponent

Gestiona interfaces de usuario y menús:

```gdscript
# game/core/components/MenuComponent.gd
extends Component
class_name MenuComponent

## Componente de menú para gestionar interfaces de usuario.
##
## Proporciona funcionalidad común para menús, diálogos
## y otros elementos de UI.

# Señales específicas
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)
signal option_selected(option: String)

# Configuración exportada
@export var menu_scene: PackedScene
@export var auto_pause_game: bool = true
@export var close_on_escape: bool = true

# Estado actual
var current_menu: Node = null
var is_menu_open: bool = false
var previous_game_state: int = -1

func _ready():
    super()
    component_id = "MenuComponent"

## Abrir menú
func open_menu(menu_resource: PackedScene = null):
    if is_menu_open:
        return

    var menu_to_load = menu_resource if menu_resource else menu_scene

    if not menu_to_load:
        push_error("No menu scene provided")
        return

    # Pausar el juego si es necesario
    if auto_pause_game and GameStateManager:
        previous_game_state = GameStateManager.current_state
        GameStateManager.pause_game()

    # Instanciar y agregar el menú
    current_menu = menu_to_load.instantiate()
    get_tree().current_scene.add_child(current_menu)

    # Conectar señales si existen
    _connect_menu_signals()

    is_menu_open = true
    menu_opened.emit(current_menu.name)

## Cerrar menú
func close_menu():
    if not is_menu_open or not current_menu:
        return

    var menu_name = current_menu.name

    # Limpiar menú
    current_menu.queue_free()
    current_menu = null

    # Restaurar estado del juego
    if auto_pause_game and GameStateManager and previous_game_state != -1:
        GameStateManager.resume_game()

    is_menu_open = false
    menu_closed.emit(menu_name)

## Conectar señales del menú
func _connect_menu_signals():
    if not current_menu:
        return

    # Conectar señales comunes
    if current_menu.has_signal("close_requested"):
        current_menu.close_requested.connect(close_menu)

    if current_menu.has_signal("option_selected"):
        current_menu.option_selected.connect(_on_option_selected)

func _on_option_selected(option: String):
    option_selected.emit(option)

## Manejo de input
func _input(event):
    if not enabled or not is_menu_open:
        return

    if close_on_escape and event.is_action_pressed("ui_cancel"):
        close_menu()
        get_viewport().set_input_as_handled()
```

## 🔗 Comunicación Entre Componentes

### 1. Referencias Directas

```gdscript
# En Player.gd
func _ready():
    # Obtener componentes necesarios
    health_component = get_node("HealthComponent")
    movement_component = get_node("MovementComponent")

    # Conectar señales entre componentes
    health_component.health_depleted.connect(_on_health_depleted)
    movement_component.movement_started.connect(_on_movement_started)

func _on_health_depleted(entity: Node):
    # Detener movimiento cuando muere
    movement_component.stop_movement()
    movement_component.can_move = false
```

### 2. EventBus Global

```gdscript
# EventBus para comunicación desacoplada
# game/core/events/EventBus.gd
extends Node

# Señales globales del juego
signal player_health_changed(current: int, maximum: int)
signal player_died()
signal enemy_defeated(enemy: Node)
signal item_collected(item_name: String, quantity: int)
signal level_completed()

# En HealthComponent
func _handle_health_depleted():
    is_alive = false
    health_depleted.emit(get_entity())

    # Notificar globalmente
    if get_entity().name == "Player":
        EventBus.player_died.emit()

# En HUD
func _ready():
    EventBus.player_health_changed.connect(_update_health_bar)
    EventBus.player_died.connect(_show_game_over_screen)
```

### 3. Sistema de Mensajes

```gdscript
# Para comunicación más compleja
class_name ComponentMessage extends RefCounted

var sender: Component
var recipient: Component
var message_type: String
var data: Dictionary

## Enviar mensaje a otro componente
func send_component_message(target_component: Component, message_type: String, data: Dictionary = {}):
    if not target_component:
        return

    var message = ComponentMessage.new()
    message.sender = self
    message.recipient = target_component
    message.message_type = message_type
    message.data = data

    target_component.receive_message(message)

## Recibir mensaje (implementar en cada componente)
func receive_message(message: ComponentMessage):
    match message.message_type:
        "REQUEST_HEAL":
            var amount = message.data.get("amount", 10)
            heal(amount)
        "REQUEST_DAMAGE":
            var damage = message.data.get("damage", 10)
            var source = message.data.get("source", null)
            take_damage(damage, source)
```

## 🎮 Uso Práctico: Crear una Entidad

### Ejemplo: Crear un Enemigo

```gdscript
# Enemy.gd
extends CharacterBody2D
class_name Enemy

@export var enemy_type: String = "basic"
@export var initial_health: int = 50
@export var movement_speed: float = 75.0

var health_component: HealthComponent
var movement_component: MovementComponent
var ai_component: AIComponent

func _ready():
    _setup_components()
    _connect_component_signals()

func _setup_components():
    # Crear HealthComponent
    health_component = HealthComponent.new()
    health_component.max_health = initial_health
    health_component.current_health = initial_health
    add_child(health_component)

    # Crear MovementComponent
    movement_component = MovementComponent.new()
    movement_component.max_speed = movement_speed
    add_child(movement_component)

    # Crear AIComponent (si existe)
    ai_component = AIComponent.new()
    ai_component.target_group = "player"
    add_child(ai_component)

func _connect_component_signals():
    # Conectar muerte con AI
    health_component.health_depleted.connect(_on_death)

    # Conectar AI con movimiento
    ai_component.movement_requested.connect(_on_ai_movement_requested)

func _physics_process(delta):
    if health_component.is_alive:
        # Aplicar movimiento
        movement_component.apply_movement()

func _on_death(entity: Node):
    # Lógica de muerte
    ai_component.enabled = false
    movement_component.can_move = false

    # Efectos de muerte
    _play_death_animation()
    await get_tree().create_timer(2.0).timeout
    queue_free()

func _on_ai_movement_requested(direction: Vector2, delta: float):
    movement_component.move_in_direction(direction, delta)

func get_entity_type() -> String:
    return "enemy"
```

### Ejemplo: Usar Componentes en Escenas

```gdscript
# Player.tscn structure:
Player (CharacterBody2D)
├── HealthComponent
├── MovementComponent
├── MenuComponent
├── AnimatedSprite2D
├── CollisionShape2D
└── AttackArea (Area2D)
    └── CollisionShape2D
```

## 🧪 Testing de Componentes

### Unit Test para HealthComponent

```gdscript
# tests/unit/components/test_health_component.gd
extends GutTest
class_name TestHealthComponent

var health_component: HealthComponent
var mock_entity: Node2D

func before_each():
    mock_entity = Node2D.new()
    health_component = HealthComponent.new()
    mock_entity.add_child(health_component)

func after_each():
    if mock_entity:
        mock_entity.queue_free()

func test_take_damage_reduces_health():
    # Arrange
    health_component.max_health = 100
    health_component.current_health = 100

    # Act
    var result = health_component.take_damage(25)

    # Assert
    assert_true(result, "Damage should be applied")
    assert_eq(health_component.current_health, 75, "Health should be reduced")

func test_heal_increases_health():
    # Arrange
    health_component.max_health = 100
    health_component.current_health = 50

    # Act
    var result = health_component.heal(25)

    # Assert
    assert_true(result, "Healing should succeed")
    assert_eq(health_component.current_health, 75, "Health should increase")

func test_signals_emitted_on_damage():
    # Arrange
    var signal_watcher = watch_signals(health_component)
    health_component.max_health = 100
    health_component.current_health = 100

    # Act
    health_component.take_damage(25)

    # Assert
    assert_signal_emitted(health_component, "damage_taken")
    assert_signal_emitted(health_component, "health_changed")
```

## 🛠️ Crear Componentes Personalizados

### Ejemplo: AttackComponent

```gdscript
# game/core/components/AttackComponent.gd
extends Component
class_name AttackComponent

## Componente de ataque para entidades que pueden atacar.

# Señales específicas
signal attack_started(target: Node)
signal attack_completed(target: Node, damage_dealt: int)
signal attack_missed(target: Node)

# Configuración exportada
@export var attack_damage: int = 25
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
@export var can_attack: bool = true

# Estado interno
var last_attack_time: float = 0.0
var current_target: Node = null
var attack_area: Area2D

func _ready():
    super()
    component_id = "AttackComponent"
    _initialize_component()

func _initialize_component():
    # Crear área de ataque si no existe
    attack_area = get_node_or_null("AttackArea")
    if not attack_area:
        _create_attack_area()

func _create_attack_area():
    attack_area = Area2D.new()
    attack_area.name = "AttackArea"
    add_child(attack_area)

    var collision = CollisionShape2D.new()
    var shape = CircleShape2D.new()
    shape.radius = attack_range
    collision.shape = shape
    attack_area.add_child(collision)

    # Conectar detección de objetivos
    attack_area.body_entered.connect(_on_target_entered)
    attack_area.body_exited.connect(_on_target_exited)

## Intentar atacar un objetivo
func attack(target: Node = null) -> bool:
    if not can_attack:
        return false

    var current_time = Time.get_time_dict_from_system()["unix"]
    if current_time - last_attack_time < attack_cooldown:
        return false

    var attack_target = target if target else current_target
    if not attack_target:
        return false

    if not _is_target_in_range(attack_target):
        return false

    _perform_attack(attack_target)
    last_attack_time = current_time
    return true

func _perform_attack(target: Node):
    attack_started.emit(target)

    # Buscar HealthComponent en el objetivo
    var target_health = target.get_node_or_null("HealthComponent")
    if target_health and target_health.has_method("take_damage"):
        var damage_dealt = target_health.take_damage(attack_damage, get_entity())
        if damage_dealt:
            attack_completed.emit(target, attack_damage)
        else:
            attack_missed.emit(target)
    else:
        attack_missed.emit(target)

func _is_target_in_range(target: Node) -> bool:
    var distance = get_entity().global_position.distance_to(target.global_position)
    return distance <= attack_range

func _on_target_entered(body: Node):
    if body != get_entity() and body.has_method("take_damage"):
        current_target = body

func _on_target_exited(body: Node):
    if body == current_target:
        current_target = null

## Getters de utilidad
func is_on_cooldown() -> bool:
    var current_time = Time.get_time_dict_from_system()["unix"]
    return current_time - last_attack_time < attack_cooldown

func get_cooldown_remaining() -> float:
    var current_time = Time.get_time_dict_from_system()["unix"]
    var elapsed = current_time - last_attack_time
    return max(0, attack_cooldown - elapsed)
```

## 📋 Mejores Prácticas

### 1. **Responsabilidad Única**

```gdscript
# ✅ Componente enfocado
class_name HealthComponent extends Component
# Solo gestiona salud, daño y curación

# ❌ Componente sobrecargado
class_name PlayerComponent extends Component
# Gestiona salud, movimiento, ataque, inventario, UI...
```

### 2. **Configuración Clara**

```gdscript
# ✅ Configuración bien organizada
@export_group("Health Settings")
@export var max_health: int = 100
@export var regeneration_rate: float = 0.0

@export_group("Damage Settings")
@export var invulnerable: bool = false
@export var damage_multiplier: float = 1.0

# ❌ Configuración desordenada
@export var max_health: int = 100
@export var can_move: bool = true  # No pertenece aquí
@export var regeneration_rate: float = 0.0
```

### 3. **Comunicación Eficiente**

```gdscript
# ✅ Uso apropiado de señales
signal health_changed(current: int, maximum: int)  # Datos específicos

health_changed.connect(_update_health_bar)  # Conexión directa

# ❌ Señales genéricas
signal something_happened()  # Muy vago
signal changed(data)         # Tipo indefinido
```

### 4. **Inicialización Robusta**

```gdscript
# ✅ Inicialización segura
func _ready():
    super()  # Llamar al padre primero
    component_id = "MyComponent"

    # Esperar un frame si es necesario
    await get_tree().process_frame
    _initialize_component()

func _initialize_component():
    # Verificar dependencias
    if not owner_entity:
        push_error("Component needs an owner entity")
        return

    # Configurar estado inicial
    _setup_component_state()

# ❌ Inicialización frágil
func _ready():
    # Asumir que todo está disponible inmediatamente
    owner_entity.connect_signal()  # Puede fallar
```

### 5. **Testing Integral**

```gdscript
# ✅ Test completo del componente
func test_component_lifecycle():
    # Test inicialización
    assert_true(component.is_component_ready)

    # Test funcionalidad principal
    var result = component.main_function()
    assert_true(result)

    # Test señales
    assert_signal_emitted(component, "important_signal")

    # Test cleanup
    component.cleanup()
    assert_false(component.enabled)
```

---

**El Sistema de Componentes proporciona una base sólida para crear gameplay complejo de manera modular y mantenible.** Con esta arquitectura, puedes combinar diferentes componentes para crear una gran variedad de entidades sin duplicar código.

**Recuerda**: Mantén los componentes pequeños, enfocados y bien testeados. La modularidad es la clave para un código escalable y mantenible.

*Siguiente: [Sistema de Recursos (.res)](resources-system.md)*

*Última actualización: Septiembre 7, 2025*
