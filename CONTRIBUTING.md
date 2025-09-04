# 🤝 Guía de Contribución - Topdown Game

¡Gracias por tu interés en contribuir al proyecto! Esta guía te ayudará a hacer contribuciones efectivas.

## 🚀 Inicio Rápido para Contribuidores

### 1. Fork y Setup
```bash
# Fork el repositorio en GitHub
# Luego clona tu fork:
git clone https://github.com/TU_USUARIO/topdown-game.git
cd topdown-game

# Configura el upstream:
git remote add upstream https://github.com/1SSeba/topdown-game.git

# Instala y configura:
godot project.godot
```

### 2. Desarrollo
```bash
# Crea una branch para tu feature:
git checkout -b feature/nombre-descriptivo

# Desarrolla siguiendo las convenciones del proyecto
# Ver DEVELOPMENT.md para detalles técnicos

# Verifica tu código:
./scripts/check_syntax.sh
./quick_export.sh  # Test básico
```

### 3. Pull Request
```bash
# Commit con mensajes descriptivos:
git add .
git commit -m "feat: añadir nueva mecánica de combate"

# Push a tu fork:
git push origin feature/nombre-descriptivo

# Crear Pull Request en GitHub
```

## 📋 Tipos de Contribuciones

### 🐛 Bug Reports
**Antes de reportar:**
- [ ] Busca en issues existentes
- [ ] Reproduce el bug consistentemente
- [ ] Verifica en la última versión

**Template de Bug Report:**
```markdown
**Bug Description:**
Descripción clara y concisa del bug.

**Steps to Reproduce:**
1. Ir a '...'
2. Hacer click en '...'
3. Ver error

**Expected Behavior:**
Lo que debería pasar.

**Actual Behavior:**
Lo que realmente pasa.

**Environment:**
- OS: [e.g. Ubuntu 22.04]
- Godot Version: [e.g. 4.4.1]
- Game Version: [e.g. v1.0.0]

**Console Output:**
```
Pegar logs relevantes aquí
```

**Additional Context:**
Screenshots, videos, o contexto adicional.
```

### 💡 Feature Requests
**Template de Feature Request:**
```markdown
**Feature Description:**
Descripción clara de la nueva funcionalidad.

**Use Case:**
¿Por qué es útil esta feature? ¿Qué problema resuelve?

**Proposed Implementation:**
Ideas sobre cómo implementarla (opcional).

**Alternatives Considered:**
Otras soluciones que consideraste.

**Additional Context:**
Mockups, ejemplos de otros juegos, etc.
```

### 🔧 Code Contributions

#### Areas Prioritarias
1. **Bug Fixes** - Siempre bienvenidos
2. **Performance Optimizations** - Especialmente en generación de mundo
3. **New Game Features** - Mecánicas de gameplay
4. **Documentation** - Mejoras a docs existentes
5. **Testing** - Unit tests y testing automatizado

#### Areas que Necesitan Aprobación
- Cambios arquitecturales mayores
- Nuevos sistemas de managers
- Modificaciones al StateMachine core
- Cambios de UI/UX significativos

## 🎯 Estándares de Código

### Convenciones de GDScript
```gdscript
# Clases: PascalCase
class_name MyNewClass

# Métodos y variables: snake_case
func my_function_name():
    var my_variable: int = 42

# Constantes: UPPER_SNAKE_CASE
const MAX_HEALTH: int = 100

# Señales: snake_case con contexto descriptivo
signal player_health_changed(new_health: int)
signal game_state_updated(old_state: GameState, new_state: GameState)
```

### Estructura de Archivos
```gdscript
# MyClass.gd - Descripción breve de la clase
extends BaseClass

# =======================
#  DOCUMENTACIÓN
# =======================
## Descripción detallada de la clase
## 
## Esta clase maneja [función principal]
## Uso típico:
## ```gdscript
## var instance = MyClass.new()
## instance.setup()
## ```

# =======================
#  SEÑALES
# =======================
signal my_signal(param: Type)

# =======================
#  CONSTANTES
# =======================
const DEFAULT_VALUE: int = 42

# =======================
#  VARIABLES EXPORTADAS
# =======================
@export var public_property: String = "default"

# =======================
#  VARIABLES PRIVADAS
# =======================
var _private_variable: bool = false

# =======================
#  INICIALIZACIÓN
# =======================
func _ready():
    print("MyClass: Initializing...")
    _setup()

# =======================
#  MÉTODOS PÚBLICOS
# =======================
func public_method() -> void:
    """Descripción del método público"""
    pass

# =======================
#  MÉTODOS PRIVADOS
# =======================
func _setup():
    """Configuración inicial privada"""
    pass
```

## 🧪 Testing

### Testing Manual Obligatorio
```bash
# 1. Verificar sintaxis
./scripts/check_syntax.sh

# 2. Test básico de funcionalidad
./quick_export.sh
./builds/debug/game_debug

# 3. Test de estados del juego
# En el juego:
# - Navegar por menús ✓
# - Iniciar gameplay ✓
# - Pausar/despausar ✓
# - Abrir settings ✓
# - Debug console (F3) ✓

# 4. Test específico de tu feature
# Documentar los pasos de testing en el PR
```

## 📝 Commit Guidelines

### Formato de Commits
Usamos [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Tipos de Commit
- `feat`: Nueva funcionalidad
- `fix`: Bug fix
- `docs`: Cambios en documentación
- `style`: Cambios de formato (no afectan funcionalidad)
- `refactor`: Refactoring de código
- `perf`: Mejoras de performance
- `test`: Añadir o modificar tests
- `chore`: Mantenimiento, builds, etc.

### Ejemplos
```bash
# Features
git commit -m "feat(world): añadir nuevo bioma volcánico"
git commit -m "feat(combat): implementar sistema de combate básico"

# Bug fixes
git commit -m "fix(statemachine): corregir transición de pause a gameplay"
git commit -m "fix(audio): resolver problema de volumen en música"

# Documentación
git commit -m "docs(readme): actualizar guía de instalación"
git commit -m "docs(development): añadir sección de testing"
```

## 🔄 Pull Request Process

### Antes del PR
- [ ] Branch desde `master` actualizado
- [ ] Código sigue convenciones del proyecto
- [ ] Testing manual completado
- [ ] No errores de sintaxis
- [ ] Documentación actualizada si es necesario

### Template de Pull Request
```markdown
## Description
Describe qué cambia este PR y por qué.

## Type of Change
- [ ] Bug fix (non-breaking change que arregla un issue)
- [ ] New feature (non-breaking change que añade funcionalidad)
- [ ] Breaking change (fix o feature que causa cambios incompatibles)
- [ ] Documentation update

## Testing
Describe las pruebas que realizaste:
- [ ] Testing manual básico
- [ ] Testing específico de la feature
- [ ] Performance testing (si aplica)
- [ ] Debug console testing

## Checklist
- [ ] Código sigue convenciones del proyecto
- [ ] Self-review completado
- [ ] Documentación actualizada
- [ ] No errores de sintaxis
- [ ] Testing completado
```

---

**¡Gracias por contribuir al proyecto! 🎮✨**

*Tu contribución hace que el juego sea mejor para todos.*