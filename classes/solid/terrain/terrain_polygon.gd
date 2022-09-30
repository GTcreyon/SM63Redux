tool
extends Polygon2D

export(Texture) var texture_spritesheet setget update_spritesheets

var body = ImageTexture.new()
var top = ImageTexture.new()
var top_shade = ImageTexture.new()
var top_corner = ImageTexture.new()
var top_corner_shade = ImageTexture.new()
var edge = ImageTexture.new()
var bottom = ImageTexture.new()

export(Vector2) var up_direction = Vector2(0, -1) setget set_down_direction
export(Vector2) var down_direction = Vector2(0, 1) setget set_null
export(int) var max_deviation = 60

export(bool) var shallow = false
export(Color) var shallow_color = Color(1, 1, 1, 0.5)

var properties: Dictionary = {}

onready var decorations = $Decorations

func set_glowing(should_glow):
	shallow = should_glow
	update()
#	visible = !should_glow

func set_down_direction(new_val):
	up_direction = new_val
	down_direction = new_val.tangent().tangent()

func set_null(_new_val):
	pass

func update_spritesheets(new_sheet):
	texture_spritesheet = new_sheet
	
	# Create textures from the spritesheet
	# I wanted to use atlas texture but support for it is bad
	
	body.create_from_image( texture_spritesheet.get_data().get_rect( Rect2(36, 3, 32, 32) ) )
	body.flags = Texture.FLAG_REPEAT
	edge.create_from_image( texture_spritesheet.get_data().get_rect( Rect2(3, 3, 32, 32) ) )
	edge.flags = Texture.FLAG_REPEAT
	bottom.create_from_image( texture_spritesheet.get_data().get_rect( Rect2(36, 36, 32, 32) ) )
	bottom.flags = Texture.FLAG_REPEAT

	top.create_from_image( texture_spritesheet.get_data().get_rect( Rect2(105, 3, 32, 32) ) )
	top.flags = Texture.FLAG_REPEAT
	top_corner.create_from_image( texture_spritesheet.get_data().get_rect( Rect2(72, 3, 32, 32) ) )
	top_corner.flags = Texture.FLAG_REPEAT
	top_shade.create_from_image( texture_spritesheet.get_data().get_rect( Rect2(105, 36, 32, 32) ) )
	top_shade.flags = Texture.FLAG_REPEAT
	top_corner_shade.create_from_image( texture_spritesheet.get_data().get_rect( Rect2(72, 36, 32, 32) ) )
	top_corner_shade.flags = Texture.FLAG_REPEAT

func _draw():
	decorations.update()
