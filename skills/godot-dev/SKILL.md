---
name: godot-dev
description: "Use when building games with Godot Engine 4.x and GDScript. Covers project architecture, scene/node patterns, GDScript coding, 2D/3D physics, state machines, UI systems, signals, autoloads, tilemaps, shaders, audio, input handling, procedural generation, AI behavior trees, CLI workflows, and text-based .tscn scene editing. Also use for Godot project setup, GDScript debugging, and exporting builds."
---

# Godot 4 Game Developer

Expert Godot 4 game developer specializing in GDScript, scene architecture, and production-quality game systems.

## Core Concepts

Godot's architecture: **Nodes** compose into **Scenes**, scenes form the **SceneTree**, nodes communicate via **Signals**.

- **Node**: Smallest building block. Has lifecycle callbacks (_ready, _process, _physics_process, _input).
- **Scene**: Reusable tree of nodes saved as `.tscn` (text) or `.scn` (binary). Can be instanced.
- **SceneTree**: The runtime tree. Root → Main → World/UI branches.
- **Signal**: Observer pattern. Nodes emit signals, others connect to respond. Decouples systems.
- **Resource**: Serializable data objects (textures, scripts, materials, custom data). Shared by reference.
- **Autoload**: Singleton nodes always in the SceneTree. For global state (GameManager, AudioManager).

## Project Structure

```
project/
├── project.godot              # Project settings
├── scenes/                    # .tscn scene files
│   ├── main.tscn             # Entry point
│   ├── player/
│   │   ├── player.tscn
│   │   └── player.gd
│   ├── enemies/
│   ├── ui/
│   └── levels/
├── scripts/                   # Shared/autoload scripts
│   ├── game_manager.gd
│   └── event_bus.gd
├── resources/                 # Custom resources
├── assets/                    # Art, audio, fonts
│   ├── sprites/
│   ├── audio/
│   └── fonts/
├── shaders/
└── addons/                    # Plugins
```

## GDScript Essentials

### Code Order (Official Style)
```gdscript
@tool                          # 01. Annotations
class_name MyClass             # 02. class_name
extends Node                   # 03. extends
## Documentation comment       # 04. Doc comment

signal health_changed(new_hp)  # 05. Signals
enum State { IDLE, RUN, JUMP } # 06. Enums
const MAX_HP = 100             # 07. Constants
static var instance: MyClass   # 08. Static vars
@export var speed: float = 300 # 09. @export vars
var hp: int = MAX_HP           # 10. Regular vars
@onready var sprite = $Sprite2D # 11. @onready vars

func _init(): pass             # 12. _init
func _ready(): pass            # 13. _ready
func _process(delta): pass     # 14. _process
func _physics_process(delta):  # 15. _physics_process
    pass
func _unhandled_input(event):  # 16. Virtual callbacks
    pass
func take_damage(amt: int):    # 17. Public methods
    pass
func _apply_effect():          # 18. Private methods
    pass
```

### Naming Conventions
| Type | Convention | Example |
|------|-----------|---------|
| Files | snake_case | `yaml_parser.gd` |
| Classes | PascalCase | `class_name YAMLParser` |
| Nodes | PascalCase | `Player`, `Camera3D` |
| Functions | snake_case | `func load_level():` |
| Variables | snake_case | `var particle_effect` |
| Signals | snake_case (past tense) | `signal door_opened` |
| Constants | CONSTANT_CASE | `const MAX_SPEED = 200` |
| Enums | PascalCase/CONSTANT_CASE | `enum State { IDLE, RUNNING }` |

### Type Hints (Always Use)
```gdscript
var health: int = 100
var direction: Vector2 = Vector2.ZERO
@export var speed: float = 300.0
func take_damage(amount: int) -> void:
    health -= amount
func get_direction() -> Vector2:
    return Input.get_vector("left", "right", "up", "down")
```

## Core Patterns

### Signal Bus (Global Events)
```gdscript
# scripts/event_bus.gd (Autoload)
extends Node
signal player_died
signal score_changed(new_score: int)
signal level_completed(level_id: int)
```

### State Machine
```gdscript
class_name StateMachine extends Node
signal state_changed(old_state, new_state)
@export var initial_state: State
var current_state: State

func _ready():
    for child in get_children():
        if child is State:
            child.state_machine = self
    current_state = initial_state
    current_state.enter({})

func _process(delta):
    current_state.update(delta)

func _physics_process(delta):
    current_state.physics_update(delta)

func transition_to(target_state_name: StringName, msg: Dictionary = {}):
    var new_state = get_node(NodePath(target_state_name))
    if not new_state or new_state == current_state:
        return
    current_state.exit()
    var old = current_state
    current_state = new_state
    current_state.enter(msg)
    state_changed.emit(old, current_state)
```

### Resource-Based Data
```gdscript
# Custom resource for items
class_name ItemData extends Resource
@export var name: String
@export var icon: Texture2D
@export var damage: int
@export var description: String
```

## Scene Architecture Rules

1. **Scenes should be self-contained** — no hard dependencies on parent structure
2. **Use signals to communicate up** — children emit, parents connect
3. **Use method calls to communicate down** — parents call children's methods
4. **Siblings communicate through parent** — parent mediates
5. **Use Dependency Injection** — pass references in, don't reach out
6. **Autoloads for truly global singletons only** — GameManager, AudioManager, EventBus

## CLI Workflow (Headless / Text-Based)

```bash
# Run project
godot --path /path/to/project

# Run specific scene
godot --path /path/to/project --scene res://scenes/main.tscn

# Run headless (servers, CI)
godot --headless --path /path/to/project --script res://scripts/test.gd

# Export release build
godot --headless --path /path/to/project --export-release "Linux/X11" builds/game.x86_64

# Check script errors without running
godot --headless --path /path/to/project --check-only --script res://scripts/my_script.gd

# Run with debug collision shapes visible
godot --path /path/to/project --debug-collisions
```

## Text-Based Scene Editing (.tscn)

Scenes are text files — editable without the GUI. See `references/tscn-format.md` for full format.

```ini
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://player.gd" id="1"]
[ext_resource type="Texture2D" path="res://icon.svg" id="2"]

[sub_resource type="RectangleShape2D" id="3"]
size = Vector2(32, 64)

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1")
speed = 300.0

[node name="Sprite" type="Sprite2D" parent="."]
texture = ExtResource("2")

[node name="Collision" type="CollisionShape2D" parent="."]
shape = SubResource("3")

[connection signal="body_entered" from="." to="." method="_on_body_entered"]
```

## Reference Files

Load these as needed for deeper guidance:

- **`references/gdscript-reference.md`** — Language details: types, operators, annotations, coroutines, lambdas, static typing
- **`references/scene-architecture.md`** — Node types, scene organization, dependency injection, when to use Object vs Node vs Resource
- **`references/physics-and-movement.md`** — CharacterBody2D/3D, RigidBody, Area2D, collision layers, movement patterns
- **`references/common-patterns.md`** — State machines, object pooling, behavior trees, save/load, screen shake, tweens, timers
- **`references/tscn-format.md`** — Full .tscn format specification for text-based scene editing
- **`references/cli-reference.md`** — Complete CLI flags and headless workflow
