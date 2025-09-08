# 📦 Recursos .res del Juego

## 🎯 **¿Qué son los archivos .res?**

Los archivos `.res` son recursos de Godot que permiten organizar y agrupar datos del juego de manera eficiente. Son como "cajas" que contienen múltiples recursos relacionados.

## 📁 **Archivos .res Creados**

### **1. player_sprites.res**
Contiene todos los sprites del jugador:
- `attack1_down`, `attack1_left`, `attack1_right`, `attack1_up`
- `attack2_down`, `attack2_left`, `attack2_right`, `attack2_up`
- `idle_down`, `idle_left`, `idle_right`, `idle_up`
- `run_down`, `run_left`, `run_right`, `run_up`

### **2. map_textures.res**
Contiene texturas de mapas:
- `plant`, `player`, `props`
- `shadow_plant`, `shadow`, `struct`
- `tileset_grass`, `tileset_stone`, `tileset_wall`
- `plant_with_shadow`, `props_with_shadow`

### **3. game_config.res**
Configuraciones del juego:
- `player_speed`, `player_max_health`, `player_health_regen`
- `game_title`, `game_version`, `max_fps`
- `master_volume`, `music_volume`, `sfx_volume`
- `screen_width`, `screen_height`, `fullscreen`

### **4. game_colors.res**
Colores del juego:
- `ui_background`, `ui_panel`, `ui_text`
- `health_full`, `health_half`, `health_low`
- `debug_info`, `debug_warning`, `debug_error`
- `player_color`, `enemy_color`, `item_color`

### **5. audio_resources.res**
Recursos de audio (placeholders):
- `music_main_menu`, `music_gameplay`, `music_boss`
- `sfx_player_move`, `sfx_player_attack`, `sfx_player_hurt`
- `sfx_enemy_hurt`, `sfx_item_pickup`, `sfx_ui_click`

### **6. game_resources.res**
Recurso principal que contiene todos los demás.

## 🚀 **Cómo Usar los Recursos**

### **1. Cargar el ResourceLoader**
```gdscript
# En cualquier script
var resource_loader = get_node("/root/ResourceLoader")
if not resource_loader:
    resource_loader = preload("res://game/core/ResourceLoader.gd").new()
    get_tree().root.add_child(resource_loader)
```

### **2. Obtener Sprites del Jugador**
```gdscript
# Obtener sprite de idle hacia abajo
var idle_sprite = resource_loader.get_player_sprite("idle", "down")

# Obtener sprite de run hacia la izquierda
var run_sprite = resource_loader.get_player_sprite("run", "left")
```

### **3. Obtener Texturas de Mapas**
```gdscript
# Obtener textura de hierba
var grass_texture = resource_loader.get_map_texture("tileset_grass")

# Obtener textura de pared
var wall_texture = resource_loader.get_map_texture("tileset_wall")
```

### **4. Obtener Configuraciones**
```gdscript
# Obtener velocidad del jugador
var player_speed = resource_loader.get_player_speed()

# Obtener salud máxima
var max_health = resource_loader.get_player_max_health()

# Obtener cualquier configuración
var game_title = resource_loader.get_config_value("game_title", "Mi Juego")
```

### **5. Obtener Colores**
```gdscript
# Obtener color de fondo de UI
var bg_color = resource_loader.get_ui_color("ui_background")

# Obtener color de salud completa
var health_color = resource_loader.get_ui_color("health_full")
```

## 🔧 **Ventajas de Usar .res**

### **Organización**
- ✅ Todos los recursos relacionados en un solo lugar
- ✅ Fácil de encontrar y modificar
- ✅ Estructura clara y lógica

### **Rendimiento**
- ✅ Carga más rápida que archivos individuales
- ✅ Menos llamadas a `load()`
- ✅ Mejor gestión de memoria

### **Mantenimiento**
- ✅ Cambios centralizados
- ✅ Fácil de actualizar
- ✅ Menos errores de rutas

## 📝 **Ejemplos de Uso**

### **En el Player**
```gdscript
func _load_resources():
    var resource_loader = get_node("/root/ResourceLoader")
    player_sprites = resource_loader.player_sprites

func get_sprite(animation: String, direction: String) -> Texture2D:
    return resource_loader.get_player_sprite(animation, direction)
```

### **En el HUD**
```gdscript
func _apply_game_colors():
    var resource_loader = get_node("/root/ResourceLoader")
    var bg_color = resource_loader.get_ui_color("ui_background")
    # Aplicar color al fondo
```

### **En Configuración**
```gdscript
func load_game_settings():
    var resource_loader = get_node("/root/ResourceLoader")
    var config = resource_loader.game_config

    # Aplicar configuraciones
    speed = config.player_speed
    max_health = config.player_max_health
```

## 🎯 **Próximos Pasos**

1. **Agregar más recursos** según necesites
2. **Crear recursos para enemigos** cuando los tengas
3. **Agregar recursos de UI** para menús
4. **Expandir configuraciones** según el juego crezca

## 💡 **Consejos**

- **Mantén los .res organizados** por categorías
- **Usa nombres descriptivos** para las propiedades
- **Documenta qué contiene** cada archivo .res
- **Actualiza los .res** cuando agregues nuevos recursos

---

*Creado para Proyecto-Z - Pre-alpha v0.0.1*

