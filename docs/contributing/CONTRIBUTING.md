# Guía de Contribución - Proyecto-Z

Gracias por tu interés en contribuir a **Proyecto-Z**. Esta guía explica cómo contribuir de manera efectiva al proyecto.

## 📋 **Tabla de Contenidos**

- [Código de Conducta](#código-de-conducta)
- [¿Cómo Contribuir?](#cómo-contribuir)
- [Configuración del Entorno](#configuración-del-entorno)
- [Workflow de Desarrollo](#workflow-de-desarrollo)
- [Convenciones de Código](#convenciones-de-código)
- [Proceso de Pull Request](#proceso-de-pull-request)
- [Reportar Bugs](#reportar-bugs)
- [Sugerir Características](#sugerir-características)
- [Preguntas Frecuentes](#preguntas-frecuentes)

## 📜 **Código de Conducta**

### Nuestros Compromisos

- **Respeto**: Tratamos a todos con respeto y consideración
- **Inclusión**: Acogemos a personas de todos los orígenes y niveles de experiencia
- **Colaboración**: Trabajamos juntos para crear el mejor proyecto posible
- **Constructividad**: Proporcionamos feedback constructivo y útil

### Comportamiento Esperado

- Usar lenguaje inclusivo y acogedor
- Respetar diferentes puntos de vista y experiencias
- Aceptar críticas constructivas con gracia
- Enfocarse en lo que es mejor para la comunidad
- Mostrar empatía hacia otros miembros de la comunidad

### Comportamiento Inaceptable

- Lenguaje o imágenes sexualizadas
- Trolling, comentarios insultantes o despectivos
- Acoso público o privado
- Publicar información privada de otros
- Cualquier conducta inapropiada en un entorno profesional

## 🚀 **¿Cómo Contribuir?**

### Tipos de Contribuciones

- 🐛 **Reportar Bugs**: Encontrar y reportar problemas
- ✨ **Nuevas Características**: Implementar funcionalidades
- 📚 **Documentación**: Mejorar guías y documentación
- 🧪 **Testing**: Probar y validar funcionalidades
- 🎨 **Assets**: Crear sprites, sonidos, música
- 🔧 **Herramientas**: Mejorar scripts de desarrollo

### Antes de Empezar

1. **Revisar Issues existentes** para evitar duplicados
2. **Leer la documentación** del proyecto
3. **Entender la arquitectura** de componentes
4. **Configurar el entorno** de desarrollo

## ⚙️ **Configuración del Entorno**

### Requisitos Previos

- **Godot Engine 4.4+** ([Descargar](https://godotengine.org/download))
- **Git** para control de versiones
- **Editor de código** (VS Code recomendado con extensión GDScript)
- **Sistema operativo**: Windows, Linux, macOS

### Configuración Inicial

```bash
# 1. Fork del repositorio en GitHub
# 2. Clonar tu fork
git clone https://github.com/1SSeba/Proyecto-Z.git
cd Proyecto-Z

# 3. Agregar upstream remote
git remote add upstream https://github.com/1SSeba/Proyecto-Z.git

# 4. Crear rama de desarrollo
git checkout -b develop
git push -u origin develop

# 5. Abrir en Godot
godot project.godot
```

### Verificación del Entorno

```bash
# Verificar que todo funciona
./tools/scripts/check_syntax.sh
./tools/scripts/test.sh

# Debería mostrar:
# ✅ ServiceManager: Initialized
# ✅ ConfigService: Ready
# ✅ AudioService: Ready
# ✅ InputService: Ready
```

## 🔄 **Workflow de Desarrollo**

### 1. Crear Nueva Funcionalidad

```bash
# 1. Sincronizar con upstream
git checkout develop
git pull upstream develop

# 2. Crear rama para feature
git checkout -b feature/nombre-descriptivo
# Ejemplos:
# feature/enemy-ai-system
# feature/inventory-component
# feature/audio-improvements

# 3. Desarrollar funcionalidad
# ... hacer cambios ...

# 4. Verificar cambios
./tools/scripts/check_syntax.sh
./tools/scripts/test.sh

# 5. Commit con convenciones
git add .
git commit -m "feat: añadir sistema de IA para enemigos"

# 6. Push y crear PR
git push origin feature/nombre-descriptivo
```

### 2. Corregir Bug

```bash
# 1. Crear rama para bugfix
git checkout -b bugfix/descripcion-del-bug

# 2. Implementar corrección
# ... hacer cambios ...

# 3. Verificar corrección
./tools/scripts/check_syntax.sh
./tools/scripts/test.sh

# 4. Commit
git add .
git commit -m "fix: corregir bug en sistema de movimiento"

# 5. Push y crear PR
git push origin bugfix/descripcion-del-bug
```

### 3. Mejorar Documentación

```bash
# 1. Crear rama para docs
git checkout -b docs/mejorar-guia-desarrollo

# 2. Actualizar documentación
# ... editar archivos .md ...

# 3. Verificar formato
./tools/scripts/check_docs.sh

# 4. Commit
git add .
git commit -m "docs: mejorar guía de desarrollo de componentes"

# 5. Push y crear PR
git push origin docs/mejorar-guia-desarrollo
```

## 📝 **Convenciones de Código**

### Naming Conventions

```gdscript
# Clases: PascalCase
class_name StateMachine
class_name GameStateManager

# Métodos y variables: snake_case
func transition_to(state_name: String):
func get_current_state() -> GameState:
var current_state: GameState
var is_initialized: bool

# Constantes: UPPER_SNAKE_CASE
const MAX_HEALTH: int = 100
const DEFAULT_SPEED: float = 150.0

# Señales: snake_case con contexto
signal state_changed(old_state, new_state)
signal player_spawned(player_node)
```

### Estructura de Archivos GDScript

```gdscript
# Template estándar para nuevos archivos:
# NombreClase.gd - Descripción breve
extends NodoBase

# ============================================================================
#  SEÑALES
# ============================================================================
signal mi_señal(parametro: Type)

# ============================================================================
#  CONSTANTES
# ============================================================================
const MI_CONSTANTE: int = 100

# ============================================================================
#  VARIABLES EXPORTADAS
# ============================================================================
@export var mi_variable: String = "default"

# ============================================================================
#  VARIABLES PRIVADAS
# ============================================================================
var _variable_privada: bool = false

# ============================================================================
#  INICIALIZACIÓN
# ============================================================================
func _ready():
    print("NombreClase: Initialization...")
    _setup()

# ============================================================================
#  MÉTODOS PÚBLICOS
# ============================================================================
func metodo_publico():
    pass

# ============================================================================
#  MÉTODOS PRIVADOS
# ============================================================================
func _setup():
    pass
```

### Convenciones de Commits

```bash
# Formato: tipo(scope): descripción
# Tipos: feat, fix, docs, style, refactor, test, chore

# Ejemplos:
feat(components): añadir HealthComponent con regeneración
fix(audio): corregir bug en AudioService pools
docs(architecture): actualizar documentación de EventBus
style(ui): mejorar espaciado en MainMenu
refactor(services): simplificar ServiceManager
test(components): añadir tests para MovementComponent
chore(deps): actualizar dependencias de desarrollo
```

### Manejo de Errores

```gdscript
# Siempre verificar dependencias
func _connect_to_manager():
    if not ManagerUtils.is_config_manager_available():
        print("ERROR: ConfigManager not available")
        return false

    var config_manager = ManagerUtils.get_config_manager()
    # ... resto del código

# Logging consistente
print("ManagerName: Mensaje informativo")
ManagerUtils.log_error("Mensaje de error")
ManagerUtils.log_success("Operación exitosa")
```

## 🔀 **Proceso de Pull Request**

### Antes de Crear PR

- [ ] **Código compila** sin errores
- [ ] **Tests pasan** correctamente
- [ ] **Documentación actualizada** si es necesario
- [ ] **Convenciones seguidas** (naming, estructura)
- [ ] **Commits descriptivos** con convenciones
- [ ] **Rama actualizada** con develop

### Crear Pull Request

1. **Ir a GitHub** y hacer clic en "New Pull Request"
2. **Seleccionar ramas**: `feature/tu-rama` → `develop`
3. **Título descriptivo**: "feat: añadir sistema de inventario"
4. **Descripción detallada**:
   ```markdown
   ## Descripción
   Añade sistema de inventario con componentes modulares

   ## Cambios Realizados
   - Creado InventoryComponent
   - Añadido ItemComponent
   - Integrado con EventBus
   - Añadidos tests unitarios

   ## Testing
   - [ ] Tests unitarios pasan
   - [ ] Tests de integración pasan
   - [ ] Probado en diferentes escenarios

   ## Screenshots (si aplica)
   [Añadir capturas de pantalla]
   ```

### Review Process

1. **Automático**: CI/CD verifica sintaxis y tests
2. **Manual**: Revisores verifican código y funcionalidad
3. **Feedback**: Se proporciona feedback constructivo
4. **Cambios**: Se realizan cambios si es necesario
5. **Aprobación**: Se aprueba cuando está listo
6. **Merge**: Se fusiona con develop

### Después del Merge

```bash
# 1. Sincronizar local
git checkout develop
git pull upstream develop

# 2. Limpiar rama local
git branch -d feature/tu-rama

# 3. Actualizar fork
git push origin develop
```

## 🐛 **Reportar Bugs**

### Antes de Reportar

1. **Buscar issues existentes** para evitar duplicados
2. **Verificar versión** de Godot y del proyecto
3. **Reproducir el bug** consistentemente
4. **Revisar documentación** y troubleshooting

### Template de Bug Report

```markdown
## Descripción del Bug
Descripción clara y concisa del problema.

## Pasos para Reproducir
1. Ir a '...'
2. Hacer clic en '...'
3. Ver error

## Comportamiento Esperado
Descripción de lo que debería pasar.

## Comportamiento Actual
Descripción de lo que realmente pasa.

## Screenshots
[Añadir capturas si es relevante]

## Información del Sistema
- OS: [ej. Windows 10, Ubuntu 20.04]
- Godot Version: [ej. 4.4.1]
- Project Version: [ej. v1.2.3]

## Logs
[Añadir logs relevantes de la consola]

## Contexto Adicional
Cualquier otra información relevante.
```

## ✨ **Sugerir Características**

### Antes de Sugerir

1. **Revisar roadmap** existente
2. **Verificar que no existe** ya
3. **Considerar arquitectura** del proyecto
4. **Pensar en implementación** práctica

### Template de Feature Request

```markdown
## Resumen de la Característica
Descripción clara de la funcionalidad deseada.

## Problema que Resuelve
¿Qué problema resuelve esta característica?

## Solución Propuesta
Descripción detallada de la solución.

## Alternativas Consideradas
Otras soluciones que consideraste.

## Impacto en la Arquitectura
Cómo afecta a la arquitectura existente.

## Casos de Uso
Ejemplos específicos de uso.

## Contexto Adicional
Cualquier otra información relevante.
```

## ❓ **Preguntas Frecuentes**

### ¿Cómo empiezo a contribuir?

1. **Fork** el repositorio
2. **Configura** el entorno de desarrollo
3. **Lee** la documentación
4. **Elige** un issue etiquetado como "good first issue"
5. **Crea** una rama y empieza a desarrollar

### ¿Qué tipo de contribuciones necesitas?

- **Código**: Nuevas funcionalidades, corrección de bugs
- **Documentación**: Mejorar guías, añadir ejemplos
- **Testing**: Escribir tests, probar funcionalidades
- **Assets**: Sprites, sonidos, música
- **Herramientas**: Scripts de desarrollo, automatización

### ¿Cómo elijo qué trabajar?

- **Issues etiquetados**: "good first issue", "help wanted"
- **Roadmap**: Características planificadas
- **Bugs**: Problemas reportados por usuarios
- **Mejoras**: Optimizaciones y refactoring

### ¿Qué pasa si no estoy seguro de algo?

- **Pregunta** en GitHub Discussions
- **Abre** un issue para discutir
- **Revisa** la documentación existente
- **Contacta** a los maintainers

### ¿Cómo mantengo mi fork actualizado?

```bash
# Sincronizar con upstream
git fetch upstream
git checkout develop
git merge upstream/develop
git push origin develop
```

## 📞 **Contacto y Soporte**

- **GitHub Issues**: Para bugs y feature requests
- **GitHub Discussions**: Para preguntas y discusiones
- **Email**: [tu-email@ejemplo.com]
- **Discord**: [Enlace al servidor si tienes]

## 🙏 **Agradecimientos**

¡Gracias a todos los contribuidores que hacen posible este proyecto!

---

*Última actualización: Diciembre 2024*
*Versión: 1.0.0*
