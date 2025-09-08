# 🗂️ Índice de Arquitectura - RougeLike Base

Esta sección contiene documentación detallada sobre la arquitectura técnica del proyecto, explicando los sistemas fundamentales que componen el juego.

## 📚 Documentos de Arquitectura

### 🎛️ [Sistema de State Machine](state-machine.md)
**Estado de máquinas y gestión de flujo del juego**

- **¿Qué es?** Sistema para gestionar diferentes estados del juego (Menú, Jugando, Pausado, etc.)
- **Componentes principales:**
  - `GameStateManager` - Controlador global de estados
  - `StateMachine` - Motor de transiciones
  - `State` - Clase base para estados específicos
- **Estados implementados:** MainMenu, Loading, Gameplay, Paused, GameOver, Settings
- **Casos de uso:** Flujo de navegación, transiciones entre escenas, gestión de pausa

### 🧩 [Sistema de Componentes](components-system.md)
**Arquitectura modular para entidades del juego**

- **¿Qué es?** Sistema que permite crear entidades complejas combinando componentes reutilizables
- **Componentes principales:**
  - `Component` - Clase base para todos los componentes
  - `HealthComponent` - Gestión de vida y daño
  - `MovementComponent` - Control de movimiento y física
  - `MenuComponent` - Gestión de interfaces de usuario
- **Ventajas:** Modularidad, reutilización, testing aislado, escalabilidad
- **Casos de uso:** Player, enemigos, NPCs, objetos interactivos

### 📦 [Sistema de Recursos (.res)](resources-system.md)
**Gestión centralizada de datos y configuraciones**

- **¿Qué es?** Sistema para organizar todos los datos del juego en archivos .res optimizados
- **Recursos principales:**
  - `GameConfig` - Configuraciones centrales del juego
  - `PlayerSprites` - Sprites organizados del jugador
  - `GameColors` - Paleta de colores centralizada
  - `WeaponConfig` - Configuraciones de armas
- **Ventajas:** Performance optimizada, datos tipados, referencias automáticas
- **Casos de uso:** Configuraciones, sprites, audio, balanceado del juego

## 🏗️ Diagrama de Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                     AUTOLOAD LAYER                          │
├─────────────────────────────────────────────────────────────┤
│ GameStateManager │ ServiceManager │ EventBus │ ResourceLoader │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    CORE SYSTEMS                             │
├─────────────────────────────────────────────────────────────┤
│              StateMachine              │    Component System │
│   ┌─────────────────────────────┐     │  ┌─────────────────┐ │
│   │ States/                     │     │  │ HealthComponent │ │
│   │ ├── MainMenuState           │     │  │ MovementComp    │ │
│   │ ├── LoadingState            │     │  │ MenuComponent   │ │
│   │ ├── GameplayState           │     │  │ AttackComponent │ │
│   │ ├── PausedState             │     │  │ ...             │ │
│   │ └── SettingsState           │     │  └─────────────────┘ │
│   └─────────────────────────────┘     │                     │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                   RESOURCE SYSTEM                           │
├─────────────────────────────────────────────────────────────┤
│ GameConfig │ PlayerSprites │ GameColors │ WeaponConfig │ ... │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                   GAME ENTITIES                             │
├─────────────────────────────────────────────────────────────┤
│    Player    │   Enemies   │    NPCs    │   Environment    │
│ + Components │ + Components │ + Components │  + Components   │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Flujo de Comunicación

### 1. **Inicialización del Sistema**
```
1. Autoloads se cargan (GameStateManager, ServiceManager, etc.)
2. ResourceLoader carga todos los recursos .res
3. ServiceManager inicializa servicios individuales
4. GameStateManager configura StateMachine
5. Transición al primer estado (MainMenuState)
```

### 2. **Creación de Entidades**
```
1. Instanciar entidad base (Player, Enemy, etc.)
2. Agregar componentes necesarios (Health, Movement, etc.)
3. Componentes se auto-registran con la entidad
4. Conectar señales entre componentes
5. Entidad lista para uso
```

### 3. **Gestión de Estados**
```
1. Evento dispara transición (ej: click "Start Game")
2. Estado actual ejecuta exit()
3. StateMachine cambia al nuevo estado
4. Nuevo estado ejecuta enter()
5. Estado gestiona input y lógica específica
```

## 📋 Principios de Diseño

### 1. **Separación de Responsabilidades**
- Cada sistema tiene una responsabilidad específica y bien definida
- Los componentes son independientes y pueden funcionar en aislamiento
- Estados manejan solo la lógica específica de ese estado

### 2. **Composición sobre Herencia**
- Las entidades se construyen combinando componentes
- Evita jerarquías de herencia profundas
- Facilita la reutilización y testing

### 3. **Comunicación Desacoplada**
- EventBus para comunicación global
- Señales para comunicación directa entre componentes
- Interfaces bien definidas entre sistemas

### 4. **Configuración Centralizada**
- Recursos .res contienen todas las configuraciones
- Fácil modificación sin tocar código
- Balanceado del juego centralizado

### 5. **Testabilidad**
- Cada componente puede testearse independientemente
- Dependencias inyectables para mocking
- Estados aislados permiten testing de flujos específicos

## 🎯 Casos de Uso Comunes

### Crear un Nuevo Tipo de Entidad

```gdscript
# 1. Crear la clase base
extends CharacterBody2D
class_name MiEntidad

# 2. Agregar componentes necesarios
func _ready():
    var health = HealthComponent.new()
    add_child(health)

    var movement = MovementComponent.new()
    add_child(movement)

# 3. Conectar lógica específica
    health.health_depleted.connect(_on_death)
```

### Agregar un Nuevo Estado

```gdscript
# 1. Crear clase del estado
extends State
class_name MiNuevoState

# 2. Implementar métodos requeridos
func enter(_previous_state: State = null):
    # Lógica de entrada

func exit():
    # Lógica de salida

# 3. Registrar en StateMachine
state_machine.add_state("MiNuevoState", mi_nuevo_state)
```

### Configurar Nuevo Tipo de Recurso

```gdscript
# 1. Crear clase del recurso
extends Resource
class_name MiConfig

@export var mi_propiedad: int = 100

# 2. Crear instancia .res en editor
# 3. Cargar en ResourceLoader
var mi_config = load("res://assets/mi_config.res")
```

## 🐛 Troubleshooting Común

### Estado no cambia
```gdscript
# Verificar que el estado esté registrado
print("Estados disponibles:", state_machine.get_state_list())

# Verificar transición válida
if state_machine.has_state("MiEstado"):
    state_machine.transition_to("MiEstado")
```

### Componente no funciona
```gdscript
# Verificar que esté agregado correctamente
var health = get_node("HealthComponent")
if health:
    print("HealthComponent encontrado")
else:
    print("HealthComponent NO encontrado")
```

### Recurso no carga
```gdscript
# Verificar que el archivo existe
if ResourceLoader.exists("res://mi_recurso.res"):
    var recurso = load("res://mi_recurso.res")
    if recurso:
        print("Recurso cargado correctamente")
```

## 🔗 Enlaces Relacionados

- **[Guía de Usuario](../user-guides/README.md)** - Cómo usar el juego
- **[Desarrollo](../development/README.md)** - Guías para desarrolladores
- **[API Reference](../api-reference/README.md)** - Documentación técnica de clases

---

Esta arquitectura proporciona una base sólida y escalable para el desarrollo del juego, facilitando el mantenimiento, testing y extensión de funcionalidades.

*Última actualización: Septiembre 7, 2025*
