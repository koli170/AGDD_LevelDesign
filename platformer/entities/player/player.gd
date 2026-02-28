class_name Player extends CharacterBody2D

## ADDED BY US:
var block_jump := false

var is_dying := false
@export var death_slow_scale: float = 0.2
@export var death_slow_duration: float = 0.8
@export var death_freeze_duration: float = 0.8
@onready var death_particles: GPUParticles2D = $GPUParticles2D
## NOT ADDED BY US vvvvv

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
	$GPUParticles2D.emitting = false
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if is_dying:
		# super died
		velocity.x = 0
		move_and_slide()
		return
		
		
	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	coyote_counter += delta
	if is_on_floor():
		_double_jump_charged = true
		velocity.x = direction
		coyote_counter = 0
	else:
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
	

func process_tilemap(tilemap: TileMapLayer, _rid: RID) -> void:
	# Check multiple layers
	var local_pos = tilemap.to_local(global_position)
	var cell = tilemap.local_to_map(local_pos)
	
	# Check a small radius of cells in case of edge contacts
	for dx in range(-2, 2):
		for dy in range(-2, 2):
			var check_cell = cell + Vector2i(dx, dy)
			var tile_data: TileData = tilemap.get_cell_tile_data(check_cell)
			if tile_data and tile_data.get_custom_data("is_killer"):
				respawn()
				return
				
func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		process_tilemap(body, body_rid)

func respawn():
	if is_dying:
		return
		
	$GPUParticles2D.emitting = true
	is_dying = true
	velocity = Vector2.ZERO
	
	# Btw if the last arg in .create_timer() isn't "true" it'll wait for timout second [[in slo-mo]]
	Engine.time_scale = death_slow_scale
	await get_tree().create_timer(death_slow_duration, false, true, true).timeout
	Engine.time_scale = 1.0
	await get_tree().create_timer(death_freeze_duration, false, true, true).timeout
	
	global_position = respawn_point.global_position
	velocity = Vector2.ZERO
	is_dying = false
	$GPUParticles2D.emitting = false

func try_jump() -> void:
	if block_jump or is_dying:
		return
	if is_on_floor() or (coyote_counter <= COYOTE_TIMER):
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged:
		_double_jump_charged = false
		velocity.x *= 2.5
		jump_sound.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	jump_sound.play()
