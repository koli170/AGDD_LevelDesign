extends Marker2D

@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	add_to_group("spawns")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.respawn_point = self
		sprite.modulate = Color.GREEN
		for spawn: Marker2D in get_tree().get_nodes_in_group("spawns"):
			if spawn != self:
				spawn.sprite.modulate = Color.WHITE
