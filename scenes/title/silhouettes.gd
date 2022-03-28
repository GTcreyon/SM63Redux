extends TextureRect

func _process(_delta):
	var scale = round(OS.window_size.y / Singleton.DEFAULT_SIZE.y)
	rect_scale = scale * Vector2.ONE
