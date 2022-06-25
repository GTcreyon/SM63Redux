extends TextureRect

const SCROLL_SPEED = 0.5
var wait = 0.0
var progress = 0.0

onready var flash = $Flash

func _process(delta):
	var scale = get_parent().scale
	margin_left -= SCROLL_SPEED * scale.x * 60 * delta
	margin_top = -194 * ease_out_quart(min(progress, 60) / 60)
	rect_scale = scale * Vector2.ONE
	if wait < 50:
		wait += 1
	else:
		progress = min(progress + 60 * delta, 98)
		if progress > 68:
			flash.color.a = (1 - (progress - 68) / 30) * 0.25


func ease_out_quart(x: float) -> float:
	return 1 - pow(1 - x, 4)
