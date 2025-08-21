# Top-Down Game 🎮

Un juego top-down desarrollado en **Godot Engine 4.4** con una arquitectura modular y profesional.

[![Godot Engine](https://img.shields.io/badge/Godot-4.4-blue.svg)](https://godotengine.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/Docs-Complete-brightgreen.svg)](docs/)

## 🚀 Inicio rápido

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/1SSeba/topdown-game.git
   cd topdown-game
   ```

2. **Abre en Godot 4.4**
   - Ejecuta Godot Engine 4.4
   - Importa el proyecto usando `project.godot`

3. **Ejecuta el juego**
   - Presiona F5 o haz clic en "Play"
   - La escena principal se cargará automáticamente

## 🎯 Características principales

- **🏗️ Arquitectura modular** con sistema de managers
- **🔄 State Machine profesional** para gestión de estados
- **🎵 Sistema de audio** completo (música y efectos)
- **⚙️ Gestión de configuración** persistente
- **🐛 Herramientas de debug** integradas
- **📱 Sistema de input** flexible y configurable

## 🎮 Controles

- **ESC**: Pausar/reanudar, volver en menús
- **P**: Pausar/reanudar juego
- **M** (en pausa): Volver al menú principal
- **Enter**: Confirmar selecciones
- **WASD/Flechas**: Movimiento del jugador

## 📁 Estructura del proyecto

```
topdown-game/
├── docs/              # 📚 Documentación completa
├── Assets/            # 🎨 Recursos (sprites, audio, UI)
├── Autoload/          # 🔄 Sistemas globales (managers)
├── Core/              # 🏗️ Arquitectura central
│   ├── StateMachine/  # Sistema de estados
│   └── Events/        # Sistema de eventos
├── Scenes/            # 🎭 Escenas del juego
├── Scripts/           # 📜 Scripts auxiliares
└── UI/                # 🖥️ Interfaces de usuario
```

## 📚 Documentación

Toda la documentación está en la carpeta [`docs/`](docs/):

- 📋 [Índice de documentación](docs/README.md)
- 🏗️ [Estructura del proyecto](docs/PROJECT_STRUCTURE.md)
- 📊 [Estado del proyecto](docs/PROJECT_STATUS.md)
- 🔄 [Guía del State Machine](docs/STATEMACHINE_USAGE.md)

## 🛠️ Tecnologías utilizadas

- **Motor**: Godot Engine 4.4
- **Lenguaje**: GDScript
- **Arquitectura**: Modular con Autoload managers
- **Patrones**: State Machine, Event Bus, Singleton

## 🎮 Estados del juego

El juego utiliza un sistema de state machine con los siguientes estados:

- **🔄 LoadingState**: Carga inicial del juego
- **🏠 MainMenuState**: Menú principal y navegación
- **🎯 GameplayState**: Juego activo
- **⏸️ PausedState**: Juego pausado
- **⚙️ SettingsState**: Configuración del juego

## 🔧 Desarrollo

### Requisitos
- Godot Engine 4.4 o superior
- Conocimientos básicos de GDScript

### Arquitectura
El proyecto usa una arquitectura modular con:
- **Managers (Autoload)**: Sistemas globales
- **State Machine**: Control de flujo del juego
- **EventBus**: Comunicación entre componentes

### Extender el juego
1. **Nuevos estados**: Crea archivos en `Core/StateMachine/States/`
2. **Nuevos managers**: Añade a `Autoload/` y registra en project.godot
3. **Nuevas escenas**: Organiza en `Scenes/` por categoría

## 📈 Estado del proyecto

✅ **Sistema base completado**
- State Machine funcional
- Managers modulares operativos
- Documentación completa
- Sin errores de compilación

🔄 **En desarrollo**
- Mecánicas específicas del jugador
- Contenido de juego (niveles, enemigos)
- Assets definitivos

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. **Fork** el proyecto
2. **Crea una rama** para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. **Abre un Pull Request**

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👤 Autor

**1SSeba** - [GitHub](https://github.com/1SSeba)

---

⭐ **¡Dale una estrella al proyecto si te parece útil!**

*Última actualización: Agosto 2025*