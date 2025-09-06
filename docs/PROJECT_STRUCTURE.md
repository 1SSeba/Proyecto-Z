# Project Structure - Topdown Game

## 📁 Root Directory
```
topdown-game/
├── 📂 .git/                 # Git repository
├── 📂 .godot/               # Godot cache and temp files
├── 📂 .vscode/              # VSCode settings
├── 📂 builds/               # Export builds
├── 📂 config/               # Configuration files
│   └── export_presets.cfg   # Export presets
├── 📂 docs/                 # Project documentation
├── 📂 game/                 # Main game source code
├── 📄 project.godot         # Godot project file
├── 📄 default_bus_layout.tres # Audio bus layout
└── 📄 README.md            # Project overview
```

## 🎮 Game Directory Structure

### 📂 game/
Main source code organized by function:

```
game/
├── 📂 assets/              # Art, audio, and other resources
│   ├── 📂 Audio/          # Sound effects and music
│   ├── 📂 Characters/     # Character sprites and animations
│   ├── 📂 Maps/           # Map textures and tiles
│   └── 📂 Ui/             # UI graphics and themes
│
├── 📂 core/               # Core systems and framework
│   ├── 📄 ServiceManager.gd    # Service management system
│   ├── 📂 components/     # Reusable components
│   ├── 📂 events/         # Event system (EventBus)
│   └── 📂 services/       # Core services (Audio, Config, etc.)
│
├── 📂 entities/           # Game entities and objects
│   ├── 📂 characters/     # Player and NPCs
│   └── 📂 Room/           # Room entity definition
│
├── 📂 scenes/            # Scene files (.tscn)
│   ├── 📄 Main.tscn      # Main game scene
│   ├── 📂 Characters/    # Character scenes
│   └── 📂 Menus/         # Menu scenes
│
├── 📂 systems/           # Game systems (organized by category)
│   ├── 📂 dungeon/       # Dungeon generation systems
│   │   ├── 📄 RoomsSystem.gd      # Room management
│   │   ├── 📄 RoomGenerator.gd    # Room generation
│   │   └── 📄 CorridorGenerator.gd # Corridor generation
│   └── 📂 game-state/    # Game state management
│       ├── 📄 GameStateManager.gd  # Main state manager
│       └── 📂 StateMachine/        # State machine implementation
│
├── 📂 ui/                # User interface
│   ├── 📄 MainMenu.gd           # Main menu logic
│   ├── 📄 SettingsMenu.gd       # Settings menu
│   ├── 📄 BackgroundManager.gd  # UI background management
│   └── 📄 TransitionManager.gd  # UI transitions
│
└── 📂 data/              # Game data and configurations
```

## 🏗️ Architecture Overview

### Core Systems
- **ServiceManager**: Centralizes service management and dependency injection
- **EventBus**: Global event communication system
- **GameStateManager**: Manages game states (menu, playing, paused, etc.)

### Component System
- **Components**: Reusable gameplay components (Health, Movement, Menu)
- **Entities**: Game objects that use components (Player, Room)

### Dungeon System
- **RoomsSystem**: Main dungeon management and room logic
- **RoomGenerator**: Procedural room generation
- **CorridorGenerator**: Corridor and connection generation

### UI System
- **MainMenu**: Main menu with settings integration
- **TransitionManager**: Smooth UI transitions and effects
- **BackgroundManager**: Dynamic background management

## 📋 File Naming Conventions

- **Scripts**: PascalCase (e.g., `GameStateManager.gd`)
- **Scenes**: PascalCase (e.g., `MainMenu.tscn`)
- **Folders**: kebab-case (e.g., `game-state/`)
- **Assets**: descriptive names with context

## 🔄 Recent Changes

### Structure Reorganization
1. **Eliminated Duplicates**: Removed duplicate DungeonWorld and consolidated with RoomsSystem
2. **Clear Separation**: Moved entities to `entities/`, systems to `systems/`
3. **Categorized Systems**: Organized systems by function (dungeon/, game-state/)
4. **Fixed References**: Updated all path references to new structure
5. **Clean Documentation**: Consolidated multiple README files

### Benefits
- ✅ **Clear Organization**: Easy to find files by function
- ✅ **No Duplicates**: Single source of truth for each system
- ✅ **Scalable**: Easy to add new systems in appropriate categories
- ✅ **Maintainable**: Logical grouping makes maintenance easier

---

*Last updated: September 4, 2025*
