extends Area2D

@onready var bg := $"../BG/Background"
var blend := 0.0
var speed := 0.05
var transitioning := false

func _process(delta):
	if transitioning and blend < 1.0:
		blend = clamp(blend + delta * speed, 0.0, 1.0)
		bg.material.set_shader_parameter("blend_amount", blend)
		bg.material.set_shader_parameter("strength", clampf(blend, 0.1, 1.0))

func _on_area_entered(_area: Area2D) -> void:
	transitioning = true
