extends AnimatedSprite2D

var time = 0


func _ready():
	time = randf_range(0, 4 * 60)

func _process(delta):
	time -= 1 * 60 * delta
	if time <= 0:
		play()
		frame = 0
		time = randf_range(2 * 60, 3 * 60)
