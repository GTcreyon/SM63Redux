extends Light2D

var time = 7 * 60

func _process(_delta):
	if time > 0:
		time -= 1
		position.x = -255
	else:
		position.x += 30
		if position.x > 213:
			time = 9 * 60
