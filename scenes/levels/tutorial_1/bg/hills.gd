extends TextureRect

@onready var cam = $"/root/Main".find_child("Camera", true, false)

func _process(_delta):
	scale = Vector2.ONE * Singleton.get_screen_scale(1)
	if !weakref(cam).get_ref(): # DO NOT use an else statement, this has to happen sequentially
		cam = $"/root/Main".find_child("Camera", true, false)
	if weakref(cam).get_ref():
		var cam_pos = cam.position
		var tex_size = texture.get_size().x
		var target = max(-343, (-343 -cam_pos.y) / 5 / scale.x - 150 * scale.x)
		offset_left = (fmod(-cam_pos.x / 20, tex_size) - tex_size) * scale.x
		if abs(offset_top - target) > 50:
			offset_top = target
		else:
			offset_top = lerpf(offset_top, target, 0.05)
