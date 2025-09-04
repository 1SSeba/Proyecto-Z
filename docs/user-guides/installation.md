# 💿 Instalación y Configuración

## 📋 **Índice**
- [Requisitos del Sistema](#requisitos-del-sistema)
- [Instalación Básica](#instalación-básica)
- [Configuración Inicial](#configuración-inicial)
- [Verificación de Instalación](#verificación-de-instalación)
- [Configuración Avanzada](#configuración-avanzada)
- [Solución de Problemas](#solución-de-problemas)

---

## 💻 **Requisitos del Sistema**

### **Mínimos**
- **SO**: Windows 10/11, Linux (Ubuntu 18.04+), macOS 10.14+
- **RAM**: 4 GB
- **Almacenamiento**: 500 MB libres
- **GPU**: OpenGL 3.3 / DirectX 11 compatible

### **Recomendados**
- **SO**: Windows 11, Linux (Ubuntu 22.04+), macOS 12+
- **RAM**: 8 GB o más
- **Almacenamiento**: 2 GB libres (para desarrollo)
- **GPU**: Dedicada con OpenGL 4.5+ / DirectX 12

### **Para Desarrollo**
- **Godot Engine**: 4.4 o superior
- **Git**: Para control de versiones
- **Editor de Código**: VS Code recomendado

---

## 🚀 **Instalación Básica**

### **Opción 1: Descarga Directa (Usuarios)**
```bash
# Descargar release desde GitHub
wget https://github.com/1SSeba/topdown-game/releases/latest/download/topdown-game.zip

# Extraer
unzip topdown-game.zip
cd topdown-game

# Ejecutar (Linux)
chmod +x topdown-game
./topdown-game

# Ejecutar (Windows)
# Doble click en topdown-game.exe
```

### **Opción 2: Compilar desde Código (Desarrolladores)**
```bash
# Clonar repositorio
git clone https://github.com/1SSeba/topdown-game.git
cd topdown-game

# Instalar Godot Engine 4.4+
# Desde: https://godotengine.org/download

# Abrir proyecto
godot project.godot

# O ejecutar directamente
godot --main-pack . --headless
```

### **Opción 3: Instalación Automática (Linux)**
```bash
# Script de instalación automática
curl -sSL https://raw.githubusercontent.com/1SSeba/topdown-game/master/install.sh | bash

# O manualmente:
./install.sh
```

---

## ⚙️ **Configuración Inicial**

### **Primera Ejecución**
Al ejecutar el juego por primera vez:

1. **Se creará automáticamente**:
   - Carpeta de configuración: `~/.local/share/godot/app_userdata/topdown-game/`
   - Archivo de config: `config.cfg`
   - Carpeta de saves: `saves/`

2. **Configuración predeterminada**:
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

### **Configuración Manual**
Puedes editar manualmente el archivo de configuración:

```bash
# Linux/macOS
nano ~/.local/share/godot/app_userdata/topdown-game/config.cfg

# Windows
notepad %APPDATA%\Godot\app_userdata\topdown-game\config.cfg
```

---

## ✅ **Verificación de Instalación**

### **Test Básico**
```bash
# Verificar que el juego se ejecuta
./topdown-game --version

# Debería mostrar:
# Topdown Roguelike v1.0.0
# Godot Engine 4.4.x
# Component Architecture Ready
```

### **Test de Funcionalidades**
1. **Menú Principal**: Debería aparecer sin errores
2. **Audio**: Música de fondo debe reproducirse
3. **Input**: Controles deben responder
4. **Configuración**: Settings deben guardar cambios

### **Logs de Diagnóstico**
```bash
# Ejecutar con logs detallados
./topdown-game --verbose

# Verificar logs en:
# Linux: ~/.local/share/godot/app_userdata/topdown-game/logs/
# Windows: %APPDATA%\Godot\app_userdata\topdown-game\logs\
```

---

## 🔧 **Configuración Avanzada**

### **Configuración de Video**
```ini
[video]
# Modo de pantalla: 0=Ventana, 1=Pantalla completa, 2=Sin bordes
screen_mode=0

# Resolución personalizada
screen_width=1920
screen_height=1080

# Escalado de UI
ui_scale=1.0

# Calidad de renderizado
render_quality="High"  # Low, Medium, High, Ultra

# Anti-aliasing
msaa_quality=2  # 0=Disabled, 1=2x, 2=4x, 3=8x
```

### **Configuración de Audio**
```ini
[audio]
# Volúmenes (0.0 a 1.0)
master_volume=1.0
music_volume=0.8
sfx_volume=1.0
voice_volume=1.0

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
- ⚙️ **[Settings Guide](settings-guide.md)** - Configuración detallada

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
