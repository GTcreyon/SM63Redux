tool
extends Polygon2D

onready var player = $"/root/Main/Player"
onready var camera = player.get_node("Camera")

onready var base_modifier = BaseModifier.new()

onready var collision = $StaticBody2D/CollisionPolygon2D
onready var body = $KinematicBody2D
onready var body_collision: CollisionPolygon2D = $KinematicBody2D/CollisionPolygon2D

#export var spawn_position: Vector2 setget force_draw

var window_prev_length: float
var shrink_number = 0
var frozen = false
#func force_draw(val):
#	spawn_position = val
#	update()
#
#func _draw():
#	if Engine.editor_hint:
#		draw_rect(Rect2(
#			spawn_position - Vector2(Singleton.DEFAULT_SIZE.x * 2, Singleton.DEFAULT_SIZE.y) / 2,
#			Vector2(Singleton.DEFAULT_SIZE.x * 2, Singleton.DEFAULT_SIZE.y)
#		), Color(1, 0, 1, 0.5))
#		draw_rect(Rect2(
#			spawn_position - Vector2(Singleton.DEFAULT_SIZE.x, Singleton.DEFAULT_SIZE.y) / 2,
#			Vector2(Singleton.DEFAULT_SIZE.x, Singleton.DEFAULT_SIZE.y)
#		), Color(0, 0, 1, 0.5))

func get_rect(poly, margin = 0):
	var min_v = Vector2.INF
	var max_v = -Vector2.INF
	for vec in poly:
		min_v.x = min(min_v.x, vec.x)
		min_v.y = min(min_v.y, vec.y)
		max_v.x = max(max_v.x, vec.x)
		max_v.y = max(max_v.y, vec.y)
	return Rect2(min_v - Vector2(margin, margin), max_v - min_v + Vector2(margin, margin) * 2)

func set_physics_polygon(poly):
	var rect = get_rect(poly, 20)
	var inject = [
		rect.position, rect.position + Vector2(rect.size.x, 0),
		rect.position + rect.size, rect.position + Vector2(0, rect.size.y)
	]
	
	# Re-arrange the polygon to the first vertex is the most top vertex
	
	# First find the top most vertex
	var top_vertex = 0
	var top_y_pos = 0
	var poly_size = poly.size()
	for ind in range(poly_size):
		var poly_y = poly[ind].y
		if poly_y <= top_y_pos:
			top_y_pos = poly_y
			top_vertex = ind
	
	# Rebuild the polygon
	var real_poly = []
	for ind in range(poly_size):
		if ind >= top_vertex:
			real_poly.append(poly[ind])
	for ind in range(poly_size):
		if ind < top_vertex:
			real_poly.append(poly[ind])
	poly = real_poly
	
	# Our ray upwards
	var ray_start = poly[0]
	var ray_end = poly[0] - Vector2(0, 10000)
	
	# Get the point where we should inject
	var inject_index
	var inject_vector
	
	var p_size = inject.size()
	for ind in range(p_size):
		var p_start = inject[ind]
		var p_end = inject[(ind + 1) % p_size]
		# Check if there's an intersection, if so, check if it is the nearest one
		var point = Geometry.segment_intersects_segment_2d(
			ray_start,
			ray_end,
			p_start, 
			p_end
		)
		
		if point:
			inject_index = ind
			inject_vector = point
			break
	
	# Build the REAL shape array
	var real = []
	var did_inject = false
	for ind in range(p_size):
		real.append(inject[ind])
		if !did_inject and ind >= inject_index:
			
			# Add our injection vector
			real.append(inject_vector)
			
			# To prevent the injection points from crossing eachother
			var first_vector = poly[0]
			poly.invert()
			real.append_array(poly)
			
			# Add our injection vector
			real.append(first_vector)
			real.append(inject_vector)
			
			did_inject = true
	
	polygon = real
	collision.polygon = real

func set_hitbox_extends(size):
	body_collision.polygon = PoolVector2Array([
		Vector2(0, -size.y / 2),
		Vector2(size.x / 2, 0),
		Vector2(0, size.y / 2),
		Vector2(-size.x / 2, 0)
	])
	window_prev_length = size.length()

func _ready():
	if Engine.editor_hint:
		return
	# Invert the current polygon
	set_physics_polygon(polygon)
	
#	body_collision.shape.set_extents(OS.window_size / 2)
	set_hitbox_extends(OS.window_size)
	shrink_number = 0
	
	body.position = player.position # spawn_position
	# Make it invisible
	color = Color(0, 0, 0, 0)
	
func _physics_process(dt):
	if Engine.editor_hint:
		return

	shrink_number = min(1, shrink_number + dt * 5)
	var target_size = OS.window_size * camera.zoom * shrink_number
	if target_size.length() != window_prev_length:
		set_hitbox_extends(target_size)
	
		window_prev_length = target_size.length()
		body_collision.polygon = PoolVector2Array([
			Vector2(0, -target_size.y / 2),
			Vector2(target_size.x / 2, 0),
			Vector2(0, target_size.y / 2),
			Vector2(-target_size.x / 2, 0)
		])
	
	# Emergency workaround
	if Singleton.disable_limits:
		body_collision.polygon = PoolVector2Array([
			Vector2.ZERO,
		])
	elif body_collision.polygon == PoolVector2Array([
			Vector2.ZERO,
		]):
		body_collision.polygon = PoolVector2Array([
			Vector2(0, -target_size.y / 2),
			Vector2(target_size.x / 2, 0),
			Vector2(0, target_size.y / 2),
			Vector2(-target_size.x / 2, 0)
		])
		
	#update the camera position and stuff
	var target = player.position
	if !frozen:
		body.move_and_slide(((target - body.position) / dt))

	# Set the base of the camera to the body
	base_modifier.set_base(camera, "position", body.position - player.position)
