extends Sprite

func _process(_delta):
	scale = get_parent().scale
	position.x = round(OS.window_size.x / 2)
	position.y = round(OS.window_size.y / 8 * 3)
