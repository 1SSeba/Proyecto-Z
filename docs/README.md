# 📚 Documentación - RougeLike Base

![Version](https://img.shields.io/badge/version-pre--alpha__v0.0.1-orange)
![Godot](https://img.shields.io/badge/Godot-4.4-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Documentation](https://img.shields.io/badge/docs-complete-brightgreen)

Bienvenido a la documentación completa de **RougeLike Base**, un proyecto de videojuego top-down desarrollado en Godot 4.4 con una arquitectura modular profesional.

## 🎯 Visión General

**RougeLike Base** es una base técnica sólida para el desarrollo de juegos roguelike que implementa:

- **🏗️ Arquitectura Modular**: Sistema de componentes reutilizables
- **⚙️ Servicios Centralizados**: ServiceManager para audio, input, configuración
- **📡 Sistema de Eventos**: EventBus para comunicación desacoplada
- **🎮 Control de Estados**: GameStateManager para flujo del juego
- **🎨 Recursos Organizados**: Sistema optimizado de assets .res

## 📖 Navegación de la Documentación

### 🚀 **Para Comenzar**
- **[Guía de Inicio Rápido](user-guides/quick-start.md)** - Primeros pasos para nuevos desarrolladores

### 🏗️ **Arquitectura y Diseño**
- **[Arquitectura General](architecture/README.md)** - Vista general del sistema
- **[Sistema de State Machine](architecture/state-machine.md)** - Gestión de estados del juego
- **[Sistema de Componentes](architecture/components-system.md)** - Arquitectura modular de componentes
- **[Sistema de Recursos (.res)](architecture/resources-system.md)** - Gestión optimizada de datos

### 👨‍💻 **Desarrollo**
- **[Configuración de Desarrollo](development/setup.md)** - Environment de desarrollo
- **[Estándares de Código](development/coding-standards.md)** - Convenciones y mejores prácticas
- **[Flujo de Contribución](development/contributing.md)** - Cómo contribuir al proyecto
- **[Testing y QA](development/testing.md)** - Pruebas y calidad de código
- **[Tools de Desarrollo](development/tools.md)** - Herramientas y scripts disponibles

## 🎯 Estructura de la Documentación

```
docs/
├── README.md                          # Este archivo - índice principal
├── QUICK_REFERENCE.md                 # Referencia rápida de APIs
├── SCRIPT_DOCUMENTATION.md            # Documentación de scripts
├── USAGE_GUIDE.md                     # Guía general de uso
│
├── 🏗️ architecture/                   # Arquitectura y patrones
│   ├── overview.md                    # Vista general del sistema
│   ├── component-system.md            # Sistema de componentes
│   ├── service-layer.md               # Capa de servicios
│   ├── event-system.md                # Sistema de eventos
│   ├── state-management.md            # Gestión de estados
│   └── project-structure.md           # Estructura del proyecto
│
├── 👨‍💻 development/                    # Guías de desarrollo
│   ├── setup.md                       # Configuración de desarrollo
│   ├── coding-standards.md            # Estándares de código
│   ├── contributing.md                # Cómo contribuir
│   ├── testing.md                     # Testing y QA
│   └── tools.md                       # Herramientas de desarrollo
│
├── 📚 api-reference/                   # Referencia de APIs
│   ├── service-manager.md             # ServiceManager API
│   ├── event-bus.md                   # EventBus API
│   ├── components.md                  # Componentes disponibles
│   ├── player.md                      # Player API
│   └── config-service.md              # ConfigService API
│
├── 🎓 tutorials/                       # Tutoriales paso a paso
│   ├── creating-components.md         # Crear componentes
│   ├── adding-services.md             # Agregar servicios
│   ├── using-events.md                # Usar eventos
│   ├── managing-assets.md             # Gestión de assets
│   └── creating-scenes.md             # Crear escenas
│
├── 🔧 troubleshooting/                 # Solución de problemas
│   ├── common-issues.md               # Problemas comunes
│   ├── faq.md                         # Preguntas frecuentes
│   ├── debugging.md                   # Debug y profiling
│   └── error-handling.md              # Gestión de errores
│
└── 🎮 user-guides/                     # Guías para usuarios
    ├── installation.md                # Instalación y setup
    ├── quick-start.md                 # Inicio rápido
    ├── controls.md                    # Controles del juego
    ├── settings-menu.md               # Menú de configuraciones
    └── gameplay.md                    # Gameplay básico
```

## 🚀 Inicio Rápido

### Para Desarrolladores
1. **[Configurar el entorno](development/setup.md)** de desarrollo
2. **[Leer estándares](development/coding-standards.md)** de código
3. **[Explorar la arquitectura](architecture/overview.md)** del proyecto
4. **[Seguir tutoriales](tutorials/creating-components.md)** prácticos

### Para Usuarios
1. **[Instalar el juego](user-guides/installation.md)**
2. **[Aprender controles](user-guides/controls.md)**
3. **[Configurar settings](user-guides/settings-menu.md)**
4. **[Comenzar a jugar](user-guides/gameplay.md)**

## 🔍 Buscar en la Documentación

| Necesitas... | Ve a... |
|--------------|---------|
| **Instalar el proyecto** | [Installation Guide](user-guides/installation.md) |
| **Entender la arquitectura** | [Architecture Overview](architecture/overview.md) |
| **Agregar funcionalidad** | [Development Guides](development/) |
| **Usar una API específica** | [API Reference](api-reference/) |
| **Resolver un problema** | [Troubleshooting](troubleshooting/) |
| **Aprender con ejemplos** | [Tutorials](tutorials/) |

## 🎯 Versiones de la Documentación

| Versión del Proyecto | Documentación | Estado |
|---------------------|---------------|--------|
| **pre-alpha v0.0.1** | Esta versión | ✅ Actual |
| **v0.1.0** (planeada) | En desarrollo | 🔄 Pendiente |

## 📞 Soporte y Comunidad

- **🐛 Reportar Issues**: [GitHub Issues](https://github.com/1SSeba/Proyecto-Z/issues)
- **💬 Discusiones**: [GitHub Discussions](https://github.com/1SSeba/Proyecto-Z/discussions)
- **📧 Contacto**: Ver información en el README principal del proyecto

## 🤝 Contribuir a la Documentación

¿Encontraste un error o quieres mejorar la documentación?

1. **Fork** el repositorio
2. **Edita** los archivos en `docs/`
3. **Sigue** los [estándares de documentación](development/coding-standards.md#documentation)
4. **Envía** un Pull Request

## 📄 Licencia

Esta documentación está bajo la misma licencia **MIT** que el proyecto.

---

**🎮 ¡Explora la documentación y comienza a desarrollar con RougeLike Base!**

*Última actualización: Septiembre 7, 2025*
*Versión de la documentación: 1.0*
*Proyecto versión: pre-alpha v0.0.1*
