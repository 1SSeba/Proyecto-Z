# 🔧 Herramientas de Desarrollo - RougeLike Base

Esta documentación cubre las herramientas esenciales, utilidades de desarrollo y flujos de trabajo optimizados para maximizar la productividad al desarrollar en Godot 4.4.

## 🛠️ Stack de Herramientas

### 🎮 **Desarrollo Principal**

- **Godot 4.4**: Motor de juego principal
- **GDScript**: Lenguaje de programación principal
- **VS Code**: Editor de código con extensiones Godot
- **Git**: Control de versiones
- **GUT**: Framework de testing para Godot

### 🧪 **Testing y QA**

- **GUT (Godot Unit Test)**: Testing unitario y de integración
- **Godot Profiler**: Análisis de performance
- **Memory Profiler**: Detección de memory leaks
- **Debug Console**: Debugging en tiempo real

### 📊 **Análisis y Monitoreo**

- **Godot Remote Debugger**: Debugging remoto
- **Performance Monitor**: Métricas en tiempo real
- **Static Analysis**: Análisis estático de código
- **Coverage Tools**: Análisis de cobertura de tests

## 🎯 Configuración del Entorno

### VS Code Extensions

```json
// .vscode/extensions.json
{
    "recommendations": [
        "geequlim.godot-tools",           // Godot support
        "ms-vscode.vscode-json",          // JSON support
        "bradlc.vscode-tailwindcss",      // CSS utilities
        "formulahendry.auto-rename-tag",  // HTML tag support
        "ms-python.python",               // Python scripting
        "ms-vscode.cmake-tools",          // Build system
        "github.copilot",                 // AI assistance
        "github.copilot-chat",            // AI chat
        "gruntfuggly.todo-tree",          // TODO tracking
        "aaron-bond.better-comments",     // Enhanced comments
        "streetsidesoftware.code-spell-checker" // Spell checking
    ]
}
```

### Configuración de VS Code

```json
// .vscode/settings.json
{
    "godot_tools.editor_path": "/usr/bin/godot",
    "godot_tools.gdscript_lsp_server_port": 6005,
    "files.associations": {
        "*.gd": "gdscript",
        "*.cs": "csharp",
        "*.tscn": "text",
        "*.tres": "text"
    },
    "editor.insertSpaces": false,
    "editor.detectIndentation": false,
    "editor.tabSize": 4,
    "[gdscript]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": false
    },
    "godot_tools.scene_file_config": {
        "instantiate_scenes": true,
        "auto_build_project": true
    },
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "editor.rulers": [100],
    "todo-tree.general.tags": [
        "TODO",
        "FIXME",
        "HACK",
        "BUG",
        "NOTE"
    ]
}
```

### Snippets para GDScript

```json
// .vscode/gdscript.json
{
    "Component Class": {
        "prefix": "component",
        "body": [
            "extends Component",
            "class_name ${1:ComponentName}",
            "",
            "## ${2:Component description}",
            "",
            "signal ${3:signal_name}(${4:parameters})",
            "",
            "const ${5:CONSTANT_NAME}: ${6:Type} = ${7:value}",
            "",
            "@export var ${8:property_name}: ${9:Type} = ${10:default_value}",
            "",
            "var ${11:variable_name}: ${12:Type}",
            "",
            "func _ready():",
            "\tsuper()",
            "\t_initialize_component()",
            "",
            "func _initialize_component():",
            "\tcomponent_id = \"${1:ComponentName}\"",
            "\t${0}"
        ]
    },
    "Test Function": {
        "prefix": "test",
        "body": [
            "func test_${1:function_name}():",
            "\t\"\"\"${2:Test description}.\"\"\"",
            "\t# Arrange",
            "\t${3:setup}",
            "\t",
            "\t# Act",
            "\t${4:action}",
            "\t",
            "\t# Assert",
            "\tassert_${5:assertion}(${6:parameters})",
            "\t${0}"
        ]
    }
}
```

## 🎮 Herramientas de Godot

### Debug Console Avanzado

```gdscript
# game/core/tools/DebugConsole.gd
extends CanvasLayer
class_name DebugConsole

signal command_executed(command: String, result: Variant)

var commands: Dictionary = {}
var history: Array[String] = []
var history_index: int = -1

@onready var console_panel: Panel = $ConsolePanel
@onready var output_label: RichTextLabel = $ConsolePanel/VBox/OutputScroll/OutputLabel
@onready var input_line: LineEdit = $ConsolePanel/VBox/InputLine

func _ready():
    _register_default_commands()
    visible = false

    input_line.text_submitted.connect(_on_command_submitted)

func _input(event):
    if event.is_action_pressed("toggle_console"):
        toggle_console()
    elif visible and event.is_action_pressed("ui_up"):
        _navigate_history(-1)
    elif visible and event.is_action_pressed("ui_down"):
        _navigate_history(1)

func toggle_console():
    visible = !visible
    if visible:
        input_line.grab_focus()

func _register_default_commands():
    # Game commands
    register_command("help", _cmd_help, "Show available commands")
    register_command("quit", _cmd_quit, "Quit the game")
    register_command("restart", _cmd_restart, "Restart current scene")

    # Debug commands
    register_command("god", _cmd_god_mode, "Toggle god mode")
    register_command("speed", _cmd_set_speed, "Set player speed [value]")
    register_command("health", _cmd_set_health, "Set player health [value]")
    register_command("teleport", _cmd_teleport, "Teleport player [x] [y]")

    # Performance commands
    register_command("fps", _cmd_show_fps, "Toggle FPS display")
    register_command("memory", _cmd_memory_info, "Show memory usage")
    register_command("profiler", _cmd_toggle_profiler, "Toggle profiler")

    # Component commands
    register_command("components", _cmd_list_components, "List player components")
    register_command("services", _cmd_list_services, "List active services")

    # Scene commands
    register_command("scene", _cmd_change_scene, "Change scene [path]")
    register_command("reload", _cmd_reload_scene, "Reload current scene")

func register_command(name: String, callback: Callable, description: String = ""):
    commands[name] = {
        "callback": callback,
        "description": description
    }

func execute_command(command_line: String):
    var parts = command_line.strip_edges().split(" ", false)
    if parts.is_empty():
        return

    var command_name = parts[0].to_lower()
    var args = parts.slice(1)

    if command_name in commands:
        var result = commands[command_name].callback.call(args)
        _output_result(command_line, result)
        command_executed.emit(command_line, result)
    else:
        _output_error("Unknown command: %s. Type 'help' for available commands." % command_name)

    # Add to history
    if history.is_empty() or history[-1] != command_line:
        history.append(command_line)
    history_index = history.size()

func _output_result(command: String, result: Variant):
    var color = "green" if result != null else "white"
    output_label.append_text("[color=%s]> %s[/color]\n" % [color, command])
    if result != null:
        output_label.append_text("%s\n" % str(result))

func _output_error(error: String):
    output_label.append_text("[color=red]%s[/color]\n" % error)

# Command implementations
func _cmd_help(args: Array) -> String:
    var help_text = "Available commands:\n"
    for cmd_name in commands.keys():
        var desc = commands[cmd_name].description
        help_text += "  %s - %s\n" % [cmd_name, desc]
    return help_text

func _cmd_god_mode(args: Array) -> String:
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return "Player not found"

    var health_comp = player.get_node("HealthComponent")
    if health_comp:
        health_comp.invulnerable = !health_comp.invulnerable
        return "God mode: %s" % ("ON" if health_comp.invulnerable else "OFF")
    return "HealthComponent not found"

func _cmd_set_speed(args: Array) -> String:
    if args.is_empty():
        return "Usage: speed [value]"

    var speed = args[0].to_float()
    var player = get_tree().get_first_node_in_group("player")
    if player:
        player.movement_speed = speed
        return "Player speed set to %d" % speed
    return "Player not found"

func _cmd_memory_info(args: Array) -> String:
    var info = "Memory Usage:\n"
    info += "  Static: %s\n" % String.humanize_size(OS.get_static_memory_usage_by_type().get("total", 0))
    info += "  Dynamic: %s\n" % String.humanize_size(OS.get_dynamic_memory_usage())
    return info

func _cmd_list_components(args: Array) -> String:
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return "Player not found"

    var components_text = "Player Components:\n"
    for child in player.get_children():
        if child is Component:
            components_text += "  - %s (enabled: %s)\n" % [child.component_id, child.enabled]
    return components_text

func _on_command_submitted(text: String):
    if text.strip_edges().is_empty():
        return

    execute_command(text)
    input_line.clear()
```

### DebugService (nuevo)

El `DebugService` es un servicio simple cargado por `ServiceManager` que expone helpers para logging y utilidades asíncronas.

Ejemplo de uso:

```gdscript
# Obtener el servicio desde cualquier script
var dbg = ServiceManager.get_service("DebugService")
dbg.info("Juego inicializado")
await dbg.wait_frames(2)
dbg.print_after_frames("Mensaje después de 2 frames", 2)
```

### Performance Profiler

```gdscript
# game/core/tools/PerformanceProfiler.gd
extends Control
class_name PerformanceProfiler

var fps_history: Array[float] = []
var memory_history: Array[int] = []
var frame_time_history: Array[float] = []

@onready var fps_label: Label = $VBox/FPSLabel
@onready var memory_label: Label = $VBox/MemoryLabel
@onready var frame_time_label: Label = $VBox/FrameTimeLabel
@onready var graph: Control = $VBox/Graph

var update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.1  # Update every 100ms
const HISTORY_SIZE: int = 100

func _ready():
    visible = false

func _process(delta):
    update_timer += delta
    if update_timer >= UPDATE_INTERVAL:
        _update_metrics()
        update_timer = 0.0

func _update_metrics():
    # FPS
    var current_fps = Engine.get_frames_per_second()
    fps_history.append(current_fps)
    if fps_history.size() > HISTORY_SIZE:
        fps_history.pop_front()

    # Memory
    var current_memory = OS.get_static_memory_usage_by_type().get("total", 0)
    memory_history.append(current_memory)
    if memory_history.size() > HISTORY_SIZE:
        memory_history.pop_front()

    # Frame time
    var frame_time = get_process_delta_time() * 1000  # Convert to ms
    frame_time_history.append(frame_time)
    if frame_time_history.size() > HISTORY_SIZE:
        frame_time_history.pop_front()

    _update_labels()
    _update_graph()

func _update_labels():
    var avg_fps = _calculate_average(fps_history)
    var min_fps = fps_history.min() if not fps_history.is_empty() else 0
    var max_fps = fps_history.max() if not fps_history.is_empty() else 0

    fps_label.text = "FPS: %.1f (avg: %.1f, min: %.1f, max: %.1f)" % [
        Engine.get_frames_per_second(), avg_fps, min_fps, max_fps
    ]

    var current_memory = memory_history[-1] if not memory_history.is_empty() else 0
    memory_label.text = "Memory: %s" % String.humanize_size(current_memory)

    var avg_frame_time = _calculate_average(frame_time_history)
    frame_time_label.text = "Frame Time: %.2f ms (avg: %.2f ms)" % [
        frame_time_history[-1] if not frame_time_history.is_empty() else 0, avg_frame_time
    ]

func _update_graph():
    graph.queue_redraw()

func _draw():
    if fps_history.size() < 2:
        return

    var rect = graph.get_rect()
    var points: PackedVector2Array = []

    # Draw FPS graph
    for i in range(fps_history.size()):
        var x = (float(i) / float(fps_history.size() - 1)) * rect.size.x
        var normalized_fps = (fps_history[i] - 30.0) / 30.0  # Normalize around 30-60 FPS
        var y = rect.size.y - (normalized_fps * rect.size.y)
        points.append(Vector2(x, y))

    if points.size() > 1:
        graph.draw_polyline(points, Color.GREEN, 2.0)

func toggle_visibility():
    visible = !visible

func _calculate_average(array: Array) -> float:
    if array.is_empty():
        return 0.0
    return array.reduce(func(sum, val): return sum + val, 0.0) / array.size()
```

### Script de Generación de Assets

```bash
#!/bin/bash
# scripts/generate_assets.sh

echo "🎨 Generating game assets..."

PROJECT_ROOT=$(pwd)
ASSETS_DIR="$PROJECT_ROOT/game/assets"

# Create directories if they don't exist
mkdir -p "$ASSETS_DIR/generated/textures"
mkdir -p "$ASSETS_DIR/generated/animations"
mkdir -p "$ASSETS_DIR/generated/audio"

# Generate placeholder textures
generate_placeholder_texture() {
    local name=$1
    local size=$2
    local color=$3

    convert -size "${size}x${size}" "xc:$color" "$ASSETS_DIR/generated/textures/${name}.png"
    echo "Generated placeholder texture: $name.png (${size}x${size}, $color)"
}

# Check if ImageMagick is available
if command -v convert >/dev/null 2>&1; then
    echo "📷 Generating placeholder textures..."

    # Player textures
    generate_placeholder_texture "player_idle" 64 "#4A90E2"
    generate_placeholder_texture "player_run" 64 "#357ABD"
    generate_placeholder_texture "player_attack" 64 "#D0021B"

    # Enemy textures
    generate_placeholder_texture "enemy_basic" 48 "#F5A623"
    generate_placeholder_texture "enemy_strong" 64 "#BD10E0"

    # Item textures
    generate_placeholder_texture "health_potion" 32 "#7ED321"
    generate_placeholder_texture "mana_potion" 32 "#50E3C2"

    # Environment textures
    generate_placeholder_texture "wall" 32 "#8B572A"
    generate_placeholder_texture "floor" 32 "#F8E71C"
    generate_placeholder_texture "door" 32 "#9013FE"

else
    echo "⚠️  ImageMagick not found. Skipping texture generation."
fi

# Generate sprite sheets info
generate_sprite_info() {
    local name=$1
    local frames=$2
    local size=$3

    cat > "$ASSETS_DIR/generated/animations/${name}.json" << EOF
{
    "name": "$name",
    "frames": $frames,
    "frame_size": {
        "width": $size,
        "height": $size
    },
    "frame_duration": 0.1,
    "loop": true
}
EOF
    echo "Generated sprite info: $name.json"
}

echo "🎞️  Generating animation configs..."
generate_sprite_info "player_idle" 4 64
generate_sprite_info "player_run" 8 64
generate_sprite_info "player_attack" 6 64
generate_sprite_info "enemy_walk" 4 48

# Generate audio placeholder files (silence)
if command -v ffmpeg >/dev/null 2>&1; then
    echo "🔊 Generating placeholder audio..."

    # Generate short beep sounds
    ffmpeg -f lavfi -i "sine=frequency=440:duration=0.1" -ac 1 -ar 44100 "$ASSETS_DIR/generated/audio/beep.wav" -y 2>/dev/null
    ffmpeg -f lavfi -i "sine=frequency=220:duration=0.2" -ac 1 -ar 44100 "$ASSETS_DIR/generated/audio/damage.wav" -y 2>/dev/null
    ffmpeg -f lavfi -i "sine=frequency=880:duration=0.05" -ac 1 -ar 44100 "$ASSETS_DIR/generated/audio/pickup.wav" -y 2>/dev/null

    echo "Generated placeholder audio files"
else
    echo "⚠️  FFmpeg not found. Skipping audio generation."
fi

echo "✅ Asset generation completed!"
```

### Herramienta de Análisis de Código

```python
#!/usr/bin/env python3
# scripts/analyze_code.py

import os
import re
import json
from pathlib import Path
from collections import defaultdict

class GodotCodeAnalyzer:
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.game_path = self.project_path / "game"
        self.stats = defaultdict(int)
        self.issues = []

    def analyze(self):
        """Run full code analysis."""
        print("🔍 Analyzing Godot project...")

        for gd_file in self.game_path.rglob("*.gd"):
            self._analyze_file(gd_file)

        self._generate_report()

    def _analyze_file(self, file_path):
        """Analyze a single GDScript file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.split('\n')

            self.stats['total_files'] += 1
            self.stats['total_lines'] += len(lines)

            # Analyze content
            self._check_naming_conventions(file_path, content, lines)
            self._check_complexity(file_path, content, lines)
            self._check_documentation(file_path, content, lines)
            self._check_performance_issues(file_path, content, lines)

        except Exception as e:
            self.issues.append({
                'type': 'error',
                'file': str(file_path),
                'message': f"Failed to analyze: {e}"
            })

    def _check_naming_conventions(self, file_path, content, lines):
        """Check naming convention compliance."""
        # Check class names
        class_pattern = r'class_name\s+([A-Za-z_][A-Za-z0-9_]*)'
        for match in re.finditer(class_pattern, content):
            class_name = match.group(1)
            if not re.match(r'^[A-Z][A-Za-z0-9]*$', class_name):
                self.issues.append({
                    'type': 'naming',
                    'severity': 'warning',
                    'file': str(file_path),
                    'message': f"Class name '{class_name}' should use PascalCase"
                })

        # Check function names
        func_pattern = r'func\s+([A-Za-z_][A-Za-z0-9_]*)'
        for match in re.finditer(func_pattern, content):
            func_name = match.group(1)
            if not re.match(r'^[a-z_][a-z0-9_]*$', func_name):
                self.issues.append({
                    'type': 'naming',
                    'severity': 'warning',
                    'file': str(file_path),
                    'message': f"Function name '{func_name}' should use snake_case"
                })

        # Check constants
        const_pattern = r'const\s+([A-Za-z_][A-Za-z0-9_]*)'
        for match in re.finditer(const_pattern, content):
            const_name = match.group(1)
            if not re.match(r'^[A-Z][A-Z0-9_]*$', const_name):
                self.issues.append({
                    'type': 'naming',
                    'severity': 'info',
                    'file': str(file_path),
                    'message': f"Constant '{const_name}' should use UPPER_SNAKE_CASE"
                })

    def _check_complexity(self, file_path, content, lines):
        """Check code complexity metrics."""
        # Count functions
        func_count = len(re.findall(r'func\s+', content))
        self.stats['total_functions'] += func_count

        # Check function length
        in_function = False
        func_start = 0
        indent_level = 0

        for i, line in enumerate(lines):
            stripped = line.strip()

            if stripped.startswith('func '):
                if in_function:
                    func_length = i - func_start
                    if func_length > 50:
                        self.issues.append({
                            'type': 'complexity',
                            'severity': 'warning',
                            'file': str(file_path),
                            'line': func_start + 1,
                            'message': f"Function too long ({func_length} lines). Consider breaking it down."
                        })

                in_function = True
                func_start = i
                indent_level = len(line) - len(line.lstrip())

            elif in_function and line.strip() and len(line) - len(line.lstrip()) <= indent_level and not line.strip().startswith('#'):
                # End of function
                func_length = i - func_start
                if func_length > 50:
                    self.issues.append({
                        'type': 'complexity',
                        'severity': 'warning',
                        'file': str(file_path),
                        'line': func_start + 1,
                        'message': f"Function too long ({func_length} lines). Consider breaking it down."
                    })
                in_function = False

        # Check line length
        for i, line in enumerate(lines):
            if len(line) > 100:
                self.issues.append({
                    'type': 'style',
                    'severity': 'info',
                    'file': str(file_path),
                    'line': i + 1,
                    'message': f"Line too long ({len(line)} characters). Consider breaking it."
                })

    def _check_documentation(self, file_path, content, lines):
        """Check documentation coverage."""
        # Check for class documentation
        if 'class_name' in content and '##' not in content:
            self.issues.append({
                'type': 'documentation',
                'severity': 'info',
                'file': str(file_path),
                'message': "Class missing documentation comment"
            })

        # Check public functions for documentation
        func_pattern = r'func\s+([A-Za-z_][A-Za-z0-9_]*)'
        for match in re.finditer(func_pattern, content):
            func_name = match.group(1)
            if not func_name.startswith('_') and '##' not in content[max(0, match.start() - 200):match.start()]:
                self.issues.append({
                    'type': 'documentation',
                    'severity': 'info',
                    'file': str(file_path),
                    'message': f"Public function '{func_name}' missing documentation"
                })

    def _check_performance_issues(self, file_path, content, lines):
        """Check for potential performance issues."""
        # Check for get_node calls in _process or _physics_process
        if '_process(' in content or '_physics_process(' in content:
            if 'get_node(' in content or '$' in content:
                self.issues.append({
                    'type': 'performance',
                    'severity': 'warning',
                    'file': str(file_path),
                    'message': "Avoid get_node() calls in _process(). Use @onready variables instead."
                })

        # Check for string concatenation in loops
        loop_pattern = r'for\s+.*in.*:'
        for match in re.finditer(loop_pattern, content):
            loop_block = content[match.end():match.end() + 500]  # Check next 500 chars
            if '+=' in loop_block and 'str(' in loop_block:
                self.issues.append({
                    'type': 'performance',
                    'severity': 'warning',
                    'file': str(file_path),
                    'message': "String concatenation in loop. Consider using Array.join() or StringBuilder."
                })

    def _generate_report(self):
        """Generate analysis report."""
        print("\n📊 Code Analysis Report")
        print("=" * 50)

        # Summary statistics
        print(f"📁 Files analyzed: {self.stats['total_files']}")
        print(f"📄 Total lines: {self.stats['total_lines']}")
        print(f"⚙️  Total functions: {self.stats['total_functions']}")
        print(f"⚠️  Issues found: {len(self.issues)}")

        # Group issues by type
        issues_by_type = defaultdict(list)
        for issue in self.issues:
            issues_by_type[issue['type']].append(issue)

        # Print issues by category
        for issue_type, issues in issues_by_type.items():
            print(f"\n🔍 {issue_type.title()} Issues ({len(issues)}):")
            for issue in issues[:10]:  # Show first 10 issues
                severity_icon = {"error": "❌", "warning": "⚠️", "info": "ℹ️"}.get(issue.get('severity', 'info'), "ℹ️")
                print(f"  {severity_icon} {issue['message']}")
                print(f"     📁 {issue['file']}")
                if 'line' in issue:
                    print(f"     📍 Line {issue['line']}")

            if len(issues) > 10:
                print(f"     ... and {len(issues) - 10} more")

        # Save detailed report
        report_data = {
            'summary': dict(self.stats),
            'issues': self.issues,
            'timestamp': str(Path.cwd())
        }

        report_path = self.project_path / "docs" / "analysis" / "code_analysis.json"
        report_path.parent.mkdir(parents=True, exist_ok=True)

        with open(report_path, 'w') as f:
            json.dump(report_data, f, indent=2)

        print(f"\n💾 Detailed report saved to: {report_path}")

if __name__ == "__main__":
    import sys

    project_path = sys.argv[1] if len(sys.argv) > 1 else "."
    analyzer = GodotCodeAnalyzer(project_path)
    analyzer.analyze()
```

## 🧪 Herramientas de Testing

### Test Runner Avanzado

```gdscript
# tests/advanced_test_runner.gd
extends SceneTree
class_name AdvancedTestRunner

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0
var test_results: Array[Dictionary] = []

func _init():
    var gut = GUT.new()
    _configure_gut(gut)

    # Add test directories
    gut.add_directory("res://tests/unit", "test_", true)
    gut.add_directory("res://tests/integration", "test_", true)

    # Connect to GUT signals
    gut.test_script_started.connect(_on_test_script_started)
    gut.test_started.connect(_on_test_started)
    gut.test_passed.connect(_on_test_passed)
    gut.test_failed.connect(_on_test_failed)
    gut.tests_finished.connect(_on_tests_finished)

    add_child(gut)
    gut.test_scripts()

func _configure_gut(gut: GUT):
    gut.log_level = GUT.LOG_LEVEL_INFO
    gut.should_exit = true
    gut.should_exit_on_success = false
    gut.should_maximize = false
    gut.should_print_to_console = true

func _on_test_script_started(script_path: String):
    print("🧪 Running tests in: %s" % script_path)

func _on_test_started(test_name: String):
    total_tests += 1

func _on_test_passed(test_name: String):
    passed_tests += 1
    test_results.append({
        "name": test_name,
        "result": "PASSED",
        "timestamp": Time.get_datetime_string_from_system()
    })

func _on_test_failed(test_name: String):
    failed_tests += 1
    test_results.append({
        "name": test_name,
        "result": "FAILED",
        "timestamp": Time.get_datetime_string_from_system()
    })

func _on_tests_finished():
    _generate_report()
    _exit_with_code()

func _generate_report():
    print("\n" + "="*60)
    print("🧪 TEST RESULTS SUMMARY")
    print("="*60)
    print("📊 Total Tests: %d" % total_tests)
    print("✅ Passed: %d" % passed_tests)
    print("❌ Failed: %d" % failed_tests)
    print("📈 Success Rate: %.1f%%" % (float(passed_tests) / float(total_tests) * 100.0))

    # Generate HTML report
    _generate_html_report()

    # Generate JUnit XML (for CI)
    _generate_junit_xml()

func _generate_html_report():
    var html_content = """
<!DOCTYPE html>
<html>
<head>
    <title>Test Results - RougeLike Base</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f4f4f4; padding: 20px; border-radius: 5px; }
        .passed { color: green; }
        .failed { color: red; }
        .summary { margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧪 Test Results - RougeLike Base</h1>
        <p>Generated: %s</p>
    </div>

    <div class="summary">
        <h2>📊 Summary</h2>
        <p><strong>Total Tests:</strong> %d</p>
        <p><strong class="passed">Passed:</strong> %d</p>
        <p><strong class="failed">Failed:</strong> %d</p>
        <p><strong>Success Rate:</strong> %.1f%%</p>
    </div>

    <h2>📋 Test Details</h2>
    <table>
        <tr>
            <th>Test Name</th>
            <th>Result</th>
            <th>Timestamp</th>
        </tr>
""" % [
        Time.get_datetime_string_from_system(),
        total_tests,
        passed_tests,
        failed_tests,
        float(passed_tests) / float(total_tests) * 100.0
    ]

    for result in test_results:
        var css_class = "passed" if result.result == "PASSED" else "failed"
        html_content += """
        <tr>
            <td>%s</td>
            <td class="%s">%s</td>
            <td>%s</td>
        </tr>
""" % [result.name, css_class, result.result, result.timestamp]

    html_content += """
    </table>
</body>
</html>
"""

    var file = FileAccess.open("tests/results/report.html", FileAccess.WRITE)
    if file:
        file.store_string(html_content)
        file.close()
        print("📄 HTML report generated: tests/results/report.html")

func _generate_junit_xml():
    var xml_content = """<?xml version="1.0" encoding="UTF-8"?>
<testsuites tests="%d" failures="%d" time="0">
    <testsuite name="RougeLike Base Tests" tests="%d" failures="%d">
""" % [total_tests, failed_tests, total_tests, failed_tests]

    for result in test_results:
        xml_content += """        <testcase name="%s" classname="GDScript">
""" % result.name

        if result.result == "FAILED":
            xml_content += """            <failure message="Test failed"/>
"""

        xml_content += """        </testcase>
"""

    xml_content += """    </testsuite>
</testsuites>"""

    var file = FileAccess.open("tests/results/junit.xml", FileAccess.WRITE)
    if file:
        file.store_string(xml_content)
        file.close()
        print("📄 JUnit XML generated: tests/results/junit.xml")

func _exit_with_code():
    var exit_code = 0 if failed_tests == 0 else 1
    quit(exit_code)
```

## 🚀 Scripts de Automatización

### Build y Deploy Script

```bash
#!/bin/bash
# scripts/build_and_deploy.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="rougelike-base"
GODOT_VERSION="4.4.0"
BUILD_DIR="builds"
PLATFORMS=("linux" "windows" "web")

echo -e "${GREEN}🚀 Starting build and deploy process...${NC}"

# Function to print colored output
log_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v godot &> /dev/null; then
        log_error "Godot not found. Please install Godot $GODOT_VERSION"
        exit 1
    fi

    local godot_version=$(godot --version 2>&1 | head -n1)
    log_info "Using Godot: $godot_version"
}

# Run tests
run_tests() {
    log_info "Running tests..."

    if ! godot --headless --script tests/run_tests.gd; then
        log_error "Tests failed. Aborting build."
        exit 1
    fi

    log_info "All tests passed ✅"
}

# Build for specific platform
build_platform() {
    local platform=$1
    local export_name=""
    local export_path=""

    case $platform in
        "linux")
            export_name="Linux/X11"
            export_path="$BUILD_DIR/linux/$PROJECT_NAME"
            ;;
        "windows")
            export_name="Windows Desktop"
            export_path="$BUILD_DIR/windows/$PROJECT_NAME.exe"
            ;;
        "web")
            export_name="Web"
            export_path="$BUILD_DIR/web/index.html"
            ;;
        *)
            log_error "Unknown platform: $platform"
            return 1
            ;;
    esac

    log_info "Building for $platform..."

    # Create build directory
    mkdir -p "$(dirname "$export_path")"

    # Export the project
    if godot --headless --export-release "$export_name" "$export_path"; then
        log_info "$platform build completed ✅"

        # Create archive
        local archive_name="$PROJECT_NAME-$platform-$(date +%Y%m%d-%H%M%S)"
        case $platform in
            "linux"|"windows")
                cd "$(dirname "$export_path")"
                tar -czf "../$archive_name.tar.gz" *
                cd - > /dev/null
                ;;
            "web")
                cd "$BUILD_DIR/web"
                zip -r "../$archive_name.zip" *
                cd - > /dev/null
                ;;
        esac

        log_info "Archive created: $archive_name"
    else
        log_error "Failed to build for $platform"
        return 1
    fi
}

# Generate build info
generate_build_info() {
    log_info "Generating build information..."

    local build_info_file="$BUILD_DIR/build_info.json"

    cat > "$build_info_file" << EOF
{
    "project_name": "$PROJECT_NAME",
    "build_timestamp": "$(date -Iseconds)",
    "git_commit": "$(git rev-parse HEAD)",
    "git_branch": "$(git rev-parse --abbrev-ref HEAD)",
    "godot_version": "$(godot --version 2>&1 | head -n1)",
    "platforms": $(printf '%s\n' "${PLATFORMS[@]}" | jq -R . | jq -s .),
    "build_number": "${BUILD_NUMBER:-$(date +%Y%m%d%H%M%S)}"
}
EOF

    log_info "Build info saved to $build_info_file"
}

# Upload to itch.io (if configured)
upload_to_itch() {
    local platform=$1

    if [[ -z "$ITCH_IO_API_KEY" ]] || [[ -z "$ITCH_IO_USER" ]] || [[ -z "$ITCH_IO_GAME" ]]; then
        log_warning "Itch.io credentials not configured. Skipping upload."
        return 0
    fi

    log_info "Uploading $platform build to itch.io..."

    if command -v butler &> /dev/null; then
        local build_path="$BUILD_DIR/$platform"
        butler push "$build_path" "$ITCH_IO_USER/$ITCH_IO_GAME:$platform"
        log_info "$platform uploaded to itch.io ✅"
    else
        log_warning "Butler not installed. Skipping itch.io upload."
    fi
}

# Main execution
main() {
    local skip_tests=false
    local upload=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-tests)
                skip_tests=true
                shift
                ;;
            --upload)
                upload=true
                shift
                ;;
            --platforms)
                IFS=',' read -ra PLATFORMS <<< "$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Usage: $0 [--skip-tests] [--upload] [--platforms linux,windows,web]"
                exit 1
                ;;
        esac
    done

    # Execute build pipeline
    check_dependencies

    if [[ "$skip_tests" == false ]]; then
        run_tests
    else
        log_warning "Skipping tests as requested"
    fi

    # Clean previous builds
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"

    # Build for all platforms
    local failed_builds=()
    for platform in "${PLATFORMS[@]}"; do
        if ! build_platform "$platform"; then
            failed_builds+=("$platform")
        fi

        if [[ "$upload" == true ]]; then
            upload_to_itch "$platform"
        fi
    done

    generate_build_info

    # Report results
    if [[ ${#failed_builds[@]} -eq 0 ]]; then
        log_info "All builds completed successfully! 🎉"
    else
        log_error "Some builds failed: ${failed_builds[*]}"
        exit 1
    fi
}

# Run main function
main "$@"
```

---

**Las herramientas de desarrollo son multiplicadores de productividad.** Una buena configuración de herramientas te permite enfocarte en crear gameplay increíble en lugar de luchar con procesos manuales.

**Recuerda**: Invierte tiempo en automatizar tareas repetitivas. El tiempo invertido en scripting se recupera rápidamente.

*Finalización de la sección de desarrollo*

*Última actualización: Septiembre 7, 2025*
