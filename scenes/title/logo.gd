extends Sprite

var progress = 0.0
var wait = 0.0

onready var flash = $Flash

func _process(delta):
	scale = get_parent().scale
	position.x = round(OS.window_size.x / 2)
	position.y = -104 + ease_out_quart(min(progress, 60) / 60) * (104 + round(OS.window_size.y / 8 * 3))
	if wait < 30:
		wait += 1
	else:
		progress = min(progress + 60 * delta, 120)
		if progress > 60:
			flash.modulate.a = (1 - (progress - 60) / 60) * 0.75

func ease_out_quart(x: float) -> float:
	return 1 - pow(1 - x, 4)
