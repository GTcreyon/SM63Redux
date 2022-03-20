extends Sprite

func _process(delta):
	scale = Vector2.ONE * round(OS.window_size.x / Singleton.DEFAULT_SIZE.x)
	position.x = OS.window_size.x / 2
	position.y = OS.window_size.y / 2
