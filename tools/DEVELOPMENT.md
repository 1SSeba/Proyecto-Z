# 🔧 Development Tools

Este directorio contiene herramientas para facilitar el desarrollo del juego top-down.

## Problema: Configuraciones de Video en Editor

Las configuraciones de video (resolución, pantalla completa) **NO funcionan** en el editor de Godot debido a las limitaciones de la ventana embebida. Esto es molesto durante el desarrollo.

## Solución: Herramientas de Desarrollo

### 🎯 DevTools Autoload

- **Ubicación**: `Autoload/DevTools.gd`
- **Función**: Proporciona atajos y herramientas para desarrollo

#### Atajos Disponibles (Solo en Editor):
- **F6**: Exportación rápida para testing
- **F7**: Toggle fullscreen básico (funciona parcialmente en editor)

### 🚀 Exportación Rápida

#### Método 1: Script Automatizado
```bash
./quick_export.sh
```

#### Método 2: Tarea de VS Code
- Presiona `Ctrl+Shift+P`
- Busca "Tasks: Run Task"
- Selecciona "Quick Export Debug"

#### Método 3: Comando Manual
```bash
godot --headless --export-debug "Linux/X11" "builds/debug/game_debug"
```

### 🎮 Testing Video Settings

1. **Aplicar configuraciones** en el menú de settings (verás mensaje de desarrollo)
2. **Exportar** usando cualquiera de los métodos anteriores
3. **Ejecutar** el binario exportado:
   ```bash
   cd builds/debug && ./game_debug
   ```
4. **Verificar** que las configuraciones se aplicaron correctamente

## 📁 Estructura de Archivos

```
builds/
├── debug/              # Builds de desarrollo
│   ├── game_debug      # Ejecutable de testing
│   └── logs/           # Logs de exportación
├── linux/              # Build Linux final
└── windows/            # Build Windows final
```

## 🔄 Flujo de Desarrollo Recomendado

1. **Desarrollar** funcionalidad en editor
2. **Configurar** settings (aparecerá mensaje dev mode)
3. **Exportar** rápidamente (F6 o script)
4. **Testear** en build exportado
5. **Iterar** según necesidades

## 📝 Notas Técnicas

- VSync **SÍ funciona** en editor
- Resolución y fullscreen **NO funcionan** en editor
- Audio settings funcionan en ambos modos
- Los cambios se guardan en `ConfigManager` independientemente del modo

## 🐛 Troubleshooting

### Export Preset No Encontrado
```bash
# Verificar que existe el preset de Linux
grep -A 5 "Linux/X11" export_presets.cfg
```

### Permisos de Ejecución
```bash
chmod +x builds/debug/game_debug
```

### Godot No Encontrado
```bash
# Verificar instalación
which godot
# O usar path absoluto en scripts
/usr/bin/godot --version
```
