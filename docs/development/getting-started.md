# 🚀 Getting Started - Primeros Pasos

## 📋 **Índice**
- [Configuración Inicial](#configuración-inicial)
- [Entendiendo la Arquitectura](#entendiendo-la-arquitectura)
- [Tu Primer Componente](#tu-primer-componente)
- [Usar Servicios](#usar-servicios)
- [Comunicación con EventBus](#comunicación-con-eventbus)
- [Próximos Pasos](#próximos-pasos)

---

## 💻 **Configuración Inicial**

### **Requisitos**
- **Godot Engine 4.4+** ([Descargar](https://godotengine.org/download))
- **Git** para control de versiones
- **Editor de código** (VS Code recomendado)

### **Clonar el Proyecto**
```bash
# Clonar repositorio
git clone https://github.com/1SSeba/topdown-game.git
cd topdown-game

# Abrir en Godot
godot project.godot
```

### **Verificar Configuración**
Una vez abierto el proyecto, verifica que todo funcione:

1. **Ejecutar el proyecto** (F5)
2. **Verificar autoloads** en Project → Project Settings → Autoload
3. **Comprobar que aparezca**: `ServiceManager: All services initialized successfully`

---

## 🏗️ **Entendiendo la Arquitectura**

### **Estructura del Proyecto**
```
src/core/                    # 🏗️ Arquitectura base
├── components/              # 🧩 Sistema de componentes
├── services/               # ⚙️ Servicios globales
├── events/                 # 📡 EventBus
└── ServiceManager.gd       # 🎯 Coordinador central

content/scenes/             # 🎭 Escenas del juego
├── Main.tscn              # 🚪 Punto de entrada
├── Menus/                 # 📋 Interfaces
└── Characters/            # 👤 Personajes
```

### **Conceptos Clave**

#### **Componentes**
Módulos independientes que añaden funcionalidad a entidades:
```gdscript
# Un componente maneja UNA responsabilidad
HealthComponent → Solo maneja salud
MovementComponent → Solo maneja movimiento
```

#### **Servicios**
Funcionalidades globales accesibles desde cualquier lugar:
```gdscript
# Servicios son singletons
ServiceManager.get_audio_service() → Para reproducir sonidos
ServiceManager.get_config_service() → Para configuración
```

#### **EventBus**
Sistema de comunicación desacoplada:
```gdscript
# Emitir eventos
EventBus.player_moved.emit(position)

# Escuchar eventos
EventBus.player_moved.connect(_on_player_moved)
```

---

## 🧩 **Tu Primer Componente**

Vamos a crear un componente simple paso a paso:

### **1. Crear el Archivo**
```gdscript
# /src/core/components/ExampleComponent.gd
class_name ExampleComponent
extends Component

# Propiedades exportadas (configurables en editor)
@export var example_value: int = 10
@export var example_text: String = "Hello World"

# Estado interno
var internal_counter: int = 0

func initialize(entity: Node) -> void:
    print("ExampleComponent initialized for: ", entity.name)
    # Conectar a eventos si es necesario
    EventBus.player_input.connect(_on_player_input)

func cleanup() -> void:
    # Desconectar eventos
    if EventBus.player_input.is_connected(_on_player_input):
        EventBus.player_input.disconnect(_on_player_input)

# Funcionalidad específica del componente
func do_something() -> void:
    internal_counter += 1
    print("ExampleComponent did something! Counter: ", internal_counter)
    
    # Emitir evento para notificar a otros componentes
    EventBus.entity_acted.emit(get_parent(), "example_action")

# Responder a eventos
func _on_player_input(action: String) -> void:
    if action == "interact":
        do_something()
```

### **2. Usar el Componente**
```gdscript
# En cualquier entidad (por ejemplo, Player.gd)
extends CharacterBody2D

func _ready() -> void:
    # Añadir el componente
    var example_comp = ExampleComponent.new()
    example_comp.example_value = 20
    example_comp.example_text = "Player Example"
    add_child(example_comp)
    
    print("Player created with ExampleComponent")
```

### **3. Configurar en Editor**
1. Selecciona tu entidad en la escena
2. En el script, añade el componente como child
3. Las propiedades `@export` aparecerán en el Inspector
4. Configura los valores según necesites

---

## ⚙️ **Usar Servicios**

Los servicios proporcionan funcionalidades globales:

### **ConfigService - Configuración**
```gdscript
# Obtener configuración
var config = ServiceManager.get_config_service()
var volume = config.get_master_volume()

# Cambiar configuración
config.set_master_volume(0.8)  # Guarda automáticamente

# Escuchar cambios
EventBus.config_changed.connect(_on_config_changed)

func _on_config_changed(setting: String, value: Variant):
    print("Setting changed: ", setting, " = ", value)
```

### **AudioService - Sonidos**
```gdscript
# Reproducir efectos de sonido
var audio = ServiceManager.get_audio_service()
var explosion_sound = preload("res://content/assets/Audio/explosion.ogg")
audio.play_sfx(explosion_sound, 0.8)  # Volume 0.8

# Reproducir música de fondo
var bg_music = preload("res://content/assets/Audio/background.ogg")
audio.play_music(bg_music, true)  # Con fade-in
```

### **InputService - Input Avanzado**
```gdscript
# Cambiar contexto de input
var input_service = ServiceManager.get_input_service()
input_service.set_input_context(InputService.InputContext.GAMEPLAY)

# El InputService maneja automáticamente el buffering y contextos
# Solo necesitas escuchar los eventos:
EventBus.player_input.connect(_on_player_input)

func _on_player_input(action: String):
    match action:
        "move_left":
            # Lógica de movimiento
            pass
        "jump":
            # Lógica de salto
            pass
```

---

## 📡 **Comunicación con EventBus**

### **Emitir Eventos**
```gdscript
# Eventos simples
EventBus.player_spawned.emit(player_node)
EventBus.menu_opened.emit("MainMenu")

# Eventos con datos
EventBus.health_changed.emit(player_node, new_health)
EventBus.entity_moved.emit(entity, new_position)

# Eventos personalizados (añádelos al EventBus primero)
EventBus.custom_event.emit(custom_data)
```

### **Escuchar Eventos**
```gdscript
func _ready() -> void:
    # Conectar a eventos específicos
    EventBus.health_changed.connect(_on_health_changed)
    EventBus.player_spawned.connect(_on_player_spawned)
    
    # One-shot connections (se desconectan automáticamente)
    EventBus.game_started.connect(_on_game_started, CONNECT_ONE_SHOT)

func _on_health_changed(entity: Node, health: int) -> void:
    # Solo procesar si es el player
    if entity.is_in_group("player"):
        update_health_display(health)

func _on_player_spawned(player: Node) -> void:
    print("Player spawned: ", player.name)
```

### **Limpiar Conexiones**
```gdscript
# Siempre limpiar al destruir nodos
func _exit_tree() -> void:
    if EventBus.health_changed.is_connected(_on_health_changed):
        EventBus.health_changed.disconnect(_on_health_changed)
```

---

## 🎯 **Ejemplo Práctico Completo**

Vamos a crear una entidad simple con componentes:

### **1. Crear la Entidad**
```gdscript
# /content/scenes/Characters/SimpleEnemy.gd
extends CharacterBody2D
class_name SimpleEnemy

func _ready() -> void:
    # Añadir grupo para identificación
    add_to_group("enemies")
    
    # Crear componentes
    setup_components()
    
    # Emitir evento de spawn
    EventBus.entity_spawned.emit(self)

func setup_components() -> void:
    # Componente de salud
    var health_comp = HealthComponent.new()
    health_comp.max_health = 50
    add_child(health_comp)
    
    # Componente de movimiento básico
    var movement_comp = MovementComponent.new()
    movement_comp.speed = 80.0
    add_child(movement_comp)
    
    print("SimpleEnemy created with ", get_children().size(), " components")
```

### **2. Escena SimpleEnemy.tscn**
1. Crear nueva escena 2D
2. Raíz: CharacterBody2D
3. Añadir CollisionShape2D con forma
4. Añadir Sprite2D con textura
5. Asignar el script SimpleEnemy.gd
6. Guardar como SimpleEnemy.tscn

### **3. Instanciar en el Juego**
```gdscript
# En algún script de nivel/spawn
func spawn_enemy(position: Vector2) -> void:
    var enemy_scene = preload("res://content/scenes/Characters/SimpleEnemy.tscn")
    var enemy = enemy_scene.instantiate()
    enemy.global_position = position
    get_tree().current_scene.add_child(enemy)
```

---

## 🎓 **Próximos Pasos**

Una vez domines lo básico, puedes avanzar a:

### **1. Crear Componentes Avanzados**
- [Component Development](component-development.md) - Componentes más complejos
- [Components API](../api-reference/components-api.md) - Referencia completa

### **2. Desarrollar Servicios Personalizados**
- [Service Development](service-development.md) - Crear nuevos servicios
- [Services API](../api-reference/services-api.md) - API de servicios

### **3. Arquitectura Avanzada**
- [Service Layer](../architecture/service-layer.md) - Servicios en profundidad
- [Event System](../architecture/event-system.md) - EventBus avanzado

### **4. Testing y Debugging**
- [Testing Guide](testing-guide.md) - Pruebas y validación
- [Troubleshooting](../user-guides/troubleshooting.md) - Solución de problemas

---

## 💡 **Tips para Empezar**

### **✅ Buenas Prácticas desde el Inicio**
1. **Siempre usa componentes** para funcionalidad específica
2. **Usa servicios** para funcionalidades globales
3. **Comunica via EventBus** en lugar de referencias directas
4. **Limpia conexiones** en `_exit_tree()`
5. **Usa grupos** para identificar tipos de entidades

### **❌ Evita desde el Principio**
1. ❌ Referencias directas entre nodos distantes
2. ❌ Código todo en un solo script gigante
3. ❌ Hardcodear valores sin usar @export
4. ❌ Ignorar la limpieza de conexiones
5. ❌ No seguir las convenciones de naming

---

**🚀 ¡Listo para desarrollar con arquitectura modular!**

*Última actualización: Septiembre 4, 2025*
