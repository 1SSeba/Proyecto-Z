# 📝 Changelog - Topdown Game

Todos los cambios notables del proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### 🔄 En Desarrollo
- Sistema de inventario básico
- Múltiples tipos de enemigos
- Sistema de mejoras/upgrades
- Boss battles

## [1.0.0] - 2025-08-22

### ✨ Añadido
- **Sistema de Estados Completo**: StateMachine profesional con estados Loading, MainMenu, Playing, Paused, RunComplete, RunFailed
- **Arquitectura de Managers**: Sistema modular con ConfigManager, InputManager, AudioManager, GameStateManager, GameManager, DebugManager
- **Generación Procedural de Mundo**: Sistema completo con chunks, biomas (Grass, Desert, Forest, Mountains, Water, Snow), y ruido FastNoiseLite
- **Sistema de Runs**: Tracking de tiempo, estadísticas persistentes, mejor tiempo, rachas
- **Debug Console**: Consola interactiva con comandos de desarrollo y testing (F3)
- **Sistema de Configuración**: Persistencia automática de settings de audio, video, controles y progreso
- **Event Bus**: Sistema de comunicación desacoplada entre componentes
- **Menús Completos**: MainMenu con settings embebidos, navegación por teclado
- **Sistema de Audio**: Gestión de música y efectos con control de volumen
- **Scripts de Desarrollo**: check_syntax.sh, clean_project.sh, quick_export.sh, dev.sh
- **Documentación Completa**: README formal, guías de desarrollo, troubleshooting

### 🔧 Técnico
- **Autoloads Optimizados**: Orden de carga correcto, inicialización asíncrona
- **ManagerUtils**: Utilidades centralizadas para acceso a managers
- **Error Handling**: Verificaciones robustas de dependencias
- **Performance**: Sistema de chunks para mundo optimizado
- **Testing**: Herramientas integradas de testing y benchmarking

### 🎮 Gameplay
- **Mundo Procedural**: 6 biomas diferentes con características únicas
- **Sistema de Chunks**: Carga dinámica optimizada para mundos grandes
- **Estadísticas Avanzadas**: Tracking completo de runs, tiempos, éxito
- **Controles Flexibles**: Soporte para WASD, flechas, gamepad (preparado)
- **Pausar/Reanudar**: Sistema robusto de pausa con estado preservado

## [0.3.0] - 2025-08-20

### ✨ Añadido
- Sistema básico de StateMachine
- Managers fundamentales (Config, Input, Audio)
- Estructura de proyecto organizada

### 🐛 Corregido
- Errores de inicialización de managers
- Problemas de orden de autoloads
- Transiciones de estado inconsistentes

### 📚 Documentación
- Estructura inicial de documentación
- Guías básicas de uso

## [0.2.0] - 2025-08-15

### ✨ Añadido
- Sistema de menús básico
- Configuración inicial de audio
- Estructura de escenas

### 🔧 Técnico
- Configuración de proyecto Godot 4.4
- Autoloads básicos
- Sistema de escenas modular

## [0.1.0] - 2025-08-10

### ✨ Añadido
- Configuración inicial del proyecto
- Estructura de directorios básica
- Assets placeholder
- Configuración de Git

---

## 🔍 Tipos de Cambios

- `✨ Añadido` - para nuevas funcionalidades
- `🔧 Cambiado` - para cambios en funcionalidades existentes
- `🐛 Corregido` - para bug fixes
- `🗑️ Removido` - para funcionalidades removidas
- `🔒 Seguridad` - para mejoras de seguridad
- `📚 Documentación` - para cambios solo en documentación
- `🎮 Gameplay` - para mejoras específicas de gameplay
- `⚡ Performance` - para mejoras de rendimiento

## 📋 Convenciones de Versionado

### Major (X.0.0)
- Cambios arquitecturales significativos
- Breaking changes en APIs públicas
- Nuevas mecánicas core del juego

### Minor (1.X.0)
- Nuevas funcionalidades compatibles
- Nuevos sistemas que no rompen existentes
- Mejoras significativas de UX

### Patch (1.0.X)
- Bug fixes
- Mejoras menores de performance
- Actualizaciones de documentación
- Tweaks de balance

## 🎯 Roadmap por Versiones

### v1.1.0 - Combate y Enemigos
- [ ] Sistema de combate básico
- [ ] AI de enemigos
- [ ] Sistema de daño y vida
- [ ] Efectos visuales de combate

### v1.2.0 - Inventario y Items
- [ ] Sistema de inventario
- [ ] Items y equipamiento
- [ ] Tienda básica
- [ ] Sistema de drop de items

### v1.3.0 - Progresión
- [ ] Sistema de niveles
- [ ] Habilidades y upgrades
- [ ] Árbol de progresión
- [ ] Unlockables

### v2.0.0 - Contenido Mayor
- [ ] Múltiples niveles/mundos
- [ ] Boss battles
- [ ] Historia/narrativa
- [ ] Sistema de achievements

---

*Para más detalles sobre cada versión, ver los commits y PRs asociados en GitHub.*