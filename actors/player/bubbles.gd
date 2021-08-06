extends Sprite

onready var viewport = $"../BubbleViewport"

func _ready():
	#create a texture for the bubbles
	var tex = ImageTexture.new()
	tex.create(viewport.size.x, viewport.size.y, Image.FORMAT_RGB8)
	texture = tex
	#now give the shader our viewport texture
	material.set_shader_param("viewport_texture", viewport.get_texture())
