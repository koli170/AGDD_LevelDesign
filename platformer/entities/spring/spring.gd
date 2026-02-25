extends Node2D

var is_furled : bool
var unfurled_timer : float
const UNFURLED_SEC: float = 1
var furled_sprite : Resource = load("res://entities/spring/SpringFurled.png")
var unfurled_sprite : Resource = load("res://entities/spring/SpringUnfurled.png")
var bounce_vec : Vector2 = Vector2(0,-1000)
@onready var spring_sprite : Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_furled = true;
	bounce_vec = bounce_vec.rotated(transform.get_rotation())
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_furled:
		unfurled_timer += delta
	if not is_furled and unfurled_timer >= UNFURLED_SEC:
		is_furled = true
		unfurled_timer = 0
		spring_sprite.texture = furled_sprite
		
		
		


func _on_static_body_2d_body_entered(body: Node2D) -> void:
	print("bounce")
	print(bounce_vec.x, " ", bounce_vec.y)
	if body is Player:
		body.velocity = bounce_vec
		
		is_furled = false
		spring_sprite.texture = unfurled_sprite
