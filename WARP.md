# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview
WaterWarfare is a third-person multiplayer game built with Godot 4.5.

## Development Commands

### Running the Game
```bash
# Run the game from command line (requires Godot 4.5 in PATH)
godot --path . --headless  # Run in headless mode for testing
godot --path .              # Run with GUI
```

### Project Management
```bash
# Open project in Godot Editor
godot --path . --editor

# Export builds (after export presets are configured)
godot --path . --export-release "Linux/X11"
godot --path . --export-release "Windows Desktop"
godot --path . --export-release "macOS"
```

## Code Architecture

### Project Structure
Godot projects typically organize around:
- **Scenes** (.tscn) - Node hierarchies representing game objects, levels, UI
- **Scripts** (.gd) - GDScript files attached to nodes for behavior
- **Resources** (.tres) - Reusable data assets
- **Assets** - Textures, 3D models, audio, shaders

### Key Godot Concepts for This Project

#### Third-Person Character Controller
- Main character scene should contain CharacterBody3D with CollisionShape3D
- Camera3D positioned behind/above character with SpringArm3D for smooth following
- Input handling in `_physics_process()` using `Input.get_vector()` for movement
- Use `move_and_slide()` for physics-based movement

#### Multiplayer Architecture
- Godot 4.5 uses MultiplayerAPI with ENetMultiplayerPeer or WebRTCMultiplayerPeer
- Mark synchronized properties with `@export` and `@rpc` annotations
- Use `MultiplayerSynchronizer` nodes to automatically sync properties
- Server-authoritative design: validate player actions on server
- RPCs: `@rpc("any_peer")`, `@rpc("authority")`, `@rpc("call_local")`

#### Scene Organization Pattern
```
res://
├── scenes/
│   ├── characters/     # Player and NPC characters
│   ├── levels/         # Game maps/arenas
│   ├── ui/            # HUD, menus, inventory
│   └── weapons/       # Weapon systems
├── scripts/
│   ├── autoload/      # Global singletons (network, game state)
│   ├── components/    # Reusable components
│   └── utilities/     # Helper functions
├── assets/
│   ├── models/
│   ├── textures/
│   └── audio/
└── project.godot
```

### GDScript Conventions
- Use `snake_case` for variables and functions
- Use `PascalCase` for class names
- Signals declared at top: `signal health_changed(new_health)`
- Export variables for Inspector editing: `@export var speed: float = 5.0`
- Type hints: `var player: CharacterBody3D`, `func move(direction: Vector3) -> void:`

### Multiplayer Synchronization Patterns
- **Client prediction**: Move locally, await server confirmation
- **Interpolation**: Smooth remote player movement between updates
- **Spawn/despawn**: Use `MultiplayerSpawner` for dynamic object creation
- **State synchronization**: Use `MultiplayerSynchronizer` with replication config

## Testing
Godot doesn't have built-in unit testing by default. Common approaches:
- **GUT (Godot Unit Test)**: Add-on for unit testing - install from AssetLib
- **Manual testing**: Run multiple game instances for multiplayer testing
- **Headless mode**: Use `--headless` flag for automated testing

## Common Issues

### Multiplayer Testing
To test multiplayer locally:
1. Run server: `godot --path . -- --server`
2. Run clients: `godot --path . -- --client` (in separate terminal windows)
3. Or use editor's multiple window feature: Remote > Multiple Instances

### Performance Optimization
- Use `Object Pooling` for frequently spawned/destroyed objects (projectiles, effects)
- Enable `MultiMesh` for rendering many identical objects
- Profile with built-in profiler: Debug > Profiler
- Monitor network traffic: Debug > Network Profiler

### Version Control with Godot
- `.import` files are auto-generated; typically gitignored
- `.godot/` directory contains cache; should be gitignored
- Coordinate changes to `project.godot` carefully in teams
