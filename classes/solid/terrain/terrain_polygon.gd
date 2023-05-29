tool
class_name TerrainPolygon
extends Polygon2D

export var texture_spritesheet: Texture setget update_spritesheets

var body: Texture = ImageTexture.new()
var top: Texture = ImageTexture.new()
var top_shade: Texture = ImageTexture.new()
var top_corner: Texture = ImageTexture.new()
var top_corner_shade: Texture = ImageTexture.new()
var edge: Texture = ImageTexture.new()
var bottom: Texture = ImageTexture.new()

export var up_direction = Vector2(0, -1) setget set_down_direction
# TODO: This should always == -up_direction.
export var down_direction = Vector2(0, 1) setget set_null
export var max_deviation: int = 60

# TODO: "shallow" makes no sense. Name it "tint" instead.
export var shallow = false
export var shallow_color = Color(1, 1, 1, 0.5)

# Manually set the type on each edge, rather than using the auto-generated one
# Types are indexed by first vertex: edge_types[3] will return the
# type ID of segment (3, 4).
export var edge_types: Dictionary = {}

var properties: Dictionary = {}

onready var decorations: TerrainPencil = $Decorations


func set_glowing(should_glow):
	shallow = should_glow
	update()


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
	# Queue the decorations to draw (leads to calling _draw()).
	# (In Godot 4, this function is called "queue_redraw," which explains itself,
	# so this comment is redundant and can be removed.)
	decorations.update()
