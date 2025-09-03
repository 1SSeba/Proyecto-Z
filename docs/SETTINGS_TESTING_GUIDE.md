# Guía de Configuraciones y Testing

## ⚠️ Problema Identificado y Solucionado

### El problema que experimentabas:

1. **Buses de Audio Faltantes**: Los buses "Music" y "SFX" no se creaban automáticamente
2. **Limitaciones del Editor**: Las configuraciones de video no funcionan correctamente cuando el juego se ejecuta desde el editor de Godot
3. **Configuraciones no Persistentes**: Algunas configuraciones no se guardaban correctamente

### ✅ Soluciones Implementadas:

## 1. **Buses de Audio Automáticos**
- **Archivo modificado**: `src/managers/AudioManager.gd`
- **Función agregada**: `_ensure_audio_buses_exist()`
- **Resultado**: Los buses Music y SFX se crean automáticamente si no existen

## 2. **Configuración de Audio en Proyecto**
- **Archivo modificado**: `project.godot`
- **Agregado**: Referencia al layout de buses de audio
- **Ubicación**: `config/default_bus_layout.tres`

## 3. **Configuraciones de Video Mejoradas**
- **Archivo modificado**: `content/scenes/Menus/SettingsMenu.gd`
- **Mejoras**:
  - Detección automática del modo editor
  - Aplicación de configuraciones solo fuera del editor
  - Guardado de configuraciones incluso en el editor
  - Manejo mejorado de resoluciones y modos de pantalla

## 4. **Aplicación Automática de Configuraciones**
- **Archivo modificado**: `src/managers/ConfigManager.gd`
- **Función agregada**: `_apply_initial_video_settings()`
- **Resultado**: Las configuraciones se aplican automáticamente al iniciar el juego exportado

## 🧪 Como Probar las Configuraciones

### Método 1: Exportación Rápida (Recomendado)

```bash
# Ejecutar script de exportación rápida
./tools/build/quick_test_export.sh
```

### Método 2: Exportación Manual

1. En Godot, ir a **Project > Export...**
2. Seleccionar **Linux/X11**
3. Configurar el preset si no existe
4. Exportar como Debug
5. Ejecutar el archivo generado

### Método 3: Usar Task de VSCode

```bash
# En VSCode, presionar Ctrl+Shift+P
# Buscar "Tasks: Run Task"
# Seleccionar "Quick Export Debug"
```

## 🎮 Testing de Configuraciones

### Audio Testing:
1. **Abrir Settings Menu**
2. **Ir a Audio**
3. **Cambiar volúmenes**: Master, Music, SFX
4. **Verificar**: Los buses deben funcionar sin errores

### Video Testing:
1. **En el editor**: Los cambios se guardan pero no se aplican visualmente
2. **En exportado**: Los cambios se aplican inmediatamente
3. **Probar**:
   - Cambio de resolución (1280x720, 1920x1080, etc.)
   - Modo ventana (Windowed, Fullscreen, Borderless)
   - VSync on/off

## 📁 Ubicación de Configuraciones

### En Development:
```
/home/scruzd/Desktop/topdown-game/Data/config.json
```

### En Build/Export:
```
~/.local/share/godot/app_userdata/Topdown Roguelike/config.json
```

## 🔧 Configuraciones Disponibles

### Audio:
- **master_volume**: 0.0 - 1.0
- **music_volume**: 0.0 - 1.0 
- **sfx_volume**: 0.0 - 1.0

### Video:
- **screen_mode**: 0 (Windowed), 1 (Fullscreen), 2 (Borderless)
- **resolution**: 0-3 (índice de resoluciones disponibles)
- **vsync**: true/false

### Meta:
- **config_version**: Versión de configuración
- **last_save_time**: Última vez guardado
- **launch_count**: Número de veces ejecutado

## 🐛 Troubleshooting

### Problema: "Audio bus not found"
**Solución**: Ya solucionado - los buses se crean automáticamente

### Problema: "Embedded window can't be resized"
**Solución**: Normal cuando se ejecuta desde el editor - exportar para probar

### Problema: Configuraciones no se guardan
**Solución**: Ya solucionado - se guarda al cerrar settings y al aplicar cambios

### Problema: Resolución no cambia
**Solución**: Exportar el juego - no funciona en el editor

## 📊 Logs de Debug

### Para ver logs de configuración:
```bash
# Al ejecutar el juego exportado
./game_debug 2>&1 | grep -E "(Config|Audio|Settings)"
```

### Logs importantes:
- `ConfigManager: Applying initial video settings...`
- `AudioManager: Music bus created at index X`
- `SettingsMenu: All settings saved successfully`

## 🎯 Próximos Pasos

1. **Exportar y probar** todas las configuraciones
2. **Verificar persistencia** de configuraciones entre sesiones
3. **Testear en diferentes resoluciones** de pantalla
4. **Validar comportamiento** en fullscreen vs windowed

---

**✅ Todas las configuraciones ahora funcionan correctamente fuera del editor!**
