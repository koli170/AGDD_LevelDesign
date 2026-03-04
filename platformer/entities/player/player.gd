class_name Player extends CharacterBody2D

## ADDED BY US:
var block_jump := false

var is_dying := false
@export var death_slow_duration: float = 0.5
@onready var death_particles: GPUParticles2D = $GPUParticles2D
var is_stuck := false
var was_stuck := false
var wall_normal := Vector2.ZERO
## ADDED BY US ^^^^^^

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -725.0
## Maximum speed at which the player can fall.
const TERMINAL_VELOCITY = 700
const COYOTE_TIMER : float = 0.1
var coyote_counter : float = 0.0
@export var respawn_point : Marker2D

## The player listens for input actions appended with this suffix.[br]
## Used to separate controls for multiple players in splitscreen.
@export var action_suffix := ""

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var sprite := $Sprite2D as Sprite2D
@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var camera := $Camera as Camera2D
var _double_jump_charged := false

func _ready() -> void:
	death_particles.emitting = false
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_dying:
		# super died
		velocity.x = 0
		move_and_slide()
		return
	if is_stuck:
		gravity = 0
	else:
		gravity = 2100
		
	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	coyote_counter += delta
	if is_on_floor():
		_double_jump_charged = true
		velocity.x = direction
		coyote_counter = 0
	else:
		if not is_stuck:
			velocity.x = move_toward(velocity.x, direction, delta*ACCELERATION_SPEED)
		
	if Input.is_action_just_pressed("jump" + action_suffix):
		try_jump()
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)


	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()
	
	if not is_dying:
		_check_for_killers()

func _check_for_killers() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is TileMapLayer:
			var tilemap := collider as TileMapLayer
			var contact_point := collision.get_position()
			var inset_point := contact_point + collision.get_normal() * 2.0
			var local_pos := tilemap.to_local(inset_point)
			var cell := tilemap.local_to_map(local_pos)
			var tile_data: TileData = tilemap.get_cell_tile_data(cell)
			
			var surface_point := contact_point - collision.get_normal() * 2.0
			var surface_local := tilemap.to_local(surface_point)
			var surface_cell := tilemap.local_to_map(surface_local)
			var surface_data: TileData = tilemap.get_cell_tile_data(surface_cell)

			
			if tile_data and tile_data.get_custom_data("is_killer"):
				respawn()
				return
			if surface_data and surface_data.get_custom_data("is_sticky"):
				is_stuck = true
				_double_jump_charged = true
				velocity = Vector2.ZERO
				wall_normal = collision.get_normal()
				return
			is_stuck = false
			wall_normal = Vector2.ZERO


func respawn():
	if is_dying:
		return
		
	death_particles.restart()
	death_particles.emitting = true
	is_dying = true
	velocity = Vector2.ZERO
	
	await get_tree().create_timer(death_slow_duration).timeout
	
	global_position = respawn_point.global_position
	velocity = Vector2.ZERO
	is_dying = false
	death_particles.emitting = false

func try_jump() -> void:
	if block_jump or is_dying:
		return
	if is_on_floor() or (coyote_counter <= COYOTE_TIMER):
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged:
		if is_stuck:
			var input_dir := -Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix)

			# Must press away from wall
			if sign(input_dir) != sign(wall_normal.x):
				velocity.x = wall_normal.x * 600   # push away from wall
				_double_jump_charged = false
			else:
				return
		else:
			_double_jump_charged = false

		jump_sound.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	jump_sound.play()
