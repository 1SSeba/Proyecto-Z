# Contributing to Topdown Game

¡Gracias por tu interés en contribuir al proyecto! Este documento proporciona pautas para contribuir de manera efectiva.

## 🚀 Cómo Contribuir

### Reportar Bugs

1. **Verifica que el bug no haya sido reportado**: Busca en los issues existentes
2. **Crea un issue detallado** incluyendo:
   - Descripción clara del problema
   - Pasos para reproducir el bug
   - Comportamiento esperado vs comportamiento actual
   - Screenshots/videos si es apropiado
   - Información del sistema (OS, versión de Godot)

### Sugerir Features

1. **Verifica que la feature no exista**: Revisa la documentación y issues
2. **Crea un issue de feature request** con:
   - Descripción clara de la funcionalidad
   - Casos de uso
   - Posible implementación (opcional)
   - Mockups o diagramas si es relevante

### Pull Requests

1. **Fork el repositorio**
2. **Crea una rama desde `main`**: `git checkout -b feature/nombre-descriptivo`
3. **Desarrolla tu feature**:
   - Sigue las convenciones de código del proyecto
   - Añade comentarios donde sea necesario
   - Mantén commits pequeños y descriptivos
4. **Testea tu código**: Asegúrate de que funciona correctamente
5. **Actualiza documentación** si es necesario
6. **Crea el Pull Request**

## 📝 Convenciones de Código

### GDScript Style Guide

Seguimos las convenciones estándar de Godot:

```gdscript
# Variables en snake_case
var player_health: int = 100
var movement_speed: float = 150.0

# Constantes en UPPER_SNAKE_CASE
const MAX_HEALTH: int = 100
const PLAYER_SCENE = preload("res://scenes/Player.tscn")

# Funciones en snake_case
func handle_player_input():
    pass

# Funciones privadas con underscore
func _process_movement(delta: float):
    pass

# Señales en past tense
signal player_died
signal health_changed(new_health: int)
```

### Estructura de Archivos

```gdscript
extends Node

# =======================
#  SEÑALES
# =======================
signal example_signal

# =======================
#  CONSTANTES Y EXPORTS
# =======================
const EXAMPLE_CONSTANT = 100
@export var example_variable: int = 50

# =======================
#  VARIABLES PRIVADAS
# =======================
var private_variable: bool = false
@onready var node_reference: Node = $NodePath

# =======================
#  MÉTODOS BUILT-IN
# =======================
func _ready():
    pass

func _process(delta):
    pass

# =======================
#  MÉTODOS PÚBLICOS
# =======================
func public_method():
    pass

# =======================
#  MÉTODOS PRIVADOS
# =======================
func _private_method():
    pass

# =======================
#  SEÑALES/CALLBACKS
# =======================
func _on_signal_received():
    pass
```

### Comentarios

- Usa comentarios para explicar **por qué**, no **qué**
- Documenta funciones complejas
- Usa secciones con `# ===` para organizar código
- Inglés para código, español para documentación de usuario

```gdscript
# Calcula daño con bonificadores de crítico
# Retorna: daño final calculado
func calculate_damage(base_damage: float, is_critical: bool) -> float:
    var final_damage = base_damage
    
    # Aplicar crítico si procede (x1.5 daño)
    if is_critical:
        final_damage *= 1.5
    
    return final_damage
```

## 🏗️ Arquitectura del Proyecto

### Autoloads/Managers

Cada manager debe:
- Ser singleton via autoload
- Tener método `is_ready()` 
- Inicializarse de forma segura
- Proporcionar API clara y documentada
- Manejar cleanup en `_exit_tree()`

### Escenas

- Una responsabilidad por escena
- Usar composition sobre inheritance
- Nodes nombrados descriptivamente
- Señales bien definidas

### Scripts

- Un script por archivo
- Funciones pequeñas y enfocadas
- Evitar dependencias circulares
- Usar tipos explícitos cuando sea posible

## 🧪 Testing

### Debug Console

Usa el sistema de debug integrado:

```gdscript
# En cualquier script
func _test_feature():
    DebugManager.log_to_console("Testing feature X", "cyan")
    # ... test code ...
    DebugManager.log_success("Feature X works correctly")
```

### Verificaciones

Antes de hacer commit:

1. ✅ El juego arranca sin errores
2. ✅ No hay warnings críticos en la consola
3. ✅ Las funcionalidades básicas funcionan
4. ✅ No se rompe la navegación de menús
5. ✅ Los managers se inicializan correctamente

## 📋 Proceso de Review

### Para Reviewers

- ✅ Verificar que sigue las convenciones de código
- ✅ Testear la funcionalidad
- ✅ Revisar impacto en performance
- ✅ Verificar que no rompe funcionalidades existentes
- ✅ Comprobar que la documentación está actualizada

### Para Contributors

- 📝 Descripción clara del PR
- 🔗 Link al issue relacionado (si existe)
- 📸 Screenshots/videos si hay cambios visuales
- ✅ Checklist de verificaciones completado
- 🧪 Instrucciones para testear

## 🎯 Prioridades Actuales

1. **Sistema de combate**: Implementación de ataques y daño
2. **Enemigos**: AI básica y spawning
3. **Level design**: Herramientas para crear niveles
4. **Audio**: Integración completa del sistema de audio
5. **Save system**: Persistencia de progreso

## 🚫 Qué NO hacer

- ❌ Commits directos a `main`
- ❌ PRs masivos sin discusión previa
- ❌ Cambiar arquitectura sin consenso
- ❌ Remover funcionalidades sin deprecation
- ❌ Hardcodear valores sin constantes
- ❌ Ignorar los sistemas de managers existentes

## 💬 Comunicación

- **Issues**: Para bugs y feature requests
- **Discussions**: Para ideas y preguntas generales
- **PRs**: Para code reviews
- **Comments**: Para clarificaciones específicas

## 🏷️ Labels y Tags

### Issues
- `bug`: Errores en el código
- `enhancement`: Nuevas funcionalidades
- `documentation`: Mejoras en documentación
- `good first issue`: Ideal para nuevos contributors
- `help wanted`: Se necesita asistencia externa

### PRs
- `ready for review`: Listo para revisión
- `work in progress`: En desarrollo
- `needs testing`: Requiere testing adicional

¡Gracias por contribuir al proyecto! 🎮
