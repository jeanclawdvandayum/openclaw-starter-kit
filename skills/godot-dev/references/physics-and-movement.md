# Physics & Movement

## CharacterBody2D — The Player/NPC Workhorse

### 8-Way Top-Down Movement
```gdscript
extends CharacterBody2D

@export var speed: float = 300.0

func _physics_process(delta: float) -> void:
    var direction := Input.get_vector("left", "right", "up", "down")
    velocity = direction * speed
    move_and_slide()
```

### Platformer Movement
```gdscript
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var gravity_scale: float = 1.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
    # Gravity
    if not is_on_floor():
        velocity.y += gravity * gravity_scale * delta

    # Jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    # Horizontal movement
    var direction := Input.get_axis("left", "right")
    if direction:
        velocity.x = direction * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)

    move_and_slide()
```

### Advanced Platformer (Coyote Time, Jump Buffer)
```gdscript
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -500.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false

func _physics_process(delta: float) -> void:
    # Coyote time tracking
    if is_on_floor():
        coyote_timer = coyote_time
    else:
        coyote_timer -= delta

    # Jump buffer
    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = jump_buffer_time
    else:
        jump_buffer_timer -= delta

    # Gravity
    if not is_on_floor():
        velocity.y += gravity * delta

    # Jump (with coyote time and jump buffer)
    if jump_buffer_timer > 0 and coyote_timer > 0:
        velocity.y = jump_velocity
        jump_buffer_timer = 0
        coyote_timer = 0

    # Variable jump height (release to fall faster)
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= 0.5

    # Horizontal
    var direction := Input.get_axis("left", "right")
    velocity.x = direction * speed if direction else move_toward(velocity.x, 0, speed)

    move_and_slide()
```

### Rotation + Movement (Asteroids Style)
```gdscript
extends CharacterBody2D

@export var speed: float = 400.0
@export var rotation_speed: float = 1.5

func _physics_process(delta: float) -> void:
    var rotation_dir := Input.get_axis("left", "right")
    rotation += rotation_dir * rotation_speed * delta
    velocity = transform.x * Input.get_axis("down", "up") * speed
    move_and_slide()
```

## RigidBody2D — Physics-Driven Bodies

```gdscript
extends RigidBody2D

var thrust := Vector2(0, -250)
var torque := 20000.0

# Use _integrate_forces, NOT _physics_process for RigidBody
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
    if Input.is_action_pressed("thrust"):
        state.apply_force(thrust.rotated(rotation))

    var rotation_dir := Input.get_axis("left", "right")
    state.apply_torque(rotation_dir * torque)
```

**Key rules for RigidBody:**
- Never set `position` or `linear_velocity` directly (use forces/impulses)
- Use `_integrate_forces()` instead of `_physics_process()`
- `apply_force()` for continuous forces, `apply_impulse()` for one-shot

## Area2D — Detection Zones

```gdscript
extends Area2D

# Detect bodies entering
func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        body.take_damage(10)

func _on_body_exited(body: Node2D) -> void:
    pass
```

### Hitbox/Hurtbox Pattern
```gdscript
# HitBox (deals damage) — on weapons/attacks
extends Area2D
@export var damage: int = 10

# HurtBox (receives damage) — on characters
extends Area2D
signal damage_received(amount: int)

func _ready():
    area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: Area2D) -> void:
    if hitbox.has_method("get_damage"):
        damage_received.emit(hitbox.get_damage())
```

## Collision Layers & Masks

- **Layer**: What this object IS (its identity)
- **Mask**: What this object SCANS FOR (what it detects)

```
Layer 1: Walls
Layer 2: Player
Layer 3: Enemies
Layer 4: Pickups
Layer 5: Projectiles
```

**Player**: Layer=2, Mask=1,3,4 (is player, detects walls/enemies/pickups)
**Enemy**: Layer=3, Mask=1,2,5 (is enemy, detects walls/player/projectiles)
**Pickup**: Layer=4, Mask=2 (is pickup, detects player only)

```gdscript
# Set in code
collision_layer = 0b00010  # Layer 2
collision_mask = 0b01101   # Layers 1, 3, 4
# Or:
set_collision_layer_value(2, true)
set_collision_mask_value(1, true)
```

## CharacterBody3D — 3D Movement

```gdscript
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * mouse_sensitivity)
        $Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
        $Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity

    var input_dir := Input.get_vector("left", "right", "forward", "backward")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()
```

## Navigation / Pathfinding

```gdscript
extends CharacterBody2D

@export var speed: float = 200.0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func set_target(target_pos: Vector2) -> void:
    nav_agent.target_position = target_pos

func _physics_process(delta: float) -> void:
    if nav_agent.is_navigation_finished():
        return
    var next_pos := nav_agent.get_next_path_position()
    var direction := global_position.direction_to(next_pos)
    velocity = direction * speed
    move_and_slide()
```
