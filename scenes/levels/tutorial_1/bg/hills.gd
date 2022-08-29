extends TextureRect

onready var cam = $"/root/Main".find_node("Camera", true, false)

func _process(_delta):
	rect_scale = Vector2.ONE * max(round(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	if !weakref(cam).get_ref(): # DO NOT use an else statement, this has to happen sequentially
		cam = $"/root/Main".find_node("Camera", true, false)
	if weakref(cam).get_ref():
		var cam_pos = cam.get_camera_position()
		var size = texture.get_size().x
		var target = max(-343, (-343 -cam_pos.y) / 5 / rect_scale.x - 150 * rect_scale.x)
		margin_left = (fmod(-cam_pos.x / 20, size) - size) * rect_scale.x
		if abs(margin_top - target) > 50:
			margin_top = target
		else:
			margin_top = lerp(margin_top, target, 0.05)
