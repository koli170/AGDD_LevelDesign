extends Area2D
@export var zoom_level: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var tween = get_tree().create_tween()
		tween.tween_property(body.camera, "zoom", Vector2(zoom_level,zoom_level), 1.0).set_trans(Tween.TRANS_SINE)
		await tween.finished
		body.camera.zoom = Vector2(zoom_level,zoom_level)
