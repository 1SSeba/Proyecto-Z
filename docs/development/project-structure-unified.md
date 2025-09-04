# Estructura del Proyecto - Nueva Versión Unificada

## Estructura Principal Simplificada

```
topdown-game/
├── game/                           # TODO el código y assets del juego unificado
│   ├── core/                       # Sistema central
│   │   ├── components/            # Componentes del sistema ECS
│   │   ├── events/                # Sistema de eventos
│   │   ├── services/              # Servicios centrales
│   │   └── systems/               # Sistemas de juego
│   ├── scenes/                    # Escenas principales
│   ├── characters/                # Personajes y entidades
│   ├── world/                     # Mundo y generación
│   ├── ui/                        # Interfaces de usuario
│   └── assets/                    # Assets (sprites, sonidos, etc.)
├── docs/                          # Documentación
├── tools/                         # Herramientas de desarrollo
├── builds/                        # Compilaciones
└── config/                        # Configuración del proyecto
```

## ¿Por qué la Nueva Estructura?

### Problema Anterior ❌
- `src/` para código + `content/` para assets = **confuso**
- Separación artificial que no ayudaba
- Difícil de navegar y entender el propósito

### Solución Actual ✅
- `game/` contiene **todo** lo relacionado con el juego
- Organización por **funcionalidad**, no por tipo de archivo
- Más **intuitivo** y fácil de usar

## Directorios del Juego

### `/game/core/` - Sistema Central
El corazón del juego con arquitectura modular:

```
core/
├── components/          # Componentes ECS reutilizables
│   ├── Component.gd     # Clase base de componentes
│   ├── HealthComponent.gd
│   ├── MovementComponent.gd
│   └── MenuComponent.gd
├── events/              # Sistema de comunicación global
│   └── EventBus.gd      # Bus de eventos central
├── services/            # Servicios centrales del juego
│   ├── BaseService.gd   # Clase base para servicios
│   ├── ConfigService.gd # Gestión de configuración
│   ├── InputService.gd  # Gestión de entrada
│   ├── AudioService.gd  # Gestión de audio
│   └── GameService.gd   # Lógica central del juego
├── systems/             # Sistemas especializados
│   ├── StateMachine/    # Máquina de estados
│   ├── *Generator.gd    # Generadores de mundo
│   └── optimization/    # Sistemas de optimización
└── ServiceManager.gd    # Coordinador de servicios
```

### `/game/scenes/` - Escenas Principales
```
scenes/
└── Main.tscn/Main.gd    # Escena coordinadora principal
```

### `/game/characters/` - Personajes
```
characters/
└── Player.tscn/Player.gd  # Jugador principal
```

### `/game/world/` - Sistema de Mundo
```
world/
├── World.gd               # Controlador del mundo
├── WorldGenerator.gd      # Generador base
├── RoomBasedWorldGenerator.gd  # Generador de habitaciones
└── world.tscn            # Escena del mundo
```

### `/game/ui/` - Interfaces de Usuario
```
ui/
├── MainMenu.tscn/MainMenu.gd           # Menú principal básico
├── MainMenuModular.tscn/MainMenuModular.gd  # Menú modular
└── SettingsPanelModular.gd            # Panel de configuraciones
```

### `/game/assets/` - Recursos del Juego
```
assets/
├── Audio/               # Música y efectos de sonido
├── Characters/          # Sprites de personajes
│   └── Player/         # Sprites del jugador (idle, run, etc.)
├── Maps/               # Tiles y mapas
└── UI/                 # Elementos de interfaz
```

## Autoloads Configurados

### Configuración Actual en `project.godot`:
```ini
[autoload]
EventBus="*res://game/core/events/EventBus.gd"
ServiceManager="*res://game/core/ServiceManager.gd"
GameStateManager="*res://src/managers/GameStateManager.gd"  # TODO: Migrar
```

### EventBus
- Sistema de comunicación global por eventos
- Permite comunicación desacoplada entre sistemas

### ServiceManager
Gestor central que coordina todos los servicios:
- **ConfigService**: Configuración del juego
- **InputService**: Gestión de entrada de usuario
- **AudioService**: Sistema de audio completo
- **GameService**: Lógica central del juego

### GameStateManager
- Gestión de estados del juego con StateMachine
- **TODO**: Migrar a `res://game/core/systems/`

## Migración en Progreso

### ✅ Completado
- [x] Nueva estructura `/game/` creada
- [x] Servicios migrados y funcionando
- [x] Escenas principales actualizadas
- [x] Referencias de archivos corregidas
- [x] System compilation working

### 🔄 En Progreso
- [ ] Migrar GameStateManager a nueva estructura
- [ ] Completar migración de Debug tools
- [ ] Limpiar estructura anterior (`src/`, `content/`)

### 📋 Próximos Pasos
1. Finalizar migración de GameStateManager
2. Mover herramientas de debug a `/game/core/debug/`
3. Eliminar directorios antiguos
4. Actualizar autoloads finales
5. Probar compilación completa

## Ventajas de la Nueva Estructura

### 🎯 Simplicidad
- Un solo directorio `game/` para todo
- Organización por funcionalidad
- Más fácil de entender para nuevos desarrolladores

### 🔧 Mantenibilidad
- Relacionado está junto
- Fácil refactoring
- Referencias más claras

### 📈 Escalabilidad
- Fácil agregar nuevas funcionalidades
- Estructura modular preparada para crecimiento
- Separación clara de responsabilidades

## Convenciones de Archivos

### Nomenclatura
- **Archivos de clases**: `PascalCase.gd` (ej: `PlayerController.gd`)
- **Archivos de servicios**: `NombreService.gd` (ej: `AudioService.gd`)
- **Archivos de escenas**: `snake_case.tscn` (ej: `main_menu.tscn`)
- **Directorios**: `lowercase` o `PascalCase` según contexto

### Organización
- Scripts de escenas junto a sus `.tscn`
- Componentes agrupados por funcionalidad
- Assets organizados por tipo y uso

Esta nueva estructura elimina la confusión de la separación `src/`/`content/` y proporciona una organización más intuitiva y mantenible.
