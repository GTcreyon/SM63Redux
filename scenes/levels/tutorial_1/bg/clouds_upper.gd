extends TextureRect

@onready var cam = $"/root/Main".find_child("Camera3D", true, false)
var scroll = 0


func _process(delta):
	if !weakref(cam).get_ref(): # DO NOT use an else statement, this has to happen sequentially
		cam = $"/root/Main".find_child("Camera3D", true, false)
	if weakref(cam).get_ref():
		var cam_pos = cam.get_camera_position()
		var size = texture.get_size().x
		scroll += 0.125 * scale.x * delta * 60
		offset_left = fmod(-scroll, size * scale.x) - size * scale.x
		offset_top = max(-50 * scale.x, -50 * scale.x - cam_pos.y / 50)
		offset_bottom = -50 * scale.x
		scale = Vector2.ONE * Singleton.get_screen_scale(1)
