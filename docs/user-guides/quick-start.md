# ⚡ Guía de Inicio Rápido - RougeLike Base

¡Comienza a desarrollar con RougeLike Base en minutos! Esta guía te llevará desde la instalación hasta tu primer componente personalizado.

## 🎯 Objetivos de esta Guía

Al final de esta guía, habrás:
- ✅ Configurado el proyecto correctamente
- ✅ Ejecutado el juego y explorado sus características
- ✅ Entendido la arquitectura básica
- ✅ Creado tu primer componente personalizado
- ✅ Usado el sistema de eventos

## 🏃‍♂️ Setup Rápido (5 minutos)

### 1. Instalación Express
```bash
# Clonar y entrar al proyecto
git clone https://github.com/1SSeba/Proyecto-Z.git
cd Proyecto-Z/topdown-game

# Verificar que Godot está instalado
godot --version  # Debe ser 4.4+

# Importar y abrir proyecto
godot project.godot
```

### 2. Primera Ejecución
1. En Godot: Presiona **F5**
2. Selecciona `game/scenes/menus/MainMenu.tscn` si se pide
3. ¡El menú principal debería aparecer!

### 3. Verificación Rápida
- **Menú Principal**: Navegación con ratón/teclado ✅
- **[Configuraciones]**: Abre menú de settings ✅
- **[Comenzar Juego]**: Inicia gameplay ✅
- **Movimiento**: WASD mueve al personaje ✅

## 🏗️ Entendiendo la Arquitectura (10 minutos)

### Componentes Principales

#### 1. ServiceManager - El Centro de Control
```gdscript
# Acceso a servicios globales
var audio_service = ServiceManager.get_audio_service()
var config_service = ServiceManager.get_config_service()

# Verificar que servicios están listos
if ServiceManager.are_services_ready():
    print("¡Todos los servicios funcionando!")
```

#### 2. EventBus - Comunicación Global
```gdscript
# Emitir eventos
EventBus.audio_play_sfx.emit("jump_sound", 0.8)
EventBus.player_died.emit()

# Escuchar eventos
EventBus.player_died.connect(_on_player_died)

func _on_player_died():
    print("¡El jugador murió!")
```

#### 3. Component System - Funcionalidad Modular
```gdscript
# Los componentes añaden funcionalidad a entidades
extends Component
class_name MiComponente

func _initialize():
    component_id = "MiComponente"
    # Tu lógica aquí
```

### Flujo de Datos Básico
```
Input → InputService → Player → HealthComponent → EventBus → GameHUD
                                      ↓
                               AudioService → Sonidos
```

## 🎮 Explorando el Proyecto (15 minutos)

### Arquitectura de Carpetas
```
game/
├── core/           # 🏗️ Sistemas fundamentales
│   ├── ServiceManager.gd     # Gestor de servicios
│   ├── events/EventBus.gd    # Sistema de eventos
│   ├── components/           # Componentes reutilizables
│   └── services/            # Servicios globales
├── entities/       # 🎭 Entidades del juego
│   └── characters/Player.gd  # Personaje principal
├── scenes/         # 🎬 Escenas principales
│   ├── menus/              # Menús del juego
│   ├── gameplay/           # Escenas de juego
│   └── hud/               # Interfaces
└── assets/         # 🎨 Recursos (.res files)
```

### Sistemas en Acción

#### 1. Explorar el Player
```gdscript
# Abre: game/entities/characters/Player.gd
# Funcionalidades implementadas:
- Movimiento fluido con aceleración/fricción
- Animaciones direccionales automáticas
- Sistema de salud integrado
- Debug commands (F2=heal, F3=kill)
```

#### 2. Explorar los Menús
```gdscript
# MainMenu.gd - Menú principal
# SettingsMenu.gd - Configuraciones completas
# Navegación con teclado y ratón
```

#### 3. Sistema de Componentes
```gdscript
# HealthComponent.gd - Gestión de vida
# MovementComponent.gd - Control de movimiento
# MenuComponent.gd - Lógica de menús
```

## 🛠️ Tu Primer Componente (20 minutos)

Vamos a crear un componente de stamina para el jugador.

### 1. Crear el Archivo
Crea: `game/core/components/StaminaComponent.gd`

```gdscript
extends Component
class_name StaminaComponent

signal stamina_changed(current: float, maximum: float)
signal stamina_depleted()
signal stamina_regenerated()

@export var max_stamina: float = 100.0
@export var regeneration_rate: float = 10.0  # por segundo
@export var drain_rate: float = 20.0         # por acción

var current_stamina: float = 100.0
var is_regenerating: bool = true

func _initialize():
    component_id = "StaminaComponent"
    current_stamina = max_stamina
    _start_regeneration()

func _start_regeneration():
    # Regeneración automática cada segundo
    var timer = Timer.new()
    timer.wait_time = 0.1  # Actualizar cada 0.1s para suavidad
    timer.timeout.connect(_regenerate)
    add_child(timer)
    timer.start()

func _regenerate():
    if is_regenerating and current_stamina < max_stamina:
        var regen_amount = regeneration_rate * 0.1  # 0.1s intervals
        add_stamina(regen_amount)

func use_stamina(amount: float) -> bool:
    if current_stamina >= amount:
        current_stamina = max(0, current_stamina - amount)
        stamina_changed.emit(current_stamina, max_stamina)

        if current_stamina <= 0:
            stamina_depleted.emit()

        # Pausar regeneración brevemente después de usar
        _pause_regeneration()
        return true

    return false

func add_stamina(amount: float):
    var old_stamina = current_stamina
    current_stamina = min(max_stamina, current_stamina + amount)

    if current_stamina != old_stamina:
        stamina_changed.emit(current_stamina, max_stamina)

        if old_stamina <= 0 and current_stamina > 0:
            stamina_regenerated.emit()

func _pause_regeneration():
    is_regenerating = false
    await get_tree().create_timer(1.0).timeout  # Pausa 1 segundo
    is_regenerating = true

func get_stamina_percentage() -> float:
    return (current_stamina / max_stamina) * 100.0

func is_exhausted() -> bool:
    return current_stamina <= 0
```

### 2. Integrar con el Player
Modifica `game/entities/characters/Player.gd`:

```gdscript
# Agregar al inicio del archivo
@onready var stamina_component: StaminaComponent = null

# En la función _ready(), después de la inicialización:
func _ready():
    # ... código existente ...

    # Agregar componente de stamina
    stamina_component = StaminaComponent.new()
    add_child(stamina_component)

    # Conectar eventos
    stamina_component.stamina_depleted.connect(_on_stamina_depleted)
    stamina_component.stamina_changed.connect(_on_stamina_changed)

# Modificar _handle_movement para usar stamina al correr
func _handle_movement(delta):
    var input_vector = Vector2.ZERO

    # ... código de input existente ...

    if input_vector != Vector2.ZERO:
        # Usar stamina si está corriendo (por ejemplo, con shift)
        var is_running = Input.is_action_pressed("ui_accept")  # Temporalmente usar space

        if is_running and stamina_component and not stamina_component.is_exhausted():
            velocity = velocity.move_toward(input_vector * speed * 1.5, acceleration * delta)
            stamina_component.use_stamina(stamina_component.drain_rate * delta)
        else:
            velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

    move_and_slide()

# Handlers para stamina
func _on_stamina_depleted():
    print("¡Sin stamina! No puedes correr.")

func _on_stamina_changed(current: float, maximum: float):
    var percentage = (current / maximum) * 100.0
    print("Stamina: %.1f%%" % percentage)
```

### 3. Agregar al HUD
Modifica `game/scenes/hud/GameHUD.gd`:

```gdscript
# Agregar referencias al HUD
@onready var stamina_bar: ProgressBar = null  # Agregar si tienes UI
@onready var stamina_text: Label = null       # Agregar si tienes UI

# En _connect_to_player(), agregar:
func _connect_to_player():
    # ... código existente ...

    # Conectar stamina si el player lo tiene
    if player_reference.has_method("get_node"):
        var stamina_comp = player_reference.get_node("StaminaComponent")
        if stamina_comp and stamina_comp.has_signal("stamina_changed"):
            stamina_comp.stamina_changed.connect(_on_stamina_changed)

func _on_stamina_changed(current: float, max_stamina: float):
    add_log("Stamina: %.0f%%" % ((current / max_stamina) * 100))
```

### 4. Probar tu Componente
1. Ejecuta el juego (F5)
2. Ve al gameplay (Comenzar Juego)
3. Muévete con WASD normalmente
4. Mantén **Espacio** para correr más rápido
5. Observa los logs de stamina en el HUD

## 📡 Usando el Sistema de Eventos (15 minutos)

Vamos a hacer que el sistema de stamina use eventos.

### 1. Agregar Eventos al EventBus
Modifica `game/core/events/EventBus.gd`:

```gdscript
# Agregar al final del archivo, antes de las funciones:

# Stamina Events
signal stamina_changed(current: float, maximum: float)
signal stamina_depleted(entity: Node)
signal stamina_regenerated(entity: Node)
signal dash_attempted(entity: Node, has_stamina: bool)
```

### 2. Modificar StaminaComponent para usar EventBus
En tu `StaminaComponent.gd`:

```gdscript
# Modificar las funciones para emitir eventos globales:

func use_stamina(amount: float) -> bool:
    if current_stamina >= amount:
        current_stamina = max(0, current_stamina - amount)
        stamina_changed.emit(current_stamina, max_stamina)

        # Emitir evento global
        if EventBus:
            EventBus.stamina_changed.emit(current_stamina, max_stamina)

        if current_stamina <= 0:
            stamina_depleted.emit()
            if EventBus:
                EventBus.stamina_depleted.emit(get_entity())

        _pause_regeneration()
        return true

    return false

func add_stamina(amount: float):
    var old_stamina = current_stamina
    current_stamina = min(max_stamina, current_stamina + amount)

    if current_stamina != old_stamina:
        stamina_changed.emit(current_stamina, max_stamina)

        if EventBus:
            EventBus.stamina_changed.emit(current_stamina, max_stamina)

        if old_stamina <= 0 and current_stamina > 0:
            stamina_regenerated.emit()
            if EventBus:
                EventBus.stamina_regenerated.emit(get_entity())
```

### 3. Escuchar Eventos en otros Sistemas
Crea `game/systems/StaminaEffects.gd`:

```gdscript
extends Node

func _ready():
    # Esperar a que EventBus esté disponible
    await get_tree().process_frame

    if EventBus:
        EventBus.stamina_depleted.connect(_on_stamina_depleted)
        EventBus.stamina_regenerated.connect(_on_stamina_regenerated)

func _on_stamina_depleted(entity: Node):
    print("Sistema de Efectos: %s se quedó sin stamina" % entity.name)

    # Podrías agregar efectos visuales, sonidos, etc.
    if EventBus:
        EventBus.audio_play_sfx.emit("stamina_empty", 0.6)

func _on_stamina_regenerated(entity: Node):
    print("Sistema de Efectos: %s regeneró stamina" % entity.name)

    if EventBus:
        EventBus.audio_play_sfx.emit("stamina_full", 0.4)
```

## 🎯 Próximos Pasos

¡Felicidades! Ya has:
- ✅ Configurado el proyecto
- ✅ Entendido la arquitectura básica
- ✅ Creado tu primer componente
- ✅ Usado el sistema de eventos

### Continúa Aprendiendo

#### 📚 **Arquitectura Profunda**
- [Component System](../architecture/component-system.md) - Sistema de componentes completo
- [Service Layer](../architecture/service-layer.md) - Servicios y dependencias
- [Event System](../architecture/event-system.md) - Comunicación por eventos

#### 🎓 **Tutoriales Avanzados**
- [Adding Services](../tutorials/adding-services.md) - Crear servicios personalizados
- [Managing Assets](../tutorials/managing-assets.md) - Sistema de recursos .res
- [Creating Scenes](../tutorials/creating-scenes.md) - Nuevas escenas y UI

#### 👨‍💻 **Desarrollo**
- [Coding Standards](../development/coding-standards.md) - Estándares del proyecto
- [Contributing](../development/contributing.md) - Cómo contribuir
- [Testing](../development/testing.md) - Pruebas y QA

### Ideas para Experimentar

1. **Crear más componentes**:
   - `ManaComponent` - Sistema de magia
   - `InventoryComponent` - Inventario básico
   - `ExperienceComponent` - Sistema de XP

2. **Extender el stamina system**:
   - Efectos visuales cuando se agota
   - Diferentes tipos de acciones que consumen stamina
   - Buff/debuff que afecten la regeneración

3. **Agregar servicios**:
   - `ParticleService` - Efectos de partículas
   - `SaveService` - Sistema de guardado
   - `AnalyticsService` - Tracking de gameplay

## 🤝 Obtener Ayuda

### Recursos Útiles
- **📚 [Documentación Completa](../README.md)** - Índice de toda la documentación
- **🔧 [Troubleshooting](../troubleshooting/common-issues.md)** - Problemas comunes
- **❓ [FAQ](../troubleshooting/faq.md)** - Preguntas frecuentes

### Comunidad
- **🐛 [Issues](https://github.com/1SSeba/Proyecto-Z/issues)** - Reportar bugs
- **💬 [Discussions](https://github.com/1SSeba/Proyecto-Z/discussions)** - Preguntas y ayuda

---

**🎉 ¡Estás listo para desarrollar con RougeLike Base!**

Recuerda: La arquitectura modular te permite experimentar sin miedo. Cada componente es independiente, cada servicio es reutilizable, y el sistema de eventos mantiene todo conectado de forma limpia.

*¡Happy coding! 🚀*

*Última actualización: Septiembre 7, 2025*
