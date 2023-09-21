extends Label

var progress = 0.0
var wait = 0.0


func _init():
	if Singleton.touch_control:
		text = "Tap the screen to start!"


func _process(delta):
	var dmod = 60 * delta
	var scale_vec = get_parent().scale_vec
	var window_size = Vector2(get_window().size) # convert to float vector - avoids int div warning
	scale = scale_vec * 2 * Vector2.ONE
	pivot_offset.x = window_size.x / 2
	
	if wait < 150:
		wait += dmod
	else:
		progress = min(progress + dmod, 10)
		self_modulate.a = progress / 10
	
