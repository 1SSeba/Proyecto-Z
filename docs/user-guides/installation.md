````markdown
# Instalación y configuración

> Nota
>
> Este documento cubre instalación de usuarios y pasos para desarrolladores. Use Godot 4.4+ para el flujo de desarrollo.

## Índice

- Requisitos del sistema
- Instalación básica
- Configuración inicial
- Verificación de instalación
- Configuración avanzada
- Solución de problemas

---

## Requisitos del sistema

### Mínimos

- SO: Windows 10/11, Linux (Ubuntu 18.04+), macOS 10.14+
- RAM: 4 GB
- Almacenamiento: 500 MB libres
- GPU: OpenGL 3.3 / DirectX 11 compatible

### Recomendados

- SO: Windows 11, Linux (Ubuntu 22.04+), macOS 12+
- RAM: 8 GB o más
- Almacenamiento: 2 GB libres (para desarrollo)
- GPU: Dedicada con OpenGL 4.5+ / DirectX 12

### Para desarrollo

- Godot Engine 4.4+
- Git
- Editor de código (VS Code recomendado)

---

## Instalación básica

### Opción 1: Descarga directa (usuarios)

```bash
# Descargar release desde GitHub
wget https://github.com/1SSeba/topdown-game/releases/latest/download/topdown-game.zip

# Extraer
unzip topdown-game.zip
cd topdown-game

# Ejecutar (Linux)
chmod +x topdown-game
./topdown-game
```

### Opción 2: Compilar desde código (desarrolladores)

```bash
git clone https://github.com/1SSeba/topdown-game.git
cd topdown-game
godot project.godot
```

### Opción 3: Instalación automática (Linux)

```bash
curl -sSL https://raw.githubusercontent.com/1SSeba/topdown-game/master/install.sh | bash
```

---

## Configuración inicial

### Primera ejecución

Al ejecutar el juego por primera vez se crearán las carpetas de configuración y guardado en el directorio de usuario.

```ini
[audio]
master_volume=1.0
music_volume=0.8
sfx_volume=1.0

[video]
fullscreen=false
vsync_enabled=true
target_fps=60

[input]
mouse_sensitivity=1.0
keyboard_layout="QWERTY"
```

### Configuración manual

```bash
# Linux/macOS
nano ~/.local/share/godot/app_userdata/topdown-game/config.cfg

# Windows
notepad %APPDATA%\Godot\app_userdata\topdown-game\config.cfg
```

---

## Verificación de instalación

<details>
<summary>Comprobaciones básicas</summary>

```bash
# Verificar que el juego se ejecuta
./topdown-game --version

# Verificar logs
./topdown-game --verbose
tail -f ~/.local/share/godot/app_userdata/topdown-game/logs/latest.log
```

</details>

---

## Configuración avanzada

<details>
<summary>Opciones de video y audio (expandir)</summary>

```ini
[video]
screen_mode=0
screen_width=1920
screen_height=1080
ui_scale=1.0
render_quality="High"
msaa_quality=2

[audio]
master_volume=1.0
music_volume=0.8
sfx_volume=1.0
audio_buffer_size=1024
```

</details>

---

## Solución de problemas

- Verificar dependencias y permisos antes de ejecutar.
- Consultar logs en `~/.local/share/godot/app_userdata/topdown-game/logs/`.

> Aviso
>
> Si cambia rutas de archivos o nombres de singletons, actualice también la documentación y `project.godot`.

**Última actualización: Septiembre 4, 2025**

````

# Dispositivo de audio (vacío = predeterminado)
audio_device=""

# Buffer de audio (latencia)
audio_buffer_size=1024  # 512, 1024, 2048
```

### **Configuración de Input**
```ini
[input]
# Sensibilidad del mouse
mouse_sensitivity=1.0

# Layout de teclado
keyboard_layout="QWERTY"  # QWERTY, AZERTY, DVORAK

# Mapeo personalizado (avanzado)
custom_key_move_up="W"
custom_key_move_down="S"
custom_key_move_left="A"
custom_key_move_right="D"
custom_key_interact="E"
custom_key_pause="Escape"
```

### **Configuración de Desarrollo**
```ini
[debug]
# Modo debug (solo para desarrolladores)
debug_mode=false

# Mostrar FPS
show_fps=false

# Console de debug
debug_console_enabled=false

# Logs detallados
verbose_logging=false
```

---

## 🎮 **Configuración en Juego**

### **Menú de Settings**
Acceder desde el juego:
1. Menú Principal → Settings
2. O durante el juego: `ESC` → Settings

### **Opciones Disponibles**

#### **Audio**
- 🔊 **Volumen General**: Control del volumen maestro
- 🎵 **Música**: Volumen de música de fondo
- 🔔 **Efectos**: Volumen de sonidos del juego
- 🎧 **Dispositivo**: Selección de dispositivo de audio

#### **Video**
- 🖥️ **Modo Pantalla**: Ventana, Pantalla Completa, Sin Bordes
- 📐 **Resolución**: Resolución de pantalla
- 🎯 **V-Sync**: Sincronización vertical
- ⚡ **FPS Target**: Límite de frames por segundo

#### **Controles**
- ⌨️ **Mapeo de Teclas**: Personalizar controles
- 🖱️ **Sensibilidad Mouse**: Ajustar sensibilidad
- 🎮 **Gamepad**: Configuración de mando (si está disponible)

#### **Gameplay**
- ⏱️ **Mostrar Timer**: Mostrar tiempo de run
- 📊 **Mostrar Stats**: Estadísticas en pantalla
- 💫 **Efectos**: Partículas y efectos visuales

---

## 🛠️ **Solución de Problemas**

### **Problemas Comunes**

#### **El juego no inicia**
```bash
# Verificar dependencias (Linux)
ldd ./topdown-game

# Verificar permisos
chmod +x topdown-game

# Ejecutar con debug
./topdown-game --verbose --debug
```

#### **Sin audio**
1. Verificar que el dispositivo de audio funciona
2. Comprobar configuración en Settings → Audio
3. Reinstalar drivers de audio si es necesario

#### **Controles no responden**
1. Verificar que no hay conflictos con otros programas
2. Resetear controles en Settings → Input → Reset to Default
3. Verificar mapeo de teclas en configuración

#### **Performance baja**
1. Reducir calidad gráfica en Settings → Video
2. Desactivar efectos visuales
3. Cerrar otros programas que consuman recursos

### **Archivos de Log**
```bash
# Ubicación de logs
# Linux/macOS: ~/.local/share/godot/app_userdata/topdown-game/logs/
# Windows: %APPDATA%\Godot\app_userdata\topdown-game\logs\

# Ver logs recientes
tail -f ~/.local/share/godot/app_userdata/topdown-game/logs/latest.log

# Buscar errores específicos
grep "ERROR" ~/.local/share/godot/app_userdata/topdown-game/logs/latest.log
```

### **Reset Completo**
Si hay problemas persistentes:
```bash
# Backup de configuración actual
cp -r ~/.local/share/godot/app_userdata/topdown-game/ ~/topdown-game-backup/

# Eliminar configuración (regenerará defaults)
rm -rf ~/.local/share/godot/app_userdata/topdown-game/

# Relanzar juego (creará nueva configuración)
./topdown-game
```

---

## 📞 **Soporte**

### **Recursos de Ayuda**
- 📚 **[Troubleshooting Guide](troubleshooting.md)** - Solución de problemas específicos
- 🎮 **[Game Controls](game-controls.md)** - Guía de controles
- ⚙️ **[Settings Guide](settings-menu.md)** - Configuración detallada

### **Reportar Problemas**
1. **GitHub Issues**: [Reportar Bug](https://github.com/1SSeba/topdown-game/issues)
2. **Incluir información**:
   - Sistema operativo y versión
   - Especificaciones de hardware
   - Versión del juego
   - Pasos para reproducir el problema
   - Archivos de log relevantes

### **Información del Sistema**
```bash
# Generar reporte de sistema para soporte
./topdown-game --system-info > system-report.txt

# El archivo incluirá:
# - Versión del juego
# - Sistema operativo
# - Hardware detectado
# - Configuración actual
# - Logs de errores recientes
```

---

**💿 ¡Instalación completa y lista para jugar!**

*Última actualización: Septiembre 4, 2025*
