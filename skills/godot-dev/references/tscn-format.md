# .tscn File Format (Text Scene)

Godot scenes are **human-readable text files**. This enables editing without the GUI — critical for AI-assisted development.

## Structure

```ini
[gd_scene load_steps=<N> format=3 uid="uid://<hash>"]

# External resources (files on disk)
[ext_resource type="<Type>" path="res://<path>" id="<id>"]

# Inline resources (embedded in scene)
[sub_resource type="<Type>" id="<id>"]
property = value

# Nodes
[node name="<Name>" type="<Type>" parent="<path>"]
property = value

# Signal connections
[connection signal="<signal>" from="<node_path>" to="<node_path>" method="<method>"]
```

## Complete Example: Player Scene

```ini
[gd_scene load_steps=5 format=3 uid="uid://abc123"]

[ext_resource type="Script" path="res://scenes/player/player.gd" id="1_abc"]
[ext_resource type="Texture2D" path="res://assets/sprites/player.png" id="2_def"]
[ext_resource type="PackedScene" path="res://scenes/player/state_machine.tscn" id="3_ghi"]

[sub_resource type="CapsuleShape2D" id="CapsuleShape2D_jkl"]
radius = 12.0
height = 32.0

[sub_resource type="RectangleShape2D" id="RectangleShape2D_mno"]
size = Vector2(20, 28)

[node name="Player" type="CharacterBody2D"]
collision_layer = 2
collision_mask = 5
script = ExtResource("1_abc")
speed = 300.0
jump_velocity = -500.0

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2_def")
offset = Vector2(0, -16)

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("CapsuleShape2D_jkl")

[node name="HurtBox" type="Area2D" parent="."]
collision_layer = 0
collision_mask = 8

[node name="HurtShape" type="CollisionShape2D" parent="HurtBox"]
shape = SubResource("RectangleShape2D_mno")

[node name="StateMachine" parent="." instance=ExtResource("3_ghi")]

[node name="Camera2D" type="Camera2D" parent="."]
zoom = Vector2(2, 2)
position_smoothing_enabled = true
position_smoothing_speed = 8.0

[connection signal="area_entered" from="HurtBox" to="." method="_on_hurt_box_area_entered"]
```

## Key Syntax Rules

### Node Paths
- Root node: no `parent` attribute
- Direct children: `parent="."`
- Nested: `parent="Path/To/Parent"`
- The `.` refers to the scene root

### Resource References
- `ExtResource("id")` — references an `[ext_resource]` by its id
- `SubResource("id")` — references a `[sub_resource]` by its id

### Property Values
```ini
# Primitives
integer_prop = 42
float_prop = 3.14
bool_prop = true
string_prop = "hello"

# Vectors
vector2_prop = Vector2(100, 200)
vector3_prop = Vector3(1, 2, 3)
vector2i_prop = Vector2i(10, 20)

# Colors
color_prop = Color(1, 0, 0, 1)          # RGBA float
color_prop = Color(0.2, 0.5, 0.8, 1)

# Transforms
transform2d = Transform2D(1, 0, 0, 1, 100, 200)  # Basis + origin
transform3d = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 5, 0)

# Enums (as integers)
collision_layer = 2
process_mode = 1  # PROCESS_MODE_PAUSABLE

# Arrays
tags = PackedStringArray("enemy", "boss")
points = PackedVector2Array(0, 0, 100, 0, 100, 100)

# Node paths
target_path = NodePath("../Player")
```

### Instanced Scenes
```ini
# Instance an external scene
[node name="Enemy" parent="Enemies" instance=ExtResource("4_xyz")]
# Override properties from the instanced scene:
health = 50
speed = 100.0
```

## .godot Project File

```ini
[gd_resource type="ProjectSettings" format=3]

config_version=5

[application]
config/name="My Game"
run/main_scene="res://scenes/main.tscn"
config/features=PackedStringArray("4.3")

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[input]
move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"keycode":65)]
}

[autoload]
GameManager="*res://scripts/game_manager.gd"
EventBus="*res://scripts/event_bus.gd"

[layer_names]
2d_physics/layer_1="walls"
2d_physics/layer_2="player"
2d_physics/layer_3="enemies"
2d_physics/layer_4="pickups"

[physics]
2d/default_gravity=980.0
```

## Creating Scenes Programmatically (from code)

```gdscript
# Create a scene in code and save to disk
var scene = PackedScene.new()
var root = CharacterBody2D.new()
root.name = "Enemy"
var sprite = Sprite2D.new()
sprite.name = "Sprite2D"
root.add_child(sprite)
sprite.owner = root  # IMPORTANT: set owner for saving
scene.pack(root)
ResourceSaver.save(scene, "res://scenes/enemies/enemy.tscn")
```
