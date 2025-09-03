# Main Menu Modular - Guía Completa

## 🎯 Visión General

El nuevo sistema de Main Menu está diseñado para ser escalable, modular y fácil de mantener. Está integrado perfectamente con el StateMachine existente y permite extensiones futuras sin romper el código base.

## 🏗️ Arquitectura del Sistema

```
GameStateManager (Autoload)
├── StateMachine (Autoload)
│   └── MainMenuStateModular.gd (Estado modular mejorado)
│
└── MainMenuModular.tscn (Escena principal)
    ├── MainMenuModular.gd (Lógica de UI escalable)
    │   ├── Señales para StateMachine
    │   ├── Sistema de botones extensible
    │   ├── Manejo de input configurable
    │   └── API pública para customización
    │
    └── SettingsPanelModular.gd (Panel integrado)
        ├── Configuración de audio/video
        ├── Cache de settings
        └── API para agregar opciones
```

## 📁 Estructura de Archivos

### Archivos Principales
- `content/scenes/Menus/MainMenuModular.tscn` - Escena principal del menú
- `content/scenes/Menus/MainMenuModular.gd` - Lógica principal del menú
- `content/scenes/Menus/SettingsPanelModular.gd` - Panel de configuraciones
- `src/systems/StateMachine/States/MainMenuStateModular.gd` - Estado para StateMachine

### Archivos Legacy (compatibilidad)
- `content/scenes/Menus/MainMenuModular.tscn` - Menú modular (canonical)
`content/scenes/Menus/MainMenuModular.gd` - Lógica modular (reemplaza al legacy)
- `src/systems/StateMachine/States/MainMenuState.gd` - Estado original

## 🔧 Configuración Paso a Paso

### 1. Configurar MainMenuModular.tscn

```
MainMenu (Control) - Script: MainMenuModular.gd
│
├── Background (ColorRect) - Color de fondo
│
├── TitleLabel (Label) - Título del juego
│   [Anchors: Top Center]
│   [Text: "ROGUELIKE GAME"]
│
├── MainContainer (VBoxContainer) - Botones principales
│   [Anchors: Center]
│   [Separation: 20px]
│   │
│   ├── StartButton (Button) - "Start Game"
│   ├── SettingsButton (Button) - "Settings"  
│   └── QuitButton (Button) - "Quit Game"
│
├── VersionLabel (Label) - Versión del juego
│   [Anchors: Bottom Right]
│   [Text: "v1.0.0" (auto)]
│
└── SettingsPanel (Control) - Panel de configuraciones
    [Script: SettingsPanelModular.gd]
    [Visible: false]
    [Anchors: Full Rect]
    │
    ├── SettingsBackground (ColorRect) - Fondo semi-transparente
    │
    └── SettingsContainer (VBoxContainer)
        [Anchors: Center]
        │
        ├── SettingsTitle (Label) - "SETTINGS"
        ├── AudioButton (Button) - "Audio Settings"
        ├── VideoButton (Button) - "Video Settings"
        ├── ControlsButton (Button) - "Controls"
        └── BackButton (Button) - "Back to Main Menu"
```

### 2. Configurar Propiedades en el Inspector

#### MainMenu (Control Root)
- **Script:** MainMenuModular.gd
- **Layout:** Full Rect anchors
- **Process Mode:** When Paused

#### Configuración de Exports (Inspector)
```gdscript
# Main UI Nodes
main_container: VBoxContainer → "MainContainer"
start_button: Button → "MainContainer/StartButton"
settings_button: Button → "MainContainer/SettingsButton"
quit_button: Button → "MainContainer/QuitButton"

# Sub Menus
settings_panel: Control → "SettingsPanel"

# Optional Elements
title_label: Label → "TitleLabel"
version_label: Label → "VersionLabel"
background_control: Control → "Background"

# Menu Configuration
auto_focus_start: bool = true
enable_keyboard_shortcuts: bool = true
enable_debug_shortcuts: bool = true
show_version_info: bool = true
```

### 3. Configurar StateMachine

Actualizar autoloads en `project.godot`:

```ini
[autoload]
StateMachine="*res://src/systems/StateMachine/StateMachine.gd"
GameStateManager="*res://src/managers/GameStateManager.gd"
```

### 4. Cambiar Escena Principal

En Project Settings → Application:
```ini
run/main_scene="res://content/scenes/Menus/MainMenuModular.tscn"
```

## 🎮 Controles y Input

### Controles por Defecto
- **ENTER/SPACE:** Start Game
- **TAB:** Navegar entre botones
- **ESC:** Back/Quit
- **F1:** Mostrar ayuda
- **F12:** Info de debug
- **F2:** Toggle debug mode
- **F5:** Quick start (debug)
- **Ctrl+Q:** Quit (Linux)

### Input Map Requerido
```
ui_accept → Enter, Space
ui_cancel → Escape
debug_toggle → F12
menu → Tab, M
```

## 🔌 API de Extensión

### Agregar Botones Personalizados

```gdscript
# En tu script personalizado
func _ready():
    var main_menu = get_node("/root/MainMenu")
    if main_menu and main_menu.has_method("add_custom_button"):
        var custom_btn = main_menu.add_custom_button(
            "My Custom Option",
            _on_custom_option_pressed,
            2  # Posición (opcional)
        )
        custom_btn.modulate = Color.YELLOW
```

### Conectar a Señales del Menú

```gdscript
# Conectar a señales principales
main_menu.start_game_requested.connect(_on_game_start)
main_menu.settings_requested.connect(_on_settings_open)
main_menu.quit_requested.connect(_on_game_quit)

# Señales adicionales
main_menu.debug_mode_toggled.connect(_on_debug_toggle)
main_menu.menu_initialized.connect(_on_menu_ready)
```

### Personalizar Panel de Settings

```gdscript
# Agregar configuración personalizada
func setup_custom_settings():
    var settings_panel = main_menu.settings_panel
    if settings_panel and settings_panel.has_method("add_custom_setting_button"):
        settings_panel.add_custom_setting_button(
            "My Setting",
            _on_my_setting_pressed
        )
```

## 🔄 Integración con StateMachine

### Estados Disponibles
- **MainMenuState** → Menú principal activo
- **SettingsState** → Panel de configuraciones
- **LoadingState** → Pantalla de carga
- **GameplayState** → Juego activo
- **PausedState** → Juego pausado

### Flujo de Estados
```
MainMenuState
├── → GameplayState (Start Game)
├── → SettingsState (Settings)
└── → Quit (Quit Game)

SettingsState
└── → MainMenuState (Back)

GameplayState
├── → PausedState (Pause)
└── → MainMenuState (Quit to Menu)
```

### Usar desde Código

```gdscript
# Cambiar estado desde cualquier script
if GameStateManager:
    GameStateManager.change_state(GameStateManager.GameState.PLAYING)

# O usar StateMachine directamente
if StateMachine:
    StateMachine.transition_to("GameplayState", {"new_run": true})
```

## 🐛 Debug y Troubleshooting

### Comandos de Debug
- **F12:** Info completa del menú
- **F1:** Ayuda de controles
- **F2:** Toggle debug mode

### Verificar Estado
```gdscript
# Verificar si el menú está funcionando
if MainMenuState.is_menu_ready():
    print("Menu is ready!")

# Debug info del estado
print(MainMenuState.get_menu_debug_info())
```

### Logs Importantes
```
MainMenu: ✅ Modular initialization complete!
MainMenuState: ✅ Ready and active
SettingsPanel: ✅ Initialized
StateMachine: MainMenuState → GameplayState
```

## ⚡ Performance y Optimizaciones

### Características de Performance
1. **Cache de UI Elements:** Referencias cachadas para evitar búsquedas
2. **Lazy Loading:** Settings se cargan solo cuando es necesario
3. **Input Optimizado:** Manejo eficiente de eventos
4. **Memory Management:** Cleanup automático al salir

### Configuraciones Recomendadas
- Usar `process_mode = WHEN_PAUSED` para menús
- Ocultar elementos no visibles con `visible = false`
- Cachear referencias de managers

## 🔮 Extensiones Futuras

### Ideas para Expandir
1. **Menú de Opciones Avanzadas**
   - Configuración de gráficos
   - Keybinding personalizado
   - Mods/Addons

2. **Sistema de Perfiles**
   - Múltiples save slots
   - Estadísticas por perfil
   - Achievements

3. **UI Animada**
   - Transiciones suaves
   - Efectos visuales
   - Audio feedback

4. **Accesibilidad**
   - Navegación completa con teclado
   - Soporte para screen readers
   - Opciones de contraste

## 📝 Notas de Migración

### Desde MainMenu Original
1. La API es **100% compatible** hacia atrás
2. Los nombres de señales son **idénticos**
3. Se puede usar como **drop-in replacement**

### Fallback Automático
Preferir `MainMenuModular.tscn`. El legacy `MainMenu.tscn` está deprecado.
- Si los nodes no están configurados, los crea automáticamente
- Funciona con o sin StateMachine

## 🎯 Checklist de Implementación

- [ ] Crear `MainMenuModular.tscn` con estructura correcta
- [ ] Configurar exports en Inspector
- [ ] Verificar que todos los botones están conectados
- [ ] Probar navegación con teclado
- [ ] Verificar integración con StateMachine
- [ ] Configurar Input Map
- [ ] Probar modo debug (F12)
- [ ] Verificar que settings funcionan
- [ ] Probar transiciones entre estados
- [ ] Verificar cleanup al salir

## 🚀 ¡Listo para Escalar!

Con esta estructura modular, tu proyecto está preparado para:
- **Agregar nuevas funciones fácilmente**
- **Mantener código limpio y organizado**
- **Escalar sin romper funcionalidad existente**
- **Integrar nuevos sistemas sin problemas**

La arquitectura está diseñada para crecer contigo y con tu roguelike. ¡Cada nueva característica se puede agregar de forma incremental sin tocar el código base!
