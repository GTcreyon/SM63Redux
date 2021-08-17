extends Sprite

onready var viewport = $"../BubbleViewport"

func _ready():
	#set the viewport size to the window size
	viewport.size = get_viewport_rect().size
	#create a texture for the bubbles
	var tex = ImageTexture.new()
	tex.create(viewport.size.x, viewport.size.y, Image.FORMAT_RGB8)
	texture = tex
	#now give the shader our viewport texture
	material.set_shader_param("viewport_texture", viewport.get_texture())
	
	#deparent this node
	$"/root/Main/Player".call_deferred("remove_child", self)
	$"/root/Main".call_deferred("add_child", self)
	#deparent the viewport
	$"/root/Main/Player".call_deferred("remove_child", viewport)
	$"/root/Main".call_deferred("add_child", viewport)

func _process(delta):
	#set the position to the screen center
	position = get_viewport_rect().size / 2 - get_viewport().get_canvas_transform().origin
