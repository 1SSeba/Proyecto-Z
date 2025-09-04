# 📡 Sistema de Eventos - EventBus

## 📋 **Índice**
- [Visión General](#visión-general)
- [Implementación del EventBus](#implementación-del-eventbus)
- [Eventos Disponibles](#eventos-disponibles)
- [Uso del EventBus](#uso-del-eventbus)
- [Patrones de Comunicación](#patrones-de-comunicación)
- [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 **Visión General**

El **EventBus** es un sistema de comunicación centralizado que permite a los componentes y servicios comunicarse de manera desacoplada. Actúa como un hub central donde se emiten y escuchan eventos.

### **Ventajas del EventBus**
- ✅ **Desacoplamiento**: Los componentes no se conocen directamente
- ✅ **Flexibilidad**: Fácil añadir/remover listeners
- ✅ **Centralización**: Todos los eventos en un lugar
- ✅ **Debugging**: Monitoreo centralizado de comunicación
- ✅ **Escalabilidad**: Nuevos componentes pueden usar eventos existentes

---

## 🚌 **Implementación del EventBus**

### **Estructura Base**
```gdscript
# /src/core/events/EventBus.gd
extends Node

# El EventBus es un Autoload global
# Configurado en project.godot como:
# Nombre: EventBus
# Ruta: res://src/core/events/EventBus.gd

# ============================================================================
# EVENTOS DE JUEGO
# ============================================================================

# Eventos de entidades
signal entity_spawned(entity: Node)
signal entity_destroyed(entity: Node)
signal entity_moved(entity: Node, position: Vector2)

# Eventos de salud
signal health_changed(entity: Node, new_health: int)
signal health_depleted(entity: Node)
signal entity_healed(entity: Node, amount: int)
signal entity_damaged(entity: Node, amount: int)

# Eventos de jugador
signal player_spawned(player: Node)
signal player_moved(position: Vector2)
signal player_input(action: String, value: Variant)
signal player_died()

# ============================================================================
# EVENTOS DE UI
# ============================================================================

# Eventos de menú
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)
signal menu_button_pressed(button_name: String)
signal menu_transition_requested(from_menu: String, to_menu: String)

# Eventos de configuración
signal settings_opened()
signal settings_closed()
signal setting_changed(setting_name: String, value: Variant)

# ============================================================================
# EVENTOS DE SISTEMA
# ============================================================================

# Eventos de servicios
signal service_initialized(service_name: String)
signal service_error(service_name: String, error: String)
signal config_loaded()
signal config_saved()

# Eventos de audio
signal music_changed(track: AudioStream)
signal sfx_played(sound: AudioStream)
signal volume_changed(bus_name: String, volume: float)

# Eventos de input
signal input_context_changed(context: String)
signal input_received(action: String, pressed: bool)

# ============================================================================
# MÉTODOS DE UTILIDAD
# ============================================================================

func _ready() -> void:
    print("EventBus: Initialized and ready")

# Emitir múltiples eventos con datos
func emit_entity_action(entity: Node, action: String, data: Dictionary = {}) -> void:
    match action:
        "spawn":
            entity_spawned.emit(entity)
        "destroy":
            entity_destroyed.emit(entity)
        "move":
            if "position" in data:
                entity_moved.emit(entity, data.position)

# Debug: Imprimir todos los eventos conectados
func debug_print_connections() -> void:
    print("=== EventBus Connections ===")
    for signal_name in get_signal_list():
        var connections = get_signal_connection_list(signal_name.name)
        if connections.size() > 0:
            print("Signal: %s (%d connections)" % [signal_name.name, connections.size()])
            for connection in connections:
                print("  -> %s::%s" % [connection.target, connection.method])

# Verificar si un evento tiene listeners
func has_listeners(signal_name: String) -> bool:
    return get_signal_connection_list(signal_name).size() > 0
```

---

## 📋 **Eventos Disponibles**

### **Eventos de Entidades**
```gdscript
# Spawning y destrucción
EventBus.entity_spawned.emit(player_node)
EventBus.entity_destroyed.emit(enemy_node)

# Movimiento
EventBus.entity_moved.emit(player, Vector2(100, 200))
EventBus.player_moved.emit(Vector2(100, 200))

# Estado de salud
EventBus.health_changed.emit(player, 75)
EventBus.health_depleted.emit(player)
EventBus.entity_damaged.emit(enemy, 25)
```

### **Eventos de UI**
```gdscript
# Navegación de menús
EventBus.menu_opened.emit("MainMenu")
EventBus.menu_closed.emit("SettingsMenu")
EventBus.menu_button_pressed.emit("PlayButton")

# Transiciones
EventBus.menu_transition_requested.emit("MainMenu", "GameplayScene")

# Configuración
EventBus.setting_changed.emit("master_volume", 0.8)
EventBus.settings_opened.emit()
```

### **Eventos de Sistema**
```gdscript
# Servicios
EventBus.service_initialized.emit("AudioService")
EventBus.config_loaded.emit()

# Audio
EventBus.music_changed.emit(background_music)
EventBus.sfx_played.emit(explosion_sound)
EventBus.volume_changed.emit("Master", 0.5)

# Input
EventBus.input_context_changed.emit("Gameplay")
EventBus.player_input.emit("move_left", true)
```

---

## 🔧 **Uso del EventBus**

### **Emitir Eventos**
```gdscript
# Desde cualquier componente
class_name HealthComponent
extends Component

func take_damage(amount: int) -> void:
    current_health -= amount
    
    # Emitir evento de cambio de salud
    EventBus.health_changed.emit(get_parent(), current_health)
    
    if current_health <= 0:
        # Emitir evento de muerte
        EventBus.health_depleted.emit(get_parent())
```

### **Escuchar Eventos**
```gdscript
# Desde cualquier nodo
class_name HealthBar
extends Control

func _ready() -> void:
    # Conectar a eventos de salud
    EventBus.health_changed.connect(_on_health_changed)
    EventBus.health_depleted.connect(_on_entity_died)

func _on_health_changed(entity: Node, new_health: int) -> void:
    # Solo responder si es el jugador
    if entity.is_in_group("player"):
        update_health_bar(new_health)

func _on_entity_died(entity: Node) -> void:
    if entity.is_in_group("player"):
        show_game_over_screen()
```

### **Desconectar Eventos**
```gdscript
func _exit_tree() -> void:
    # Limpiar conexiones al destruir el nodo
    if EventBus.health_changed.is_connected(_on_health_changed):
        EventBus.health_changed.disconnect(_on_health_changed)
    
    if EventBus.health_depleted.is_connected(_on_entity_died):
        EventBus.health_depleted.disconnect(_on_entity_died)
```

---

## 🔄 **Patrones de Comunicación**

### **1. Component → Component**
```gdscript
# HealthComponent informa cambios
# HealthBarComponent responde a cambios

# HealthComponent.gd
func take_damage(amount: int):
    current_health -= amount
    EventBus.health_changed.emit(get_parent(), current_health)

# HealthBarComponent.gd
func _ready():
    EventBus.health_changed.connect(_update_display)

func _update_display(entity: Node, health: int):
    if entity == get_parent():
        health_bar.value = health
```

### **2. Service → Component**
```gdscript
# AudioService notifica cambios de música
# MusicVisualizerComponent responde

# AudioService.gd
func play_music(track: AudioStream):
    EventBus.music_changed.emit(track)

# MusicVisualizerComponent.gd
func _ready():
    EventBus.music_changed.connect(_on_music_changed)

func _on_music_changed(track: AudioStream):
    start_visualization(track)
```

### **3. UI → System**
```gdscript
# MenuComponent solicita cambios
# GameStateManager responde

# MenuComponent.gd
func _on_play_button_pressed():
    EventBus.menu_button_pressed.emit("PlayButton")

# GameStateManager.gd (o similar)
func _ready():
    EventBus.menu_button_pressed.connect(_handle_menu_button)

func _handle_menu_button(button: String):
    match button:
        "PlayButton":
            start_game()
        "SettingsButton":
            open_settings()
```

### **4. Broadcast Events**
```gdscript
# Un evento, múltiples listeners

# Player.gd
func _on_level_up():
    EventBus.player_leveled_up.emit(current_level)

# Múltiples componentes escuchan:
# - UI actualiza indicador de nivel
# - Audio reproduce sonido de level up
# - Effects muestra partículas
# - Stats aumenta atributos
```

---

## 🎯 **Mejores Prácticas**

### **1. Nombres Descriptivos**
```gdscript
# ✅ Bueno: Nombres claros
signal health_changed(entity: Node, new_health: int)
signal menu_button_pressed(button_name: String)
signal player_moved(position: Vector2)

# ❌ Malo: Nombres ambiguos
signal changed(what: Variant)
signal pressed(button: String)
signal moved(pos: Vector2)
```

### **2. Parámetros Específicos**
```gdscript
# ✅ Bueno: Parámetros tipados y descriptivos
signal health_changed(entity: Node, new_health: int, max_health: int)
signal item_collected(player: Node, item: Item, quantity: int)

# ❌ Malo: Parámetros genéricos
signal something_happened(data: Dictionary)
signal event_occurred(values: Array)
```

### **3. Validación de Listeners**
```gdscript
# ✅ Bueno: Verificar antes de emitir eventos costosos
func emit_expensive_event():
    if EventBus.has_listeners("expensive_calculation_needed"):
        EventBus.expensive_calculation_needed.emit(complex_data)

# ✅ Bueno: Validación de parámetros
func emit_health_changed(entity: Node, health: int):
    if not entity:
        push_error("Entity cannot be null")
        return
    
    if health < 0:
        push_warning("Health is negative: %d" % health)
    
    EventBus.health_changed.emit(entity, health)
```

### **4. Limpieza de Conexiones**
```gdscript
# ✅ Bueno: Limpieza automática
func _exit_tree():
    # Desconectar todos los eventos
    for connection in EventBus.get_incoming_connections():
        if connection.target == self:
            connection.signal.disconnect(connection.callable)

# ✅ Bueno: Conexiones one-shot cuando sea apropiado
EventBus.game_started.connect(_on_game_started, CONNECT_ONE_SHOT)
```

### **5. Debugging de Eventos**
```gdscript
# ✅ Útil para debugging
func _ready():
    if OS.is_debug_build():
        # Monitorear todos los eventos en debug
        for signal_info in EventBus.get_signal_list():
            EventBus.connect(signal_info.name, _debug_event_fired.bind(signal_info.name))

func _debug_event_fired(signal_name: String, args: Array = []):
    print("Event fired: %s with args: %s" % [signal_name, args])
```

---

## 📊 **Ventajas del Sistema**

### **Desacoplamiento**
- Los componentes no necesitan referencias directas
- Fácil intercambiar implementaciones
- Menos dependencias entre clases

### **Flexibilidad**
- Múltiples listeners por evento
- Fácil añadir nuevos comportamientos
- Comportamientos condicionales

### **Mantenimiento**
- Eventos centralizados y documentados
- Fácil debugging de comunicación
- Menos código spaghetti

### **Escalabilidad**
- Nuevos componentes pueden usar eventos existentes
- Sistema preparado para networking futuro
- Fácil añadir sistemas de undo/redo

---

**📡 ¡Comunicación limpia y desacoplada para arquitectura modular!**

*Última actualización: Septiembre 4, 2025*
