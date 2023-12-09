extends TextureRect

@onready var cam: Camera2D = $"/root/Main".find_child("Camera", true, false)
var scroll = 0


func _process(delta):
	if !weakref(cam).get_ref(): # DO NOT use an else statement, this has to happen sequentially
		cam = $"/root/Main".find_child("Camera", true, false)
	if weakref(cam).get_ref():
		var cam_pos = cam.position
		var tex_size = texture.get_size().x
		scroll += 0.125 * scale.x * delta * 60
		offset_left = fmod(-scroll, tex_size * scale.x) - tex_size * scale.x
		offset_top = max(-50 * scale.x, -50 * scale.x - cam_pos.y / 50)
		offset_bottom = -50 * scale.x
		scale = Vector2.ONE * Singleton.get_screen_scale(1)
