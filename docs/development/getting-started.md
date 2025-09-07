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

````markdown
# Getting Started — Primeros pasos

> Nota
>
> Este documento describe los pasos mínimos para poner en marcha Proyecto-Z en un entorno de desarrollo. Confirme la versión de Godot (4.4+) antes de proceder.

## Índice

- Configuración inicial
- Entendiendo la arquitectura
- Tu primer componente
- Usar servicios
- Comunicación con EventBus
- Próximos pasos

---

## Configuración inicial

### Requisitos

- Godot Engine 4.4+ (https://godotengine.org/download)
- Git
- Editor de código (VS Code recomendado)

### Clonar el proyecto

```bash
git clone https://github.com/1SSeba/topdown-game.git
cd topdown-game

# Abrir en Godot
godot project.godot
```

### Verificar configuración

1. Ejecutar el proyecto (F5).
2. Verificar autoloads en Project → Project Settings → Autoload.
3. Confirmar inicialización de servicios en la consola: `ServiceManager: All services initialized successfully`.

---

## Entendiendo la arquitectura

### Estructura del proyecto (resumen)

```
game/core/
├── components/
├── services/
├── events/
└── ServiceManager.gd

game/scenes/
├── menus/
└── characters/
```

### Conceptos clave

#### Componentes
Módulos independientes que añaden una responsabilidad única a una entidad (por ejemplo, `HealthComponent`).

#### Servicios
Singletons centralizados accesibles vía `ServiceManager`.

#### EventBus
Sistema de eventos global para comunicación desacoplada.

---

## Tu primer componente

<details>
<summary>Plantilla de componente (expandir)</summary>

```gdscript
# /game/core/components/ExampleComponent.gd
class_name ExampleComponent
extends Component

@export var example_value: int = 10
@export var example_text: String = "Hello World"

var internal_counter: int = 0

func initialize(entity: Node) -> void:
    EventBus.player_input.connect(_on_player_input)

func cleanup() -> void:
    if EventBus.player_input.is_connected(_on_player_input):
        EventBus.player_input.disconnect(_on_player_input)

func do_something() -> void:
    internal_counter += 1
    EventBus.entity_acted.emit(get_parent(), "example_action")

func _on_player_input(action: String) -> void:
    if action == "interact":
        do_something()
```

</details>

---

## Usar servicios

> Aviso
>
> Use siempre los getters de `ServiceManager` para acceder a servicios (p. ej. `ServiceManager.get_audio_service()`).

<details>
<summary>Ejemplo de uso de `ConfigService`</summary>

```gdscript
var config = ServiceManager.get_config_service()
var volume = config.get_master_volume()
config.set_master_volume(0.8)
EventBus.config_changed.connect(_on_config_changed)

func _on_config_changed(setting: String, value: Variant):
    print("Setting changed: ", setting, " = ", value)
```

</details>

---

## Comunicación con EventBus

<details>
<summary>Ejemplos de emisión y suscripción</summary>

```gdscript
EventBus.player_spawned.emit(player_node)
EventBus.health_changed.connect(_on_health_changed)

func _on_health_changed(entity: Node, health: int) -> void:
    if entity.is_in_group("player"):
        update_health_display(health)
```

</details>

---

## Próximos pasos

- Desarrollo de Componentes — `development/desarrollo-componentes.md`
- Components API — `../api-reference/api-componentes.md`
 - Desarrollo de Componentes — `development/desarrollo-componentes.md`
 - Components API — `../api-reference/api-componentes.md`
- Service Layer — `../architecture/service-layer.md`
- Event System — `../architecture/event-system.md`

---

**Última actualización: Septiembre 4, 2025**

````
