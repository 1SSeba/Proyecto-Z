# Guía: Integración StateMachine SIMPLE paso a paso

## 🎯 Objetivo
Hacer que el menú funcione SIN complicaciones de StateMachine primero, luego agregar StateMachine gradualmente.

## ✅ PASO 1: Hacer funcionar el menú básico

### Tu estructura de nodos en Godot debe ser:
```
MainMenu (Control) - Script: MainMenu.gd
├── BoxContainer (VBoxContainer)
│   ├── StartGame (Button) - Text: "Start Game" 
│   ├── Settings (Button) - Text: "Settings"
│   └── Quit (Button) - Text: "Quit"
└── SettingsMenu (Control) - Visible: false
```

### Configuración de nodos:
1. **MainMenu (Control)**:
   - Layout → Full Rect
   - Script: `content/scenes/Menus/MainMenuModular.gd`

2. **BoxContainer (VBoxContainer)**:
   - Anchors: Center (0.5, 0.5, 0.5, 0.5)
   - Separation: 20-30 pixels

3. **Botones** (StartGame, Settings, Quit):
   - Size: 200x50 pixels mínimo
   - Focus Mode: ALL

4. **SettingsMenu (Control)**:
   - Visible: FALSE
   - Layout: Full Rect

## ✅ PASO 2: Probar que funciona

1. **Ejecutar el proyecto**
2. **Verificar console** - debe mostrar:
   ```
   ✅ Start button connected
   ✅ Settings button connected  
   ✅ Quit button connected
   MainMenu: Ready! Press ENTER to start...
   ```

3. **Probar controles**:
   - ENTER → Debe intentar cambiar escena
   - TAB → Debe mostrar/ocultar settings
   - ESC → Debe salir

4. **F12** → Muestra debug info

## ✅ PASO 3: Una vez que funcione básico, OPCIONALMENTE agregar StateMachine

### Opción A: SIN StateMachine (MÁS SIMPLE)
- Cambiar escenas directamente con `get_tree().change_scene_to_file()`
- Usar GameManager directamente
- Funciona perfectamente para un juego simple

### Opción B: CON StateMachine (MÁS COMPLEJO)
Solo SI quieres un sistema más sofisticado:

1. **Eliminar autoload de StateMachine temporalmente**
2. **Usar solo GameStateManager**
3. **Hacer que GameStateManager maneje estados simples**

## 🚨 ERRORES COMUNES Y SOLUCIONES

### Error: "Button not found"
**Solución**: Los nombres de nodos deben ser exactamente:
- `StartGame` (no "Start Game")
- `Settings` 
- `Quit`

### Error: Settings no aparece
**Solución**: SettingsMenu debe ser hijo directo de MainMenu

### Error: StateMachine fails
**Solución**: Comentar autoload de StateMachine en project.godot temporalmente

## 📋 CHECKLIST RÁPIDO

- [ ] Nodos con nombres exactos: StartGame, Settings, Quit
- [ ] MainMenu.gd asignado al Control root
- [ ] SettingsMenu como hijo de MainMenu (visible: false)
- [ ] Input Map configurado (ui_accept, ui_cancel, menu)
- [ ] Console muestra "✅" para todos los botones
- [ ] F12 muestra debug info
- [ ] ENTER cambia a game scene

## 🎮 RESULTADO ESPERADO

**Menú funcional donde**:
- Los botones responden
- Keyboard shortcuts funcionan
- Settings se puede abrir/cerrar
- Start Game carga el juego
- Todo es simple y directo

## 💡 RECOMENDACIÓN

**EMPIEZA SIMPLE**. Haz que el menú funcione básico primero. StateMachine es un extra para sistemas más complejos, pero no es necesario para que funcione el menú.

Una vez que tengas el menú básico funcionando al 100%, podemos agregar StateMachine gradualmente si realmente lo necesitas.
