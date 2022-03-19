tool
extends Polygon2D

onready var player = $"/root/Main/Player"
onready var camera = player.get_node("Camera2D")

onready var singleton = $"/root/Singleton"
onready var base_modifier: BaseModifier = singleton.base_modifier

onready var collision = $StaticBody2D/CollisionPolygon2D
onready var body = $KinematicBody2D
onready var body_collision = $KinematicBody2D/CollisionShape2D

export var spawn_position: Vector2 setget force_draw

func force_draw(val):
	spawn_position = val
	update()

func _draw():
	if Engine.editor_hint:
		var base_size = Vector2(640, 360)
		draw_rect(Rect2(
			spawn_position - base_size / 2,
			base_size
		), Color(0, 0, 1, 0.5))

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
	
	#re-arrange the polygon to the first vertex is the most top vertex
	
	#first find the top most vertex
	var top_vertex = 0
	var top_y_pos = 0
	var poly_size = poly.size()
	for ind in range(poly_size):
		var poly_y = poly[ind].y
		if poly_y <= top_y_pos:
			top_y_pos = poly_y
			top_vertex = ind
	
	#rebuild the polygon
	var real_poly = []
	for ind in range(poly_size):
		if ind >= top_vertex:
			real_poly.append(poly[ind])
	for ind in range(poly_size):
		if ind < top_vertex:
			real_poly.append(poly[ind])
	poly = real_poly
	
	#our ray upwards
	var ray_start = poly[0]
	var ray_end = poly[0] - Vector2(0, 10000)
	
	#get the point where we should inject
	var inject_index
	var inject_vector
	
	var p_size = inject.size()
	for ind in range(p_size):
		var p_start = inject[ind]
		var p_end = inject[(ind + 1) % p_size]
		#check if there's an intersection, if so, check if it is the nearest one
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
	
	#build the REAL shape array
	var real = []
	var did_inject = false
	for ind in range(p_size):
		real.append(inject[ind])
		if !did_inject && ind >= inject_index:
			
			#add our injection vector
			real.append(inject_vector)
			
			#to prevent the injection points from crossing eachother
			var first_vector = poly[0]
			poly.invert()
			real.append_array(poly)
			
			#add our injection vector
			real.append(first_vector)
			real.append(inject_vector)
			
			did_inject = true
	
	polygon = real
	collision.polygon = real

func _ready():
	if Engine.editor_hint:
		return
	#invert the current polygon
	set_physics_polygon(polygon)
	
	body_collision.shape.set_extents(OS.window_size / 2)
	
	body.position = spawn_position
	#make it invisible
	color = Color(0, 0, 0, 0)
	
func _physics_process(dt):
	if Engine.editor_hint:
		return
	#handle the scaling of the window / zoom of the camera
	if body_collision.shape:
		var target_size = OS.window_size / 2 * camera.zoom
		if target_size != body_collision.shape.get_extents():
			body_collision.shape.set_extents(target_size)
	
	#update the camera position and stuff
	var target = player.position
	body.move_and_slide(((target - body.position) / dt))

	#set the base of the camera to the body
	base_modifier.set_base(camera, "position", body.position - player.position)
