@tool
extends Sprite2D

const WATER_VIEWPORT_MATERIAL = preload("res://classes/water/water_viewport.tres")
const FRAME_TIMESTEP = 0.2

@export var polygon: PackedVector2Array = PackedVector2Array()
@export var surface_texture: Texture2D = load("res://classes/water/water_outline_anim.png")
@export var water_texture_size: Vector2 = Vector2(64, 64) # Unused
@export var surface_texture_size: Vector2 = Vector2(32, 12)
@export var water_color: Color = Color(0, 0.7, 1, 0.8)
#@export var texture_color_impact: float = 0.2;
#@export var animation_swing_range: float = 32;
#@export var animation_speed: float = 1;

var next_frame_time = FRAME_TIMESTEP
var frame_timer = 0
var current_frame = 0

@onready var viewport: SubViewport = $SubViewport
@onready var water_polygon: Polygon2D = $SubViewport/WaterPolygon
@onready var detection_area: Area2D = $DetectionArea
@onready var collision: CollisionPolygon2D = $DetectionArea/Collision

func refresh():
	#viewport.world_2d = get_world_2d()

	# Find the axis-aligned bounding box of the water polygon.
	var min_vec = Vector2.INF
	var max_vec = -Vector2.INF
	for vertex in polygon:
		min_vec.x = min(min_vec.x, vertex.x)
		min_vec.y = min(min_vec.y, vertex.y)
		max_vec.x = max(max_vec.x, vertex.x)
		max_vec.y = max(max_vec.y, vertex.y)
	if min_vec == Vector2.INF: # If we have 0 polygons, then don't do anything
		return
	
	# Find size of the AABB.
	var size_extents = max_vec - min_vec
	# This will be used to add headroom to the viewport.
	var size_diff = Vector2(0, size_extents.y * 1.5)
	
	# Set viewport size big enough to contain the whole polygon plus headroom.
	viewport.size = size_extents + size_diff
	
	# Set up the water polygon.
	water_polygon.position += size_diff / 2 # TODO: what happens w/o this?
	water_polygon.polygon = polygon
	# Collision polygon is just a rectangle for now.
	collision.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(size_extents.x, 0),
		size_extents, Vector2(0, size_extents.y)
	])

	# Put object origin at AABB center.
	position += size_extents / 2
	# But not collision--leave that where it was!
	collision.position -= size_extents / 2
	detection_area.top_left_corner = position - size_extents / 2
	# Start!
	detection_area.on_ready()
	
	# Now give the shader our viewport texture
	var root_mat = WATER_VIEWPORT_MATERIAL.duplicate()
	root_mat.set_shader_parameter("base_water_color", water_color)
	root_mat.set_shader_parameter("surface_texture", surface_texture)
	root_mat.set_shader_parameter("surface_texture_size", surface_texture_size)
	material = root_mat
	texture = viewport.get_texture()
	2
	# For the editor, update the display color.
	water_polygon.color = Color(water_color.r, water_color.g, water_color.b, 1)
	
	# Set the water shaders
#	var mat = water_material.duplicate()
#	mat.set_shader_param("base_water_color", water_color)
#	mat.set_shader_param("texture_repeat", (size_extents / water_texture_size).y)
#	mat.set_shader_param("water_xy_ratio", Vector2(size_extents.x / size_extents.y, 1))
#	mat.set_shader_param("normal_map_mult", texture_color_impact)
#	mat.set_shader_param("animation_swing_range_px", animation_swing_range)
#	mat.set_shader_param("animation_speed", animation_speed)
#	water_polygon.material = mat


func _draw():
	if Engine.is_editor_hint():
		# Full water rendering isn't available in editor.
		# Draw solid-colored polygons instead.
		var colors = PackedColorArray()
		for poly in polygon:
			colors.append(Color(0, 0.7, 1))#water_color)
		draw_polygon(polygon, colors)
		# Draw circles on the verts as well.
		for poly in polygon:
			draw_circle(poly, 3, Color(0, 1, 1))


func _process(dt):
	if Engine.is_editor_hint():
		return
	
	# Tick surface animation timer.
	frame_timer += dt
	if frame_timer >= next_frame_time:
		# Advance surface to next flipbook frame.
		current_frame = (current_frame + 1) % 4
		material.set_shader_parameter("surface_anim_phase", current_frame)

		# Reset timer for next frame.
		next_frame_time = frame_timer + FRAME_TIMESTEP


func _ready():
	if !Engine.is_editor_hint():
		refresh()
