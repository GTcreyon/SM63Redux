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
		var cam_pos = cam.get_camera_position()
		var size = texture.get_size().x
		
		# Plane can't actually move relative to the camera.
		# Instead, simulate scrolling on the X axis.
		margin_left = (fmod(-cam_pos.x / 20, size) - size) * rect_scale.x
		
		# Do likewise for the Y axis.
		var top_target = max(-Y_SIZE,
			( 
				(-Y_SIZE - cam_pos.y) / 5
					/
				rect_scale.x
			)
			-
			MAGIC * rect_scale.x
		)
		if abs(margin_top - top_target) > 50:
			# Appears to happen when the camera snaps back in bounds.
			margin_top = top_target
		else:
			margin_top = lerp(margin_top, top_target, 0.05)
