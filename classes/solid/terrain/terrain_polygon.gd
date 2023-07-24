@tool
class_name TerrainPolygon
extends Polygon2D
# Root node for terrain polygons. All terrain-polygon behavior can be controlled
# from here.

const COLLISION_LAYER_TERRAIN = 1

@export var texture_spritesheet: Texture2D: set = update_spritesheets

var body: Texture2D
var top: Texture2D
var top_shade: Texture2D
var top_corner: Texture2D
var top_corner_shade: Texture2D
var edge: Texture2D
var bottom: Texture2D

@export var up_direction = Vector2(0, -1): set = set_down_direction
# TODO: This should always == -up_direction.
@export var down_direction = Vector2(0, 1): set = set_null
@export var max_deviation: int = 60

@export var tint = false
@export var tint_color = Color(1, 1, 1, 0.5)

@export var solid = true

# Manually set the type on each edge, rather than using the auto-generated one
# Types are indexed by first vertex: edge_types[3] will return the
# type ID of segment (3, 4).
@export var edge_types: Dictionary = {}

var properties: Dictionary = {}

@onready var decorations: TerrainBorder = $Borders
@onready var collision_body: StaticBody2D = $Static
@onready var collision_shape: CollisionPolygon2D = $Static/Collision


func _draw():
	decorations.queue_redraw()
	
	# Update the collision polygon if not in editor.
	if !Engine.is_editor_hint():
		# Update cols to match the terrain's designed shape.
		collision_shape.polygon = polygon
		
		# Enable/disable the collision itself as appropriate.
		collision_body.set_collision_layer_value(COLLISION_LAYER_TERRAIN, solid)


func set_glowing(should_glow):
	tint = should_glow
	queue_redraw()


func set_down_direction(new_val):
	up_direction = new_val
	down_direction = new_val.orthogonal().orthogonal()


func set_null(_new_val):
	pass


func update_spritesheets(new_sheet: Texture2D):
	texture_spritesheet = new_sheet
	
	# Create textures from the spritesheet.
	# Can't just use atlas textures, they don't loop like we need.
	
	body = ImageTexture.create_from_image(texture_spritesheet.get_image().get_region( Rect2(36, 3, 32, 32) ) )
	edge = ImageTexture.create_from_image(texture_spritesheet.get_image().get_region( Rect2(3, 3, 32, 32) ) )
	bottom = ImageTexture.create_from_image(texture_spritesheet.get_image().get_region( Rect2(36, 36, 32, 32) ) )

	top = ImageTexture.create_from_image(texture_spritesheet.get_image().get_region( Rect2(105, 3, 32, 32) ) )
	top_corner = ImageTexture.create_from_image(texture_spritesheet.get_image().get_region( Rect2(72, 3, 32, 32) ) )
	top_shade = ImageTexture.create_from_image(texture_spritesheet.get_image().get_region( Rect2(105, 36, 32, 32) ) )
	top_corner_shade = ImageTexture.create_from_image(texture_spritesheet.get_image().get_region( Rect2(72, 36, 32, 32) ) )
