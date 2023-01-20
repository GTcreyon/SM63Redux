extends TextureRect

const SCROLL_SPEED = 0.25
const TIME = 30.0
var progress = 0.0
var wait = 0.0


func _process(delta):
	var dmod = 60 * delta
	var scale = get_parent().scale
	margin_left -= SCROLL_SPEED * scale.x * dmod
	rect_scale = scale * Vector2.ONE
	if wait < 90:
		wait += 1
	else:
		progress = min(progress + dmod, TIME)
