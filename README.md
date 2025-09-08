# 🎮 RougeLike Base - Juego Top-Down con Arquitectura Modular

![Version](https://img.shields.io/badge/version-pre--alpha__v0.0.1-orange)
![Godot](https://img.shields.io/badge/Godot-4.4-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 📖 Descripción

**RougeLike Base** es un proyecto de juego top-down desarrollado en Godot 4.4 que implementa una arquitectura modular robusta y escalable. El proyecto está diseñado como una base sólida para el desarrollo de juegos roguelike con un sistema de componentes reutilizables, gestión de servicios centralizados y un bus de eventos desacoplado.

### 🎯 Características Principales

- **🏗️ Arquitectura Modular**: Sistema de componentes reutilizables basado en composición
- **⚙️ Gestión de Servicios**: ServiceManager centralizado para audio, input, configuración y más
- **📡 Sistema de Eventos**: EventBus global para comunicación desacoplada
- **🎮 Control de Estados**: GameStateManager para transiciones fluidas entre estados del juego
- **🎨 Assets Organizados**: Sistema de recursos optimizado con carga dinámica
- **🔧 Herramientas de Desarrollo**: Tasks automatizados para build, testing y deployment

## 🚀 Instalación Rápida

### Prerrequisitos
- **Godot 4.4** o superior
- **Git** para control de versiones
- **Sistema Operativo**: Linux, Windows, macOS

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/1SSeba/Proyecto-Z.git
   cd topdown-game
   ```

2. **Abrir en Godot**
   - Abrir Godot 4.4
   - Hacer clic en "Import"
   - Seleccionar `project.godot`
   - Hacer clic en "Import & Edit"

3. **Verificar configuración**
   ```bash
   # Opcional: Verificar sintaxis de scripts
   ./scripts/check_syntax.sh
   ```

4. **Ejecutar el juego**
   - Presionar `F5` en Godot
   - O usar la task: `Run Game - Graphic Mode`

## 🎮 Controles

| Acción | Teclado | Gamepad |
|--------|---------|---------|
| **Movimiento** | WASD / Flechas | Stick Izquierdo |
| **Interactuar** | E / Espacio | Botón A |
| **Cancelar** | Escape | Botón B |
| **Debug Damage** | Enter | - |
| **Debug Heal** | F2 | - |
| **Debug Kill** | F3 | - |

## 🏗️ Arquitectura del Proyecto

### 📁 Estructura de Directorios

```
topdown-game/
├── 🎮 game/                          # Código del juego
│   ├── 🏗️ core/                      # Arquitectura base
│   │   ├── 🧩 components/             # Sistema de componentes
│   │   ├── ⚙️ services/               # Servicios globales
│   │   ├── 📡 events/                 # Sistema de eventos
│   │   └── 🔄 systems/                # Sistemas del juego
│   ├── 🎭 entities/                   # Entidades del juego
│   ├── 🎬 scenes/                     # Escenas principales
│   ├── 🎨 assets/                     # Recursos del juego
│   └── 🖥️ ui/                         # Interfaces de usuario
├── 📋 config/                         # Configuración del proyecto
├── 📚 docs/                           # Documentación
└── 🔧 scripts/                        # Herramientas de desarrollo
```

### 🧩 Sistema de Componentes

El proyecto utiliza un **patrón de componentes** donde cada funcionalidad está encapsulada en módulos independientes:

```gdscript
# Ejemplo: Crear una entidad Player
extends CharacterBody2D

func _ready():
    # Añadir componentes necesarios
    var health_comp = HealthComponent.new()
    health_comp.max_health = 100
    add_child(health_comp)

    var movement_comp = MovementComponent.new()
    movement_comp.speed = 150.0
    add_child(movement_comp)
```

**Componentes Disponibles:**
- `HealthComponent` - Gestión de vida y daño
- `MovementComponent` - Control de movimiento
- `MenuComponent` - Lógica de interfaces
- `Component` (base) - Clase base para componentes personalizados

### ⚙️ Gestión de Servicios

El `ServiceManager` centraliza todos los servicios globales:

```gdscript
# Acceso a servicios
var audio_service = ServiceManager.get_audio_service()
var input_service = ServiceManager.get_input_service()
var config_service = ServiceManager.get_config_service()

# Verificar disponibilidad
if ServiceManager.are_services_ready():
    # Todos los servicios están listos
```

**Servicios Disponibles:**
- `ConfigService` - Configuración global
- `AudioService` - Gestión de audio
- `InputService` - Gestión de input
- `TransitionService` - Transiciones de UI

### 📡 Sistema de Eventos

Comunicación desacoplada mediante `EventBus`:

```gdscript
# Emitir eventos
EventBus.audio_play_sfx.emit("sword_hit", 0.8)
EventBus.player_died.emit()
EventBus.room_entered.emit("room_001")

# Escuchar eventos
EventBus.player_died.connect(_on_player_died)
EventBus.health_changed.connect(_on_health_changed)
```

## 🔧 Herramientas de Desarrollo

### Tasks Disponibles

| Task | Descripción |
|------|-------------|
| `Quick Export Debug` | Exporta build de debug para Linux |
| `Run Game - Graphic Mode` | Ejecuta el juego en modo gráfico |
| `Test Game - Simple Settings` | Prueba rápida con configuración básica |

### Scripts de Desarrollo

```bash
# Verificar sintaxis de todos los scripts
./scripts/check_syntax.sh

# Limpiar archivos temporales
./scripts/clean_project.sh

# Export rápido para testing
./scripts/quick_export.sh
```

## 📚 Documentación

### 🎯 **Documentación Basada en Código Real**

- **[📖 Análisis de Código Real](docs/REAL_CODE_ANALYSIS.md)** - Documentación detallada de todos los scripts implementados
- **[🛠️ Guía Práctica](docs/PRACTICAL_GUIDE.md)** - Cómo usar los sistemas existentes con ejemplos reales
- **[📋 Documentación Completa](docs/README_DOCS.md)** - Índice de toda la documentación del proyecto

### 📁 **Documentación Adicional**

- **[🏗️ Arquitectura de Componentes](docs/architecture/component-architecture.md)** - Guía detallada del sistema de componentes
- **[⚙️ Sistema de Servicios](docs/architecture/service-layer.md)** - ServiceManager y servicios disponibles
- **[📡 Sistema de Eventos](docs/architecture/event-system.md)** - EventBus y patrones de comunicación
- **[📂 Estructura del Proyecto](docs/architecture/project-structure.md)** - Organización de archivos y directorios
- **[🛠️ Guía de Desarrollo](docs/development/DEVELOPMENT.md)** - Setup y mejores prácticas
- **[🎨 Gestión de Recursos](game/assets/README_RESOURCES.md)** - Documentación de assets y recursos

## 🎯 Características Implementadas

### ✅ Core Systems
- [x] Sistema de componentes modular
- [x] ServiceManager con dependency injection
- [x] EventBus para comunicación desacoplada
- [x] GameStateManager para control de estados
- [x] Sistema de configuración persistente

### ✅ Gameplay
- [x] Personaje jugador con animaciones
- [x] Sistema de movimiento fluido
- [x] Sistema de salud y daño
- [x] Controles configurables (WASD/Flechas)
- [x] Debug tools integradas

### ✅ UI/UX
- [x] Menú principal
- [x] Menú de configuraciones
- [x] Transiciones suaves
- [x] Gestión de temas y estilos

### ✅ Technical
- [x] Autoloads optimizados
- [x] Error handling robusto
- [x] Sistema de logging
- [x] Tools de desarrollo integradas

## 🔮 Roadmap

### v0.1.0 - Sistema de Combate
- [ ] Sistema de armas básico
- [ ] Enemigos con IA simple
- [ ] Efectos visuales de combate
- [ ] Sistema de colisiones de combate

### v0.2.0 - Mundo Procedural
- [ ] Generación de habitaciones
- [ ] Sistema de conectores/puertas
- [ ] Spawn points para enemigos
- [ ] Objetivos por habitación

### v0.3.0 - Inventario y Items
- [ ] Sistema de inventario
- [ ] Items equipables
- [ ] Drop system
- [ ] Estadísticas de items

### v0.4.0 - Progresión
- [ ] Sistema de experiencia
- [ ] Skill tree básico
- [ ] Unlockables
- [ ] Achievement system

## 🤝 Contribuir al Proyecto

### Setup para Desarrolladores

1. **Fork del repositorio**
2. **Clonar tu fork**
   ```bash
   git clone https://github.com/tu-usuario/Proyecto-Z.git
   cd topdown-game
   ```
3. **Crear branch para feature**
   ```bash
   git checkout -b feature/mi-nueva-feature
   ```
4. **Verificar código antes de commit**
   ```bash
   ./scripts/check_syntax.sh
   ```

### Estándares de Código

- **Nomenclatura**: PascalCase para clases, snake_case para variables
- **Documentación**: Todos los métodos públicos deben estar documentados
- **Testing**: Incluir tests para nuevas funcionalidades
- **Commits**: Usar conventional commits (feat:, fix:, docs:, etc.)

### Arquitectura de Contribuciones

- **Core Components** → Cambios requieren review extenso
- **Game Systems** → Nuevos sistemas welcome
- **UI/UX** → Mejoras de usabilidad prioritarias
- **Documentation** → Siempre bienvenida

## 📄 Licencia

Este proyecto está bajo la **Licencia MIT**. Ver [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- **Godot Community** por el excelente motor de juego
- **Contributors** que han aportado al proyecto
- **1SSeba** por la arquitectura base y visión del proyecto

## 📞 Contacto

- **Repositorio**: [GitHub](https://github.com/1SSeba/Proyecto-Z)
- **Issues**: [GitHub Issues](https://github.com/1SSeba/Proyecto-Z/issues)
- **Discusiones**: [GitHub Discussions](https://github.com/1SSeba/Proyecto-Z/discussions)

---

**🚀 ¡Comienza a desarrollar tu roguelike con una base sólida y profesional!**

*Última actualización: Septiembre 6, 2025*
