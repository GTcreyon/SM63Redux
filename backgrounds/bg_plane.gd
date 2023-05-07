extends TextureRect

const Y_SIZE = 343
const MAGIC = 150

onready var cam = $"/root/Main".find_node("Camera", true, false)
var scroll = 0


func _process(_delta):
	# Get zoom level so we can factor that in.
	rect_scale = Vector2.ONE * Singleton.get_screen_scale(1)
	
	# Ensure we have a valid camera reference.
	if !weakref(cam).get_ref(): # DO NOT use an else statement, this has to happen sequentially
		cam = $"/root/Main".find_node("Camera", true, false)
	
	# If we successfully got a valid camera reference, do parallax logic.
	if weakref(cam).get_ref():
		# Save dimensions of plane and camera for later.
		var cam_pos = cam.get_camera_screen_center()
		var size = texture.get_size().x
		
		# Plane can't actually move relative to the camera.
		# Instead, simulate scrolling.
		margin_left = (fmod(-cam_pos.x / 20, size) - size) * rect_scale.x
		margin_top = (fmod(-cam_pos.y / 20, size) - size) * rect_scale.y
