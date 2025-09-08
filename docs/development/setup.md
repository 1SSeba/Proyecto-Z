# 👨‍💻 Configuración de Desarrollo - RougeLike Base

Esta guía te ayudará a configurar un entorno de desarrollo completo y productivo para contribuir al proyecto RougeLike Base.

## 🎯 Configuración Inicial

### 1. Clonar el Repositorio

```bash
# Clonar el repositorio principal
git clone https://github.com/1SSeba/Proyecto-Z.git
cd Proyecto-Z/topdown-game

# Configurar repositorio upstream (para contributors)
git remote add upstream https://github.com/1SSeba/Proyecto-Z.git

# Verificar remotos
git remote -v
# origin    https://github.com/TU_USERNAME/Proyecto-Z.git (fetch)
# origin    https://github.com/TU_USERNAME/Proyecto-Z.git (push)
# upstream  https://github.com/1SSeba/Proyecto-Z.git (fetch)
# upstream  https://github.com/1SSeba/Proyecto-Z.git (push)
```

### 2. Configurar Git

```bash
# Configurar información personal
git config user.name "Tu Nombre"
git config user.email "tu.email@example.com"

# Configurar editor preferido
git config core.editor "code --wait"  # VS Code
# git config core.editor "vim"        # Vim
# git config core.editor "nano"       # Nano

# Configurar branch por defecto
git config init.defaultBranch main

# Habilitar colores en terminal
git config --global color.ui auto
```

### 3. Configurar Hooks de Git

```bash
# Copiar hooks de desarrollo
cp scripts/hooks/* .git/hooks/
chmod +x .git/hooks/*

# O crear enlaces simbólicos
ln -sf ../../scripts/hooks/pre-commit .git/hooks/pre-commit
ln -sf ../../scripts/hooks/commit-msg .git/hooks/commit-msg
```

## 🛠️ Herramientas de Desarrollo

### Editores Recomendados

#### VS Code (Recomendado)

```bash
# Instalar VS Code
# Descargar desde: https://code.visualstudio.com/

# Instalar extensiones esenciales
code --install-extension ms-vscode.vscode-godot
code --install-extension ms-vscode.vscode-json
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-vscode.vscode-language-pack-es
```

**Configuración VS Code** (`.vscode/settings.json`):
```json
{
    "godot_tools.gdscript_lsp_server_port": 6005,
    "files.associations": {
        "*.gd": "gdscript",
        "*.cs": "csharp",
        "*.tres": "godot-resource",
        "*.tscn": "godot-scene"
    },
    "editor.insertSpaces": false,
    "editor.detectIndentation": false,
    "editor.tabSize": 4,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "editor.rulers": [100],
    "editor.wordWrap": "wordWrapColumn",
    "editor.wordWrapColumn": 100
}
```

**Tasks para VS Code** (`.vscode/tasks.json`):
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run Game",
            "type": "shell",
            "command": "godot",
            "args": ["--resolution", "1280x720"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "silent",
                "focus": false,
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "Export Debug",
            "type": "shell",
            "command": "./scripts/quick_export.sh",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Check Syntax",
            "type": "shell",
            "command": "./scripts/check_syntax.sh",
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        }
    ]
}
```

#### Godot Editor

```bash
# Configurar Godot Editor
# Project Settings > Network > Language Server:
# - Use Language Server: ON
# - Remote Host: 127.0.0.1
# - Remote Port: 6005

# Editor Settings > Text Editor > Behavior:
# - Indent Type: Tabs
# - Indent Size: 4
# - Auto Indent: ON
# - Trim Trailing Whitespace: ON

# Editor Settings > Text Editor > Appearance:
# - Show Line Numbers: ON
# - Show Fold Gutter: ON
# - Highlight Current Line: ON
```

### Terminal y Scripts

#### Scripts de Desarrollo Disponibles

```bash
# En la raíz del proyecto (topdown-game/)

# Verificación de código
./scripts/check_syntax.sh          # Verificar sintaxis GDScript
./scripts/check_style.sh           # Verificar estilo de código
./scripts/verify_project.sh        # Verificar estructura del proyecto

# Desarrollo
./scripts/dev.sh                   # Modo desarrollo con hot-reload
./scripts/run_tests.sh             # Ejecutar tests automáticos
./scripts/debug.sh                 # Ejecutar con debugging habilitado

# Build y export
./scripts/quick_export.sh          # Export rápido para testing
./scripts/build_debug.sh           # Build completo de debug
./scripts/build_release.sh         # Build de release

# Mantenimiento
./scripts/clean_project.sh         # Limpiar archivos temporales
./scripts/update_deps.sh           # Actualizar dependencias
./scripts/generate_docs.sh         # Generar documentación automática
```

#### Alias Útiles

Agrega a tu `.bashrc` o `.zshrc`:

```bash
# Aliases para RougeLike Base
alias rl-dev='cd /path/to/topdown-game && ./scripts/dev.sh'
alias rl-test='cd /path/to/topdown-game && ./scripts/run_tests.sh'
alias rl-check='cd /path/to/topdown-game && ./scripts/check_syntax.sh'
alias rl-clean='cd /path/to/topdown-game && ./scripts/clean_project.sh'
alias rl-export='cd /path/to/topdown-game && ./scripts/quick_export.sh'

# Godot shortcuts
alias godot-run='godot --resolution 1280x720'
alias godot-headless='godot --headless'
alias godot-debug='godot --verbose --debug'
```

## 🔧 Configuración del Entorno

### Variables de Entorno

Crear `.env` en la raíz del proyecto:

```bash
# Configuración de desarrollo
GODOT_DEBUG=1
GODOT_VERBOSE=1
GODOT_RESOLUTION="1280x720"

# Paths
GODOT_BIN="/usr/bin/godot"
EXPORT_PATH="./builds"

# Testing
TEST_TIMEOUT=30
RUN_SLOW_TESTS=0

# Logging
LOG_LEVEL="DEBUG"
LOG_FILE="./logs/dev.log"
```

Cargar en tu shell (`.bashrc`/`.zshrc`):

```bash
# Auto-cargar .env si existe
if [ -f .env ]; then
    export $(cat .env | xargs)
fi
```

### Configuración de Desarrollo

#### 1. Habilitar Debug Mode

En `project.godot`, asegurar:

```ini
[debug]
settings/fps/force_fps=60
settings/stdout/print_fps=true
settings/stdout/verbose_stdout=true

[rendering]
driver/driver_name="Vulkan"
vulkan/rendering/back_end=1
```

#### 2. Configurar Logging

Crear `game/core/Debug.gd`:

```gdscript
extends Node

enum LogLevel {
    DEBUG,
    INFO,
    WARNING,
    ERROR
}

var log_level: LogLevel = LogLevel.DEBUG if OS.is_debug_build() else LogLevel.INFO
var log_file: FileAccess

func _ready():
    if OS.is_debug_build():
        _setup_debug_logging()

func _setup_debug_logging():
    var log_dir = "user://logs/"
    if not DirAccess.dir_exists_absolute(log_dir):
        DirAccess.open("user://").make_dir_recursive("logs")

    var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
    log_file = FileAccess.open("user://logs/debug_%s.log" % timestamp, FileAccess.WRITE)

func log_debug(message: String, context: String = ""):
    _log(LogLevel.DEBUG, message, context)

func log_info(message: String, context: String = ""):
    _log(LogLevel.INFO, message, context)

func log_warning(message: String, context: String = ""):
    _log(LogLevel.WARNING, message, context)

func log_error(message: String, context: String = ""):
    _log(LogLevel.ERROR, message, context)

func _log(level: LogLevel, message: String, context: String = ""):
    if level < log_level:
        return

    var timestamp = Time.get_datetime_string_from_system()
    var level_str = LogLevel.keys()[level]
    var ctx_str = " [%s]" % context if context else ""
    var full_message = "[%s] %s%s: %s" % [timestamp, level_str, ctx_str, message]

    print(full_message)

    if log_file:
        log_file.store_string(full_message + "\n")
        log_file.flush()
```

#### 3. Hot Reload Configuration

Para desarrollo con hot-reload:

```gdscript
# game/core/DevTools.gd
extends Node

var file_watcher: FileSystemDock
var last_modification_times: Dictionary = {}

func _ready():
    if OS.is_debug_build():
        _setup_hot_reload()

func _setup_hot_reload():
    # Monitorear cambios en scripts
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.timeout.connect(_check_file_changes)
    add_child(timer)
    timer.start()

func _check_file_changes():
    var files_to_watch = [
        "res://game/core/",
        "res://game/entities/",
        "res://game/scenes/"
    ]

    for path in files_to_watch:
        _check_directory_changes(path)

func _check_directory_changes(path: String):
    var dir = DirAccess.open(path)
    if not dir:
        return

    dir.list_dir_begin()
    var file_name = dir.get_next()

    while file_name != "":
        if file_name.ends_with(".gd"):
            var full_path = path + file_name
            var file = FileAccess.open(full_path, FileAccess.READ)
            if file:
                var modified_time = file.get_modified_time()

                if not last_modification_times.has(full_path):
                    last_modification_times[full_path] = modified_time
                elif last_modification_times[full_path] != modified_time:
                    last_modification_times[full_path] = modified_time
                    _on_file_changed(full_path)

                file.close()

        file_name = dir.get_next()

func _on_file_changed(file_path: String):
    print("Hot Reload: File changed - %s" % file_path)
    # Implementar lógica de hot-reload específica
```

## 🧪 Testing y QA

### Configurar Testing Framework

Instalar GUT (Godot Unit Testing):

```bash
# Opción 1: Via Asset Library en Godot
# Tools > Asset Library > Search "GUT" > Install

# Opción 2: Manual
git clone https://github.com/bitwes/Gut.git addons/gut
```

Crear `test/TestRunner.gd`:

```gdscript
extends GutTest

# Tests para ServiceManager
func test_service_manager_initialization():
    assert_not_null(ServiceManager)
    assert_true(ServiceManager.are_services_ready())

func test_service_manager_get_services():
    var config_service = ServiceManager.get_config_service()
    var audio_service = ServiceManager.get_audio_service()

    assert_not_null(config_service)
    assert_not_null(audio_service)

# Tests para Components
func test_health_component():
    var health_comp = HealthComponent.new()
    health_comp.max_health = 100
    health_comp.current_health = 100

    var damage_applied = health_comp.take_damage(25)
    assert_true(damage_applied)
    assert_eq(health_comp.current_health, 75)

    var heal_applied = health_comp.heal(10)
    assert_true(heal_applied)
    assert_eq(health_comp.current_health, 85)

# Tests para EventBus
func test_event_bus():
    var event_received = false

    EventBus.player_died.connect(func(): event_received = true)
    EventBus.player_died.emit()

    await get_tree().process_frame
    assert_true(event_received)
```

Script de testing `scripts/run_tests.sh`:

```bash
#!/bin/bash

echo "🧪 Running RougeLike Base Tests..."

# Ejecutar tests de GUT
godot --headless -s addons/gut/gut_cmdln.gd

# Verificar sintaxis
echo "🔍 Checking syntax..."
./scripts/check_syntax.sh

# Verificar estilo
echo "🎨 Checking code style..."
./scripts/check_style.sh

# Verificar estructura del proyecto
echo "📁 Verifying project structure..."
./scripts/verify_project.sh

echo "✅ All tests completed!"
```

### Configurar CI/CD

Crear `.github/workflows/ci.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Godot
      uses: chickensoft-games/setup-godot@v1
      with:
        version: 4.4.0
        include-templates: true

    - name: Import project
      run: |
        cd topdown-game
        godot --headless --import

    - name: Run syntax check
      run: |
        cd topdown-game
        ./scripts/check_syntax.sh

    - name: Run tests
      run: |
        cd topdown-game
        ./scripts/run_tests.sh

    - name: Build debug
      run: |
        cd topdown-game
        ./scripts/build_debug.sh

    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: debug-build
        path: topdown-game/builds/debug/
```

## 📊 Profiling y Performance

### Godot Profiler

```gdscript
# game/core/Profiler.gd
extends Node

var frame_times: Array[float] = []
var max_frame_time: float = 0.0
var avg_frame_time: float = 0.0

func _ready():
    if OS.is_debug_build():
        set_process(true)
    else:
        set_process(false)

func _process(delta):
    frame_times.append(delta)

    if frame_times.size() > 60:  # Keep last 60 frames
        frame_times.pop_front()

    max_frame_time = frame_times.max()
    avg_frame_time = frame_times.reduce(func(a, b): return a + b) / frame_times.size()

    # Detectar frame drops
    if delta > 0.02:  # > 20ms (< 50 FPS)
        Debug.log_warning("Frame drop detected: %.2fms" % (delta * 1000))

func get_performance_stats() -> Dictionary:
    return {
        "fps": Engine.get_frames_per_second(),
        "avg_frame_time": avg_frame_time * 1000,
        "max_frame_time": max_frame_time * 1000,
        "memory_usage": OS.get_static_memory_usage_by_type(),
        "process_memory": OS.get_static_memory_peak_usage()
    }
```

### Memory Profiling

```gdscript
# game/core/MemoryProfiler.gd
extends Node

var memory_samples: Array[Dictionary] = []

func _ready():
    if OS.is_debug_build():
        var timer = Timer.new()
        timer.wait_time = 5.0  # Sample every 5 seconds
        timer.timeout.connect(_sample_memory)
        add_child(timer)
        timer.start()

func _sample_memory():
    var sample = {
        "timestamp": Time.get_ticks_msec(),
        "static_memory": OS.get_static_memory_usage_by_type(),
        "peak_memory": OS.get_static_memory_peak_usage(),
        "object_count": Performance.get_monitor(Performance.OBJECT_COUNT),
        "nodes_count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
    }

    memory_samples.append(sample)

    # Keep only last 12 samples (1 hour at 5min intervals)
    if memory_samples.size() > 12:
        memory_samples.pop_front()

    # Detect memory leaks
    if memory_samples.size() > 2:
        var current = memory_samples[-1]
        var previous = memory_samples[-2]

        var memory_increase = current.static_memory - previous.static_memory
        if memory_increase > 1024 * 1024:  # > 1MB increase
            Debug.log_warning("Potential memory leak: +%.2fMB" % (memory_increase / 1024.0 / 1024.0))

func print_memory_report():
    print("=== MEMORY REPORT ===")
    if memory_samples.size() > 0:
        var latest = memory_samples[-1]
        print("Static Memory: %.2f MB" % (latest.static_memory / 1024.0 / 1024.0))
        print("Peak Memory: %.2f MB" % (latest.peak_memory / 1024.0 / 1024.0))
        print("Object Count: %d" % latest.object_count)
        print("Node Count: %d" % latest.nodes_count)
    print("==================")
```

## 🔍 Debugging Tools

### Debug Console

```gdscript
# game/ui/DebugConsole.gd
extends Control

var console_commands: Dictionary = {}
var command_history: Array[String] = []
var history_index: int = 0

@onready var input_line: LineEdit = $VBox/InputLine
@onready var output_text: RichTextLabel = $VBox/ScrollContainer/OutputText

func _ready():
    _register_default_commands()

    # Solo mostrar en debug builds
    visible = OS.is_debug_build()

func _register_default_commands():
    console_commands["help"] = _cmd_help
    console_commands["clear"] = _cmd_clear
    console_commands["fps"] = _cmd_fps
    console_commands["memory"] = _cmd_memory
    console_commands["services"] = _cmd_services
    console_commands["player"] = _cmd_player
    console_commands["teleport"] = _cmd_teleport

func _input(event):
    if event.is_action_pressed("ui_cancel") and Input.is_key_pressed(KEY_SHIFT):
        visible = not visible
        if visible:
            input_line.grab_focus()

func _on_input_line_text_submitted(text: String):
    if text.is_empty():
        return

    command_history.append(text)
    history_index = command_history.size()

    _execute_command(text)
    input_line.clear()

func _execute_command(command_text: String):
    var parts = command_text.split(" ")
    var command = parts[0].to_lower()
    var args = parts.slice(1)

    _add_output("> " + command_text)

    if console_commands.has(command):
        console_commands[command].call(args)
    else:
        _add_output("Unknown command: " + command + ". Type 'help' for available commands.")

func _add_output(text: String):
    output_text.append_text(text + "\n")

# Command implementations
func _cmd_help(args: Array):
    _add_output("Available commands:")
    for cmd in console_commands.keys():
        _add_output("  " + cmd)

func _cmd_clear(args: Array):
    output_text.clear()

func _cmd_fps(args: Array):
    _add_output("FPS: " + str(Engine.get_frames_per_second()))

func _cmd_memory(args: Array):
    var mem = OS.get_static_memory_usage_by_type()
    _add_output("Memory: %.2f MB" % (mem / 1024.0 / 1024.0))

func _cmd_services(args: Array):
    ServiceManager.print_services_status()

func _cmd_player(args: Array):
    var player = get_tree().get_first_node_in_group("player")
    if player and player.has_method("debug_info"):
        player.debug_info()
    else:
        _add_output("Player not found or debug info not available")

func _cmd_teleport(args: Array):
    if args.size() < 2:
        _add_output("Usage: teleport <x> <y>")
        return

    var player = get_tree().get_first_node_in_group("player")
    if player:
        player.global_position = Vector2(float(args[0]), float(args[1]))
        _add_output("Teleported player to (%s, %s)" % [args[0], args[1]])
    else:
        _add_output("Player not found")
```

## 📝 Workflow de Desarrollo

### Branching Strategy

```bash
# Feature branches
git checkout -b feature/new-component
# Desarrollar feature...
git add .
git commit -m "feat: add stamina component"
git push origin feature/new-component
# Crear Pull Request

# Hotfix branches
git checkout -b hotfix/critical-bug
# Arreglar bug...
git commit -m "fix: resolve player movement bug"
git push origin hotfix/critical-bug

# Release branches
git checkout -b release/v0.1.0
# Preparar release...
git commit -m "chore: prepare v0.1.0 release"
```

### Commit Convention

```bash
# Tipos de commits
feat: nueva funcionalidad
fix: corrección de bug
docs: cambios en documentación
style: formateo, punto y coma faltante, etc.
refactor: refactoring de código
test: agregar tests faltantes
chore: mantenimiento

# Ejemplos
git commit -m "feat: add inventory component"
git commit -m "fix: resolve health component initialization bug"
git commit -m "docs: update component system documentation"
git commit -m "refactor: simplify event bus implementation"
```

### Code Review Checklist

- [ ] **Funcionalidad**: ¿El código hace lo que se supone que debe hacer?
- [ ] **Testing**: ¿Hay tests para la nueva funcionalidad?
- [ ] **Performance**: ¿El código es eficiente?
- [ ] **Estilo**: ¿Sigue los estándares del proyecto?
- [ ] **Documentación**: ¿Está documentado adecuadamente?
- [ ] **Compatibilidad**: ¿Es compatible con sistemas existentes?
- [ ] **Seguridad**: ¿No introduce vulnerabilidades?

---

**Con esta configuración tendrás un entorno de desarrollo robusto y productivo.** Los scripts automatizan tareas repetitivas, el debugging te ayuda a diagnosticar problemas, y el workflow asegura calidad de código consistente.

*Siguiente paso: [Estándares de Código](coding-standards.md)*

*Última actualización: Septiembre 7, 2025*
