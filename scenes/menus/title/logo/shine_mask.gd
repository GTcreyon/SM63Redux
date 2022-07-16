extends Light2D

var time = 7 * 60

func _process(delta):
	var dmod = 60 * delta
	if time > 0:
		time -= 1 * dmod
		position.x = -255
	else:
		position.x += 30 * dmod
		if position.x > 213:
			time = 9 * 60
