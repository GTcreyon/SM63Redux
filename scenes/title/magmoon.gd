extends Sprite

var progress = 0

func _process(_delta):
	var scalar = get_parent().scale
	scale = scalar * Vector2.ONE
	progress = fmod(progress + (1.0 / 60.0) / 10, 2.0)
	position.y = 90 - sin((progress - 0.1) * PI) * 45
	position.x = OS.window_size.x * (progress - 0.1)
