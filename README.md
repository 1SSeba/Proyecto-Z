# Topdown Game

Un juego top-down desarrollado en Godot 4.4 con sistemas modulares y arquitectura escalable.

## 🚀 Quick Start

```bash
# Run the game in editor
./dev.sh run

# Check for errors
./dev.sh check

# Export for testing (requires export templates)
./dev.sh export
```

> **⚠️ Nota**: Las configuraciones de video no funcionan en el editor. Usa `./dev.sh export` para testearlas.

## 🎮 Descripción

Este es un juego de vista cenital (top-down) con elementos de roguelike, featuring:

- Sistema de jugador con movimiento fluido
- Sistema de salud y combate
- Sistema de habitaciones/salas
- Interfaz de usuario completa con menús
- Sistema de debug integrado
- Arquitectura modular con Autoloads

## 🚀 Características

### Jugabilidad
- Movimiento del jugador en 8 direcciones
- Sistema de salud con invulnerabilidad temporal
- Progresión por habitaciones
- Interfaz de usuario responsive

### Sistemas Técnicos
- **GameManager**: Gestión del estado del juego
- **InputManager**: Manejo centralizado de inputs
- **AudioManager**: Gestión de audio
- **ConfigManager**: Configuración del juego
- **DebugManager**: Sistema de debug con consola

### Interface
- Menú principal completo
- Menú de configuración con opciones de audio y video
- Sistemas de navegación intuitivos

## 🛠️ Requisitos

- **Godot 4.4** o superior
- Sistema operativo compatible con Godot (Windows, macOS, Linux)

## 📁 Estructura del Proyecto

```
topdown-game/
├── Assets/                 # Recursos del juego
│   ├── Audio/             # Música y efectos de sonido
│   ├── Characters/        # Sprites de personajes
│   │   └── Player/        # Animaciones del jugador
│   ├── Fonts/            # Fuentes tipográficas
│   ├── Icons/            # Iconos de UI
│   └── Ui/               # Elementos de interfaz
├── Autoload/             # Scripts de gestión global
│   ├── AudioManager.gd
│   ├── ConfigManager.gd
│   ├── DebugManager.gd
│   ├── GameManager.gd
│   ├── GameStateManager.gd
│   ├── InputManager.gd
│   └── ManagerUtils.gd
├── Scenes/               # Escenas del juego
│   ├── Characters/       # Personajes jugables
│   ├── Debug/           # Herramientas de debug
│   ├── MainMenu/        # Menús principales
│   └── Room/            # Habitaciones del juego
├── Scripts/             # Scripts auxiliares
├── UI/                  # Elementos de interfaz
└── Data/               # Datos del juego
```

## 🎯 Cómo Jugar

1. **Ejecutar el juego**: Abre el proyecto en Godot y presiona F5
2. **Navegación**: 
   - WASD o flechas del teclado para moverse
   - Espacio/Enter para interactuar
3. **Debug**: 
   - ` (tilde) para abrir la consola de debug
   - F1 para información rápida
   - F12 para toggle del modo debug

## 🔧 Instalación y Desarrollo

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/tu-usuario/topdown-game.git
   cd topdown-game
   ```

2. **Abrir en Godot**:
   - Abre Godot Engine
   - Importa el proyecto seleccionando el archivo `project.godot`
   - Espera a que Godot importe todos los assets

3. **Ejecutar**:
   - Presiona F5 o el botón "Play" en Godot
   - Selecciona la escena principal si es solicitado

## 🎨 Sistemas de Arte

### Animaciones del Jugador
- **Idle**: Estados de reposo en 4 direcciones
- **Run**: Animaciones de movimiento en 4 direcciones  
- **Attack1/Attack2**: Dos tipos de ataques en 4 direcciones

### Resoluciones Soportadas
- 960x540 (base)
- Escalado automático para diferentes resoluciones
- Soporte para pantalla completa y ventana

## 🔊 Audio

El juego incluye sistemas para:
- Música de fondo
- Efectos de sonido
- Control de volumen por categorías (Master, Music, SFX)

## 🐛 Debug y Desarrollo

### Consola de Debug
- Acceso con tecla ` (tilde)
- Comandos disponibles para testing
- Información en tiempo real del estado del juego

### Shortcuts de Debug
- `F1`: Estado rápido
- `F11`: Test rápido
- `F12`: Toggle modo debug

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 🎮 Estado del Desarrollo

- [x] Sistema básico de jugador
- [x] Managers fundamentales
- [x] Interfaz de usuario
- [x] Sistema de debug
- [ ] Sistema de combate completo
- [ ] Enemigos y AI
- [ ] Sistema de inventario
- [ ] Generación procedural de niveles
- [ ] Sistema de save/load

## 🔗 Enlaces

- [Godot Engine](https://godotengine.org/)
- [Documentación de Godot](https://docs.godotengine.org/)

---

**Nota**: Este proyecto está en desarrollo activo. Algunas características pueden estar incompletas o sujetas a cambios.
