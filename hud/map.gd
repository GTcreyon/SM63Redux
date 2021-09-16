extends Control

#func _process(delta):
#	print(rect_size)

func resize(scale):
	rect_scale = Vector2.ONE * scale
	margin_left = 37 * (scale - 1)
	margin_top = 19 * (scale - 1)
	margin_right = -37 * (scale - 1)
	margin_bottom = -19 * (scale - 1)
	#rect_size = (OS.window_size) / (scale + 1)# / scale
	
