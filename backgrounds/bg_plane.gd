extends TextureRect

enum WrapMode {
	NO_WRAP = 0,
	INFINITE_BEFORE = 1 << 0, # TODO: Complex to implement this behavior.
	INFINITE_AFTER = 1 << 1,
	INFINITE = 1 << 0 | 1 << 1,
}

export var parallax_factor = Vector2(1.0/20, 1.0/5)
export var autoscroll = Vector2(0, 0)
# TODO: Implement this one.
export(WrapMode) var wrap_x_mode = WrapMode.INFINITE
export(WrapMode) var wrap_y_mode = WrapMode.NO_WRAP

var autoscroll_state = Vector2(0, 0)

onready var cam: Camera2D = $"/root/Main".find_node("Camera", true, false)
onready var size = texture.get_size()
onready var offset_global = (get_parent().get_parent() as CanvasLayer).offset
onready var offset_local = Vector2(margin_left, margin_top)


func _process(delta):
	# Get zoom level so we can factor that in.
	rect_scale = Vector2.ONE * Singleton.get_screen_scale(1)
	
	# Ensure we have a valid camera reference.
	if !weakref(cam).get_ref(): # DO NOT use an else statement, this has to happen sequentially
		cam = $"/root/Main".find_node("Camera", true, false)
	
	# If we successfully got a valid camera reference, do parallax logic.
	if weakref(cam).get_ref():
		# Save visual position of camera for later.
		var cam_pos = cam.get_camera_screen_center()
		var screen_size = get_viewport_rect().size / rect_scale
		
		# Plane can't actually move relative to the camera.
		# Instead, simulate scrolling.
		
		# Find un-parallax'd position of the plane.
		var position = -cam_pos + -size
		# Parallax it.
		position *= parallax_factor
		# Apply local offset so it ends up in the expected place.
		position += offset_local + vec2lerp(-offset_global, offset_global, parallax_factor)
		
		# Update automatic scrolling.
		autoscroll_state += autoscroll * rect_scale.x * delta * 60
		# Wrap autoscroll position within texture size.
		autoscroll_state = autoscroll_state.posmodv(size)
		# Apply autoscroll.
		position += autoscroll_state
		
		# Assign X position authored in the editor.
		if wrap_x_mode & WrapMode.INFINITE_BEFORE:
			# Wrap within the main width of the texture,
			# so the size stays manageable.
			margin_left = fmod(position.x - size.x, size.x)
		else:
			margin_left = position.x
		
		# Make plane infinite on the right, if desired.
		if wrap_x_mode & WrapMode.INFINITE_AFTER:
			margin_right = max(screen_size.x, margin_left)
		
		# Assign Y position authored in the editor.
		if wrap_y_mode & WrapMode.INFINITE_BEFORE:
			# Wrap within the main width of the texture,
			# so the size stays manageable.
			margin_top = fmod(position.y - size.y, size.y)
		else:
			margin_top = position.y
		# Counteract camera zoom so BG stays same size onscreen.
		# Ensure the camera never crosses below the plane.
		#margin_top = max(-size.y, margin_top)
		
		# Make plane infinite on the bottom, if desired.
		if wrap_y_mode & WrapMode.INFINITE_AFTER:
			margin_bottom = max(screen_size.y, margin_top)
			
		# Counteract camera zoom so BG stays same size onscreen.
		margin_left *= rect_scale.x
		margin_top *= rect_scale.x


func vec2lerp(from: Vector2, to: Vector2, fac: Vector2):
	return Vector2(
		lerp(from.x, to.x, fac.x),
		lerp(from.y, to.y, fac.y)
	)
