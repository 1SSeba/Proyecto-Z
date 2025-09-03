# Estructura de Nodos para MainMenu con StateMachine

> **NOTA IMPORTANTE:** Este documento describe la implementación ORIGINAL del MainMenu. 
> Para la nueva implementación mejorada y escalable, consulta [MAINMENU_MODULAR_GUIDE.md](./MAINMENU_MODULAR_GUIDE.md)

## 🆕 Nueva Implementación Recomendada

**Para nuevos proyectos o mejoras, usa:**
- `MainMenuModular.tscn` + `MainMenuModular.gd`
- `MainMenuStateModular.gd`
- Ver guía completa: [MAINMENU_MODULAR_GUIDE.md](./MAINMENU_MODULAR_GUIDE.md)

## 📋 Implementación Original (Legacy)

Esta documentación se mantiene para compatibilidad y referencia.

## Diagrama de Arquitectura

```
GameStateManager (Autoload)
├── StateMachine (Autoload)
│   └── MainMenuState.gd (registrado en StateMachine)
│
└── MainMenuModular.tscn (Scene principal)
        ├── Control (MainMenuModular) - Script: MainMenuModular.gd
    │   ├── BoxContainer (VBoxContainer recomendado)
    │   │   ├── StartGame (Button)
    │   │   ├── Settings (Button)
    │   │   └── Quit (Button)
    │   │
    │   └── SettingsMenu (Control)
    │       └── [Contenido del menú de settings]
    │
    └── [Otros elementos de UI como fondo, título, etc.]
```

## Configuración Paso a Paso en Godot

### 1. Estructura Principal de MainMenuModular.tscn
```
MainMenuModular (Control) - Script: content/scenes/Menus/MainMenuModular.gd
│
├── BoxContainer (VBoxContainer)
│   │   [Configurar como centro de pantalla]
│   │   [Usar anchors: Center]
│   │   [Add Theme Overrides para spacing]
│   │
│   ├── StartGame (Button)
│   │   [Text: "Start Game"]
│   │   [Focus Mode: ALL]
│   │
│   ├── Settings (Button)
│   │   [Text: "Settings"] 
│   │   [Focus Mode: ALL]
│   │
│   └── Quit (Button)
│       [Text: "Quit Game"]
│       [Focus Mode: ALL]
│
└── SettingsMenu (Control)
    [Visible: false]
    [Anchors: Full Rect]
    [Script: content/scenes/Menus/SettingsMenu.gd]
```

### 2. Configuración de Propiedades

#### MainMenu (Control Root)
- **Name:** MainMenu
- **Script:** content/scenes/Menus/MainMenuModular.gd
- **Layout:** Full Rect anchors
- **Process Mode:** When Paused (importante para menús)

#### BoxContainer (VBoxContainer)
- **Name:** BoxContainer
- **Type:** VBoxContainer
- **Anchors:** Center (0.5, 0.5, 0.5, 0.5)
- **Size:** Fit Content
- **Separation:** 20-30 pixels
- **Alignment:** Center

#### Botones (StartGame, Settings, Quit)
- **Names exactos:** StartGame, Settings, Quit
- **Type:** Button
- **Focus Mode:** ALL
- **Size:** Minimum 200x50 pixels
- **Text:** Como se indica arriba

#### SettingsMenu (Control)
- **Name:** SettingsMenu  
- **Type:** Control
- **Visible:** false (oculto por defecto)
- **Anchors:** Full Rect
- **Script:** content/scenes/Menus/SettingsMenu.gd

### 3. Input Map Configuration

Asegúrate de que estas acciones estén configuradas en Project → Project Settings → Input Map:

```
ui_accept          → Enter, Space
ui_cancel          → Escape
menu              → Tab, M
debug_toggle      → F12, `
```

### 4. Configuración de StateMachine

El StateMachine debe tener estos estados registrados:
- MainMenuState
- SettingsState  
- LoadingState
- GameplayState
- PausedState

### 5. Señales Importantes

El MainMenuModular.gd emite estas señales que MainMenuState escucha:
```gdscript
signal start_game_requested
signal settings_requested
signal quit_requested
```

## Flujo de Comunicación

```
Usuario presiona botón
        ↓
MainMenuModular.gd emite señal
        ↓
MainMenuState escucha señal
        ↓
MainMenuState llama StateMachine.change_state()
        ↓
GameStateManager actualiza estado
        ↓
MainMenuModular.gd recibe _on_game_state_changed()
        ↓
UI se actualiza según nuevo estado
```

## Estados y Transiciones

```
MainMenuState
├── → LoadingState (al presionar Start)
├── → SettingsState (al presionar Settings)
└── → Quit (al presionar Quit)

SettingsState
└── → MainMenuState (al presionar Back/ESC)

LoadingState
└── → GameplayState (cuando carga completa)
```

## Configuración de Project Settings

En **project.godot**, asegurar que:
```
[application]
run/main_scene="res://content/scenes/Menus/MainMenu.tscn"

[autoload]
ManagerUtils="*res://src/managers/ManagerUtils.gd"
StateMachine="*res://src/systems/StateMachine/StateMachine.gd"
ConfigManager="*res://src/managers/ConfigManager.gd"
InputManager="*res://src/managers/InputManager.gd"
GameStateManager="*res://src/managers/GameStateManager.gd"
GameManager="*res://src/managers/GameManager.gd"
AudioManager="*res://src/managers/AudioManager.gd"
DebugManager="*res://src/managers/DebugManager.gd"
EventBus="*res://src/systems/Events/EventBus.gd"
NodeCache="*res://src/systems/NodeCache.gd"
ObjectPool="*res://src/systems/ObjectPool.gd"
```

## Tips de Debugging

1. Presiona F12 para debug info del menú
2. Observa la consola para mensajes de StateMachine
3. Verifica que las señales se conecten correctamente
4. Asegúrate de que GameStateManager esté activo antes que MainMenu

## Nota Importante

- Los nombres de nodos DEBEN coincidir exactamente con los del código
- El orden de autoloads importa - GameStateManager debe cargar después de StateMachine
- SettingsMenu puede ser un scene separado que se instancia dinámicamente si prefieres
