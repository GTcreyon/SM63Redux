extends TextureRect

const SCROLL_SPEED = 0.25

func _process(delta):
	var scale = get_parent().scale
	margin_left -= SCROLL_SPEED * scale.x * 60 * delta
	rect_scale = scale * Vector2.ONE
