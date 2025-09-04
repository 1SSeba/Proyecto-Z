# 🏗️ Arquitectura de Componentes

## 📋 **Índice**
- [Visión General](#visión-general)
- [Principios de Diseño](#principios-de-diseño)
- [Sistema de Componentes](#sistema-de-componentes)
- [Jerarquía de Componentes](#jerarquía-de-componentes)
- [Ciclo de Vida](#ciclo-de-vida)
- [Comunicación entre Componentes](#comunicación-entre-componentes)
- [Ejemplo Práctico](#ejemplo-práctico)

---

## 🎯 **Visión General**

El proyecto utiliza una **arquitectura basada en componentes** donde la funcionalidad se divide en módulos independientes y reutilizables. Esta arquitectura proporciona:

- ✅ **Modularidad**: Cada componente tiene una responsabilidad específica
- ✅ **Reutilización**: Los componentes pueden usarse en múltiples contextos
- ✅ **Testeo**: Componentes independientes son fáciles de probar
- ✅ **Mantenimiento**: Código organizado y fácil de modificar

---

## 🧭 **Principios de Diseño**

### **1. Separación de Responsabilidades**
Cada componente tiene una única responsabilidad bien definida:
- `HealthComponent`: Solo maneja la salud de la entidad
- `MovementComponent`: Solo maneja el movimiento
- `MenuComponent`: Solo maneja la lógica de menús

### **2. Composición sobre Herencia**
En lugar de jerarquías complejas, combinamos componentes:
```gdscript
# Malo: Herencia compleja
class Player extends Character extends Entity

# Bueno: Composición con componentes
Player + HealthComponent + MovementComponent + InputComponent
```

### **3. Comunicación por Eventos**
Los componentes se comunican a través del EventBus, no directamente:
```gdscript
# Los componentes emiten eventos
EventBus.health_changed.emit(new_health)

# Otros componentes escuchan eventos
EventBus.health_changed.connect(_on_health_changed)
```

### **4. Estado Local**
Cada componente maneja su propio estado sin depender de otros:
```gdscript
# Cada componente es independiente
health_component.current_health = 50
movement_component.speed = 100
```

---

## 🧩 **Sistema de Componentes**

### **Clase Base: Component**
```gdscript
# /src/core/components/Component.gd
class_name Component
extends Node

# Interfaz común para todos los componentes
func initialize(entity: Node) -> void:
    # Configuración inicial del componente
    pass

func cleanup() -> void:
    # Limpieza de recursos
    pass

# Verificación de tipo
func is_component() -> bool:
    return true
```

### **Componentes Específicos**

#### **HealthComponent**
```gdscript
class_name HealthComponent
extends Component

@export var max_health: int = 100
var current_health: int

func initialize(entity: Node) -> void:
    current_health = max_health
    EventBus.health_initialized.emit(entity, current_health)

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    EventBus.health_changed.emit(get_parent(), current_health)
    
    if current_health <= 0:
        EventBus.entity_died.emit(get_parent())

func heal(amount: int) -> void:
    current_health = min(max_health, current_health + amount)
    EventBus.health_changed.emit(get_parent(), current_health)
```

#### **MovementComponent**
```gdscript
class_name MovementComponent
extends Component

@export var speed: float = 100.0
@export var acceleration: float = 10.0

var velocity: Vector2 = Vector2.ZERO
var entity: CharacterBody2D

func initialize(entity_node: Node) -> void:
    entity = entity_node as CharacterBody2D
    if not entity:
        push_error("MovementComponent requires CharacterBody2D")

func move_towards(direction: Vector2) -> void:
    if direction.length() > 0:
        velocity = velocity.move_toward(direction * speed, acceleration)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, acceleration)
    
    entity.velocity = velocity
    entity.move_and_slide()
    
    EventBus.entity_moved.emit(entity, entity.global_position)
```

---

## 📊 **Jerarquía de Componentes**

```
Component (Base)
├── HealthComponent
│   ├── PlayerHealthComponent
│   └── EnemyHealthComponent
├── MovementComponent
│   ├── PlayerMovementComponent
│   ├── EnemyMovementComponent
│   └── ProjectileMovementComponent
├── MenuComponent
│   ├── MainMenuComponent
│   └── SettingsMenuComponent
└── InputComponent
    ├── PlayerInputComponent
    └── MenuInputComponent
```

---

## 🔄 **Ciclo de Vida**

### **1. Creación**
```gdscript
# Instanciar componente
var health_comp = HealthComponent.new()
health_comp.max_health = 150

# Añadir al nodo
add_child(health_comp)
```

### **2. Inicialización**
```gdscript
# El componente se auto-inicializa
func _ready():
    initialize(get_parent())
```

### **3. Operación**
```gdscript
# El componente responde a eventos del juego
func _on_damage_received(amount: int):
    take_damage(amount)
```

### **4. Limpieza**
```gdscript
# Limpieza automática al destruir
func _exit_tree():
    cleanup()
```

---

## 📡 **Comunicación entre Componentes**

### **EventBus Pattern**
Los componentes se comunican a través del EventBus global:

```gdscript
# Emisión de eventos
EventBus.health_changed.emit(entity, new_health)
EventBus.entity_moved.emit(entity, position)
EventBus.player_input.emit(input_vector)

# Escucha de eventos
EventBus.health_changed.connect(_on_health_changed)
EventBus.player_input.connect(_on_player_input)
```

### **Ventajas del EventBus**
- ✅ **Desacoplamiento**: Los componentes no se conocen directamente
- ✅ **Flexibilidad**: Fácil añadir/remover componentes
- ✅ **Debugging**: Eventos centralizados para monitoreo
- ✅ **Extensibilidad**: Nuevos componentes pueden escuchar eventos existentes

---

## 💡 **Ejemplo Práctico**

### **Crear una Entidad Player**
```gdscript
# Player.gd
extends CharacterBody2D
class_name Player

func _ready():
    # Añadir componentes necesarios
    var health_comp = HealthComponent.new()
    health_comp.max_health = 100
    add_child(health_comp)
    
    var movement_comp = PlayerMovementComponent.new()
    movement_comp.speed = 150.0
    add_child(movement_comp)
    
    var input_comp = PlayerInputComponent.new()
    add_child(input_comp)
    
    # Los componentes se inicializan automáticamente
    print("Player created with", get_children().size(), "components")
```

### **Interacción entre Componentes**
```gdscript
# PlayerInputComponent escucha input
func _input(event):
    if event.is_action_pressed("move_right"):
        EventBus.player_input.emit(Vector2.RIGHT)

# MovementComponent responde a input
func _on_player_input(direction: Vector2):
    move_towards(direction)

# HealthComponent responde a colisiones
func _on_area_entered(area):
    if area.is_in_group("enemies"):
        take_damage(10)
```

---

## 🔧 **Mejores Prácticas**

### **1. Una Responsabilidad por Componente**
```gdscript
# ✅ Bueno: Componente enfocado
class HealthComponent:
    func take_damage()
    func heal()
    func get_health_percentage()

# ❌ Malo: Componente sobrecargado
class PlayerController:
    func take_damage()
    func move()
    func shoot()
    func open_inventory()
```

### **2. Usar Eventos para Comunicación**
```gdscript
# ✅ Bueno: Comunicación por eventos
EventBus.health_low.emit(entity)

# ❌ Malo: Referencias directas
movement_component.slow_down()
```

### **3. Configuración Externa**
```gdscript
# ✅ Bueno: Configuración por @export
@export var max_health: int = 100
@export var speed: float = 150.0

# ❌ Malo: Valores hardcodeados
const MAX_HEALTH = 100
const SPEED = 150.0
```

### **4. Validación de Dependencias**
```gdscript
# ✅ Bueno: Validar entidad requerida
func initialize(entity: Node) -> void:
    if not entity is CharacterBody2D:
        push_error("Requires CharacterBody2D")
        return
```

---

## 🎯 **Beneficios de esta Arquitectura**

### **Para Desarrolladores**
- **Código Modular**: Fácil de entender y modificar
- **Reutilización**: Un componente sirve para múltiples entidades
- **Testing**: Componentes independientes = tests independientes
- **Colaboración**: Diferentes developers pueden trabajar en componentes separados

### **Para el Proyecto**
- **Escalabilidad**: Fácil añadir nuevas funcionalidades
- **Mantenimiento**: Bugs localizados en componentes específicos
- **Performance**: Solo componentes necesarios activos
- **Flexibilidad**: Combinaciones dinámicas de componentes

---

**🚀 ¡Arquitectura modular lista para desarrollo profesional!**

*Última actualización: Septiembre 4, 2025*
