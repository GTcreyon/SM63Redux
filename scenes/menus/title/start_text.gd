extends Label

var progress = 0.0
var wait = 0.0


func _init():
	if Singleton.touch_control:
		text = "Tap the screen to start!"


func _process(delta):
	var dmod = 60 * delta
	var scale = get_parent().scale_vec
	scale = scale * 2 * Vector2.ONE
	pivot_offset.x = get_window().size.x / 2
	offset_top = get_window().size.y / 4 * 3
	if wait < 150:
		wait += dmod
	else:
		progress = min(progress + dmod, 10)
		self_modulate.a = progress / 10
	
