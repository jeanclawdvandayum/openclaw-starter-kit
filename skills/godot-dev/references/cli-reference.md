# Godot CLI Reference

## Installation (macOS)
```bash
brew install godot
# Or for C# support:
brew install godot-mono
```

## Essential Commands

### Running
```bash
# Run project (opens editor by default)
godot --path /path/to/project -e

# Run the game (main scene)
godot --path /path/to/project

# Run specific scene
godot --path /path/to/project --scene res://scenes/test_level.tscn

# Run headless (no window — for CI/servers)
godot --headless --path /path/to/project

# Run a standalone script
godot --headless --path /path/to/project -s res://scripts/tool.gd
```

### Validation & Debugging
```bash
# Check scripts for errors (no run)
godot --headless --path /path/to/project --check-only -s res://scripts/my_script.gd

# Debug collision shapes visible
godot --path /path/to/project --debug-collisions

# Debug navigation meshes
godot --path /path/to/project --debug-navigation

# Verbose output
godot --path /path/to/project -v

# FPS limit
godot --path /path/to/project --max-fps 60

# Fixed timestep (for deterministic testing)
godot --path /path/to/project --fixed-fps 60
```

### Exporting
```bash
# Export release build (preset must be configured in export_presets.cfg)
godot --headless --path /path/to/project --export-release "Linux/X11" builds/game.x86_64
godot --headless --path /path/to/project --export-release "Windows Desktop" builds/game.exe
godot --headless --path /path/to/project --export-release "macOS" builds/game.dmg
godot --headless --path /path/to/project --export-release "Web" builds/index.html

# Export debug build
godot --headless --path /path/to/project --export-debug "Linux/X11" builds/game_debug.x86_64

# Export pack only (no executable)
godot --headless --path /path/to/project --export-pack "Linux/X11" builds/game.pck
```

### Other Tools
```bash
# Import resources (useful before export in CI)
godot --headless --path /path/to/project --import

# Generate API docs
godot --headless --doctool /path/to/output

# Record video of gameplay
godot --path /path/to/project --write-movie output.avi --fixed-fps 30 --quit-after 300
```

## Project Creation (from scratch, no GUI)

```bash
mkdir my_game && cd my_game

# Minimal project.godot
cat > project.godot << 'EOF'
; Engine configuration file
config_version=5

[application]
config/name="My Game"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.3")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[rendering]
renderer/rendering_method="gl_compatibility"
EOF

# Create directory structure
mkdir -p scenes scripts assets/sprites assets/audio resources

# Create main scene
cat > scenes/main.tscn << 'EOF'
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/main.gd" id="1"]

[node name="Main" type="Node2D"]
script = ExtResource("1")
EOF

# Create main script
cat > scripts/main.gd << 'EOF'
extends Node2D

func _ready() -> void:
    print("Game started!")
EOF

# Test it
godot --path . 
```

## Useful File Paths

| Path | Description |
|------|-------------|
| `res://` | Project root (read-only after export) |
| `user://` | User data directory (writable, saves go here) |
| `project.godot` | Project configuration |
| `export_presets.cfg` | Export presets |
| `.godot/` | Cache/import directory (gitignore this) |
| `.gdignore` | Place in a folder to hide it from Godot |

### User data locations
- **macOS**: `~/Library/Application Support/Godot/app_userdata/<project>/`
- **Linux**: `~/.local/share/godot/app_userdata/<project>/`
- **Windows**: `%APPDATA%/Godot/app_userdata/<project>/`

## .gitignore for Godot Projects
```
.godot/
*.import
export_presets.cfg
builds/
```
