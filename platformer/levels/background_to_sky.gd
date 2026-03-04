extends Area2D

@onready var bg := $"../BG/Background"
@onready var target_marker: Marker2D = $"../TargetMarker"

var blend := 0.0
var speed := 0.05
var transitioning := false
var player: Player

var camera: Camera2D
var start_position: Vector2

func _ready():
	player = get_tree().get_first_node_in_group("player")
	camera = player.camera

func _process(delta):
	if transitioning and blend < 1.0:
		blend = clamp(blend + delta * speed, 0.0, 1.0)
		bg.material.set_shader_parameter("blend_amount", blend)
		bg.material.set_shader_parameter("strength", clampf(blend, 0.1, 1.0))
		var t = smoothstep(0.0, 1.0, blend)
		camera.global_position = start_position.lerp(target_marker.global_position, t)

func _on_area_entered(_area: Area2D) -> void:
	if transitioning:
		return
	transitioning = true
	start_position = camera.global_position

	camera.set_as_top_level(true)
	camera.global_position = start_position

	camera.limit_left = -9999
	camera.limit_top = -100000
	player.is_dying = true

	print("start: ", start_position)
	print("target: ", target_marker.global_position)
