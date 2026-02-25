extends Node2D
class_name Level

@export var top_left: Marker2D
@export var bottom_right: Marker2D

func _ready():
	for child in get_children():
		if child is Player:
			var camera = child.get_node("Camera")
			child.block_jump = false
			camera.limit_left = top_left.global_position.x
			camera.limit_top = top_left.global_position.y
			camera.limit_right = bottom_right.global_position.x
			camera.limit_bottom = bottom_right.global_position.y
