# GDScript Language Reference

## Type System

### Built-in Types
- **null**: Empty, only for Object-derived types
- **bool**: `true` / `false`
- **int**: 64-bit signed integer
- **float**: 64-bit double precision
- **String**: Unicode text. Use `StringName` (&"name") for identifiers/dict keys (fast comparison)
- **NodePath**: `^"Node/Label"` — pre-parsed paths for get_node()

### Vector Types
- `Vector2` / `Vector2i` — 2D position, direction, size
- `Vector3` / `Vector3i` — 3D equivalent
- `Rect2` — Position + size (2D bounding box)
- `Transform2D` / `Transform3D` — Affine transforms
- `Basis` — 3x3 rotation/scale matrix
- `Quaternion` — 3D rotation (use for interpolation)
- `AABB` — 3D bounding box
- `Color` — RGBA (also HSV access)

### Container Types
- `Array` — Dynamic, heterogeneous: `[1, "two", Vector2()]`
- `Array[Type]` — Typed array: `var enemies: Array[Enemy] = []`
- `Dictionary` — Key-value: `{"hp": 100, "name": "Player"}`
- `PackedByteArray`, `PackedInt32Array`, `PackedFloat32Array`, etc. — Performance arrays

### Type Hints (Strongly Recommended)
```gdscript
var health: int = 100
var velocity: Vector2 = Vector2.ZERO
var items: Array[ItemData] = []
@export var speed: float = 300.0

func calculate_damage(base: int, multiplier: float) -> int:
    return int(base * multiplier)

# Inferred types with :=
var direction := Vector2(1, 0)  # Inferred as Vector2
var name := "Player"            # Inferred as String
```

## Annotations

### Export Annotations
```gdscript
@export var hp: int = 100                          # Basic export
@export_range(0, 100, 1) var hp: int = 100         # Slider
@export_enum("Warrior", "Mage", "Rogue") var cls: int  # Dropdown
@export_file("*.png") var texture_path: String      # File picker
@export_dir var save_dir: String                    # Dir picker
@export_multiline var description: String           # Multiline text
@export_color_no_alpha var color: Color             # Color picker
@export_node_path("CharacterBody2D") var target     # Node path
@export_group("Movement")                           # Group header
@export var speed: float = 300.0
@export var jump_force: float = 500.0
@export_subgroup("Advanced")
@export var acceleration: float = 50.0
@export_category("Combat")                          # Category header
```

### Other Annotations
```gdscript
@onready var sprite = $Sprite2D    # Deferred init until _ready()
@tool                               # Run in editor
@icon("res://icon.png")             # Editor icon
@warning_ignore("unused_variable")  # Suppress warning
```

## Signals

```gdscript
# Declaration
signal health_changed(new_health: int)
signal died

# Emission
health_changed.emit(current_health)
died.emit()

# Connection (in code)
func _ready():
    $Button.pressed.connect(_on_button_pressed)
    health_changed.connect(_on_health_changed)

# One-shot connection
signal_name.connect(callable, CONNECT_ONE_SHOT)

# Disconnection
signal_name.disconnect(callable)

# Awaiting signals (coroutines)
func wait_for_animation():
    $AnimationPlayer.play("attack")
    await $AnimationPlayer.animation_finished
    print("Animation done!")

# Await with timeout
func wait_with_timeout():
    var timer = get_tree().create_timer(5.0)
    await timer.timeout
```

## Coroutines and Await

```gdscript
func async_operation() -> void:
    print("Starting...")
    await get_tree().create_timer(1.0).timeout
    print("1 second later")

    # Await a signal
    await $AnimationPlayer.animation_finished

    # Await another coroutine
    await do_something_else()

func do_something_else() -> void:
    await get_tree().create_timer(0.5).timeout
```

## Lambdas and Callables

```gdscript
# Lambda
var double = func(x: int) -> int: return x * 2
print(double.call(5))  # 10

# Signal connection with lambda
$Button.pressed.connect(func(): print("Pressed!"))

# Callable from method
var cb: Callable = take_damage
cb.call(10)

# Callable with bind
$Timer.timeout.connect(spawn_enemy.bind("goblin"))
```

## Match Statement (Pattern Matching)

```gdscript
match action:
    "move":
        move_player()
    "attack":
        attack()
    "defend" when shield_up:  # Pattern guard
        block_damage()
    _:
        idle()

# Matching arrays
match input:
    [var x, var y]:
        position = Vector2(x, y)
    [var x, var y, var z]:
        position = Vector3(x, y, z)

# Matching dictionaries
match event:
    {"type": "damage", "amount": var amt}:
        take_damage(amt)
```

## Getter/Setter Properties

```gdscript
var health: int = 100:
    set(value):
        health = clamp(value, 0, max_health)
        health_changed.emit(health)
        if health <= 0:
            died.emit()
    get:
        return health

# Short form
var speed: float = 300.0:
    set = set_speed, get = get_speed

func set_speed(value: float) -> void:
    speed = max(0, value)
func get_speed() -> float:
    return speed
```

## Groups

```gdscript
# Add to group
func _ready():
    add_to_group("enemies")

# Call all in group
get_tree().call_group("enemies", "take_damage", 10)

# Get all in group
var enemies = get_tree().get_nodes_in_group("enemies")
for enemy in enemies:
    enemy.alert(player.position)
```

## Node References

```gdscript
# $ shorthand (get_node)
var sprite = $Sprite2D
var nested = $"Path/To/Deep/Node"

# Unique names (%)
@onready var health_bar = %HealthBar  # Finds anywhere in scene

# @export node reference (most robust)
@export var target: CharacterBody2D
```
