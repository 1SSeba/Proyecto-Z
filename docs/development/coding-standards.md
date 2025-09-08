# 🎯 Estándares de Código - RougeLike Base

Esta documentación establece los estándares de código, convenciones de estilo y mejores prácticas para mantener un código consistente, legible y mantenible en todo el proyecto.

## 📋 Principios Generales

### 1. **Legibilidad ante todo**
El código se lee mucho más de lo que se escribe. Prioriza claridad sobre brevedad.

### 2. **Consistencia**
Un estilo consistente es más importante que el estilo "perfecto". Sigue las convenciones establecidas.

### 3. **Autodocumentación**
El código debe explicarse a sí mismo. Los comentarios explican el "por qué", no el "qué".

### 4. **Modularidad**
Componentes pequeños, enfocados y reutilizables.

## 🔤 Convenciones de Nomenclatura

### Clases y Scripts

```gdscript
# ✅ PascalCase para nombres de clases
class_name PlayerController
class_name HealthComponent
class_name ServiceManager

# ✅ Nombres descriptivos y específicos
class_name WeaponInventoryComponent  # Específico
# ❌ class_name Component            # Muy genérico
# ❌ class_name WIC                  # No descriptivo

# ✅ Sufijos consistentes para tipos
class_name AudioService              # Servicios
class_name HealthComponent           # Componentes
class_name MainMenuState             # Estados
class_name PlayerEntity              # Entidades
```

### Variables y Funciones

```gdscript
# ✅ snake_case para variables y funciones
var player_health: int = 100
var max_movement_speed: float = 150.0
var is_invulnerable: bool = false

func calculate_damage(base_damage: int) -> int:
    return base_damage

func get_health_percentage() -> float:
    return float(current_health) / float(max_health)

# ✅ Nombres descriptivos
var enemy_spawn_timer: Timer
func handle_player_input(event: InputEvent):

# ❌ Nombres crípticos
# var t: Timer
# func handle_input(e):
```

### Constantes

```gdscript
# ✅ UPPER_SNAKE_CASE para constantes
const MAX_HEALTH: int = 100
const DEFAULT_SPEED: float = 150.0
const PLAYER_LAYER: int = 1

# ✅ Agrupar constantes relacionadas
enum GameState {
    MAIN_MENU,
    LOADING,
    PLAYING,
    PAUSED,
    GAME_OVER
}

enum ComponentType {
    HEALTH,
    MOVEMENT,
    ATTACK,
    INVENTORY
}
```

### Señales

```gdscript
# ✅ snake_case descriptivo para señales
signal health_changed(current: int, maximum: int)
signal player_died()
signal item_collected(item_name: String, quantity: int)
signal level_completed(level_id: String, score: int)

# ✅ Incluir tipos en parámetros
signal damage_taken(amount: int, source: Node, damage_type: String)

# ❌ Señales ambiguas
# signal changed()
# signal event()
```

### Nodos y Referencias

```gdscript
# ✅ snake_case para referencias de nodos
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var attack_timer: Timer = $AttackTimer

# ✅ Incluir tipo en el nombre si ayuda a la claridad
@onready var background_music_player: AudioStreamPlayer = $BackgroundMusic
@onready var damage_number_label: Label = $DamageNumberLabel
```

### Archivos y Carpetas

```gdscript
# ✅ PascalCase para archivos de clases
PlayerController.gd
HealthComponent.gd
AudioService.gd

# ✅ snake_case para archivos de utilidades
utility_functions.gd
debug_helpers.gd

# ✅ Carpetas en minúsculas con guiones
game/core/components/
game/scenes/main-menu/
game/assets/audio-effects/
```

## 🏗️ Estructura de Scripts

### Orden de Elementos

```gdscript
# 1. Extends y class_name
extends Component
class_name HealthComponent

# 2. Documentación de clase (si es necesaria)
## Componente responsable de gestionar la vida y el daño de entidades.
##
## Proporciona funcionalidades de daño, curación y regeneración automática.
## Se integra con el EventBus para notificar cambios de salud.

# 3. Señales
signal health_changed(current: int, maximum: int)
signal health_depleted(entity: Node)
signal damage_taken(damage: int, source: Node)

# 4. Enums
enum DamageType {
    PHYSICAL,
    MAGICAL,
    POISON,
    FIRE
}

# 5. Constantes
const MIN_HEALTH: int = 0
const DEFAULT_MAX_HEALTH: int = 100

# 6. Variables exportadas
@export var max_health: int = 100: set = set_max_health
@export var regeneration_rate: float = 0.0
@export var invulnerable: bool = false

# 7. Variables públicas
var current_health: int = 100
var is_alive: bool = true

# 8. Variables privadas (prefijo _)
var _regeneration_timer: Timer
var _damage_modifiers: Dictionary = {}

# 9. Referencias de nodos (@onready)
@onready var damage_effects: Node2D = $DamageEffects
@onready var health_bar: ProgressBar = $HealthBar

# 10. Métodos virtuales (lifecycle)
func _ready():
    _initialize_component()

func _process(delta):
    _handle_regeneration(delta)

# 11. Métodos públicos
func take_damage(amount: int, source: Node = null) -> bool:
    # Implementación...

func heal(amount: int) -> bool:
    # Implementación...

# 12. Métodos privados (prefijo _)
func _initialize_component():
    # Implementación...

func _handle_regeneration(delta: float):
    # Implementación...

# 13. Setters/Getters
func set_max_health(value: int):
    max_health = max(1, value)
    if current_health > max_health:
        current_health = max_health
```

### Documentación de Métodos

```gdscript
## Aplica daño a la entidad.
##
## Reduce la salud actual por la cantidad especificada y emite eventos
## correspondientes. Si la salud llega a 0, la entidad muere.
##
## @param amount: Cantidad de daño a aplicar (debe ser positivo)
## @param source: Entidad que causa el daño (opcional)
## @param damage_type: Tipo de daño para aplicar resistencias
## @return: true si el daño fue aplicado, false si fue bloqueado
func take_damage(amount: int, source: Node = null, damage_type: DamageType = DamageType.PHYSICAL) -> bool:
    if not is_alive or invulnerable or amount <= 0:
        return false

    # Aplicar modificadores de daño
    var final_damage = _calculate_final_damage(amount, damage_type)

    var old_health = current_health
    current_health = max(MIN_HEALTH, current_health - final_damage)

    # Emitir eventos
    damage_taken.emit(final_damage, source)
    health_changed.emit(current_health, max_health)

    # Verificar muerte
    if current_health <= 0 and old_health > 0:
        _handle_death()

    return true
```

## 🎨 Estilo de Código

### Indentación y Espacios

```gdscript
# ✅ Usar tabs para indentación (configuración de Godot)
func example_function():
	if condition:
		do_something()
	else:
		do_something_else()

# ✅ Espacios alrededor de operadores
var result = (a + b) * c
var is_valid = health > 0 and not is_dead

# ✅ Espacios después de comas
func my_function(param1: int, param2: String, param3: bool):
    pass

var my_array = [1, 2, 3, 4, 5]

# ✅ Líneas en blanco para separar secciones lógicas
func complex_function():
    # Inicialización
    var setup_data = _prepare_setup()
    var config = _load_config()

    # Procesamiento principal
    for item in items:
        process_item(item)

    # Finalización
    _cleanup_resources()
    return result
```

### Llaves y Paréntesis

```gdscript
# ✅ Llaves en líneas separadas para bloques grandes
if complex_condition_that_spans_multiple_lines or another_condition:
    complex_operation()
    another_operation()
    final_operation()

# ✅ Llaves en la misma línea para bloques simples
if simple_condition: return early_result

# ✅ Paréntesis para claridad en expresiones complejas
var result = (base_damage * multiplier) + (bonus_damage / 2)

# ✅ Alineación en diccionarios y arrays complejos
var player_stats = {
    "health": 100,
    "mana": 50,
    "speed": 150.0,
    "attack_power": 25
}
```

### Longitud de Líneas

```gdscript
# ✅ Máximo 100 caracteres por línea
# Si una línea es muy larga, dividirla lógicamente

# ❌ Línea muy larga
var very_long_variable_name = some_complex_calculation(parameter1, parameter2, parameter3, parameter4)

# ✅ Dividir en múltiples líneas
var very_long_variable_name = some_complex_calculation(
    parameter1,
    parameter2,
    parameter3,
    parameter4
)

# ✅ Para cadenas largas
var long_message = (
    "Este es un mensaje muy largo que se extiende "
    + "por múltiples líneas para mejor legibilidad "
    + "y mantenimiento del código."
)
```

## 🛡️ Buenas Prácticas

### Manejo de Errores

```gdscript
# ✅ Validación de parámetros
func take_damage(amount: int, source: Node = null) -> bool:
    if amount <= 0:
        push_warning("HealthComponent: Invalid damage amount: %d" % amount)
        return false

    if not is_alive:
        return false

    # Lógica de daño...

# ✅ Verificación de recursos
func load_player_data(file_path: String) -> Dictionary:
    if not FileAccess.file_exists(file_path):
        push_error("HealthComponent: Player data file not found: %s" % file_path)
        return {}

    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        push_error("HealthComponent: Could not open file: %s" % file_path)
        return {}

    # Cargar datos...
    file.close()
    return data

# ✅ Manejo de casos edge
func get_component(component_type: String) -> Component:
    if not owner_entity:
        push_warning("Component: No owner entity found")
        return null

    for child in owner_entity.get_children():
        if child is Component and child.component_id == component_type:
            return child

    return null
```

### Performance

```gdscript
# ✅ Cachear referencias costosas
@onready var player_body: CharacterBody2D = get_parent()
@onready var sprite: AnimatedSprite2D = $Sprite

# ✅ Evitar búsquedas en loops
func update_all_enemies():
    var enemies = get_tree().get_nodes_in_group("enemies")  # Cachear fuera del loop

    for enemy in enemies:
        update_enemy(enemy)

# ✅ Usar object pooling para objetos frecuentes
var bullet_pool: Array[Bullet] = []

func get_bullet() -> Bullet:
    if bullet_pool.is_empty():
        return Bullet.new()
    else:
        return bullet_pool.pop_back()

func return_bullet(bullet: Bullet):
    bullet.reset()
    bullet_pool.append(bullet)

# ✅ Optimizar procesamiento condicional
func _process(delta):
    if not enabled or not is_component_ready:
        return

    # Lógica de procesamiento...
```

### Memoria y Recursos

```gdscript
# ✅ Limpiar recursos en _exit_tree
func _exit_tree():
    if regeneration_timer:
        regeneration_timer.queue_free()

    # Desconectar señales
    if EventBus.player_died.is_connected(_on_player_died):
        EventBus.player_died.disconnect(_on_player_died)

# ✅ Evitar referencias circulares
# En lugar de:
# player.enemy_target = enemy
# enemy.player_target = player

# Usar:
# player.set_target(enemy)
# enemy.set_target(player)
# Y limpiar las referencias cuando sea necesario

# ✅ Usar WeakRef para referencias opcionales
var weak_target: WeakRef

func set_target(target: Node):
    weak_target = weakref(target)

func get_target() -> Node:
    if weak_target and weak_target.get_ref():
        return weak_target.get_ref()
    return null
```

## 🧪 Testing y Debugging

### Código Testeable

```gdscript
# ✅ Funciones puras cuando sea posible
func calculate_damage(base_damage: int, multiplier: float) -> int:
    return int(base_damage * multiplier)

# ✅ Dependency injection para testing
func initialize_with_services(audio_service: AudioService, config_service: ConfigService):
    _audio_service = audio_service
    _config_service = config_service

# ✅ Estado observable
func get_component_state() -> Dictionary:
    return {
        "component_id": component_id,
        "enabled": enabled,
        "ready": is_component_ready,
        "health": current_health,
        "max_health": max_health
    }
```

### Debug Helpers

```gdscript
# ✅ Métodos de debug específicos
func debug_info():
    print("=== %s DEBUG INFO ===" % component_id)
    print("Enabled: %s" % enabled)
    print("Ready: %s" % is_component_ready)
    print("Health: %d/%d" % [current_health, max_health])
    print("Alive: %s" % is_alive)
    print("========================")

# ✅ Debug condicional
func _debug_log(message: String):
    if OS.is_debug_build():
        print("[%s] %s" % [component_id, message])

# ✅ Asserts para validaciones en desarrollo
func take_damage(amount: int, source: Node = null) -> bool:
    assert(amount >= 0, "Damage amount must be non-negative")
    assert(max_health > 0, "Max health must be positive")

    # Lógica...
```

## 📝 Comentarios y Documentación

### Cuándo Comentar

```gdscript
# ✅ Comentar el "por qué", no el "qué"
# Pausar regeneración después de recibir daño para evitar
# que el jugador se cure inmediatamente durante combate
func _pause_regeneration():
    is_regenerating = false
    await get_tree().create_timer(1.0).timeout
    is_regenerating = true

# ✅ Explicar lógica compleja
# Usar interpolación cuadrática para suavizar el movimiento
# cuando el jugador cambia rápidamente de dirección
func smooth_direction_change(current_velocity: Vector2, target_velocity: Vector2, delta: float) -> Vector2:
    var smooth_factor = 1.0 - pow(0.01, delta)
    return current_velocity.lerp(target_velocity, smooth_factor)

# ❌ Comentarios obvios
# var health = 100  # Set health to 100
# if player_died:  # Check if player died
#     game_over()   # Call game over function
```

### TODOs y FIXMEs

```gdscript
# ✅ TODO: Implementar sistema de resistencias a tipos de daño
# TODO(fecha): Agregar efectos de partículas para regeneración - 2025-09-15
# FIXME: El timer de regeneración no se reinicia correctamente en algunas condiciones
# HACK: Workaround temporal para bug de Godot #12345 - remover cuando se arregle

# ❌ TODOs vagos
# TODO: Fix this
# TODO: Make better
```

## 🔧 Herramientas de Verificación

### Script de Verificación de Estilo

```bash
#!/bin/bash
# scripts/check_style.sh

echo "🎨 Checking code style..."

# Verificar nombres de archivos
find game/ -name "*.gd" | while read file; do
    filename=$(basename "$file" .gd)

    # Verificar PascalCase para componentes
    if [[ $file == *"components/"* ]] && [[ ! $filename =~ ^[A-Z][a-zA-Z]*Component$ ]]; then
        echo "❌ Component file should end with 'Component': $file"
    fi

    # Verificar PascalCase para servicios
    if [[ $file == *"services/"* ]] && [[ ! $filename =~ ^[A-Z][a-zA-Z]*Service$ ]]; then
        echo "❌ Service file should end with 'Service': $file"
    fi
done

# Verificar tabs vs spaces
find game/ -name "*.gd" -exec grep -l "^    " {} \; | while read file; do
    echo "⚠️  File uses spaces instead of tabs: $file"
done

# Verificar líneas largas
find game/ -name "*.gd" | while read file; do
    long_lines=$(awk 'length > 100 { print NR ": " $0 }' "$file")
    if [[ ! -z "$long_lines" ]]; then
        echo "⚠️  Long lines in $file:"
        echo "$long_lines"
    fi
done

echo "✅ Style check completed"
```

### Configuración de EditorConfig

```ini
# .editorconfig
root = true

[*.gd]
indent_style = tab
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
max_line_length = 100

[*.tscn]
indent_style = tab
indent_size = 4

[*.tres]
indent_style = tab
indent_size = 4

[*.md]
indent_style = space
indent_size = 2
trim_trailing_whitespace = false
```

---

**Los estándares de código son una inversión a largo plazo.** Código consistente y bien escrito es más fácil de mantener, debuggear y extender por todo el equipo.

**Recuerda**: Estos estándares evolucionan. Si encuentras casos donde las reglas no tienen sentido, propón cambios a través del proceso de contribución.

*Siguiente paso: [Contributing Guidelines](contributing.md)*

*Última actualización: Septiembre 7, 2025*
