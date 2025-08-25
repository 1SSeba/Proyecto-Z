# 📚 Examples - Ejemplos del Proyecto

Esta carpeta contiene ejemplos, versiones alternativas y implementaciones de referencia que no forman parte del sistema principal del juego.

## 📁 Estructura

### StateMachines/
Contiene diferentes implementaciones y ejemplos de State Machines:

#### 🔧 **Archivos de Ejemplo:**
- `StateMachine_Original.gd` - Versión original básica
- `ProfessionalStateMachine.gd` - Versión empresarial compleja
- `PausedState_simple.gd` - Versión alternativa simple del estado pausado
- `USAGE_EXAMPLE.md` - Ejemplos de uso y documentación

#### 🏗️ **Advanced/**
Sistema avanzado con características empresariales:
- `StateAnalytics.gd` - Análisis y métricas de estados
- `StateCondition.gd` - Condiciones complejas para transiciones
- `StateTransition.gd` - Transiciones avanzadas con validaciones

## ⚠️ **Importante**

**Estos archivos NO se usan en el proyecto principal.** Son solo para:
- 📖 Referencia y aprendizaje
- 🔬 Experimentación
- 📝 Documentación de diferentes enfoques
- 🎓 Ejemplos educativos

## 🎯 **Sistema Principal**

El sistema que SÍ se usa en el proyecto está en:
```
Core/StateMachine/
├── StateMachine.gd     # ← Motor principal (ÚNICO)
├── State.gd           # ← Clase base (ÚNICA)
└── States/            # ← Estados del juego
    ├── MainMenuState.gd
    ├── GameplayState.gd
    ├── PausedState.gd
    ├── SettingsState.gd
    └── LoadingState.gd
```

## 🚫 **No Modificar**

Los archivos en Examples/ no deben ser modificados como parte del desarrollo normal del juego. Son solo archivos históricos y de referencia.

---
*Para el desarrollo del juego, usa únicamente los archivos en `Core/StateMachine/`*
