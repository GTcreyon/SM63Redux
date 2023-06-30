extends AnimatedSprite2D

@export var area = Vector2(20, 10)
@export var speed = Vector2(2, 3.25)

var progress = 0
var initial_position: Vector2


func _ready():
	initial_position = position
	playing = true


func _physics_process(_delta):
	progress += 0.01
	var x = progress * speed.x
	var y = progress * speed.y
	flip_h = cos(x) < 0 # Derivative of sin(progress)
	position = initial_position + Vector2(sin(x) * area.x, sin(y) * area.y)
