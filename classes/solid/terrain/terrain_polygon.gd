@tool
class_name TerrainPolygon
extends Polygon2D
# Root node for terrain polygons. All terrain-polygon behavior can be controlled
# from here.

const COLLISION_LAYER_TERRAIN = 1

@export var skin: TerrainSkin: set = reload_tileset

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


func reload_tileset(new_ts: TerrainSkin):
	skin = new_ts
	
	if skin != null:
		body = new_ts.body
		edge = new_ts.side
		bottom = new_ts.bottom

		top = new_ts.top
		top_corner = new_ts.top_endcap
		top_shade = new_ts.top_shadow
		top_corner_shade = new_ts.top_endcap_shadow
	else:
		body = null
		edge = null
		bottom = null

		top = null
		top_corner = null
		top_shade = null
		top_corner_shade = null
