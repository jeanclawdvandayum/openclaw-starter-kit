# Common Game Patterns

## State Machine (Full Implementation)

### Base State
```gdscript
# state.gd
class_name State extends Node

var state_machine: StateMachine

func enter(msg: Dictionary = {}) -> void:
    pass

func exit() -> void:
    pass

func update(delta: float) -> void:
    pass

func physics_update(delta: float) -> void:
    pass

func handle_input(event: InputEvent) -> void:
    pass
```

### Example: Player States
```gdscript
# idle_state.gd
extends State

func enter(msg: Dictionary = {}) -> void:
    owner.animation_player.play("idle")

func physics_update(delta: float) -> void:
    if not owner.is_on_floor():
        state_machine.transition_to("Fall")
    elif Input.is_action_just_pressed("jump"):
        state_machine.transition_to("Jump")
    elif Input.get_vector("left", "right", "up", "down").length() > 0:
        state_machine.transition_to("Run")
```

## Object Pooling

```gdscript
class_name ObjectPool extends Node

var _pool: Array[Node] = []
var _scene: PackedScene

func _init(scene: PackedScene, initial_size: int = 10):
    _scene = scene
    for i in initial_size:
        var obj = _scene.instantiate()
        obj.set_process(false)
        obj.visible = false
        _pool.append(obj)
        add_child(obj)

func get_object() -> Node:
    for obj in _pool:
        if not obj.visible:
            obj.visible = true
            obj.set_process(true)
            return obj
    # Pool exhausted — grow
    var obj = _scene.instantiate()
    _pool.append(obj)
    add_child(obj)
    return obj

func release(obj: Node) -> void:
    obj.visible = false
    obj.set_process(false)
```

## Save/Load System

```gdscript
# save_manager.gd (Autoload)
extends Node

const SAVE_PATH = "user://save_game.json"

func save_game(data: Dictionary) -> void:
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data, "\t"))

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    var json = JSON.new()
    json.parse(file.get_as_text())
    return json.data

# Resource-based save (more type-safe)
class_name SaveData extends Resource
@export var player_position: Vector2
@export var health: int
@export var inventory: Array[String]
@export var level: int

static func save(data: SaveData) -> void:
    ResourceSaver.save(data, "user://save.tres")

static func load_save() -> SaveData:
    if ResourceLoader.exists("user://save.tres"):
        return ResourceLoader.load("user://save.tres")
    return SaveData.new()
```

## Screen Shake

```gdscript
extends Camera2D

var shake_intensity: float = 0.0
var shake_decay: float = 5.0

func shake(intensity: float = 10.0) -> void:
    shake_intensity = intensity

func _process(delta: float) -> void:
    if shake_intensity > 0:
        offset = Vector2(
            randf_range(-shake_intensity, shake_intensity),
            randf_range(-shake_intensity, shake_intensity)
        )
        shake_intensity = lerp(shake_intensity, 0.0, shake_decay * delta)
    else:
        offset = Vector2.ZERO
```

## Tweens (Juice)

```gdscript
# Smooth movement
func move_to(target: Vector2, duration: float = 0.5) -> void:
    var tween = create_tween()
    tween.tween_property(self, "position", target, duration)\
        .set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

# Hit flash
func flash_white(duration: float = 0.1) -> void:
    var tween = create_tween()
    tween.tween_property($Sprite2D, "modulate", Color.WHITE * 10, duration / 2)
    tween.tween_property($Sprite2D, "modulate", Color.WHITE, duration / 2)

# Scale bounce (for pickups, UI)
func bounce() -> void:
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

# Chained sequence
func death_animation() -> void:
    var tween = create_tween()
    tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.5)
    tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.5)
    tween.tween_callback(queue_free)
```

## Timer Patterns

```gdscript
# One-shot timer (inline)
await get_tree().create_timer(1.0).timeout
do_something()

# Repeating timer (node)
@onready var fire_timer: Timer = $FireTimer

func _ready():
    fire_timer.wait_time = 0.5
    fire_timer.timeout.connect(_on_fire)
    fire_timer.start()

func _on_fire():
    spawn_bullet()

# Cooldown pattern
var can_attack: bool = true

func attack():
    if not can_attack:
        return
    can_attack = false
    perform_attack()
    await get_tree().create_timer(attack_cooldown).timeout
    can_attack = true
```

## Input Handling

```gdscript
# Action-based input (preferred — remappable)
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("attack"):
        attack()
    elif event.is_action_pressed("interact"):
        interact()

# Continuous input (in _physics_process)
func _physics_process(delta: float) -> void:
    var direction := Input.get_vector("left", "right", "up", "down")
    velocity = direction * speed
    move_and_slide()

# Mouse input
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            shoot()
    elif event is InputEventMouseMotion:
        look_at(get_global_mouse_position())
```

## Scene Management

```gdscript
# Change scene
get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")

# Change scene (packed)
var next_level: PackedScene = preload("res://scenes/levels/level_2.tscn")
get_tree().change_scene_to_packed(next_level)

# Additive scene loading (for UI overlays)
var pause_menu = preload("res://scenes/ui/pause_menu.tscn").instantiate()
add_child(pause_menu)

# Deferred free (safe during physics)
enemy.queue_free()
```

## Behavior Tree (Simple)

```gdscript
class_name BTNode extends RefCounted
enum Status { SUCCESS, FAILURE, RUNNING }
func tick(actor: Node, delta: float) -> Status:
    return Status.FAILURE

class BTSequence extends BTNode:
    var children: Array[BTNode]
    func tick(actor: Node, delta: float) -> Status:
        for child in children:
            var result = child.tick(actor, delta)
            if result != Status.SUCCESS:
                return result
        return Status.SUCCESS

class BTSelector extends BTNode:
    var children: Array[BTNode]
    func tick(actor: Node, delta: float) -> Status:
        for child in children:
            var result = child.tick(actor, delta)
            if result != Status.FAILURE:
                return result
        return Status.FAILURE
```

## Procedural Generation (Basics)

```gdscript
# Random with seed (reproducible)
var rng := RandomNumberGenerator.new()
rng.seed = 12345

# Noise-based terrain
var noise := FastNoiseLite.new()
noise.noise_type = FastNoiseLite.TYPE_PERLIN
noise.frequency = 0.05

func generate_heightmap(width: int, height: int) -> Array:
    var map: Array = []
    for y in height:
        var row: Array = []
        for x in width:
            row.append(noise.get_noise_2d(x, y))
        map.append(row)
    return map

# Random room placement (dungeon gen)
func place_rooms(num_rooms: int, map_size: Vector2i) -> Array[Rect2i]:
    var rooms: Array[Rect2i] = []
    for i in num_rooms:
        var room_size := Vector2i(rng.randi_range(4, 10), rng.randi_range(4, 10))
        var room_pos := Vector2i(
            rng.randi_range(1, map_size.x - room_size.x - 1),
            rng.randi_range(1, map_size.y - room_size.y - 1)
        )
        var room := Rect2i(room_pos, room_size)
        var overlaps := false
        for existing in rooms:
            if room.intersects(existing.grow(1)):
                overlaps = true
                break
        if not overlaps:
            rooms.append(room)
    return rooms
```
