extends AnimatedSprite

export var vel_multipliers = Vector2(2, 3.25)
export var dist_multipliers = Vector2(20, 10)

var progress = 0
var initial_position : Vector2

func _ready():
	initial_position = position
	playing = true

func _physics_process(_delta):
	progress += 0.01
	var x = progress * vel_multipliers.x
	var y = progress * vel_multipliers.y
	flip_h = cos(x) < 0 #derivative of sin(progress)
	position = initial_position + Vector2(sin(x) * dist_multipliers.x, sin(y) * dist_multipliers.y)
