extends Node2D

var is_furled : bool
var unfurled_timer : float
const UNFURLED_SEC: float = 1
var furled_sprite : Resource = load("res://level/Spring/SpringFurled.png")
var unfurled_sprite : Resource = load("res://level/Spring/SpringUnfurled.png")
@onready var spring_sprite : Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_furled = true;


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
	if body is Player:
		body.velocity.y = -900
		is_furled = false
		spring_sprite.texture = unfurled_sprite
