extends Label

var progress = 0.0
var wait = 0.0

func _init():
	if Singleton.touch_controls():
		text = "Tap the screen to start!"


func _process(delta):
	var scale = get_parent().scale
	rect_scale = scale * 2 * Vector2.ONE
	rect_pivot_offset.x = OS.window_size.x / 2
	margin_top = OS.window_size.y / 4 * 3
	if wait < 150:
		wait += 1
	else:
		progress = min(progress + 60 * delta, 10)
		self_modulate.a = progress / 10
	
