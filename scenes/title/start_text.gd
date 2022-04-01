extends Label

func _init():
	if OS.get_name() == "Android":
		text = "Tap the screen to start!"


func _process(_delta):
	var scale = get_parent().scale
	rect_scale = scale * 2 * Vector2.ONE
	rect_pivot_offset.x = OS.window_size.x / 2
	margin_top = OS.window_size.y / 4 * 3
	
