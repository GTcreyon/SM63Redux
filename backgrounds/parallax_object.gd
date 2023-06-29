class_name ParallaxObject
extends Node2D

export var parallax_factor = Vector2(0.25, 0.25)
export var autoscroll = Vector2(0, 0)

var autoscroll_state = Vector2(0, 0)

onready var cam: Camera2D = $"/root/Main".find_node("Camera", true, false)
onready var offset_local = position


func _process(delta):	
	# Ensure we have a valid camera reference.
	if !weakref(cam).get_ref(): # DO NOT use an else statement, this has to happen sequentially
		cam = $"/root/Main".find_node("Camera", true, false)
	
	# If we successfully got a valid camera reference, do parallax logic.
	if weakref(cam).get_ref():
		# Save visual position of camera for later.
		var cam_pos = cam.get_camera_screen_center()
		var screen_size = get_viewport_rect().size / scale
		
		# Find parallax'd position of the object.
		position = cam_pos * parallax_factor
		# Apply local offset so it ends up in the expected place.
		position += offset_local
		
		# Update automatic scrolling.
		autoscroll_state += autoscroll * scale.x * delta * 60
		position += autoscroll_state
		
		# TODO: Wrapping objects around the boundary of the screen.
		# Nontrivial for arbitrary objects e.g. terrain!
