extends Marker2D

@onready var area: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.respawn_point = self
