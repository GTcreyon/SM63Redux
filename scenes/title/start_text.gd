extends Label

func _process(_delta):
	var scale = round(OS.window_size.y / Singleton.DEFAULT_SIZE.y)
	rect_scale = scale * 2 * Vector2.ONE
	rect_pivot_offset.x = OS.window_size.x / 2
	margin_top = OS.window_size.y / 4 * 3
