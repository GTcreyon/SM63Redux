@tool
class_name TerrainPolygon
extends Polygon2D
# Root node for terrain polygons. All terrain-polygon behavior can be controlled
# from here.

const COLLISION_LAYER_TERRAIN = 1

@export var skin: TerrainSkin: set = reload_tileset

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

var body: Texture2D
var top: Texture2D
var top_clip: Texture2D
var top_endcap: Texture2D
var top_endcap_clip: Texture2D
var side: Texture2D
var bottom: Texture2D

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
	# Callback to make the terrain lump update when the skin is modified.
	var redraw_on_skin_change = Callable(self, "update_and_redraw")
	
	# Clean up this terrain lump's callback from off the old skin (if it exists).
	if skin != null:
		assert(skin.changed.is_connected(redraw_on_skin_change))
		
		skin.disconnect("changed", redraw_on_skin_change.bind(skin))
	
	# Replace the old skin with the new.
	skin = new_ts
	
	if new_ts != null:
		# If the new skin isn't nothing, read in its new textures.
		update_textures(new_ts)
		# Also subscribe to updates, so this lump stays in sync.
		new_ts.changed.connect(redraw_on_skin_change.bind(new_ts))
		
		assert(new_ts.changed.is_connected(redraw_on_skin_change))
	else:
		# If the new skin is nothing, set the textures to nothing as well.
		clear_textures()
	
	# Push graphics updates to child nodes.
	# Said nodes can apparently be null right when the editor starts up,
	# so only update when these nodes exist.
	if decorations != null:
		decorations.queue_redraw()


func update_and_redraw(new_skin: TerrainSkin):
	update_textures(new_skin)
	decorations.queue_redraw()


func update_textures(src_skin: TerrainSkin):
	body = src_skin.body
	side = src_skin.side
	bottom = src_skin.bottom

	top = src_skin.top
	top_endcap = src_skin.top_endcap
	top_clip = src_skin.top_clip
	top_endcap_clip = src_skin.top_endcap_clip


func clear_textures():
	body = null
	side = null
	bottom = null

	top = null
	top_endcap = null
	top_clip = null
	top_endcap_clip = null
	
