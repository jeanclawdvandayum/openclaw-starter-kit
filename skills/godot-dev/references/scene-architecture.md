# Scene Architecture & Node Types

## Key Node Types

### 2D Nodes
| Node | Purpose |
|------|---------|
| `Node2D` | Base 2D node with transform |
| `Sprite2D` | Display texture/sprite |
| `AnimatedSprite2D` | Sprite with frame animations |
| `CharacterBody2D` | Player/NPC with code-driven movement |
| `RigidBody2D` | Physics-driven body |
| `StaticBody2D` | Immovable collision body |
| `Area2D` | Overlap detection, physics influence zones |
| `CollisionShape2D` | Collision bounds (child of physics bodies) |
| `TileMapLayer` | Tile-based maps (replaces TileMap in 4.3+) |
| `Camera2D` | 2D camera with smoothing, limits, zoom |
| `ParallaxBackground` | Scrolling background layers |
| `Path2D` / `PathFollow2D` | Predefined movement paths |
| `Line2D` | 2D line rendering |
| `Polygon2D` | 2D polygon rendering |
| `RayCast2D` | Ray-based collision detection |

### 3D Nodes
| Node | Purpose |
|------|---------|
| `Node3D` | Base 3D node with transform |
| `MeshInstance3D` | Renders a 3D mesh |
| `CharacterBody3D` | Player/NPC with code-driven 3D movement |
| `RigidBody3D` | Physics-driven 3D body |
| `StaticBody3D` | Immovable 3D collision body |
| `Area3D` | 3D overlap detection |
| `Camera3D` | 3D camera |
| `DirectionalLight3D` | Sun/moon light |
| `OmniLight3D` | Point light |
| `SpotLight3D` | Cone light |
| `WorldEnvironment` | Sky, fog, tonemap, SSAO |
| `NavigationRegion3D` | Navmesh for pathfinding |

### UI Nodes (Control)
| Node | Purpose |
|------|---------|
| `Control` | Base UI node |
| `Label` | Text display |
| `RichTextLabel` | Formatted text with BBCode |
| `Button` | Clickable button |
| `TextureButton` | Image-based button |
| `TextEdit` | Multi-line text input |
| `LineEdit` | Single-line text input |
| `HBoxContainer` / `VBoxContainer` | Horizontal/vertical layout |
| `GridContainer` | Grid layout |
| `MarginContainer` | Padding/margins |
| `PanelContainer` | Panel with background |
| `ScrollContainer` | Scrollable area |
| `TabContainer` | Tabbed panels |
| `ProgressBar` / `TextureProgressBar` | Progress indicators |
| `HSlider` / `VSlider` | Slider inputs |

### Utility Nodes
| Node | Purpose |
|------|---------|
| `Timer` | Countdown timer (one_shot or repeating) |
| `AnimationPlayer` | Keyframe animation for any property |
| `AnimationTree` | State machine for blending animations |
| `AudioStreamPlayer` / `2D` / `3D` | Sound playback |
| `HTTPRequest` | HTTP requests |
| `SubViewport` | Render-to-texture, split screen |

## Scene Organization Pattern

```
Main (Node)
├── World (Node2D or Node3D)
│   ├── TileMapLayer
│   ├── Player (CharacterBody2D)
│   │   ├── Sprite2D
│   │   ├── CollisionShape2D
│   │   ├── AnimationPlayer
│   │   ├── StateMachine (Node)
│   │   │   ├── IdleState
│   │   │   ├── RunState
│   │   │   └── JumpState
│   │   └── HurtBox (Area2D)
│   ├── Enemies (Node2D)
│   │   └── ... enemy instances
│   ├── Items (Node2D)
│   └── Camera2D
├── UI (CanvasLayer)
│   ├── HUD
│   │   ├── HealthBar
│   │   └── ScoreLabel
│   ├── PauseMenu
│   └── DialogueBox
└── Systems (Node)
    ├── AudioManager
    └── ParticlePool
```

## When to Use What

### Object vs RefCounted vs Resource vs Node

| Type | Use When | Memory |
|------|----------|--------|
| `Object` | Lightest option, custom data structures | Manual free |
| `RefCounted` | Data objects that auto-cleanup | Reference counted |
| `Resource` | Serializable data (save/load, inspector) | Reference counted |
| `Node` | Needs to be in scene tree, has lifecycle | Tree manages |

**Rule of thumb:**
- Need it in the SceneTree with callbacks? → **Node**
- Need to save/load it or edit in inspector? → **Resource**
- Just need a data container? → **RefCounted**
- Performance-critical, manual control? → **Object**

### Autoload vs Regular Node

**Use Autoload when:**
- Truly global (one instance ever): GameManager, Settings, EventBus
- Tracks its own data, doesn't modify other objects
- Needs to persist across scene changes

**Use regular Node when:**
- Part of a specific scene's logic
- Interacts with sibling nodes
- Multiple instances may exist

## Dependency Injection Patterns

```gdscript
# 1. Signal connection (loosest coupling)
# Parent connects child's signal — child doesn't know who listens
$Child.health_changed.connect(_on_child_health_changed)

# 2. Method call (parent → child)
$Child.set_target(player)

# 3. Export property (set in editor)
@export var target: CharacterBody2D  # Drag-and-drop in inspector

# 4. Callable injection
$Child.on_death = _handle_child_death

# 5. Group-based (anonymous coupling)
get_tree().call_group("enemies", "alert", position)
```
