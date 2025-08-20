# Builds Directory

Este directorio contiene las builds exportadas del juego.

## Cómo exportar el juego

### Desde Godot Editor:

1. **Abrir el menú de exportación**:
   - Ve a `Project` → `Export...`

2. **Configurar plantillas de exportación** (primera vez):
   - Si aparece "No export templates found", haz clic en "Download and Install"
   - Espera a que se descarguen las plantillas

3. **Exportar para Linux**:
   - Selecciona "Linux/X11" en la lista
   - Verifica que el path sea `builds/topdown-game-linux.x86_64`
   - Haz clic en "Export Project"

4. **Ejecutar la build**:
   ```bash
   cd builds
   chmod +x topdown-game-linux.x86_64
   ./topdown-game-linux.x86_64
   ```

### Desde línea de comandos:

```bash
# Exportar para Linux
godot --headless --export-release "Linux/X11" builds/topdown-game-linux.x86_64

# Exportar para Windows (desde Linux)
godot --headless --export-release "Windows Desktop" builds/topdown-game-windows.exe
```

## Diferencias entre Editor vs Build

### En el Editor:
- ❌ Los cambios de resolución NO funcionan (ventana embebida)
- ❌ Fullscreen NO funciona
- ✅ VSync SÍ funciona
- ✅ Audio SÍ funciona
- ✅ Todas las demás configuraciones funcionan

### En la Build exportada:
- ✅ Los cambios de resolución SÍ funcionan
- ✅ Fullscreen SÍ funciona
- ✅ VSync SÍ funciona
- ✅ Todas las configuraciones funcionan completamente

## Testing de Video Settings

Para probar que las configuraciones de video funcionen correctamente:

1. **Exporta el juego** siguiendo las instrucciones de arriba
2. **Ejecuta el ejecutable** (no desde Godot)
3. **Ve a Settings → Video**
4. **Cambia la resolución** y presiona Apply
5. **Cambia a Fullscreen** y presiona Apply

¡Las configuraciones deberían funcionar correctamente en la build exportada!

## Builds incluidas

- `topdown-game-linux.x86_64` - Ejecutable para Linux
- `topdown-game-windows.exe` - Ejecutable para Windows (si se exporta)

## Notas

- Las builds se generan automáticamente al exportar desde Godot
- Los archivos `.pck` contienen todos los assets del juego
- Las builds son autocontenidas (no requieren Godot instalado)
