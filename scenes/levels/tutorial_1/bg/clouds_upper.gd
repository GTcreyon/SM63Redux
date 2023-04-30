extends TextureRect

onready var cam = $"/root/Main".find_node("Camera", true, false)
var scroll = 0


func _process(delta):
	if !weakref(cam).get_ref(): # DO NOT use an else statement, this has to happen sequentially
		cam = $"/root/Main".find_node("Camera", true, false)
	if weakref(cam).get_ref():
		var cam_pos = cam.get_camera_position()
		var size = texture.get_size().x
		scroll += 0.125 * rect_scale.x * delta * 60
		margin_left = fmod(-scroll, size * rect_scale.x) - size * rect_scale.x
		margin_top = max(-50 * rect_scale.x, -50 * rect_scale.x - cam_pos.y / 50)
		margin_bottom = -50 * rect_scale.x
		rect_scale = Vector2.ONE * Singleton.get_screen_scale(1)
