# 🤝 Guía de Contribución - RougeLike Base

¡Gracias por tu interés en contribuir al proyecto RougeLike Base! Esta guía te ayudará a entender cómo puedes participar en el desarrollo de manera efectiva y alineada con nuestros estándares.

## 🎯 Tipos de Contribuciones

Aceptamos varios tipos de contribuciones:

### 📝 **Documentación**
- Corrección de errores tipográficos
- Mejoras en claridad y completitud
- Traducción de documentación
- Nuevos tutoriales y guías
- Ejemplos de código

### 🐛 **Reportes de Bugs**
- Problemas reproducibles
- Errores de performance
- Issues de compatibilidad
- Problemas de UX/UI

### ✨ **Nuevas Funcionalidades**
- Nuevos componentes
- Sistemas de gameplay
- Herramientas de desarrollo
- Mejoras de performance

### 🔧 **Mejoras Técnicas**
- Refactorización de código
- Optimizaciones
- Mejoras en arquitectura
- Tests adicionales

## 🚀 Proceso de Contribución

### 1. **Configuración Inicial**

```bash
# Fork el repositorio en GitHub
# Clonar tu fork
git clone https://github.com/TU_USUARIO/topdown-game.git
cd topdown-game

# Agregar el repositorio original como upstream
git remote add upstream https://github.com/USUARIO_ORIGINAL/topdown-game.git

# Verificar configuración
git remote -v
```

### 2. **Preparar Rama de Trabajo**

```bash
# Actualizar main desde upstream
git checkout main
git fetch upstream
git merge upstream/main

# Crear rama para tu contribución
git checkout -b feature/nombre-de-tu-feature
# o
git checkout -b bugfix/descripcion-del-bug
# o
git checkout -b docs/mejora-documentacion
```

### 3. **Desarrollo**

```bash
# Hacer cambios
# Seguir los estándares de código establecidos

# Testear cambios
godot --headless --script tests/run_tests.gd

# Verificar estilo de código
scripts/check_style.sh

# Verificar que el juego compile
godot --headless --export-debug "Linux/X11" builds/test/game_test
```

### 4. **Commit Guidelines**

#### Formato de Commit Messages

```
tipo(alcance): descripción breve

Descripción detallada opcional explicando el cambio,
por qué se hizo y qué problema resuelve.

Fixes #123
Closes #456
```

#### Tipos de Commit

```bash
# feat: Nueva funcionalidad
feat(player): agregar sistema de dash

# fix: Corrección de bug
fix(health): corregir regeneración automática

# docs: Cambios en documentación
docs(api): actualizar referencia de EventBus

# style: Cambios de formato (sin afectar lógica)
style(player): aplicar estándares de nomenclatura

# refactor: Refactorización de código
refactor(services): simplificar inicialización

# perf: Mejoras de performance
perf(rendering): optimizar culling de sprites

# test: Agregar o modificar tests
test(components): agregar tests para HealthComponent

# chore: Tareas de mantenimiento
chore(build): actualizar configuración de export

# ci: Cambios en CI/CD
ci(actions): agregar verificación automática de estilo
```

#### Ejemplos de Buenos Commits

```bash
git commit -m "feat(combat): implement weapon switching system

- Add WeaponComponent for managing multiple weapons
- Implement weapon switching with number keys 1-5
- Add weapon stats display in HUD
- Include sound effects for weapon switching

Fixes #45
Closes #67"

git commit -m "fix(player): resolve movement stuttering on direction change

The smooth_direction_change function was using incorrect interpolation
that caused visible stuttering when player rapidly changed directions.
Changed to use exponential decay interpolation for smoother movement.

Fixes #23"

git commit -m "docs(architecture): add component system overview

- Document component lifecycle
- Add interaction patterns between components
- Include code examples for common use cases
- Update architecture diagrams"
```

### 5. **Pull Request Process**

#### Antes de crear el PR

```bash
# Asegurar que tu rama está actualizada
git fetch upstream
git rebase upstream/main

# Verificar que todo funciona
godot --headless --script tests/run_tests.gd
scripts/check_style.sh

# Push a tu fork
git push origin feature/nombre-de-tu-feature
```

#### Crear Pull Request

1. **Ir a GitHub** y crear PR desde tu rama
2. **Título descriptivo**: Resumen claro del cambio
3. **Descripción detallada**: Usar la plantilla proporcionada

```markdown
## 📋 Tipo de Cambio
- [ ] 🐛 Bug fix (cambio que soluciona un problema)
- [ ] ✨ Nueva funcionalidad (cambio que agrega funcionalidad)
- [ ] 💥 Breaking change (cambio que rompe compatibilidad)
- [ ] 📝 Documentación

## 📝 Descripción
Descripción clara y concisa de los cambios realizados.

## 🧪 Testing
- [ ] Tests existentes pasan
- [ ] Agregué tests para nuevas funcionalidades
- [ ] Verifiqué manualmente en el editor

## 📋 Checklist
- [ ] Mi código sigue los estándares establecidos
- [ ] He revisado mi propio código
- [ ] He agregado comentarios en áreas complejas
- [ ] He actualizado la documentación correspondiente
- [ ] Mis cambios no generan nuevos warnings

## 🔗 Issues Relacionados
Fixes #(issue_number)
```

## 📋 Criterios de Aceptación

### ✅ **Requisitos Mínimos**

1. **Funcionalidad**
   - El código compila sin errores
   - La funcionalidad trabaja como se describe
   - No rompe funcionalidad existente

2. **Calidad de Código**
   - Sigue los estándares de código establecidos
   - Incluye comentarios donde es necesario
   - No tiene código muerto o debug

3. **Testing**
   - Incluye tests para nueva funcionalidad
   - Tests existentes siguen pasando
   - Ha sido probado manualmente

4. **Documentación**
   - Actualiza documentación relevante
   - Incluye ejemplos si es apropiado
   - Commits son claros y descriptivos

### 🎯 **Criterios de Calidad**

```gdscript
# ✅ Buen ejemplo de nueva funcionalidad
extends Component
class_name WeaponComponent

## Componente para gestionar múltiples armas del jugador.
##
## Permite cambiar entre diferentes armas, gestionar munición,
## y manejar estadísticas de cada arma.

signal weapon_changed(weapon: WeaponData)
signal ammo_changed(current: int, max: int)

@export var weapon_data: Array[WeaponData] = []
@export var starting_weapon_index: int = 0

var current_weapon_index: int = 0
var current_ammo: int = 0

func _ready():
    super()
    _initialize_component()

    if not weapon_data.is_empty():
        equip_weapon(starting_weapon_index)

## Equipar arma por índice.
##
## @param index: Índice del arma en el array weapon_data
## @return: true si se equipó exitosamente
func equip_weapon(index: int) -> bool:
    if index < 0 or index >= weapon_data.size():
        push_warning("WeaponComponent: Invalid weapon index: %d" % index)
        return false

    var old_weapon = get_current_weapon()
    current_weapon_index = index
    var new_weapon = get_current_weapon()

    if new_weapon:
        current_ammo = new_weapon.max_ammo
        weapon_changed.emit(new_weapon)
        ammo_changed.emit(current_ammo, new_weapon.max_ammo)

        _debug_log("Equipped weapon: %s" % new_weapon.name)
        return true

    return false

func get_current_weapon() -> WeaponData:
    if current_weapon_index >= 0 and current_weapon_index < weapon_data.size():
        return weapon_data[current_weapon_index]
    return null
```

## 🐛 Reportar Bugs

### Información Necesaria

Cuando reportes un bug, incluye:

```markdown
## 🐛 Descripción del Bug
Descripción clara y concisa del problema.

## 🔄 Pasos para Reproducir
1. Ir a '...'
2. Hacer click en '....'
3. Ejecutar comando '....'
4. Ver error

## ✅ Comportamiento Esperado
Descripción clara de lo que esperabas que pasara.

## ❌ Comportamiento Actual
Descripción clara de lo que realmente pasó.

## 📸 Screenshots/Videos
Si aplica, agrega screenshots o videos del problema.

## 🖥️ Información del Sistema
- OS: [e.g. Ubuntu 22.04, Windows 11, macOS 13]
- Godot Version: [e.g. 4.4.0]
- Project Version: [e.g. v1.2.0]
- Hardware: [e.g. RTX 3070, 16GB RAM]

## 📋 Información Adicional
Cualquier contexto adicional sobre el problema.

## 🔍 Logs
```
Pegar logs relevantes aquí
```
```

### Severidad de Bugs

- **🔥 Critical**: El juego crashea o es injugable
- **🚨 High**: Funcionalidad principal rota
- **⚠️ Medium**: Funcionalidad menor afectada
- **📝 Low**: Problemas cosméticos o de UX

## 💡 Sugerir Funcionalidades

### Plantilla para Nuevas Funcionalidades

```markdown
## 🎯 Funcionalidad Solicitada
Descripción clara y concisa de la funcionalidad deseada.

## 🤔 Problema que Resuelve
Explica qué problema resuelve o qué mejora proporciona.

## 💭 Solución Propuesta
Descripción clara de cómo implementarías la funcionalidad.

## 🔄 Alternativas Consideradas
Otras soluciones que consideraste.

## 📋 Información Adicional
Contexto adicional, mockups, referencias, etc.

## 🎮 Impacto en Gameplay
¿Cómo afectaría esta funcionalidad al gameplay actual?

## 🔧 Complejidad Técnica
- [ ] Simple (pocas horas)
- [ ] Moderada (pocos días)
- [ ] Compleja (semanas)
- [ ] No estoy seguro

## 📱 Plataformas Afectadas
- [ ] PC
- [ ] Mobile
- [ ] Web
- [ ] Todas
```

## 🔄 Proceso de Review

### Para Reviewers

1. **Verificar Funcionalidad**
   - ¿El código hace lo que dice hacer?
   - ¿Se integra bien con el sistema existente?
   - ¿Hay casos edge considerados?

2. **Verificar Calidad**
   - ¿Sigue los estándares de código?
   - ¿Es legible y mantenible?
   - ¿Hay documentación adecuada?

3. **Verificar Tests**
   - ¿Hay tests apropiados?
   - ¿Los tests son comprensivos?
   - ¿Tests existentes siguen pasando?

4. **Verificar Performance**
   - ¿Hay implicaciones de performance?
   - ¿Se optimizó apropiadamente?
   - ¿Se consideró el impacto en memoria?

### Feedback Constructivo

```markdown
# ✅ Buen feedback
"El sistema de armas se ve bien implementado! Algunas sugerencias:

1. Línea 45: Considera agregar validación de null para weapon_data antes de acceder
2. Función equip_weapon(): Sería útil retornar el arma anterior para casos donde necesites revertir
3. Performance: Podrías cachear get_current_weapon() en lugar de calcularlo cada vez

El diseño general es sólido y sigue bien nuestros patrones arquitectónicos."

# ❌ Feedback poco útil
"Este código no me gusta, cambialo."
"Muy complicado."
"No funciona en mi máquina."
```

## 🏷️ Labels y Organización

### Labels para Issues

- **🏷️ `type: bug`** - Reportes de bugs
- **🏷️ `type: feature`** - Nuevas funcionalidades
- **🏷️ `type: docs`** - Documentación
- **🏷️ `type: performance`** - Mejoras de performance
- **🏷️ `type: refactor`** - Refactorización

### Labels de Prioridad

- **🔥 `priority: critical`** - Debe arreglarse inmediatamente
- **🚨 `priority: high`** - Importante para próximo release
- **⚠️ `priority: medium`** - Importante pero no urgente
- **📝 `priority: low`** - Nice to have

### Labels de Estado

- **🏗️ `status: in-progress`** - Alguien está trabajando en esto
- **⏸️ `status: blocked`** - Bloqueado por otra issue
- **✅ `status: ready-for-review`** - Listo para review
- **❓ `status: needs-info`** - Necesita más información

### Labels de Área

- **🎮 `area: gameplay`** - Mecánicas de juego
- **🎨 `area: ui`** - Interfaz de usuario
- **🔊 `area: audio`** - Sistema de audio
- **⚡ `area: performance`** - Performance y optimización
- **🔧 `area: tools`** - Herramientas de desarrollo

## 🎉 Reconocimientos

### Proceso de Reconocimiento

1. **Contributors**: Listados en README.md
2. **Significant Contributions**: Mencionados en CHANGELOG.md
3. **Major Features**: Reconocimiento en release notes

### Tipos de Contribuciones Reconocidas

- **💻 Code**: Contribuciones de código
- **📖 Documentation**: Mejoras en documentación
- **🐛 Bug Reports**: Reportes de bugs útiles
- **💡 Ideas**: Sugerencias que se implementaron
- **📝 Translation**: Traducciones
- **🎨 Design**: Contribuciones de diseño/arte

## 📞 Contacto y Soporte

### Canales de Comunicación

- **🐛 Issues**: Para bugs y funcionalidades
- **💬 Discussions**: Para preguntas generales
- **📧 Email**: Para asuntos privados o de seguridad

### Código de Conducta

Esperamos que todos los contribuidores:

1. **Sean Respetuosos**: Trata a otros con respeto y cortesía
2. **Sean Colaborativos**: Trabaja en equipo hacia objetivos comunes
3. **Sean Constructivos**: Proporciona feedback útil y específico
4. **Sean Pacientes**: Entiende que todos tienen diferentes niveles de experiencia
5. **Sean Profesionales**: Mantén un ambiente de trabajo positivo

### Resolución de Conflictos

Si tienes problemas con:

1. **Technical Issues**: Abre una issue con detalles
2. **Process Issues**: Contacta maintainers directamente
3. **Interpersonal Issues**: Usa el proceso de código de conducta

---

**¡Gracias por contribuir!** Cada contribución, sin importar su tamaño, ayuda a hacer este proyecto mejor para toda la comunidad.

**Recuerda**: No tengas miedo de hacer preguntas. Todos fuimos principiantes alguna vez, y estamos aquí para ayudarte a tener éxito.

*Siguiente paso: [Testing Guidelines](testing.md)*

*Última actualización: Septiembre 7, 2025*
