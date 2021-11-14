extends AnimatedSprite

var motion = Vector2()

var x = 0.0

var is_incre = true
var progress = 0
var initial_position : Vector2

func _ready():
	initial_position = position

func _physics_process(_delta):
	if(x >= 2):
		is_incre = false
	elif(x <= -2):
		is_incre = true
	
	flip_h = (x < 0)
		
	if is_incre:
		x += 0.05
	else:
		x -= 0.05
	
	position.x += x
	
	progress += 0.1
	position.y = initial_position.y + sin(progress) * 10
