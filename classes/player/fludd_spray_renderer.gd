extends Sprite

onready var viewport = $"../SprayViewport"
onready var cam = $"/root/Main/Player/Camera"


func _process(_delta):
	# Regenerate texture to match window size.
	# TODO: Texture generation can't be efficient. 
	#  Only run this on frames when the viewport has actually been
	#  resized. (Profile first to ensure it's actually saving time.)
	refresh()
	
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
