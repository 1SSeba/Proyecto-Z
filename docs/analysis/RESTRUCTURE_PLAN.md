# 📁 Plan de Reestructuración del Proyecto

## 🎯 Objetivo
Reorganizar la estructura del proyecto para eliminar duplicaciones, consolidar assets y mejorar la organización general.

## 🔍 Problemas Identificados

### 1. Archivos Duplicados
- `export_presets.cfg` existe en **root** y **config/**
- Múltiples README.md sin organización clara

### 2. Assets Desorganizados
- `game/ui/assets/` está vacío pero existe
- `game/ui/materials/` y `game/ui/shaders/` podrían estar consolidados
- `game/assets/textures/` y assets UI separados innecesariamente

### 3. Sistemas Dispersos
- `game/systems/` vs `game/core/systems/`
- `game/scenes/Room/` podría estar mejor organizado

### 4. Documentación Fragmentada
- 24 archivos `.md` dispersos en múltiples ubicaciones
- Archivos de análisis en root que deberían estar en docs/

## 📊 Estado Actual vs Propuesto

### **ANTES:**
```
topdown-game/
├── export_presets.cfg                      # DUPLICADO
├── CODE_OF_CONDUCT.md                      # DISPERSO
├── DEVELOPMENT.md                          # DISPERSO
├── OPTIMIZATION_ANALYSIS.md                # DISPERSO
├── PROJECT_PREPARATION_SUMMARY.md          # DISPERSO
├── RESOURCE_OPTIMIZATION_REPORT.md         # DISPERSO
├── config/
│   └── export_presets.cfg                  # DUPLICADO
├── game/
│   ├── assets/
│   │   └── textures/                       # SEPARADO
│   ├── ui/
│   │   ├── assets/                         # VACÍO
│   │   ├── materials/                      # DISPERSO
│   │   └── shaders/                        # DISPERSO
│   ├── systems/                            # DUPLICADO
│   └── core/
│       └── systems/                        # DUPLICADO
└── docs/                                   # INCOMPLETO
```

### **DESPUÉS:**
```
topdown-game/
├── project.godot
├── export_presets.cfg                      # ÚNICO
├── README.md                               # PRINCIPAL
├── game/
│   ├── assets/
│   │   ├── audio/
│   │   ├── textures/
│   │   ├── materials/                      # CONSOLIDADO
│   │   └── shaders/                        # CONSOLIDADO
│   ├── core/
│   │   ├── components/
│   │   ├── events/
│   │   ├── services/
│   │   └── systems/                        # ÚNICO
│   ├── entities/
│   ├── scenes/
│   │   ├── environments/                   # REORGANIZADO
│   │   ├── gameplay/
│   │   ├── hud/
│   │   └── menus/
│   └── ui/
│       ├── components/
│       └── themes/
├── config/                                 # CONFIGS ÚNICOS
├── docs/                                   # TODO CENTRALIZADO
│   ├── development/
│   ├── architecture/
│   ├── user-guides/
│   └── analysis/                           # NUEVO
└── tools/
```

## 🚀 Comandos de Reestructuración

### Fase 1: Limpieza de Duplicados
```bash
# Eliminar export_presets.cfg duplicado del root
rm /home/scruzd/Desktop/topdown-game/export_presets.cfg

# El archivo principal estará en config/
```

### Fase 2: Consolidación de Assets
```bash
# Mover materials y shaders de UI a assets principales
mv game/ui/materials/ game/assets/
mv game/ui/shaders/ game/assets/

# Eliminar directorio assets vacío de UI
rmdir game/ui/assets/
```

### Fase 3: Reorganización de Sistemas
```bash
# Consolidar systems en core (ya existe game/core/systems/)
# Solo mantener game/core/systems/, eliminar game/systems/
mv game/systems/game-state/ game/core/systems/
rm -rf game/systems/
```

### Fase 4: Reorganización de Escenas
```bash
# Mover Room a environments
mkdir -p game/scenes/environments/
mv game/scenes/Room/ game/scenes/environments/
```

### Fase 5: Consolidación de Documentación
```bash
# Crear directorio de análisis
mkdir -p docs/analysis/

# Mover archivos de análisis
mv optimization-analysis.md docs/analysis/
mv project-preparation-summary.md docs/analysis/
mv resource-optimization-report.md docs/analysis/

# Mover documentación de desarrollo
mv DEVELOPMENT.md docs/development/
mv ENVIRONMENT_SETUP.md docs/development/

# Consolidar documentación de contribución
mkdir -p docs/contributing/
mv CODE_OF_CONDUCT.md docs/contributing/
mv CONTRIBUTING.md docs/contributing/
```

## 📁 Estructura Final Optimizada

```
topdown-game/
├── 📄 README.md                           # Documentación principal
├── 📄 CHANGELOG.md                        # Historial de cambios
├── 📄 LICENSE                             # Licencia
├── ⚙️ project.godot                       # Configuración Godot
├── 🎮 game/                               # Código del juego
│   ├── 🎨 assets/                         # Todos los assets
│   │   ├── audio/
│   │   ├── textures/
│   │   ├── materials/                     # Consolidado de UI
│   │   └── shaders/                       # Consolidado de UI
│   ├── 🏗️ core/                           # Sistema central
│   │   ├── components/
│   │   ├── events/
│   │   ├── services/
│   │   └── systems/                       # Único directorio sistemas
│   ├── 👥 entities/                       # Entidades del juego
│   ├── 🎬 scenes/                         # Escenas del juego
│   │   ├── environments/                  # Room movido aquí
│   │   ├── gameplay/
│   │   ├── hud/
│   │   └── menus/
│   └── 🎨 ui/                             # Interfaz de usuario
│       ├── components/
│       └── themes/
├── ⚙️ config/                             # Configuraciones
│   ├── export_presets.cfg                # Único archivo export
│   └── default_bus_layout.tres
├── 📚 docs/                               # Documentación completa
│   ├── analysis/                          # Análisis del proyecto
│   ├── architecture/                      # Arquitectura
│   ├── contributing/                      # Guías contribución
│   ├── development/                       # Desarrollo
│   └── user-guides/                       # Guías usuario
├── 🏗️ builds/                             # Builds del juego
└── 🔧 tools/                              # Herramientas desarrollo
```

## ✅ Beneficios de la Reestructuración

1. **Eliminación de Duplicados**: Solo un archivo de cada tipo
2. **Assets Consolidados**: Todos los recursos en ubicaciones lógicas
3. **Documentación Centralizada**: Fácil de encontrar y mantener
4. **Sistemas Unificados**: Un solo directorio de sistemas
5. **Estructura Más Clara**: Navegación intuitiva
6. **Mejor Mantenimiento**: Menos lugares donde buscar archivos

## 🎯 Próximos Pasos

1. **Ejecutar comandos en orden** (Fase 1-5)
2. **Verificar references** en archivos .tscn y .gd
3. **Actualizar imports** si es necesario
4. **Probar funcionamiento** después de cada fase
5. **Actualizar documentación** con nueva estructura
