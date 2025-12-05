---
allowed_tools:
  - AskUserQuestion
  - mcp__godot__*
  - Write
  - Read
---

Create common scene templates for 2D games, including characters, enemies, levels, and more.

# Process

1. **Ask the user what type of scene they want to create:**

Use AskUserQuestion with the following options:

Question: "What type of scene would you like to create?"
Header: "Scene Type"
Multi-select: false
Options:
- 2D Player Character: Platformer character with movement and collision
- 2D Enemy: Basic enemy with AI placeholder
- 2D Level: Level scene with tilemap and camera
- 2D Projectile: Bullet/projectile with movement
- Collectible: Coin/item pickup
- Interactable Object: Chest, door, switch, etc.

Question 2: "Where should the scene be created?"
Header: "Location"
Multi-select: false
Options:
- scenes/characters/: For player and NPCs
- scenes/enemies/: For enemy characters
- scenes/levels/: For level scenes
- scenes/objects/: For items and interactables
- Custom path: I'll specify the path

2. **If Custom path selected, ask for the specific path and scene name**

3. **Create the appropriate template based on selection**

## 2D Player Character Template

Create scene with:
```
CharacterBody2D (root)
├── Sprite2D (sprite)
├── CollisionShape2D (collision)
├── AnimationPlayer (animation_player)
└── Camera2D (camera)
```

Node details:
- CharacterBody2D: motion_mode = MOTION_MODE_GROUNDED
- Sprite2D: centered = true, texture = placeholder (32x32 white rect)
- CollisionShape2D: shape = RectangleShape2D (16x32)
- Camera2D: enabled = true, position_smoothing_enabled = true

Create accompanying script:
```gdscript
extends CharacterBody2D

# Movement parameters
@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction
	var direction = Input.get_axis("ui_left", "ui_right")

	# Apply movement
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)

		# Flip sprite based on direction
		sprite.flip_h = direction < 0

	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()

	# Animation logic (requires animations to be set up)
	_update_animation()

func _update_animation():
	if not animation_player:
		return

	# TODO: Create animations in AnimationPlayer:
	# - "idle": Standing still
	# - "run": Running
	# - "jump": Jumping up
	# - "fall": Falling down

	# Example animation logic:
	# if not is_on_floor():
	#     if velocity.y < 0:
	#         animation_player.play("jump")
	#     else:
	#         animation_player.play("fall")
	# elif abs(velocity.x) > 10:
	#     animation_player.play("run")
	# else:
	#     animation_player.play("idle")
	pass
```

## 2D Enemy Template

Create scene with:
```
CharacterBody2D (root)
├── Sprite2D (sprite)
├── CollisionShape2D (collision)
├── Area2D (detection_area)
│   └── CollisionShape2D (detection_collision)
├── AnimationPlayer (animation_player)
└── Timer (patrol_timer)
```

Node details:
- CharacterBody2D: motion_mode = MOTION_MODE_GROUNDED
- Sprite2D: centered = true, modulate = Color(1, 0.5, 0.5) (reddish tint)
- CollisionShape2D: shape = RectangleShape2D (16x24)
- Area2D/CollisionShape2D: shape = CircleShape2D (radius = 100) for player detection
- Timer: wait_time = 2.0, one_shot = false

Create accompanying script:
```gdscript
extends CharacterBody2D

enum State { IDLE, PATROL, CHASE, ATTACK }

# Movement parameters
@export var patrol_speed: float = 50.0
@export var chase_speed: float = 150.0
@export var detection_range: float = 100.0
@export var attack_range: float = 30.0
@export var health: int = 100

var current_state: State = State.IDLE
var player: Node2D = null
var patrol_direction: int = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $Sprite2D
@onready var detection_area = $detection_area
@onready var patrol_timer = $patrol_timer

func _ready():
	# Connect area signals for player detection
	detection_area.body_entered.connect(_on_detection_area_entered)
	detection_area.body_exited.connect(_on_detection_area_exited)

	# Connect patrol timer
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)
	patrol_timer.start()

	current_state = State.PATROL

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# State machine
	match current_state:
		State.IDLE:
			velocity.x = 0

		State.PATROL:
			velocity.x = patrol_direction * patrol_speed
			sprite.flip_h = patrol_direction < 0

			# Turn around at ledges or walls
			if is_on_wall() or not _check_floor_ahead():
				patrol_direction *= -1

		State.CHASE:
			if player:
				var direction = sign(player.global_position.x - global_position.x)
				velocity.x = direction * chase_speed
				sprite.flip_h = direction < 0

				# Check if close enough to attack
				var distance = global_position.distance_to(player.global_position)
				if distance < attack_range:
					current_state = State.ATTACK
			else:
				current_state = State.PATROL

		State.ATTACK:
			velocity.x = 0
			# TODO: Implement attack logic
			# For now, just return to chase after a moment
			await get_tree().create_timer(0.5).timeout
			current_state = State.CHASE

	move_and_slide()

func _check_floor_ahead() -> bool:
	# Raycast to check if there's floor ahead
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(patrol_direction * 20, 30)
	)
	var result = space_state.intersect_ray(query)
	return result.size() > 0

func _on_detection_area_entered(body):
	if body.is_in_group("player"):
		player = body
		current_state = State.CHASE

func _on_detection_area_exited(body):
	if body == player:
		player = null
		current_state = State.PATROL

func _on_patrol_timer_timeout():
	if current_state == State.IDLE or current_state == State.PATROL:
		patrol_direction *= -1

func take_damage(amount: int):
	health -= amount
	# TODO: Add damage flash/animation

	if health <= 0:
		die()

func die():
	# TODO: Add death animation
	queue_free()
```

## 2D Level Template

Create scene with:
```
Node2D (root)
├── TileMap (tilemap)
├── Node2D (spawn_points)
│   └── Marker2D (player_spawn)
├── Node2D (enemies)
├── Node2D (collectibles)
├── ParallaxBackground (background)
│   └── ParallaxLayer (layer1)
│       └── Sprite2D (bg_sprite)
└── Camera2D (camera)
```

Node details:
- TileMap: tile_set = null (needs to be set by user), layer 0 = "Ground", layer 1 = "Walls"
- Camera2D: enabled = true, limit_left = 0, limit_top = 0

Create accompanying script:
```gdscript
extends Node2D

@onready var tilemap = $TileMap
@onready var player_spawn = $spawn_points/player_spawn
@onready var camera = $Camera2D

# Preload player scene
const PLAYER_SCENE = preload("res://scenes/characters/player.tscn")

func _ready():
	# Spawn player
	spawn_player()

	# Set camera limits based on level bounds
	_setup_camera_limits()

func spawn_player():
	# Instance and add player
	var player = PLAYER_SCENE.instantiate()
	player.global_position = player_spawn.global_position
	add_child(player)

	# Make camera follow player
	camera.enabled = false  # Disable level camera
	# Player should have its own camera

func _setup_camera_limits():
	# Get tilemap bounds
	var used_rect = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size if tilemap.tile_set else Vector2(16, 16)

	# Set camera limits to level bounds
	camera.limit_left = used_rect.position.x * tile_size.x
	camera.limit_top = used_rect.position.y * tile_size.y
	camera.limit_right = used_rect.end.x * tile_size.x
	camera.limit_bottom = used_rect.end.y * tile_size.y

# Helper function to spawn enemies at runtime
func spawn_enemy(enemy_scene: PackedScene, position: Vector2):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = position
	$enemies.add_child(enemy)

# Helper function to spawn collectibles
func spawn_collectible(collectible_scene: PackedScene, position: Vector2):
	var collectible = collectible_scene.instantiate()
	collectible.global_position = position
	$collectibles.add_child(collectible)
```

## 2D Projectile Template

Create scene with:
```
Area2D (root)
├── Sprite2D (sprite)
├── CollisionShape2D (collision)
└── Timer (lifetime_timer)
```

Node details:
- Sprite2D: centered = true, modulate = Color(1, 1, 0) (yellow)
- CollisionShape2D: shape = CircleShape2D (radius = 4)
- Timer: wait_time = 5.0, one_shot = true, autostart = true

Create accompanying script:
```gdscript
extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.RIGHT

@onready var sprite = $Sprite2D
@onready var lifetime_timer = $lifetime_timer

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	lifetime_timer.timeout.connect(_on_lifetime_timeout)

	# Set lifetime
	lifetime_timer.wait_time = lifetime

func _physics_process(delta):
	# Move in direction
	position += direction.normalized() * speed * delta

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()

	# Rotate sprite to face direction
	rotation = direction.angle()

func _on_body_entered(body):
	# Hit something solid
	if body.has_method("take_damage"):
		body.take_damage(damage)

	# Create hit effect
	_create_hit_effect()

	queue_free()

func _on_area_entered(area):
	# Hit another area (enemy hitbox, etc.)
	if area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)

	# Create hit effect
	_create_hit_effect()

	queue_free()

func _on_lifetime_timeout():
	# Despawn after lifetime expires
	queue_free()

func _create_hit_effect():
	# TODO: Spawn particle effect or animation
	pass
```

## Collectible Template

Create scene with:
```
Area2D (root)
├── Sprite2D (sprite)
├── CollisionShape2D (collision)
├── AnimationPlayer (animation_player)
└── AudioStreamPlayer2D (pickup_sound)
```

Node details:
- Sprite2D: centered = true, modulate = Color(1, 0.8, 0) (gold color)
- CollisionShape2D: shape = CircleShape2D (radius = 8)

Create accompanying script:
```gdscript
extends Area2D

@export var collect_value: int = 1
@export var float_amplitude: float = 5.0
@export var float_speed: float = 2.0

var start_y: float
var time: float = 0.0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var pickup_sound = $pickup_sound

func _ready():
	# Connect collection signal
	body_entered.connect(_on_body_entered)

	# Store starting position for floating animation
	start_y = position.y

	# Random offset for variety
	time = randf() * TAU

func _process(delta):
	# Floating animation
	time += delta * float_speed
	position.y = start_y + sin(time) * float_amplitude

	# Rotate for visual interest
	sprite.rotation += delta * 2.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Notify player of collection
		if body.has_method("collect_item"):
			body.collect_item(collect_value)

		# Play pickup sound
		if pickup_sound and pickup_sound.stream:
			# Play sound then destroy
			pickup_sound.play()

			# Hide visuals but keep node alive for sound
			sprite.visible = false
			$CollisionShape2D.set_deferred("disabled", true)

			await pickup_sound.finished

		queue_free()
```

## Interactable Object Template

Create scene with:
```
StaticBody2D (root)
├── Sprite2D (sprite)
├── CollisionShape2D (collision)
├── Area2D (interaction_area)
│   └── CollisionShape2D (interaction_collision)
└── Label (prompt_label)
```

Node details:
- Sprite2D: centered = true
- CollisionShape2D: shape = RectangleShape2D (32x32)
- Area2D/CollisionShape2D: shape = RectangleShape2D (48x48) for interaction detection
- Label: text = "Press E", horizontal_alignment = CENTER, visible = false

Create accompanying script:
```gdscript
extends StaticBody2D

signal interacted

@export var interaction_text: String = "Press E"
@export var can_interact_multiple_times: bool = false

var player_nearby: bool = false
var has_been_used: bool = false

@onready var sprite = $Sprite2D
@onready var interaction_area = $interaction_area
@onready var prompt_label = $prompt_label

func _ready():
	# Connect area signals
	interaction_area.body_entered.connect(_on_interaction_area_entered)
	interaction_area.body_exited.connect(_on_interaction_area_exited)

	# Set prompt text
	prompt_label.text = interaction_text

	# Position prompt above object
	prompt_label.position.y = -40

func _process(_delta):
	if player_nearby and Input.is_action_just_pressed("ui_accept"):
		if not has_been_used or can_interact_multiple_times:
			_interact()

func _on_interaction_area_entered(body):
	if body.is_in_group("player"):
		player_nearby = true

		# Show prompt if not used or can use multiple times
		if not has_been_used or can_interact_multiple_times:
			prompt_label.visible = true

func _on_interaction_area_exited(body):
	if body.is_in_group("player"):
		player_nearby = false
		prompt_label.visible = false

func _interact():
	# Mark as used
	has_been_used = true

	# Hide prompt if can't be used again
	if not can_interact_multiple_times:
		prompt_label.visible = false

	# Emit signal for other systems to respond
	interacted.emit()

	# TODO: Implement specific interaction logic
	# Examples:
	# - Open a door
	# - Play an animation
	# - Give an item
	# - Show dialogue
	# - Toggle a mechanism

	print("Interacted with ", name)
```

# After Creating Scene

After creating the selected scene:

1. Inform the user of the files created:
   - Scene file location
   - Script file location

2. Provide customization tips:
   - "The [scene name] has been created at [path]"
   - "To customize this scene:"
     - Replace the placeholder sprite with your own artwork
     - Adjust the exported variables in the Inspector
     - Add animations in the AnimationPlayer
     - [Template-specific tips]

3. Provide usage instructions:
   - For characters: "Add this to your level by dragging into the scene or instantiating in code"
   - For levels: "Set this as your main scene in Project Settings or change to it with get_tree().change_scene_to_file()"
   - For projectiles: "Instance this in your player/enemy script when firing"
   - For collectibles/interactables: "Place these in your level scene as children"

4. Offer next steps:
   - "Would you like me to:"
     - Create related scenes (e.g., "create a projectile for this character?")
     - Add more features (e.g., "add a dash ability?", "add more enemy states?")
     - Set up animations (if AnimationPlayer exists)
     - Create a test level to try it out
