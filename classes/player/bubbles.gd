extends Sprite

onready var viewport = prepare_viewport()
onready var cam = $"/root/Main/Player/Camera"


func _ready():
	# At this point, viewport has been queued for freeing,
	# but has yet to be actually freed.
	
	refresh()
	# Move this node into Main
	get_parent().call_deferred("remove_child", self)
	$"/root/Main".call_deferred("add_child", self)


func _process(_delta):
	viewport.canvas_transform = get_canvas_transform()
	# Set the position to the screen center
	scale = Vector2(1, 1) / cam.get_canvas_transform().get_scale()
	position = (viewport.size / 2 - cam.get_canvas_transform().origin) * scale
	# Update shader pixel scale so the bubble outline is independent of viewport res
	material.set_shader_param("zoom", cam.zoom.x * 1.5 )


func refresh():
	# Set the viewport size to the window size
	viewport.size = OS.window_size
	# Create a new texture for self
	var tex = ImageTexture.new()
	tex.create(viewport.size.x, viewport.size.y, Image.FORMAT_RGB8)
	texture = tex
	# Now give the shader our viewport texture
	material.set_shader_param("viewport_texture", viewport.get_texture())


# Fetch any viewports that have been moved into Main.
# If there are none, move this object's parent viewport into Main.
func prepare_viewport() -> Viewport:
	if $"/root/Main".has_node("BubbleViewport"):
		# Viewport exists in main.
		# Delete my parent viewport so we don't have extras.
		$"../BubbleViewport".queue_free()
		
		return $"/root/Main/BubbleViewport" as Viewport
	else:
		# No viewport exists in main.
		# Move this node's parent viewport into main.
		var my_viewport = $"../BubbleViewport"
		my_viewport.get_parent().call_deferred("remove_child", my_viewport)
		$"/root/Main".call_deferred("add_child", my_viewport)
		
		return my_viewport
