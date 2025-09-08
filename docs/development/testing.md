# 🧪 Guía de Testing - RougeLike Base

Una estrategia completa de testing asegura que nuestro juego sea estable, mantenible y libre de regresiones. Esta guía cubre todos los aspectos del testing en Godot con GDScript.

## 🎯 Filosofía de Testing

### 🧭 **Principios Fundamentales**

1. **Confianza**: Los tests deben dar confianza en que el código funciona
2. **Velocidad**: Tests rápidos para feedback inmediato
3. **Aislamiento**: Cada test debe ser independiente
4. **Mantenibilidad**: Tests fáciles de entender y modificar
5. **Cobertura**: Testing de casos críticos y edge cases

### 📊 **Pirámide de Testing**

```
                    🔺 Manual Testing (pocos)
                   🔺🔺 Integration Tests (algunos)
              🔺🔺🔺🔺 Unit Tests (muchos)
```

- **Unit Tests**: Prueban componentes individuales aisladamente
- **Integration Tests**: Prueban interacciones entre componentes
- **Manual Testing**: Verificación manual de gameplay y UX

## 🛠️ Configuración de Testing

### Instalación de GUT (Godot Unit Test)

```bash
# Método 1: Asset Library
# 1. Abrir Godot Editor
# 2. Ir a AssetLib
# 3. Buscar "Gut"
# 4. Instalar y configurar

# Método 2: Manual
mkdir -p addons
cd addons
git clone https://github.com/bitwes/Gut.git gut
```

### Estructura de Directorios

```
tests/
├── README.md                    # Documentación de tests
├── run_tests.gd                 # Script para ejecutar todos los tests
├── test_runner.tscn             # Escena para correr tests
├── unit/                        # Unit tests
│   ├── components/
│   │   ├── test_health_component.gd
│   │   ├── test_movement_component.gd
│   │   └── test_component_base.gd
│   ├── services/
│   │   ├── test_service_manager.gd
│   │   ├── test_audio_service.gd
│   │   └── test_config_service.gd
│   ├── entities/
│   │   ├── test_player.gd
│   │   └── test_enemy.gd
│   └── systems/
│       ├── test_game_state_manager.gd
│       └── test_event_bus.gd
├── integration/                 # Integration tests
│   ├── test_player_health_integration.gd
│   ├── test_service_initialization.gd
│   └── test_scene_transitions.gd
├── fixtures/                    # Test data y helpers
│   ├── test_helpers.gd
│   ├── mock_services.gd
│   └── test_data.gd
└── performance/                 # Performance tests
    ├── test_component_performance.gd
    └── test_memory_usage.gd
```

### Configuración de GUT

```gdscript
# tests/run_tests.gd
extends SceneTree

func _init():
    var gut = GUT.new()

    # Configuración
    gut.log_level = gut.LOG_LEVEL_INFO
    gut.should_exit = true
    gut.should_exit_on_success = false

    # Directorios de tests
    gut.add_directory("res://tests/unit")
    gut.add_directory("res://tests/integration")

    # Ejecutar tests
    add_child(gut)
    gut.test_scripts()
```

## 📝 Writing Unit Tests

### Estructura Básica de Test

```gdscript
# tests/unit/components/test_health_component.gd
extends GutTest
class_name TestHealthComponent

# Variables de test
var health_component: HealthComponent
var mock_owner: Node2D

func before_each():
    """Setup ejecutado antes de cada test."""
    mock_owner = Node2D.new()
    health_component = HealthComponent.new()
    mock_owner.add_child(health_component)

    # Configurar estado inicial
    health_component.max_health = 100
    health_component.current_health = 100

func after_each():
    """Cleanup ejecutado después de cada test."""
    if mock_owner:
        mock_owner.queue_free()
    mock_owner = null
    health_component = null

func test_component_initialization():
    """Verificar que el componente se inicializa correctamente."""
    assert_eq(health_component.max_health, 100, "Max health should be 100")
    assert_eq(health_component.current_health, 100, "Current health should start at max")
    assert_true(health_component.is_alive, "Component should start alive")
    assert_false(health_component.invulnerable, "Component should not start invulnerable")

func test_take_damage_normal():
    """Test damage under normal conditions."""
    var damage_taken = health_component.take_damage(25)

    assert_true(damage_taken, "Damage should be applied")
    assert_eq(health_component.current_health, 75, "Health should be reduced by damage")
    assert_true(health_component.is_alive, "Component should still be alive")

func test_take_damage_lethal():
    """Test damage that kills the component."""
    var signal_watcher = watch_signals(health_component)

    var damage_taken = health_component.take_damage(150)

    assert_true(damage_taken, "Lethal damage should be applied")
    assert_eq(health_component.current_health, 0, "Health should not go below 0")
    assert_false(health_component.is_alive, "Component should be dead")
    assert_signal_emitted(health_component, "health_depleted", "Death signal should be emitted")

func test_take_damage_while_invulnerable():
    """Test damage while invulnerable."""
    health_component.invulnerable = true

    var damage_taken = health_component.take_damage(50)

    assert_false(damage_taken, "Damage should not be applied while invulnerable")
    assert_eq(health_component.current_health, 100, "Health should remain unchanged")

func test_take_damage_invalid_amounts():
    """Test edge cases for damage amounts."""
    # Negative damage
    var result1 = health_component.take_damage(-10)
    assert_false(result1, "Negative damage should not be applied")

    # Zero damage
    var result2 = health_component.take_damage(0)
    assert_false(result2, "Zero damage should not be applied")

    assert_eq(health_component.current_health, 100, "Health should remain unchanged")

func test_heal():
    """Test healing functionality."""
    # Damage first
    health_component.take_damage(50)
    assert_eq(health_component.current_health, 50)

    # Heal
    var healed = health_component.heal(25)

    assert_true(healed, "Healing should be successful")
    assert_eq(health_component.current_health, 75, "Health should increase")

func test_heal_beyond_max():
    """Test healing beyond max health."""
    health_component.take_damage(25)

    var healed = health_component.heal(50)  # More than damage taken

    assert_true(healed, "Healing should be successful")
    assert_eq(health_component.current_health, 100, "Health should cap at max_health")

func test_signals_emitted():
    """Test that appropriate signals are emitted."""
    var signal_watcher = watch_signals(health_component)

    # Test damage signal
    health_component.take_damage(25)
    assert_signal_emitted_with_parameters(
        health_component,
        "health_changed",
        [75, 100],
        "Health changed signal should be emitted with correct parameters"
    )

    # Test death signal
    health_component.take_damage(100)
    assert_signal_emitted(health_component, "health_depleted", "Death signal should be emitted")

func test_regeneration():
    """Test health regeneration over time."""
    health_component.regeneration_rate = 10.0  # 10 health per second
    health_component.take_damage(50)

    # Simulate time passing
    await wait_frames(60)  # 1 second at 60fps

    # Check if health regenerated
    assert_gt(health_component.current_health, 50, "Health should regenerate over time")
```

### Patterns para Testing Específico de Godot

#### Testing de Componentes con Dependencies

```gdscript
func test_component_with_service_dependencies():
    """Test component that depends on services."""
    # Arrange - Crear mock services
    var mock_audio_service = MockAudioService.new()
    var mock_config_service = MockConfigService.new()

    # Inject dependencies
    health_component.set_audio_service(mock_audio_service)
    health_component.set_config_service(mock_config_service)

    # Act
    health_component.take_damage(25)

    # Assert
    assert_true(mock_audio_service.play_sfx_called, "Should play damage sound")
    assert_eq(mock_audio_service.last_sfx_played, "damage_taken", "Should play correct sound")
```

#### Testing de Señales

```gdscript
func test_complex_signal_interaction():
    """Test complex signal chains."""
    var signal_watcher = watch_signals(health_component)

    # Setup signal listening
    health_component.health_changed.connect(_on_health_changed)
    health_component.health_depleted.connect(_on_health_depleted)

    # Trigger events
    health_component.take_damage(100)

    # Verify signal chain
    assert_signal_emit_count(health_component, "health_changed", 1)
    assert_signal_emit_count(health_component, "health_depleted", 1)

var _health_changed_called = false
var _health_depleted_called = false

func _on_health_changed(current: int, maximum: int):
    _health_changed_called = true

func _on_health_depleted(entity: Node):
    _health_depleted_called = true
```

#### Testing de Scene Loading

```gdscript
func test_scene_instantiation():
    """Test that scenes load correctly with all components."""
    var player_scene = preload("res://game/entities/characters/Player.tscn")
    var player_instance = player_scene.instantiate()

    add_child_autofree(player_instance)  # GUT helper for cleanup

    # Verify components exist
    var health_comp = player_instance.get_node("HealthComponent")
    var movement_comp = player_instance.get_node("MovementComponent")

    assert_not_null(health_comp, "Player should have HealthComponent")
    assert_not_null(movement_comp, "Player should have MovementComponent")
    assert_true(health_comp is HealthComponent, "Should be correct component type")
```

## 🔗 Integration Tests

### Testing Service Integration

```gdscript
# tests/integration/test_service_initialization.gd
extends GutTest
class_name TestServiceInitialization

var service_manager: ServiceManager

func before_each():
    service_manager = ServiceManager.new()

func after_each():
    if service_manager:
        service_manager.cleanup()
        service_manager.queue_free()

func test_service_initialization_order():
    """Test that services initialize in correct order."""
    service_manager.initialize_all_services()

    # Verify all services are created
    assert_not_null(service_manager.get_service("ConfigService"))
    assert_not_null(service_manager.get_service("AudioService"))
    assert_not_null(service_manager.get_service("InputService"))

    # Verify initialization order (config should be first)
    var config_service = service_manager.get_service("ConfigService")
    assert_true(config_service.is_ready, "ConfigService should initialize first")

func test_service_dependencies():
    """Test that service dependencies are properly resolved."""
    service_manager.initialize_all_services()

    var audio_service = service_manager.get_service("AudioService")
    var config_service = service_manager.get_service("ConfigService")

    # AudioService should have reference to ConfigService
    assert_not_null(audio_service.config_service, "AudioService should have config dependency")
    assert_same(audio_service.config_service, config_service, "Should reference same instance")
```

### Testing Player-Health Integration

```gdscript
# tests/integration/test_player_health_integration.gd
extends GutTest
class_name TestPlayerHealthIntegration

var player: Player
var health_component: HealthComponent

func before_each():
    var player_scene = preload("res://game/entities/characters/Player.tscn")
    player = player_scene.instantiate()
    add_child_autofree(player)

    health_component = player.get_node("HealthComponent")

func test_player_dies_when_health_depleted():
    """Test full player death flow."""
    var signal_watcher = watch_signals(EventBus)

    # Damage player to death
    health_component.take_damage(health_component.max_health)

    # Wait for death processing
    await wait_frames(5)

    # Verify death state
    assert_false(health_component.is_alive, "Health component should be dead")
    assert_signal_emitted(EventBus, "player_died", "EventBus should emit player_died")

func test_player_animation_changes_with_health():
    """Test that player animations reflect health state."""
    var sprite = player.get_node("AnimatedSprite2D")

    # Normal health
    assert_eq(sprite.modulate, Color.WHITE, "Player should be normal color at full health")

    # Low health
    health_component.take_damage(90)  # Leave 10 health
    await wait_frames(5)

    # Should have visual indicator of low health
    assert_ne(sprite.modulate, Color.WHITE, "Player should have different color at low health")
```

## 🎭 Mocking y Test Doubles

### Creating Mock Services

```gdscript
# tests/fixtures/mock_services.gd
extends RefCounted
class_name MockServices

class MockAudioService extends AudioService:
    var play_sfx_called: bool = false
    var last_sfx_played: String = ""
    var play_music_called: bool = false
    var last_music_played: String = ""

    func play_sfx(sfx_name: String, volume: float = 0.0):
        play_sfx_called = true
        last_sfx_played = sfx_name

    func play_music(music_name: String, fade_in: float = 0.0):
        play_music_called = true
        last_music_played = music_name

    func reset_mock():
        play_sfx_called = false
        last_sfx_played = ""
        play_music_called = false
        last_music_played = ""

class MockConfigService extends ConfigService:
    var _mock_config: Dictionary = {}

    func get_setting(key: String, default_value = null):
        return _mock_config.get(key, default_value)

    func set_setting(key: String, value):
        _mock_config[key] = value

    func set_mock_config(config: Dictionary):
        _mock_config = config

class MockInputService extends InputService:
    var _simulated_inputs: Dictionary = {}

    func is_action_pressed(action: String) -> bool:
        return _simulated_inputs.get(action + "_pressed", false)

    func is_action_just_pressed(action: String) -> bool:
        return _simulated_inputs.get(action + "_just_pressed", false)

    func simulate_input(action: String, pressed: bool = true, just_pressed: bool = false):
        _simulated_inputs[action + "_pressed"] = pressed
        _simulated_inputs[action + "_just_pressed"] = just_pressed

    func clear_simulated_inputs():
        _simulated_inputs.clear()
```

### Using Mocks in Tests

```gdscript
func test_player_movement_with_mock_input():
    """Test player movement using mocked input."""
    var mock_input = MockServices.MockInputService.new()
    player.set_input_service(mock_input)

    # Simulate W key pressed
    mock_input.simulate_input("move_up", true)

    # Process movement
    await wait_frames(10)

    # Verify movement occurred
    assert_gt(player.velocity.y, 0, "Player should move up when W is pressed")
```

## ⚡ Performance Testing

### Testing Performance Characteristics

```gdscript
# tests/performance/test_component_performance.gd
extends GutTest
class_name TestComponentPerformance

func test_health_component_performance():
    """Test that HealthComponent operations are performant."""
    var components: Array[HealthComponent] = []

    # Create many components
    for i in range(1000):
        var comp = HealthComponent.new()
        components.append(comp)

    # Measure damage processing time
    var start_time = Time.get_ticks_msec()

    for comp in components:
        comp.take_damage(10)

    var end_time = Time.get_ticks_msec()
    var total_time = end_time - start_time

    # Assert reasonable performance (less than 100ms for 1000 operations)
    assert_lt(total_time, 100, "Damage processing should complete within 100ms")

    # Cleanup
    for comp in components:
        comp.queue_free()

func test_memory_usage():
    """Test for memory leaks in component lifecycle."""
    var initial_memory = OS.get_static_memory_usage_by_type()

    # Create and destroy many components
    for i in range(100):
        var comp = HealthComponent.new()
        comp.queue_free()

    # Force garbage collection
    await wait_frames(10)

    var final_memory = OS.get_static_memory_usage_by_type()

    # Memory usage should not grow significantly
    var memory_diff = final_memory.get("HealthComponent", 0) - initial_memory.get("HealthComponent", 0)
    assert_lt(memory_diff, 1024, "Should not leak significant memory")
```

## 🎯 Test Organization y Best Practices

### Test Naming Conventions

```gdscript
# ✅ Good test names
func test_take_damage_reduces_health():
func test_heal_cannot_exceed_max_health():
func test_invulnerable_component_ignores_damage():
func test_component_emits_death_signal_when_health_reaches_zero():

# ❌ Bad test names
func test1():
func test_damage():
func test_stuff():
func test_component():
```

### AAA Pattern (Arrange, Act, Assert)

```gdscript
func test_weapon_switching():
    # Arrange - Setup test conditions
    var weapon_component = WeaponComponent.new()
    weapon_component.weapon_data = [sword_data, bow_data, staff_data]
    weapon_component.current_weapon_index = 0

    # Act - Perform the action being tested
    var result = weapon_component.switch_to_next_weapon()

    # Assert - Verify expected outcomes
    assert_true(result, "Weapon switch should succeed")
    assert_eq(weapon_component.current_weapon_index, 1, "Should switch to next weapon")
    assert_eq(weapon_component.get_current_weapon(), bow_data, "Should have bow equipped")
```

### Test Data Management

```gdscript
# tests/fixtures/test_data.gd
extends RefCounted
class_name TestData

static func create_sample_weapon_data() -> WeaponData:
    var weapon = WeaponData.new()
    weapon.name = "Test Sword"
    weapon.damage = 25
    weapon.attack_speed = 1.5
    weapon.range = 100
    return weapon

static func create_test_player() -> Player:
    var player = Player.new()
    player.max_health = 100
    player.current_health = 100
    player.movement_speed = 150.0
    return player

static func create_mock_game_state() -> Dictionary:
    return {
        "level": 1,
        "score": 1000,
        "player_position": Vector2(100, 100),
        "enemies_defeated": 5
    }
```

## 🚀 Automatización y CI/CD

### Script de Ejecución Automática

```bash
#!/bin/bash
# scripts/run_tests.sh

echo "🧪 Running automated tests..."

# Set test environment
export GODOT_TEST_MODE=true
export DISPLAY=:99

# Start virtual display for headless testing
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
XVFB_PID=$!

# Run unit tests
echo "🔬 Running unit tests..."
godot --headless --script tests/run_tests.gd

# Check test results
if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
    TEST_RESULT=0
else
    echo "❌ Some tests failed!"
    TEST_RESULT=1
fi

# Cleanup
kill $XVFB_PID > /dev/null 2>&1

exit $TEST_RESULT
```

### GitHub Actions Workflow

```yaml
# .github/workflows/tests.yml
name: 🧪 Run Tests

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
        use-dotnet: false

    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y xvfb

    - name: Import project
      run: godot --headless --import

    - name: Run tests
      run: |
        xvfb-run -a godot --headless --script tests/run_tests.gd

    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: tests/results/
```

## 📊 Test Coverage y Reporting

### Coverage Analysis

```gdscript
# tests/coverage_analyzer.gd
extends SceneTree

func _init():
    var analyzer = CoverageAnalyzer.new()

    # Analyze coverage for specific files
    var files_to_analyze = [
        "res://game/core/components/HealthComponent.gd",
        "res://game/core/components/MovementComponent.gd",
        "res://game/core/ServiceManager.gd"
    ]

    for file_path in files_to_analyze:
        var coverage = analyzer.analyze_file(file_path)
        print("Coverage for %s: %.1f%%" % [file_path, coverage.percentage])

    quit()
```

### Test Reporting

```gdscript
# tests/test_reporter.gd
extends RefCounted
class_name TestReporter

static func generate_html_report(test_results: Array):
    var html = """
    <!DOCTYPE html>
    <html>
    <head><title>Test Results</title></head>
    <body>
        <h1>RougeLike Base - Test Results</h1>
        <div class="summary">
            <p>Total Tests: %d</p>
            <p>Passed: %d</p>
            <p>Failed: %d</p>
        </div>
    """ % [test_results.size(), _count_passed(test_results), _count_failed(test_results)]

    for result in test_results:
        html += _format_test_result(result)

    html += "</body></html>"

    var file = FileAccess.open("tests/results/report.html", FileAccess.WRITE)
    file.store_string(html)
    file.close()

static func _count_passed(results: Array) -> int:
    return results.filter(func(r): return r.passed).size()

static func _count_failed(results: Array) -> int:
    return results.filter(func(r): return not r.passed).size()
```

---

**Testing es una inversión a largo plazo.** Tests bien escritos te ahorran tiempo en debugging y te dan confianza para hacer cambios audaces en tu codebase.

**Recuerda**: No busques 100% de coverage, busca testing efectivo de la funcionalidad crítica y casos edge importantes.

*Siguiente paso: [Development Tools](tools.md)*

*Última actualización: Septiembre 7, 2025*
