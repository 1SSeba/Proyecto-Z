# Documentación del Sistema World y Rooms
# =====================================================

## Resumen del Sistema

Has implementado un **sistema profesional de generación de mundos roguelike** que sigue las mejores prácticas de la industria de videojuegos. El sistema está dividido en tres componentes principales que trabajan de manera coordinada:

### 1. **DungeonWorld.gd** - Sistema Principal
- **Ubicación**: `src/systems/DungeonWorld.gd`
- **Función**: Coordina toda la generación del dungeon
- **Responsabilidades**:
  - Gestiona el flujo de generación completo
  - Coordina los generadores especializados
  - Maneja las señales y eventos del juego
  - Controla el estado del jugador y progresión

### 2. **RoomGenerator.gd** - Generador de Habitaciones
- **Ubicación**: `src/systems/RoomGenerator.gd`
- **Función**: Genera el contenido interno de las habitaciones
- **Características**:
  - Múltiples formas: rectangular, L, cruz, circular, irregular
  - Features especiales: columnas, agua, altares, fosos
  - Templates por tipo de habitación
  - Puntos de spawn inteligentes

### 3. **CorridorGenerator.gd** - Generador de Conexiones
- **Ubicación**: `src/systems/CorridorGenerator.gd`
- **Función**: Conecta habitaciones con corredores inteligentes
- **Algoritmos**:
  - Minimum Spanning Tree para conectividad óptima
  - Pathfinding A* para rutas eficientes
  - Conexiones extra para crear loops opcionales

## Como Usar el Sistema

### Configuración Básica

```gdscript
# En tu escena principal, agrega el nodo DungeonWorld
extends Node2D

@onready var dungeon_world: DungeonWorld = $DungeonWorld

func _ready():
    # El sistema se auto-inicializa si auto_generate = true
    # O puedes controlarlo manualmente:
    dungeon_world.auto_generate = false
    dungeon_world.generate_new_dungeon()
```

### Configuración Avanzada

```gdscript
# Personalizar el tamaño del dungeon
dungeon_world.dungeon_size = DungeonWorld.DungeonSize.LARGE

# Personalizar tamaños de habitaciones
dungeon_world.room_min_size = Vector2i(10, 8)
dungeon_world.room_max_size = Vector2i(20, 16)

# Personalizar corredores
dungeon_world.corridor_width = 4

# Configurar eventos
dungeon_world.room_entered.connect(_on_room_entered)
dungeon_world.room_completed.connect(_on_room_completed)
dungeon_world.dungeon_completed.connect(_on_dungeon_completed)
```

### Conectar con el Jugador

```gdscript
# Cuando el jugador entre a una habitación
func _on_room_entered(room: DungeonWorld.Room):
    print("Entraste a habitación tipo: %s" % DungeonWorld.RoomType.keys()[room.type])
    
    # Spawnear enemigos si es necesario
    if room.type == DungeonWorld.RoomType.NORMAL and not room.is_completed:
        _spawn_enemies_in_room(room)
    
    # Activar mecánicas especiales
    match room.type:
        DungeonWorld.RoomType.TREASURE:
            _activate_treasure_mechanics(room)
        DungeonWorld.RoomType.SHOP:
            _show_shop_interface()
        DungeonWorld.RoomType.BOSS:
            _start_boss_fight(room)

# Completar una habitación
func _on_room_completed(room: DungeonWorld.Room):
    # Abrir puertas hacia otras habitaciones
    for door in room.doors:
        door.open()
        dungeon_world.room_door_opened.emit(door)
```

### Spawning de Entidades

```gdscript
func _spawn_enemies_in_room(room: DungeonWorld.Room):
    # Usar los puntos de spawn generados por el RoomGenerator
    var spawn_points = dungeon_world.room_generator.get_spawn_points_for_room(room)
    
    var enemy_count = min(room.enemies_count, spawn_points.size())
    
    for i in range(enemy_count):
        var spawn_pos = spawn_points[i]
        var enemy = enemy_scene.instantiate()
        enemy.global_position = Vector2(spawn_pos * TILE_SIZE)  # Convertir a posición mundial
        dungeon_world.entities_layer.add_child(enemy)

func _activate_treasure_mechanics(room: DungeonWorld.Room):
    if not room.treasure_spawned:
        # Spawn treasure at room center
        var treasure = treasure_scene.instantiate()
        treasure.global_position = Vector2(room.center * TILE_SIZE)
        dungeon_world.entities_layer.add_child(treasure)
        room.treasure_spawned = true
```

## Tipos de Habitaciones

### **START** - Habitación de Inicio
- Más grande y simple
- Sin enemigos
- Punto de spawn del jugador

### **NORMAL** - Habitación Normal
- Habitaciones estándar con enemigos
- Formas variadas según templates
- Recompensas básicas al completar

### **TREASURE** - Habitación de Tesoro
- Contiene cofres o items especiales
- Puede tener altares o áreas elevadas
- Enemigos guardianes opcionales

### **BOSS** - Habitación del Boss
- Habitación grande con forma especial (cruz)
- Columnas y elementos arquitectónicos
- Boss fight al entrar

### **SECRET** - Habitación Secreta
- Formas irregulares
- Características especiales (fosos, agua)
- Recompensas únicas

### **SHOP** - Habitación de Tienda
- Forma L para organizar productos
- NPC vendedor
- Sin combate

### **PUZZLE** - Habitación de Puzzle
- Mecánicas especiales de resolución
- Recompensas por completar

## Características Especiales

### Features de Habitaciones
- **PILLARS**: Columnas decorativas y obstáculos
- **WATER_POOL**: Charcos de agua (pueden afectar movimiento)
- **RAISED_AREA**: Plataformas elevadas
- **PIT**: Fosos (pueden causar daño)
- **ALTAR**: Altares centrales para interacción

### Features de Corredores
- **DOORS**: Puertas en los extremos
- **PILLARS**: Columnas decorativas
- **TRAPS**: Trampas ocultas
- **LIGHTING**: Antorchas y luces
- **DECORATION**: Elementos decorativos

## Integración con Otros Sistemas

### Con el Player
```gdscript
# En tu Player.gd
func _on_area_entered(area):
    if area.has_method("get_room"):
        var room = area.get_room()
        GameManager.dungeon_world.enter_room(room)
```

### Con el GameManager
```gdscript
# En GameManager.gd (autoload)
var current_dungeon_world: DungeonWorld

func start_new_level():
    if current_dungeon_world:
        current_dungeon_world.queue_free()
    
    # Cargar nueva escena con DungeonWorld
    var world_scene = preload("res://content/scenes/World/DungeonLevel.tscn")
    current_dungeon_world = world_scene.instantiate()
    get_tree().current_scene.add_child(current_dungeon_world)
```

### Con el Sistema de Save/Load
```gdscript
# Guardar estado del dungeon
func save_dungeon_state() -> Dictionary:
    return {
        "seed": dungeon_world.current_dungeon.seed,
        "completed_rooms": _get_completed_rooms(),
        "current_room_id": dungeon_world.current_room.id if dungeon_world.current_room else -1,
        "doors_opened": _get_opened_doors()
    }

# Cargar estado del dungeon
func load_dungeon_state(data: Dictionary):
    dungeon_world.generate_new_dungeon(data.seed)
    _restore_completed_rooms(data.completed_rooms)
    _restore_opened_doors(data.doors_opened)
    if data.current_room_id != -1:
        dungeon_world.set_current_room(data.current_room_id)
```

## Tips de Optimización

1. **Pool de Entidades**: Reutiliza enemigos y objetos entre habitaciones
2. **Culling**: Solo procesa habitaciones visibles o cercanas al jugador
3. **Lazy Loading**: Carga contenido de habitaciones cuando el jugador se acerca
4. **Memory Management**: Limpia habitaciones lejanas para ahorrar memoria

## Expansiones Futuras

- **Biomas**: Diferentes temas visuales por nivel
- **Habitaciones Multi-piso**: Habitaciones con múltiples niveles
- **Corredores Especiales**: Corredores con mecánicas únicas
- **Generación Procedimental Avanzada**: Wave Function Collapse para patrones complejos
- **Networking**: Soporte para multijugador cooperativo

## Troubleshooting

### Problema: "TileMap not configured"
**Solución**: Asegúrate de que el nodo TileMapLayer tenga un TileSet asignado

### Problema: Habitaciones superpuestas
**Solución**: Aumenta el espaciado mínimo entre habitaciones en la configuración

### Problema: Corredores no se generan
**Solución**: Verifica que las habitaciones no estén demasiado lejos unas de otras

### Problema: Puertas no funcionan
**Solución**: Conecta las señales de door_opened y verifica la lógica de unlocking

---

*Este sistema representa un enfoque profesional para la generación de dungeons roguelike, optimizado para mantenibilidad, extensibilidad y rendimiento.*
