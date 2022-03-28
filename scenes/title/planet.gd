extends TextureRect

const SCROLL_SPEED = 0.5

func _process(_delta):
	var scale = round(OS.window_size.y / Singleton.DEFAULT_SIZE.y)
	margin_left -= SCROLL_SPEED * scale
	rect_scale = scale * Vector2.ONE
