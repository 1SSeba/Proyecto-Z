# 📦 Sistema de Recursos (.res) - RougeLike Base

El Sistema de Recursos de Godot (.res) permite organizar, optimizar y gestionar datos del juego de manera eficiente. Este sistema centraliza la configuración, assets y datos del juego en archivos reutilizables y fáciles de mantener.

## 🎯 ¿Qué son los Recursos .res?

Los archivos `.res` son **recursos nativos de Godot** que permiten:

- **Almacenar datos estructurados** en formato binario optimizado
- **Cargar recursos de manera eficiente** con `preload()` y `load()`
- **Serializar automáticamente** propiedades exportadas
- **Referenciar otros recursos** creando dependencias complejas
- **Optimizar el rendimiento** de carga y memoria

### Ventajas vs. JSON/CSV/XML

| Característica | .res | JSON | CSV | XML |
|----------------|------|------|-----|-----|
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Tamaño** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Tipado** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐ | ⭐⭐ |
| **Referencias** | ⭐⭐⭐⭐⭐ | ⭐ | ⭐ | ⭐⭐ |
| **Editor** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |

## 🏗️ Arquitectura del Sistema

### Estructura de Recursos del Proyecto

```
game/assets/
├── README_RESOURCES.md         # Documentación
├── game_resources.res          # Recurso principal (agrupa todo)
├──
├── Configuraciones
├── game_config.res             # Configuraciones del juego
├── game_colors.res             # Paleta de colores
├── audio_resources.res         # Referencias de audio
├──
├── Assets del Juego
├── player_sprites.res          # Sprites del jugador
├── map_textures.res           # Texturas de mapas
├── enemy_config.res           # Configuración de enemigos
├── weapon_config.res          # Configuración de armas
├── item_config.res            # Configuración de items
├── level_config.res           # Configuración de niveles
├── skill_config.res           # Configuración de habilidades
└── environment_config.res     # Configuración del entorno
```

## 🎨 Implementación de Recursos

### 1. GameConfig Resource

Configuraciones centrales del juego:

```gdscript
# game/assets/resources/GameConfig.gd
extends Resource
class_name GameConfig

## Configuración central del juego.
##
## Contiene todas las configuraciones principales del juego
## incluyendo jugador, audio, video y gameplay.

@export_group("Información del Juego")
@export var game_title: String = "RougeLike Base"
@export var game_version: String = "v0.1.0"
@export var developer: String = "Tu Estudio"

@export_group("Configuración del Jugador")
@export var player_speed: float = 150.0
@export var player_max_health: int = 100
@export var player_health_regen: float = 0.5
@export var player_invulnerability_time: float = 1.0

@export_group("Configuración de Audio")
@export var master_volume: float = 1.0
@export var music_volume: float = 0.8
@export var sfx_volume: float = 1.0
@export var voice_volume: float = 1.0

@export_group("Configuración de Video")
@export var screen_width: int = 1280
@export var screen_height: int = 720
@export var fullscreen: bool = false
@export var vsync: bool = true
@export var max_fps: int = 60

@export_group("Configuración de Gameplay")
@export var auto_save_interval: float = 300.0  # 5 minutos
@export var difficulty_multiplier: float = 1.0
@export var show_debug_info: bool = false
@export var enable_cheats: bool = false

@export_group("Configuración de UI")
@export var ui_scale: float = 1.0
@export var show_tooltips: bool = true
@export var tooltip_delay: float = 0.5

## Validar y aplicar configuraciones
func validate_config() -> bool:
    var is_valid = true

    # Validar valores de audio (0.0 - 1.0)
    if master_volume < 0.0 or master_volume > 1.0:
        push_warning("master_volume out of range [0.0, 1.0]")
        master_volume = clamp(master_volume, 0.0, 1.0)
        is_valid = false

    # Validar resolución mínima
    if screen_width < 640 or screen_height < 480:
        push_warning("Resolution too small, using minimum 640x480")
        screen_width = max(screen_width, 640)
        screen_height = max(screen_height, 480)
        is_valid = false

    # Validar valores del jugador
    if player_max_health <= 0:
        push_warning("player_max_health must be positive")
        player_max_health = 100
        is_valid = false

    return is_valid

## Aplicar configuraciones al juego
func apply_config():
    # Aplicar configuraciones de video
    if fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_size(Vector2i(screen_width, screen_height))

    # Aplicar configuraciones de audio
    var master_bus = AudioServer.get_bus_index("Master")
    var music_bus = AudioServer.get_bus_index("Music")
    var sfx_bus = AudioServer.get_bus_index("SFX")

    if master_bus != -1:
        AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))
    if music_bus != -1:
        AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
    if sfx_bus != -1:
        AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

    # Aplicar configuraciones de engine
    Engine.max_fps = max_fps if max_fps > 0 else 0

## Resetear a valores por defecto
func reset_to_defaults():
    game_title = "RougeLike Base"
    game_version = "v0.1.0"
    player_speed = 150.0
    player_max_health = 100
    master_volume = 1.0
    music_volume = 0.8
    sfx_volume = 1.0
    screen_width = 1280
    screen_height = 720
    fullscreen = false
    max_fps = 60
```

### 2. PlayerSprites Resource

Organiza todos los sprites del jugador:

```gdscript
# game/assets/resources/PlayerSprites.gd
extends Resource
class_name PlayerSprites

## Recurso que contiene todas las texturas del jugador.
##
## Organiza sprites por animación y dirección para fácil acceso.

@export_group("Idle Animations")
@export var idle_down: Texture2D
@export var idle_left: Texture2D
@export var idle_right: Texture2D
@export var idle_up: Texture2D

@export_group("Run Animations")
@export var run_down: Texture2D
@export var run_left: Texture2D
@export var run_right: Texture2D
@export var run_up: Texture2D

@export_group("Attack1 Animations")
@export var attack1_down: Texture2D
@export var attack1_left: Texture2D
@export var attack1_right: Texture2D
@export var attack1_up: Texture2D

@export_group("Attack2 Animations")
@export var attack2_down: Texture2D
@export var attack2_left: Texture2D
@export var attack2_right: Texture2D
@export var attack2_up: Texture2D

# Diccionario para acceso programático
var _sprite_cache: Dictionary = {}

func _init():
    _build_sprite_cache()

## Construir cache para acceso rápido
func _build_sprite_cache():
    _sprite_cache = {
        "idle": {
            "down": idle_down,
            "left": idle_left,
            "right": idle_right,
            "up": idle_up
        },
        "run": {
            "down": run_down,
            "left": run_left,
            "right": run_right,
            "up": run_up
        },
        "attack1": {
            "down": attack1_down,
            "left": attack1_left,
            "right": attack1_right,
            "up": attack1_up
        },
        "attack2": {
            "down": attack2_down,
            "left": attack2_left,
            "right": attack2_right,
            "up": attack2_up
        }
    }

## Obtener sprite por animación y dirección
func get_sprite(animation: String, direction: String) -> Texture2D:
    if animation in _sprite_cache and direction in _sprite_cache[animation]:
        return _sprite_cache[animation][direction]

    push_warning("Sprite not found: %s_%s" % [animation, direction])
    return null

## Obtener todas las direcciones de una animación
func get_animation_directions(animation: String) -> Array[String]:
    if animation in _sprite_cache:
        return _sprite_cache[animation].keys()
    return []

## Verificar si existe un sprite
func has_sprite(animation: String, direction: String) -> bool:
    return animation in _sprite_cache and direction in _sprite_cache[animation]

## Obtener todas las animaciones disponibles
func get_available_animations() -> Array[String]:
    return _sprite_cache.keys()

## Validar que todos los sprites estén asignados
func validate_sprites() -> bool:
    var missing_sprites: Array[String] = []

    for animation in _sprite_cache:
        for direction in _sprite_cache[animation]:
            if not _sprite_cache[animation][direction]:
                missing_sprites.append("%s_%s" % [animation, direction])

    if not missing_sprites.is_empty():
        push_warning("Missing sprites: " + str(missing_sprites))
        return false

    return true
```

### 3. GameColors Resource

Paleta de colores centralizada:

```gdscript
# game/assets/resources/GameColors.gd
extends Resource
class_name GameColors

## Paleta de colores centralizada del juego.
##
## Define todos los colores usados en UI, efectos y elementos visuales.

@export_group("UI Colors")
@export var ui_background: Color = Color(0.1, 0.1, 0.1, 0.9)
@export var ui_panel: Color = Color(0.2, 0.2, 0.2, 0.95)
@export var ui_text: Color = Color.WHITE
@export var ui_text_secondary: Color = Color(0.8, 0.8, 0.8)
@export var ui_accent: Color = Color(0.3, 0.6, 1.0)

@export_group("Health Colors")
@export var health_full: Color = Color.GREEN
@export var health_half: Color = Color.YELLOW
@export var health_low: Color = Color.RED
@export var health_background: Color = Color(0.2, 0.2, 0.2)

@export_group("Debug Colors")
@export var debug_info: Color = Color.CYAN
@export var debug_warning: Color = Color.YELLOW
@export var debug_error: Color = Color.RED

@export_group("Entity Colors")
@export var player_color: Color = Color.BLUE
@export var enemy_color: Color = Color.RED
@export var item_color: Color = Color.GREEN
@export var npc_color: Color = Color.YELLOW

@export_group("Effect Colors")
@export var damage_color: Color = Color.RED
@export var heal_color: Color = Color.GREEN
@export var experience_color: Color = Color.CYAN
@export var critical_color: Color = Color.ORANGE

## Obtener color de salud basado en porcentaje
func get_health_color(health_percentage: float) -> Color:
    if health_percentage > 0.6:
        return health_full
    elif health_percentage > 0.3:
        return health_half
    else:
        return health_low

## Obtener color con transparencia
func get_color_with_alpha(color: Color, alpha: float) -> Color:
    var new_color = color
    new_color.a = alpha
    return new_color

## Obtener color más brillante
func get_brighter_color(color: Color, factor: float = 1.2) -> Color:
    return Color(
        min(color.r * factor, 1.0),
        min(color.g * factor, 1.0),
        min(color.b * factor, 1.0),
        color.a
    )

## Obtener color más oscuro
func get_darker_color(color: Color, factor: float = 0.8) -> Color:
    return Color(
        color.r * factor,
        color.g * factor,
        color.b * factor,
        color.a
    )
```

### 4. WeaponConfig Resource

Configuración de armas del juego:

```gdscript
# game/assets/resources/WeaponConfig.gd
extends Resource
class_name WeaponConfig

## Configuración de armas del juego.

@export_group("Basic Info")
@export var weapon_id: String = ""
@export var weapon_name: String = ""
@export var weapon_description: String = ""
@export var weapon_icon: Texture2D

@export_group("Combat Stats")
@export var base_damage: int = 10
@export var attack_speed: float = 1.0
@export var critical_chance: float = 0.05
@export var critical_multiplier: float = 2.0
@export var range: float = 50.0

@export_group("Special Properties")
@export var weapon_type: WeaponType = WeaponType.MELEE
@export var damage_type: DamageType = DamageType.PHYSICAL
@export var special_effects: Array[String] = []

@export_group("Requirements")
@export var required_level: int = 1
@export var required_stats: Dictionary = {}

@export_group("Visual")
@export var weapon_sprite: Texture2D
@export var attack_animation: String = ""
@export var sound_effect: String = ""

enum WeaponType {
    MELEE,
    RANGED,
    MAGIC
}

enum DamageType {
    PHYSICAL,
    MAGICAL,
    POISON,
    FIRE,
    ICE,
    LIGHTNING
}

## Calcular daño total con modificadores
func calculate_damage(player_stats: Dictionary = {}) -> int:
    var total_damage = base_damage

    # Aplicar modificadores de stats del jugador
    if "attack_power" in player_stats:
        total_damage += player_stats["attack_power"]

    # Aplicar modificadores de tipo de arma
    match weapon_type:
        WeaponType.MELEE:
            if "strength" in player_stats:
                total_damage += player_stats["strength"] * 0.5
        WeaponType.RANGED:
            if "dexterity" in player_stats:
                total_damage += player_stats["dexterity"] * 0.5
        WeaponType.MAGIC:
            if "intelligence" in player_stats:
                total_damage += player_stats["intelligence"] * 0.5

    return int(total_damage)

## Verificar si el jugador puede usar el arma
func can_player_use(player_stats: Dictionary) -> bool:
    # Verificar nivel
    if "level" in player_stats and player_stats["level"] < required_level:
        return false

    # Verificar stats requeridos
    for stat_name in required_stats:
        if stat_name in player_stats:
            if player_stats[stat_name] < required_stats[stat_name]:
                return false
        else:
            return false

    return true

## Obtener descripción completa del arma
func get_full_description() -> String:
    var desc = weapon_description + "\n\n"
    desc += "Damage: %d\n" % base_damage
    desc += "Attack Speed: %.1f\n" % attack_speed
    desc += "Critical Chance: %.1f%%\n" % (critical_chance * 100)
    desc += "Range: %.0f\n" % range
    desc += "Type: %s\n" % WeaponType.keys()[weapon_type]

    if required_level > 1:
        desc += "Required Level: %d\n" % required_level

    if not special_effects.is_empty():
        desc += "Special Effects: " + ", ".join(special_effects)

    return desc
```

## 🔧 ResourceLoader Centralizado

Sistema para cargar y gestionar todos los recursos:

```gdscript
# game/core/ResourceLoader.gd
extends Node
class_name ResourceLoader

## Cargador centralizado de recursos del juego.
##
## Proporciona acceso fácil y optimizado a todos los recursos .res del juego.

# Referencias a recursos principales
var game_config: GameConfig
var player_sprites: PlayerSprites
var game_colors: GameColors
var map_textures: MapTextures
var audio_resources: AudioResources

# Configuraciones de entidades
var weapon_configs: Dictionary = {}
var enemy_configs: Dictionary = {}
var item_configs: Dictionary = {}
var skill_configs: Dictionary = {}
var level_configs: Dictionary = {}

# Cache de recursos
var _resource_cache: Dictionary = {}

signal resources_loaded()
signal resource_load_failed(resource_path: String)

func _ready():
    print("ResourceLoader: Initializing...")
    _load_all_resources()

## Cargar todos los recursos del juego
func _load_all_resources():
    # Recursos principales
    game_config = _load_resource("res://game/assets/game_config.res")
    player_sprites = _load_resource("res://game/assets/player_sprites.res")
    game_colors = _load_resource("res://game/assets/game_colors.res")
    map_textures = _load_resource("res://game/assets/map_textures.res")
    audio_resources = _load_resource("res://game/assets/audio_resources.res")

    # Cargar configuraciones de entidades
    _load_weapon_configs()
    _load_enemy_configs()
    _load_item_configs()
    _load_skill_configs()
    _load_level_configs()

    # Validar recursos cargados
    _validate_resources()

    print("ResourceLoader: All resources loaded")
    resources_loaded.emit()

## Cargar un recurso con cache
func _load_resource(path: String) -> Resource:
    if path in _resource_cache:
        return _resource_cache[path]

    if not ResourceLoader.exists(path):
        push_error("Resource not found: " + path)
        resource_load_failed.emit(path)
        return null

    var resource = load(path)
    if resource:
        _resource_cache[path] = resource
        print("ResourceLoader: Loaded " + path)
    else:
        push_error("Failed to load resource: " + path)
        resource_load_failed.emit(path)

    return resource

## Cargar configuraciones de armas
func _load_weapon_configs():
    var weapon_dir = "res://game/assets/weapons/"
    if DirAccess.dir_exists_absolute(weapon_dir):
        var dir = DirAccess.open(weapon_dir)
        dir.list_dir_begin()
        var file_name = dir.get_next()

        while file_name != "":
            if file_name.ends_with(".res"):
                var weapon_config = _load_resource(weapon_dir + file_name)
                if weapon_config and weapon_config is WeaponConfig:
                    weapon_configs[weapon_config.weapon_id] = weapon_config
            file_name = dir.get_next()

## Métodos de acceso a recursos

# Configuraciones del juego
func get_player_speed() -> float:
    return game_config.player_speed if game_config else 150.0

func get_player_max_health() -> int:
    return game_config.player_max_health if game_config else 100

func get_config_value(key: String, default_value = null):
    if not game_config:
        return default_value

    if key in game_config:
        return game_config.get(key)
    return default_value

# Sprites del jugador
func get_player_sprite(animation: String, direction: String) -> Texture2D:
    if player_sprites:
        return player_sprites.get_sprite(animation, direction)
    return null

func get_player_animations() -> Array[String]:
    if player_sprites:
        return player_sprites.get_available_animations()
    return []

# Colores del juego
func get_ui_color(color_name: String) -> Color:
    if not game_colors:
        return Color.WHITE

    match color_name:
        "ui_background": return game_colors.ui_background
        "ui_panel": return game_colors.ui_panel
        "ui_text": return game_colors.ui_text
        "health_full": return game_colors.health_full
        "health_half": return game_colors.health_half
        "health_low": return game_colors.health_low
        _: return Color.WHITE

func get_health_color(health_percentage: float) -> Color:
    if game_colors:
        return game_colors.get_health_color(health_percentage)
    return Color.WHITE

# Configuraciones de armas
func get_weapon_config(weapon_id: String) -> WeaponConfig:
    return weapon_configs.get(weapon_id, null)

func get_all_weapon_ids() -> Array[String]:
    return weapon_configs.keys()

# Validación de recursos
func _validate_resources():
    var validation_passed = true

    if not game_config:
        push_error("game_config not loaded")
        validation_passed = false
    elif not game_config.validate_config():
        push_warning("game_config validation failed")

    if not player_sprites:
        push_error("player_sprites not loaded")
        validation_passed = false
    elif not player_sprites.validate_sprites():
        push_warning("player_sprites validation failed")

    if not game_colors:
        push_error("game_colors not loaded")
        validation_passed = false

    if validation_passed:
        print("ResourceLoader: All resources validated successfully")
    else:
        push_error("ResourceLoader: Some resources failed validation")

## Recargar recursos (para desarrollo)
func reload_resources():
    _resource_cache.clear()
    weapon_configs.clear()
    enemy_configs.clear()
    item_configs.clear()

    _load_all_resources()
    print("ResourceLoader: Resources reloaded")

## Obtener estadísticas de memoria
func get_memory_stats() -> Dictionary:
    return {
        "cached_resources": _resource_cache.size(),
        "weapon_configs": weapon_configs.size(),
        "enemy_configs": enemy_configs.size(),
        "item_configs": item_configs.size()
    }
```

## 🎮 Uso Práctico en el Juego

### En el Player

```gdscript
# game/entities/characters/Player.gd
extends CharacterBody2D
class_name Player

var resource_loader: ResourceLoader
var player_sprites: PlayerSprites
var game_config: GameConfig

func _ready():
    _load_resources()
    _setup_player()

func _load_resources():
    resource_loader = get_node("/root/ResourceLoader")
    if resource_loader:
        player_sprites = resource_loader.player_sprites
        game_config = resource_loader.game_config

        # Aplicar configuraciones
        movement_speed = resource_loader.get_player_speed()
        max_health = resource_loader.get_player_max_health()

func get_sprite_for_animation(animation: String, direction: String) -> Texture2D:
    if resource_loader:
        return resource_loader.get_player_sprite(animation, direction)
    return null

func _setup_player():
    if game_config:
        # Aplicar configuraciones del game_config
        movement_speed = game_config.player_speed
        max_health = game_config.player_max_health
        invulnerability_time = game_config.player_invulnerability_time
```

### En el HUD

```gdscript
# game/scenes/hud/GameHUD.gd
extends Control
class_name GameHUD

@onready var health_bar: ProgressBar = $HealthBar
@onready var background: Panel = $Background

var resource_loader: ResourceLoader
var game_colors: GameColors

func _ready():
    _load_resources()
    _apply_theme()

func _load_resources():
    resource_loader = get_node("/root/ResourceLoader")
    if resource_loader:
        game_colors = resource_loader.game_colors

func _apply_theme():
    if game_colors:
        # Aplicar colores del tema
        background.modulate = game_colors.ui_background

        # Crear StyleBox para la health bar
        var style_box = StyleBoxFlat.new()
        style_box.bg_color = game_colors.health_background
        health_bar.add_theme_stylebox_override("background", style_box)

func update_health_bar(current_health: int, max_health: int):
    if health_bar and game_colors:
        health_bar.value = float(current_health) / float(max_health) * 100.0

        # Cambiar color según salud
        var health_percentage = float(current_health) / float(max_health)
        var health_color = game_colors.get_health_color(health_percentage)
        health_bar.modulate = health_color
```

### En un Sistema de Armas

```gdscript
# game/systems/WeaponSystem.gd
extends Node
class_name WeaponSystem

var resource_loader: ResourceLoader
var available_weapons: Dictionary = {}

func _ready():
    resource_loader = get_node("/root/ResourceLoader")
    if resource_loader:
        available_weapons = resource_loader.weapon_configs

func create_weapon(weapon_id: String) -> Weapon:
    var weapon_config = resource_loader.get_weapon_config(weapon_id)
    if not weapon_config:
        push_error("Weapon config not found: " + weapon_id)
        return null

    var weapon = Weapon.new()
    weapon.setup_from_config(weapon_config)
    return weapon

func get_available_weapons_for_level(player_level: int) -> Array[WeaponConfig]:
    var available: Array[WeaponConfig] = []

    for weapon_id in available_weapons:
        var config = available_weapons[weapon_id]
        if config.required_level <= player_level:
            available.append(config)

    return available
```

## 🛠️ Herramientas de Desarrollo

### Script para Crear Recursos

```gdscript
# tools/resource_creator.gd
@tool
extends EditorScript

## Script para crear recursos básicos del juego

func _run():
    create_game_config()
    create_player_sprites()
    create_game_colors()
    print("Resources created successfully!")

func create_game_config():
    var config = GameConfig.new()
    config.game_title = "My Game"
    config.player_speed = 150.0
    config.player_max_health = 100

    ResourceSaver.save(config, "res://game/assets/game_config.res")
    print("Created game_config.res")

func create_player_sprites():
    var sprites = PlayerSprites.new()
    # Asignar sprites por defecto si existen

    ResourceSaver.save(sprites, "res://game/assets/player_sprites.res")
    print("Created player_sprites.res")

func create_game_colors():
    var colors = GameColors.new()
    # Los valores por defecto ya están en la clase

    ResourceSaver.save(colors, "res://game/assets/game_colors.res")
    print("Created game_colors.res")
```

### Validador de Recursos

```gdscript
# tools/resource_validator.gd
@tool
extends EditorScript

func _run():
    validate_all_resources()

func validate_all_resources():
    var errors = []

    # Validar recursos principales
    errors.append_array(_validate_resource("res://game/assets/game_config.res", GameConfig))
    errors.append_array(_validate_resource("res://game/assets/player_sprites.res", PlayerSprites))
    errors.append_array(_validate_resource("res://game/assets/game_colors.res", GameColors))

    # Reportar resultados
    if errors.is_empty():
        print("✅ All resources are valid!")
    else:
        print("❌ Found %d validation errors:" % errors.size())
        for error in errors:
            print("  - " + error)

func _validate_resource(path: String, expected_type) -> Array[String]:
    var errors: Array[String] = []

    if not ResourceLoader.exists(path):
        errors.append("Resource not found: " + path)
        return errors

    var resource = load(path)
    if not resource:
        errors.append("Failed to load: " + path)
        return errors

    if not resource is expected_type:
        errors.append("Wrong type for %s: expected %s, got %s" % [path, expected_type, resource.get_class()])
        return errors

    # Validación específica del tipo
    if resource.has_method("validate"):
        if not resource.validate():
            errors.append("Validation failed for: " + path)

    return errors
```

## 📋 Mejores Prácticas

### 1. **Organización Clara**

```gdscript
# ✅ Estructura organizada
@export_group("Core Settings")
@export var base_value: int = 100

@export_group("Advanced Settings")
@export var multiplier: float = 1.0

# ❌ Sin organización
@export var base_value: int = 100
@export var some_other_thing: String = ""
@export var multiplier: float = 1.0
```

### 2. **Validación Robusta**

```gdscript
# ✅ Validación completa
func validate_config() -> bool:
    var is_valid = true

    if base_damage <= 0:
        push_error("base_damage must be positive")
        base_damage = 1
        is_valid = false

    if attack_speed <= 0:
        push_error("attack_speed must be positive")
        attack_speed = 1.0
        is_valid = false

    return is_valid

# ❌ Sin validación
# Los valores incorrectos pueden romper el juego
```

### 3. **Cache Inteligente**

```gdscript
# ✅ Cache eficiente
var _sprite_cache: Dictionary = {}

func get_sprite(key: String) -> Texture2D:
    if key not in _sprite_cache:
        _sprite_cache[key] = _load_sprite(key)
    return _sprite_cache[key]

# ❌ Cargar siempre
func get_sprite(key: String) -> Texture2D:
    return load("res://sprites/" + key + ".png")  # Muy lento
```

### 4. **Documentación Completa**

```gdscript
## Configuración de arma del juego.
##
## Define todas las propiedades de un arma incluyendo daño,
## velocidad de ataque, efectos especiales y requisitos.
##
## Ejemplo de uso:
## [codeblock]
## var sword_config = WeaponConfig.new()
## sword_config.weapon_id = "iron_sword"
## sword_config.base_damage = 25
## [/codeblock]
class_name WeaponConfig extends Resource
```

### 5. **Fallbacks Seguros**

```gdscript
# ✅ Con fallbacks
func get_player_speed() -> float:
    return game_config.player_speed if game_config else 150.0

func get_sprite(animation: String, direction: String) -> Texture2D:
    var sprite = player_sprites.get_sprite(animation, direction) if player_sprites else null
    return sprite if sprite else _get_default_sprite()

# ❌ Sin fallbacks
func get_player_speed() -> float:
    return game_config.player_speed  # Puede ser null
```

---

**El Sistema de Recursos .res proporciona una base sólida para organizar y optimizar todos los datos del juego.** Con esta arquitectura, tienes un control centralizado, rendimiento optimizado y fácil mantenimiento de todos los assets y configuraciones.

**Recuerda**: Los recursos .res son la columna vertebral de los datos de tu juego. Invierte tiempo en organizarlos bien desde el principio para ahorrar horas de refactoring más tarde.

*Documentación completada para el sistema de arquitectura principal*

*Última actualización: Septiembre 7, 2025*
