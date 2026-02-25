extends Marker2D

@export var next_level: PackedScene
@onready var area: Area2D = $Area2D
var is_touching := false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_touching:
		get_tree().change_scene_to_packed(next_level)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player collided!")
		is_touching = true
		body.block_jump = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player exited!")
		is_touching = false
		body.block_jump = false
