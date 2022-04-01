extends TextureRect

const SCROLL_SPEED = 0.5

func _process(_delta):
	var scale = get_parent().scale
	margin_left -= SCROLL_SPEED * scale.x
	rect_scale = scale * Vector2.ONE
