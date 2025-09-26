# 🔄 Guía de Migración: GameStateManager → GameFlowController

## 📝 Resumen de Cambios

### ❌ Sistema Anterior (OBSOLETO)
```gdscript
# Múltiples sistemas conflictivos
GameStateManager.change_state(GameState.PLAYING)  # Enum básico
state_machine.transition_to("GameplayState")      # StateMachine complejo
```

### ✅ Sistema Nuevo (LIMPIO)
```gdscript
# Sistema unificado y simple
var game_flow = ServiceManager.get_game_flow_controller()
game_flow.start_game()  # Maneja estados Y escenas automáticamente
```

## 🎯 Beneficios de la Refactorización

1. **🎮 Un Solo Controlador**: GameFlowController maneja todo el flujo principal
2. **🎬 Gestión Automática de Escenas**: SceneController maneja cambios de escena
3. **🎛️ StateMachine Especializado**: Solo para lógica compleja específica
4. **🧹 Código Más Limpio**: Sin duplicación de responsabilidades
5. **📡 Comunicación Clara**: Señales centralizadas y consistentes

## 🔄 Tabla de Equivalencias

| Sistema Anterior | Sistema Nuevo | Notas |
|------------------|---------------|-------|
| `GameStateManager.start_game()` | `GameFlowController.start_game()` | Misma API |
| `GameStateManager.pause_game()` | `GameFlowController.pause_game()` | Misma API |
| `GameStateManager.is_playing()` | `GameFlowController.is_playing()` | Misma API |
| `get_tree().change_scene_to_file()` | `SceneController.change_scene()` | Manejo seguro |
| `StateMachine.transition_to()` | `SpecializedStateMachine.transition_to()` | Solo casos complejos |

## 🛠️ Cómo Migrar

### 1. Acceso al Controlador
```gdscript
# ❌ Antes
if GameStateManager:
    GameStateManager.start_game()

# ✅ Ahora
var game_flow = ServiceManager.get_game_flow_controller()
if game_flow:
    game_flow.start_game()
```

### 2. Cambios de Escena
```gdscript
# ❌ Antes
get_tree().change_scene_to_file("res://game/scenes/Main.tscn")

# ✅ Ahora
var scene_controller = ServiceManager.get_scene_controller()
if scene_controller:
    scene_controller.change_scene("res://game/scenes/Main.tscn")

# 🔥 Mejor aún - Usar GameFlowController
var game_flow = ServiceManager.get_game_flow_controller()
if game_flow:
    game_flow.start_game()  # Maneja la escena automáticamente
```

### 3. Escuchar Cambios de Estado
```gdscript
# ❌ Antes
GameStateManager.state_changed.connect(_on_state_changed)

# ✅ Ahora
var game_flow = ServiceManager.get_game_flow_controller()
if game_flow:
    game_flow.state_changed.connect(_on_state_changed)
```

### 4. StateMachine para Casos Complejos
```gdscript
# ✅ Solo usar cuando necesites lógica compleja
var specialized_sm = SpecializedStateMachine.new()
specialized_sm.add_state("ComplexGameplay", my_complex_state)
specialized_sm.add_state("BossPhase", my_boss_state)
specialized_sm.start("ComplexGameplay")
```

## 📂 Archivos Afectados

### ✅ Nuevos Archivos
- `res://game/core/systems/GameFlowController.gd` - Controlador principal
- `res://game/core/systems/SceneController.gd` - Manejo de escenas
- `res://game/core/systems/SpecializedStateMachine.gd` - StateMachine especializado

### 🔄 Archivos Actualizados
- `res://game/core/ServiceManager.gd` - Incluye nuevos controladores
- `res://game/entities/characters/Player.gd` - Usa GameFlowController
- `res://game/scenes/menus/MainMenu.gd` - Usa GameFlowController

### ⚠️ Archivos Obsoletos (No eliminar aún)
- `res://game/core/systems/game-state/GameStateManager.gd` - Mantener por compatibilidad
- `res://game/core/systems/game-state/StateMachine/` - Puede usarse para casos específicos

## 🎯 Casos de Uso Recomendados

### 🎮 GameFlowController - Para TODO el flujo principal
- Cambios entre menú, juego, pausa, game over
- Transiciones de escena automáticas
- Estados globales del juego
- Comunicación entre sistemas

### 🎛️ SpecializedStateMachine - Solo para casos específicos
- IA de enemigos con múltiples fases
- Sistemas de diálogo complejos
- Mecánicas de gameplay con estados específicos
- Mini-juegos con lógica particular

## 🐛 Troubleshooting

### Error: "No se puede acceder a GameFlowController"
```gdscript
# Verificar que ServiceManager esté inicializado
if not ServiceManager:
    await get_tree().process_frame

var game_flow = ServiceManager.get_game_flow_controller()
if not game_flow:
    print("GameFlowController not available yet")
```

### Problema: Estados no cambian
```gdscript
# El GameFlowController maneja escenas automáticamente
# No necesitas cambiar escenas manualmente después de cambiar estado
game_flow.start_game()  # Esto ya cambia a la escena de juego
```

## ✅ Checklist de Migración

- [ ] Cambiar acceso a GameStateManager por GameFlowController
- [ ] Actualizar cambios de escena para usar SceneController
- [ ] Conectar señales al GameFlowController
- [ ] Probar todos los flujos de navegación
- [ ] Verificar que no hay conflictos entre sistemas
- [ ] Documentar casos específicos que requieran SpecializedStateMachine

## 🎉 Resultado Final

Un sistema de estados **limpio**, **simple** y **consistente** que:

1. **Separa responsabilidades claramente**
2. **Reduce la complejidad del código**
3. **Mantiene la compatibilidad existente**
4. **Facilita el mantenimiento futuro**
5. **Proporciona una API clara y consistente**
