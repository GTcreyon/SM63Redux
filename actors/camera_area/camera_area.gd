tool
extends Polygon2D

export var editor_view_extends = false

onready var player = $"/root/Main/Player"
onready var camera: Camera2D = player.get_node("Camera2D")
onready var warp = $"/root/Singleton/Warp"
onready var singleton = $"/root/Singleton"
onready var base_modifier: BaseModifier = singleton.base_modifier

const WINDOW_DIAGONAL = pow(pow(448 / 2, 2) + pow(304 / 2, 2), 0.5)

var global_polygon = PoolVector2Array()

#return segment-polygon intersection
func intersect_polygon(from, to, poly):
	var hit
	var closest_distance = INF
	var size = poly.size()
	for ind in range(size):
		var this = poly[ind]
		var next = poly[(ind + 1) % size]
		var check_hit = Geometry.segment_intersects_segment_2d(from, to, this, next)
		#if nothing got hit, then skip
		if !check_hit:
			continue
		#make sure the one we return is the closest to the player
		var dist = (check_hit - from).length()
		if dist <= closest_distance:
			closest_distance = dist
			hit = check_hit
	return hit

func get_closest_point_to_polygon(point, fallback):
	#get a list of nearest positions
	var nearest_positions = []
	var size = global_polygon.size()
	for ind in range(size):
		var this = global_polygon[ind % size]
		var next = global_polygon[(ind + 1) % size]
		var nearest = Geometry.get_closest_point_to_segment_2d(point, this, next)
		#if !(nearest == this || nearest == next):
		nearest_positions.append(nearest)
	#find the REAL nearest position
	var real_pos = fallback
	var nearest_dist = INF
	for poly in nearest_positions:
		var mag = (poly - point).length()
		if mag < nearest_dist:
			nearest_dist = mag
			real_pos = poly
	return real_pos

var last_valid_pos = null
func set_limits():
	if global_polygon.size() == 0:
		pass
	#TODO for the future, disable the tweening for the camera when outside of the radius
	var camera_pos = camera.get_camera_screen_center()
	var player_pos = player.position
	if !last_valid_pos:
		last_valid_pos = get_closest_point_to_polygon(player_pos, last_valid_pos)
	#var camera_sway = last_valid_pos - camera_pos
	#check if the camera position is inside the polygon
	if Geometry.is_point_in_polygon(player_pos, global_polygon):
		camera.offset = Vector2(0, 0)
		camera.smoothing_enabled = true
		last_valid_pos = player_pos
	else:
		var real_pos = get_closest_point_to_polygon(player_pos, last_valid_pos)
		#calculate the offset
		var offset = real_pos - player_pos
		base_modifier.add_modifier(camera, "position", "camera_limits", offset)

func _draw():
	if Engine.editor_hint && editor_view_extends:
		var margin_poly = PoolVector2Array()
		var size = polygon.size()
		var global_normal = 1 if Geometry.is_polygon_clockwise(polygon) else -1
		for ind in range(size):
			var prev = polygon[(ind - 1) % size]
			var this = polygon[ind % size]
			var next = polygon[(ind + 1) % size]
			var this_prev = this.direction_to(prev)
			var this_next = this.direction_to(next)
			var normal = (this_prev + this_next).normalized()
			normal *= 1 if Geometry.is_polygon_clockwise([prev, this, next]) else -1
			normal *= global_normal
			margin_poly.append(this - normal * WINDOW_DIAGONAL) #224 is half the width of
		draw_colored_polygon(polygon, Color(1, 0, 0, 0.5))
		draw_colored_polygon(margin_poly, Color(0, 1, 0, 0.3))

func _ready():
	if Engine.editor_hint:
		pass
	#convert polygon to global polygon
	var real_poly = PoolVector2Array()
	for vec in polygon:
		real_poly.append(vec + global_position)
	global_polygon = real_poly

func _process(_dt):
	if Engine.editor_hint:
		pass
	if warp.enter != 1:
		set_limits()
