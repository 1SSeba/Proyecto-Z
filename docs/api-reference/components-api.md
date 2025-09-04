# 📋 API Reference - Componentes

## 📋 **Índice**
- [Component (Base Class)](#component-base-class)
- [HealthComponent](#healthcomponent)
- [MovementComponent](#movementcomponent)
- [MenuComponent](#menucomponent)
- [Utilidades de Componentes](#utilidades-de-componentes)

---

## 🧩 **Component (Base Class)**

### **Descripción**
Clase base para todos los componentes del sistema. Proporciona la interfaz común y funcionalidades básicas.

### **Ubicación**
```gdscript
# /src/core/components/Component.gd
class_name Component
extends Node
```

### **Propiedades**
```gdscript
# Configuración básica
@export var enabled: bool = true
@export var debug_mode: bool = false

# Estado interno (solo lectura)
var is_initialized: bool = false
var entity: Node
```

### **Métodos Públicos**

#### **initialize(entity_node: Node) → void**
Inicializa el componente con la entidad especificada.

**Parámetros:**
- `entity_node: Node` - La entidad a la que pertenece este componente

**Ejemplo:**
```gdscript
var component = HealthComponent.new()
component.initialize(player_node)
```

#### **cleanup() → void**
Limpia recursos y desconecta eventos. Llamado automáticamente en `_exit_tree()`.

**Ejemplo:**
```gdscript
func _exit_tree():
    cleanup()  # Llamado automáticamente
```

#### **is_component() → bool**
Verifica si el nodo es un componente válido.

**Retorna:** `true` si es un componente válido

#### **get_component_type() → String**
Obtiene el tipo/nombre del componente.

**Retorna:** Nombre de la clase del componente

### **Métodos Virtuales (Override)**

#### **_component_ready() → void**
Llamado después de la inicialización. Override en clases derivadas.

#### **_component_process(_delta: float) → void**
Llamado cada frame si el componente está activo.

#### **_component_physics_process(_delta: float) → void**
Llamado cada physics frame si el componente está activo.

---

## ❤️ **HealthComponent**

### **Descripción**
Maneja la salud y el daño de una entidad. Incluye regeneración automática y eventos de salud.

### **Ubicación**
```gdscript
# /src/core/components/HealthComponent.gd
class_name HealthComponent
extends Component
```

### **Propiedades**
```gdscript
# Configuración de salud
@export var max_health: int = 100
@export var auto_regen: bool = false
@export var regen_rate: float = 1.0
@export var regen_delay: float = 3.0

# Estado de salud (solo lectura)
var current_health: int
var is_dead: bool = false
var last_damage_time: float = 0.0
```

### **Métodos Públicos**

#### **take_damage(amount: int, damage_type: String = "") → bool**
Aplica daño a la entidad.

**Parámetros:**
- `amount: int` - Cantidad de daño a aplicar
- `damage_type: String` - Tipo de daño (opcional)

**Retorna:** `true` si el daño fue aplicado exitosamente

**Eventos Emitidos:**
- `EventBus.health_changed(entity, new_health)`
- `EventBus.entity_damaged(entity, amount, damage_type)`
- `EventBus.entity_died(entity)` - Si la salud llega a 0

**Ejemplo:**
```gdscript
var health_comp = entity.get_component("HealthComponent")
if health_comp.take_damage(25, "fire"):
    print("Damage applied successfully")
```

#### **heal(amount: int) → void**
Restaura salud a la entidad.

**Parámetros:**
- `amount: int` - Cantidad de salud a restaurar

**Eventos Emitidos:**
- `EventBus.health_changed(entity, new_health)`
- `EventBus.entity_healed(entity, amount)`

#### **set_max_health(new_max: int) → void**
Cambia la salud máxima de la entidad.

**Parámetros:**
- `new_max: int` - Nueva salud máxima

#### **get_health_percentage() → float**
Obtiene el porcentaje de salud actual.

**Retorna:** Valor entre 0.0 y 1.0

#### **is_at_full_health() → bool**
Verifica si la entidad tiene salud completa.

**Retorna:** `true` si `current_health == max_health`

#### **revive(health_amount: int = -1) → void**
Revive a una entidad muerta.

**Parámetros:**
- `health_amount: int` - Salud con la que revivir (-1 = salud máxima)

### **Eventos Disponibles**
```gdscript
# Conectar a estos eventos del EventBus
EventBus.health_changed.connect(_on_health_changed)
EventBus.entity_damaged.connect(_on_entity_damaged)
EventBus.entity_healed.connect(_on_entity_healed)
EventBus.entity_died.connect(_on_entity_died)
```

---

## 🏃 **MovementComponent**

### **Descripción**
Maneja el movimiento de entidades con CharacterBody2D. Incluye aceleración, fricción y detección de colisiones.

### **Ubicación**
```gdscript
# /src/core/components/MovementComponent.gd
class_name MovementComponent
extends Component
```

### **Propiedades**
```gdscript
# Configuración de movimiento
@export var speed: float = 100.0
@export var acceleration: float = 10.0
@export var friction: float = 8.0
@export var max_speed_multiplier: float = 2.0

# Estado de movimiento (solo lectura)
var velocity: Vector2 = Vector2.ZERO
var is_moving: bool = false
var last_direction: Vector2 = Vector2.ZERO
```

### **Métodos Públicos**

#### **move_towards(direction: Vector2) → void**
Mueve la entidad en la dirección especificada.

**Parámetros:**
- `direction: Vector2` - Dirección normalizada del movimiento

**Eventos Emitidos:**
- `EventBus.entity_moved(entity, position)`
- `EventBus.movement_started(entity)` - Al comenzar a moverse
- `EventBus.movement_stopped(entity)` - Al detenerse

**Ejemplo:**
```gdscript
var movement_comp = player.get_component("MovementComponent")
movement_comp.move_towards(Vector2.RIGHT)
```

#### **stop_movement() → void**
Detiene el movimiento gradualmente usando fricción.

#### **set_speed(new_speed: float) → void**
Cambia la velocidad de movimiento.

**Parámetros:**
- `new_speed: float` - Nueva velocidad base

#### **apply_speed_multiplier(multiplier: float, duration: float = 0.0) → void**
Aplica un multiplicador temporal de velocidad.

**Parámetros:**
- `multiplier: float` - Multiplicador de velocidad
- `duration: float` - Duración en segundos (0 = permanente)

#### **get_movement_direction() → Vector2**
Obtiene la dirección actual de movimiento normalizada.

**Retorna:** Vector2 normalizado de la dirección

#### **is_moving_towards(direction: Vector2, tolerance: float = 0.1) → bool**
Verifica si se está moviendo en una dirección específica.

**Parámetros:**
- `direction: Vector2` - Dirección a verificar
- `tolerance: float` - Tolerancia para la comparación

**Retorna:** `true` si se mueve en esa dirección

---

## 📋 **MenuComponent**

### **Descripción**
Maneja la lógica de menús con auto-detección de botones y navegación por teclado.

### **Ubicación**
```gdscript
# /src/core/components/MenuComponent.gd
class_name MenuComponent
extends Component
```

### **Propiedades**
```gdscript
# Configuración de menú
@export var menu_name: String = ""
@export var auto_discover_buttons: bool = true
@export var keyboard_navigation: bool = true
@export var wrap_navigation: bool = true

# Estado del menú (solo lectura)
var buttons: Array[Button] = []
var current_selection: int = -1
var is_menu_active: bool = false
```

### **Métodos Públicos**

#### **show_menu() → void**
Muestra y activa el menú.

**Eventos Emitidos:**
- `EventBus.menu_opened(menu_name)`

#### **hide_menu() → void**
Oculta y desactiva el menú.

**Eventos Emitidos:**
- `EventBus.menu_closed(menu_name)`

#### **add_button(button: Button) → void**
Añade un botón al sistema de navegación.

**Parámetros:**
- `button: Button` - Botón a añadir

#### **remove_button(button: Button) → void**
Remueve un botón del sistema de navegación.

#### **select_button(index: int) → void**
Selecciona un botón específico.

**Parámetros:**
- `index: int` - Índice del botón a seleccionar

#### **navigate_up() → void**
Navega al botón anterior.

#### **navigate_down() → void**
Navega al siguiente botón.

#### **activate_selected() → void**
Activa el botón actualmente seleccionado.

**Eventos Emitidos:**
- `EventBus.menu_button_pressed(button_name)`

### **Eventos de Input**
```gdscript
# El componente responde automáticamente a:
# - ui_up / ui_down: Navegación
# - ui_accept: Activar botón seleccionado
# - ui_cancel: Cerrar menú
```

---

## 🛠️ **Utilidades de Componentes**

### **ComponentUtils**
Utilidades estáticas para trabajar con componentes.

```gdscript
# /src/core/components/ComponentUtils.gd
class_name ComponentUtils
```

#### **get_component(entity: Node, component_type: String) → Component**
Obtiene un componente específico de una entidad.

**Parámetros:**
- `entity: Node` - Entidad de la que obtener el componente
- `component_type: String` - Tipo de componente a buscar

**Retorna:** El componente encontrado o `null`

**Ejemplo:**
```gdscript
var health = ComponentUtils.get_component(player, "HealthComponent")
if health:
    health.take_damage(10)
```

#### **has_component(entity: Node, component_type: String) → bool**
Verifica si una entidad tiene un componente específico.

#### **get_all_components(entity: Node) → Array[Component]**
Obtiene todos los componentes de una entidad.

#### **add_component(entity: Node, component: Component) → void**
Añade un componente a una entidad de forma segura.

#### **remove_component(entity: Node, component_type: String) → bool**
Remueve un componente de una entidad.

### **ComponentRegistry**
Registro global de tipos de componentes disponibles.

```gdscript
# Registrar nuevo tipo de componente
ComponentRegistry.register_component("MyComponent", MyComponent)

# Crear componente por nombre
var component = ComponentRegistry.create_component("MyComponent")

# Listar todos los tipos disponibles
var types = ComponentRegistry.get_all_component_types()
```

---

## 📊 **Ejemplo de Uso Completo**

```gdscript
# Crear una entidad con múltiples componentes
extends CharacterBody2D

func _ready():
    setup_components()

func setup_components():
    # Salud
    var health = HealthComponent.new()
    health.max_health = 150
    health.auto_regen = true
    health.regen_rate = 2.0
    add_child(health)
    
    # Movimiento
    var movement = MovementComponent.new()
    movement.speed = 120.0
    movement.acceleration = 15.0
    add_child(movement)
    
    # Conectar eventos
    EventBus.health_changed.connect(_on_health_changed)
    EventBus.entity_moved.connect(_on_entity_moved)

func _on_health_changed(entity: Node, new_health: int):
    if entity == self:
        print("Health changed to: ", new_health)

func _on_entity_moved(entity: Node, position: Vector2):
    if entity == self:
        print("Moved to: ", position)

# Usar los componentes
func take_damage_example():
    var health = ComponentUtils.get_component(self, "HealthComponent")
    health.take_damage(25)

func move_example():
    var movement = ComponentUtils.get_component(self, "MovementComponent")
    movement.move_towards(Vector2.UP)
```

---

**📋 ¡Referencia completa de la API de componentes!**

*Última actualización: Septiembre 4, 2025*
