extends Sprite

func _process(_delta):
	scale = Vector2.ONE * round(OS.window_size.x / Singleton.DEFAULT_SIZE.x)
	position.x = round(OS.window_size.x / 2)
	position.y = round(OS.window_size.y / 8 * 3)
