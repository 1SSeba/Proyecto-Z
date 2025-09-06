# 🎮 Mystic Dungeon Crawler

[![Godot](https://img.shields.io/badge/Godot-4.4+-blue.svg)](https://godotengine.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)

Un **roguelike top-down profesional** construido con **Godot 4.4** que presenta una **arquitectura modular basada en componentes**, servicios centralizados y patrones de diseño escalables.

## ✨ **Características Principales**

- 🧩 **Arquitectura de Componentes**: Sistema modular y reutilizable
- ⚙️ **Servicios Centralizados**: Funcionalidades globales bien organizadas
- 📡 **EventBus**: Comunicación desacoplada entre sistemas
- 🎯 **ServiceManager**: Coordinación profesional de servicios
- 📚 **Documentación Completa**: Guías de desarrollo y arquitectura
- 🧪 **Testing Integrado**: Pruebas y validación incorporadas
- 🚀 **Listo para Colaboración**: Workflow profesional de desarrollo

## 🏗️ **Arquitectura del Proyecto**

### **📁 Estructura Actual**

```
mystic-dungeon-crawler/
├── 📁 game/                    # 🎮 Código del Juego
│   ├── core/                   # 🏗️ Arquitectura Base
│   │   ├── components/         # 🧩 Sistema de Componentes
│   │   ├── services/           # ⚙️ Servicios Globales
│   │   ├── events/             # 📡 Sistema de Eventos
│   │   └── systems/            # 🔧 Sistemas del Juego
│   ├── entities/               # 👤 Entidades (Player, NPCs)
│   ├── scenes/                 # 🎭 Escenas del Juego
│   └── ui/                     # 🖥️ Interfaz de Usuario
├── 📁 docs/                    # 📚 Documentación
│   ├── architecture/           # 🏗️ Documentación Técnica
│   ├── development/            # 👨‍💻 Guías de Desarrollo
│   ├── user-guides/            # 👥 Guías de Usuario
│   └── api-reference/          # 📋 Referencia de API
├── 📁 tools/                   # 🛠️ Herramientas de Desarrollo
│   ├── scripts/                # 📜 Scripts de Automatización
│   └── utilities/              # 🔧 Utilidades
├── 📁 builds/                  # 🏗️ Builds del Proyecto
└── 📁 tests/                   # 🧪 Tests y Validaciones
```

### **🎯 Arquitectura Core**

#### **Sistema de Componentes**
- **Component**: Clase base para funcionalidades modulares
- **HealthComponent**: Manejo de salud y daño
- **MovementComponent**: Física y movimiento
- **MenuComponent**: Lógica de interfaces

#### **Servicios Centralizados**
- **ServiceManager**: Coordinador de todos los servicios
- **ConfigService**: Configuración persistente con validación
- **AudioService**: Gestión de audio con pools de reproductores
- **InputService**: Input buffering y contextos avanzados

#### **Comunicación**
- **EventBus**: Sistema de eventos desacoplado
- **Señales centralizadas**: Comunicación entre componentes
- **API consistente**: Interfaces claras entre sistemas

## 🚀 **Inicio Rápido**

### **Requisitos**
- **Godot Engine 4.4+** ([Descargar](https://godotengine.org/download))
- **Git** para control de versiones
- **Sistema operativo**: Windows, Linux, macOS

### **Instalación**

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU_USUARIO/mystic-dungeon-crawler.git
cd mystic-dungeon-crawler

# 2. Abrir en Godot
godot project.godot

# 3. Verificar inicialización
# Debería aparecer en consola:
# "ServiceManager: All services initialized successfully"
```

### **Desarrollo Rápido**

```bash
# Script de desarrollo con hot-reload
./tools/scripts/dev.sh

# Verificar sintaxis
./tools/scripts/check_syntax.sh

# Build rápido para testing
./tools/scripts/build.sh
```

## 🎮 **Características del Juego**

### **🧩 Sistema de Componentes**
- **Modularidad**: Cada componente tiene una responsabilidad específica
- **Reutilización**: Los componentes se pueden usar en múltiples entidades
- **Configuración**: Propiedades exportadas para fácil configuración
- **Comunicación**: EventBus para comunicación desacoplada

### **⚙️ Servicios Profesionales**
- **ConfigService**: Configuración persistente automática con validación
- **AudioService**: Gestión de audio con pools de reproductores
- **InputService**: Input buffering y contextos de entrada
- **ServiceManager**: Coordinación y lifecycle de servicios

### **🏰 Generación Procedural**
- **RoomsSystem**: Sistema de habitaciones y mazmorras
- **RoomGenerator**: Generación de salas con diferentes tipos
- **CorridorGenerator**: Conexión inteligente entre salas

## 📚 **Documentación**

### **🏗️ [Arquitectura](docs/architecture/)**
- **[Component Architecture](docs/architecture/component-architecture.md)** - Sistema de componentes modular
- **[Service Layer](docs/architecture/service-layer.md)** - Servicios centralizados
- **[Event System](docs/architecture/event-system.md)** - EventBus y comunicación
- **[Project Structure](docs/architecture/project-structure.md)** - Organización del proyecto

### **👨‍💻 [Desarrollo](docs/development/)**
- **[Getting Started](docs/development/getting-started.md)** - Primeros pasos
- **[Component Development](docs/development/component-development.md)** - Crear componentes
- **[Service Development](docs/development/service-development.md)** - Desarrollar servicios
- **[Testing Guide](docs/development/testing-guide.md)** - Pruebas y validación

### **👥 [Guías de Usuario](docs/user-guides/)**
- **[Installation](docs/user-guides/installation.md)** - Instalación completa
- **[Game Controls](docs/user-guides/game-controls.md)** - Controles del juego
- **[Settings Guide](docs/user-guides/settings-menu.md)** - Configuración
- **[Troubleshooting](docs/user-guides/troubleshooting.md)** - Solución de problemas

### **📋 [API Reference](docs/api-reference/)**
- **[Components API](docs/api-reference/components-api.md)** - API de componentes
- **[Services API](docs/api-reference/services-api.md)** - API de servicios
- **[EventBus API](docs/api-reference/eventbus-api.md)** - Sistema de eventos
- **[Utilities API](docs/api-reference/utilities-api.md)** - Utilidades

## 🧪 **Testing y Desarrollo**

### **Verificación de Arquitectura**
```bash
# Verificar que los servicios funcionan
godot --headless --script tools/scripts/verify_services.gd

# Resultado esperado:
# ✅ ServiceManager: Initialized
# ✅ ConfigService: Ready
# ✅ AudioService: Ready
# ✅ InputService: Ready
```

### **Debug Console (F3)**
Consola interactiva con comandos de desarrollo:
```bash
# Comandos de estado
help                    # Mostrar ayuda
status                  # Estado de managers
gamestate              # Estado actual del juego

# Comandos de testing
test_components        # Test de componentes
test_services          # Test de servicios
test_architecture      # Test de arquitectura
```

## 📊 **Especificaciones Técnicas**

| Característica | Implementación |
|----------------|----------------|
| **Motor** | Godot 4.4+ |
| **Arquitectura** | Componentes + Servicios |
| **Comunicación** | EventBus centralizado |
| **Configuración** | ConfigService persistente |
| **Audio** | AudioService con pools |
| **Input** | InputService con buffering |
| **Estados** | StateMachine profesional |
| **Testing** | Framework integrado |

## 🤝 **Contribuir**

¡Las contribuciones son bienvenidas! Ver [CONTRIBUTING.md](CONTRIBUTING.md) para guías detalladas.

### **Para Desarrolladores**
1. **Fork** el repositorio
2. **Leer** [Getting Started](docs/development/getting-started.md)
3. **Seguir** [Coding Standards](docs/development/coding-standards.md)
4. **Crear** feature branch: `git checkout -b feature/mi-funcionalidad`
5. **Probar** cambios con [Testing Guide](docs/development/testing-guide.md)
6. **Submit** pull request

### **Workflow de Desarrollo**
```bash
# 1. Crear rama para nueva funcionalidad
git checkout -b feature/nueva-funcionalidad

# 2. Desarrollar y probar
./tools/scripts/check_syntax.sh
./tools/scripts/test.sh

# 3. Commit con convenciones
git add .
git commit -m "feat: añadir nueva funcionalidad X"

# 4. Push y crear PR
git push origin feature/nueva-funcionalidad
```

### **Para Usuarios**
- **Reportar bugs** en [GitHub Issues](https://github.com/TU_USUARIO/mystic-dungeon-crawler/issues)
- **Sugerir features** siguiendo la arquitectura modular
- **Probar builds** de desarrollo y dar feedback
- **Contribuir** a la documentación

## 💡 **Ejemplos de Uso**

### **Crear Nueva Entidad**
```gdscript
# MyEnemy.gd
extends CharacterBody2D

func _ready():
    # Componentes básicos
    var health = HealthComponent.new()
    health.max_health = 75
    add_child(health)

    var movement = MovementComponent.new()
    movement.speed = 80.0
    add_child(movement)

    # Eventos
    EventBus.entity_spawned.emit(self)
```

### **Usar Servicios**
```gdscript
# Configuración
var config = ServiceManager.get_config_service()
config.set_master_volume(0.8)

# Audio
var audio = ServiceManager.get_audio_service()
audio.play_sfx("explosion")

# Input
var input_service = ServiceManager.get_input_service()
var movement = input_service.get_movement_vector()
```

### **Usar EventBus**
```gdscript
# Emitir eventos
EventBus.health_changed.emit(player, new_health)

# Escuchar eventos
func _ready():
    EventBus.health_changed.connect(_on_health_changed)

func _on_health_changed(entity: Node, health: int):
    print("Health changed: ", health)
```

## 🏆 **Estado del Proyecto**

### **✅ Implementado**
- 🧩 **Sistema de Componentes** completo y funcional
- ⚙️ **Servicios Centralizados** con ServiceManager
- 📡 **EventBus** para comunicación desacoplada
- 📚 **Documentación Completa** organizada por categorías
- 🎮 **MainMenu** funcional con arquitectura limpia
- 🔧 **ConfigService** con persistencia automática
- 🎵 **AudioService** con pools de reproductores
- 🛠️ **Herramientas de Desarrollo** integradas

### **🔄 En Desarrollo**
- 🏰 **Sistema de Salas** mejorado con componentes
- 👹 **EnemyComponent** para IA modular
- 🎒 **InventoryComponent** para items
- ⚔️ **CombatComponent** para peleas

### **📋 Roadmap**
- 🎯 **QuestComponent** para misiones
- 🏪 **ShopComponent** para comercio
- 🎨 **EffectsComponent** para partículas
- 🌍 **WorldComponent** para generación
- 🧪 **Testing Framework** completo
- 🚀 **CI/CD Pipeline** automatizado

## 📜 **Licencia**

Este proyecto está bajo la licencia especificada en [LICENSE](LICENSE).

## 👨‍💻 **Desarrollado por**

- **1SSeba** - [GitHub](https://github.com/1SSeba)
- **Arquitectura**: Componentes modulares profesionales
- **Principios**: Separation of Concerns, DRY, SOLID
- **Stack**: Godot 4.4 + GDScript + Arquitectura Modular

---

*🎮 Roguelike con arquitectura profesional y componentes modulares*
*📅 Actualizado: Diciembre 2024*
*🚀 Listo para desarrollo colaborativo*

## 📞 **Contacto y Soporte**

- **Repository**: [mystic-dungeon-crawler](https://github.com/TU_USUARIO/mystic-dungeon-crawler)
- **Issues**: [GitHub Issues](https://github.com/TU_USUARIO/mystic-dungeon-crawler/issues)
- **Discussions**: [GitHub Discussions](https://github.com/TU_USUARIO/mystic-dungeon-crawler/discussions)
- **Wiki**: [Project Wiki](https://github.com/TU_USUARIO/mystic-dungeon-crawler/wiki)
