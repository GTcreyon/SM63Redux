tool
extends Polygon2D

const grass_thickness = 18
const cliff_thickness = 4
const corner_width = 4
const sub_mat = preload("res://shaders/subtract.tres")
const shadow_texture = preload("./cliff_shadow.png")

export var up_vector = Vector2(0, -1)
export var max_angle = 60
export var grass_texture = preload("./jungle_grass.png")
export var grass_texture_shade = preload("./jungle_grass_shade.png")
export var grass_left_corner = preload("./jungle_grass_left_corner.png")
export var grass_left_corner_shade = preload("./jungle_grass_left_corner_shade.png")
export var grass_right_corner = preload("./jungle_grass_right_corner.png")
export var grass_right_corner_shade = preload("./jungle_grass_right_corner_shade.png")
export var cliff_texture = preload("./jungle_cliff.png")
export var ground_texture = preload("./jungle_ground.png") setget set_ground_texture

onready var collision = $Collision/CollisionShape
onready var base = $BaseTexture
onready var top = $Top
var poly_old = PoolVector2Array([])
var poly_groups = []
var ground_shadows = {}

#update ground texture when changed
func set_ground_texture(new_texture):
	ground_texture = new_texture
	$BaseTexture.texture = ground_texture #can't use the variable cuz the node isn't ready yet

#this function generates the polygon groups
func generate_poly_groups():
	poly_groups = []
	var size = polygon.size()
	#create polygon groups
	for i in size:
		var start_vert = polygon[i] #get the current and the next poly
		var end_vert = polygon[(i + 1) % size]
		var data = { #the group it self, this precalculates a lot of stuff so yeah
			"start": start_vert,
			"end": end_vert,
			"left_overwrite": null, #these overwrites are being used with intersections, if null there's no intersection
			"right_overwrite": null,
			"prev_group": null, #link the current and previous groups
			"next_group": null,
			"index": i,
			"distance": start_vert.distance_to(end_vert),
			"direction": start_vert.direction_to(end_vert),
			"has_grass": false,
			"debug_draw_outline": false
		}
		#if i == 0 || i == 1:
		#	data.has_grass = true
		data.angle = data.direction.angle()
		data.normal = data.direction.tangent()
		data.normal_angle = data.normal.angle()
		poly_groups.append(data)
	
	#link to other groups
	size = poly_groups.size()
	for i in size:
		poly_groups[i].prev_group = poly_groups[(i - 1) % size]
		poly_groups[i].next_group = poly_groups[(i + 1) % size]

#this function takes 2 poly groups and calculates the intersection points (automatically sets the overwrite points)
func calculate_intersection(left, right):
	var half = ((left.direction + right.direction) / 2).tangent().normalized() #split vector
	var angle = half.angle_to(right.direction)
	var intersect = half * (grass_thickness / sin(angle)) * sign(half.angle())
	#2/3 is 10.67 pixels and 1/3 is 5.33 pixels
	var overwrite = [left.end + intersect * 2/3, left.end - intersect / 3]
	
	left.right_overwrite = overwrite #replace the overwrites of the groups
	right.left_overwrite = overwrite

#updates the current polygon from the poly_groups
func set_polygon_from_groups():
	var new = PoolVector2Array()
	for group in poly_groups:
		new.append(group.start)
	base.polygon = polygon
	collision.polygon = polygon

func generate_grass(group):
	var strip = Polygon2D.new()
	strip.polygon = PoolVector2Array([
		group.start + group.normal * grass_thickness / 3,
		group.end + group.normal * grass_thickness / 3,
		group.end - group.normal * grass_thickness * 2 / 3,
		group.start - group.normal * grass_thickness * 2 / 3,
	])
	if group.left_overwrite:
		strip.polygon[3] = group.left_overwrite[0]
		strip.polygon[0] = group.left_overwrite[1]
	if group.right_overwrite:
		strip.polygon[2] = group.right_overwrite[0]
		strip.polygon[1] = group.right_overwrite[1]
	
	#check for intersections, this is important for drawing grass the correct way
	#(maybe this can be done in the calculate intersections area?, it works for now though)
	var intersect = Geometry.segment_intersects_segment_2d(strip.polygon[0], strip.polygon[1], strip.polygon[2], strip.polygon[3])
	if intersect != null:
		var p1 = strip.polygon[1]
		strip.polygon[1] = strip.polygon[2]
		strip.polygon[2] = p1
	
	strip.texture = grass_texture
	strip.texture_rotation = -group.normal_angle - PI / 2
	strip.texture_offset.y = (sin(strip.texture_rotation) * -group.start.x) - group.start.y * cos(strip.texture_rotation) + grass_thickness / 3.0
	
	#purely for debugging
	if group.debug_draw_outline:
		strip.color = Color(0, 0, 1, 0)
		var size = strip.polygon.size()
		for i in size:
			var this = strip.polygon[i]
			var next = strip.polygon[(i + 1) % size]
			draw_line(this, next, Color(0, 0, float(i) / 3.0), 1)
			draw_circle(this, 1, Color(0, 0, float(i) / 3.0))
	
	strip.z_index = 1
	top.add_child(strip)
	
	var shadow_strip = strip.duplicate()
	shadow_strip.texture = grass_texture_shade
	ground_shadows[group.index] = shadow_strip
	top.add_child(shadow_strip)

func generate_edge(group):
	var strip = Polygon2D.new()
	
	var temp_thickness = cliff_thickness + 0
	strip.polygon = PoolVector2Array([
		group.start + group.normal * temp_thickness / 3 - (group.normal / 3),
		group.end + group.normal * temp_thickness / 3 - (group.normal / 3),
		group.end - group.normal * temp_thickness * 2 / 3 - (group.normal / 3),
		group.start - group.normal * temp_thickness * 2 / 3 - (group.normal / 3),
	])
	if group.left_overwrite:
		strip.polygon[3] = group.left_overwrite[0]
		strip.polygon[0] = group.left_overwrite[1]
	if group.right_overwrite:
		strip.polygon[2] = group.right_overwrite[0]
		strip.polygon[1] = group.right_overwrite[1]
	
	var intersect = Geometry.segment_intersects_segment_2d(strip.polygon[0], strip.polygon[1], strip.polygon[2], strip.polygon[3])
	if intersect != null:
		var p1 = strip.polygon[1]
		strip.polygon[1] = strip.polygon[2]
		strip.polygon[2] = p1
	
	strip.texture = cliff_texture
	strip.texture_rotation = -group.normal_angle - PI / 2
	strip.texture_offset.y = (sin(strip.texture_rotation) * -group.start.x) - group.start.y * cos(strip.texture_rotation) + (cliff_thickness - 1) / 3.0
	
	#purely for debugging
	if group.debug_draw_outline:
		strip.color = Color(0, 0, 1, 0)
		var size = strip.polygon.size()
		for i in size:
			var this = strip.polygon[i]
			var next = strip.polygon[(i + 1) % size]
			draw_line(this, next, Color(0, 0, float(i) / 3.0), 1)
			draw_circle(this, 1, Color(0, 0, float(i) / 3.0))
	
	top.add_child(strip)
	
	var shadow_strip = strip.duplicate()
	strip.texture = shadow_texture
	strip.material = sub_mat
	top.add_child(shadow_strip)

func handle_edge_cutoff(ray_origin, ray_target, target_strip, is_left_corner):
	var bottom_intersect = Geometry.segment_intersects_segment_2d(
		ray_origin, ray_target,
		target_strip.polygon[2], target_strip.polygon[3]
	)
	var left_intersect = Geometry.segment_intersects_segment_2d(
		ray_origin, ray_target,
		target_strip.polygon[3], target_strip.polygon[0]
	)
	var right_intersect = Geometry.segment_intersects_segment_2d(
		ray_origin, ray_target,
		target_strip.polygon[1], target_strip.polygon[2]
	)
	
	#now correct the polygon
	if left_intersect:
		target_strip.polygon[0] = left_intersect
	if right_intersect:
		target_strip.polygon[1] = right_intersect
	if bottom_intersect:
		#make sure we set the right vertex depending on which side we're coming from
		target_strip.polygon[3 if is_left_corner else 2] = bottom_intersect
		#this IF hurts me
		if ((is_left_corner && !left_intersect) || (!is_left_corner && !right_intersect)) && (left_intersect || right_intersect):
			target_strip.polygon[0] = bottom_intersect
	return bottom_intersect 

func generate_corner(group, is_left_corner):
	var strip = Polygon2D.new()
	
	#ternary statement fun!!!!!!
	#get the correct corner and negate the width if the corner is a left corner, not a right corner
	if is_left_corner:
		strip.polygon = PoolVector2Array([
			group.start + group.direction * -corner_width + group.normal * grass_thickness / 3,
			group.start + group.normal * grass_thickness / 3,
			group.start - group.normal * grass_thickness * 2 / 3,
			group.start + group.direction * -corner_width - group.normal * grass_thickness * 2 / 3,
		])
	else:
		strip.polygon = PoolVector2Array([
			group.end + group.direction * corner_width + group.normal * grass_thickness / 3,
			group.end + group.normal * grass_thickness / 3,
			group.end - group.normal * grass_thickness * 2 / 3,
			group.end + group.direction * corner_width - group.normal * grass_thickness * 2 / 3,
		])
	
	#MORE TERNARY OPERATORS!!!! I AM SO HAPPY
	strip.texture = grass_left_corner if is_left_corner else grass_right_corner
	strip.texture_rotation = -group.normal_angle - PI / 2
	
	var unit = Vector2(sin(strip.texture_rotation), cos(strip.texture_rotation))
	var pos = group.start if is_left_corner else group.end
	var text_offset = Vector2(0, 12)
	strip.texture_offset.x = -unit.y * pos.x + unit.x * pos.y - text_offset.x
	strip.texture_offset.y = -unit.x * pos.x - unit.y * pos.y - text_offset.y

	strip.z_index = 2
	top.add_child(strip)
	
	#purely for debugging
	if group.debug_draw_outline:
		strip.color = Color(0, 0, 1, 0)
		var size = strip.polygon.size()
		for i in size:
			var this = strip.polygon[i]
			var next = strip.polygon[(i + 1) % size]
			draw_line(this, next, Color(0, 0, float(i) / 3.0), 1)
			draw_circle(this, 1, Color(0, 0, float(i) / 3.0))
	
	#check for special cases
	if !ground_shadows.has(group.index):
		return
	
	#check if 2 groups are 90 degrees rotated, this is a special case as raycasting fails
	#thus we have to check for it
	var alt_group = group.prev_group if is_left_corner else group.next_group
	var target_strip = ground_shadows[group.index]
	var keep_shadow_regardless = false
	#check if we're inside of the ground or not, because if we are, KEEEP
	if is_equal_approx(abs(alt_group.angle - group.angle), PI / 2):
		var check_for_pos = pos + group.direction * (-1 if is_left_corner else 1)
		draw_circle(check_for_pos, 3, Color(1, 0, 0))
		if !Geometry.is_point_in_polygon(check_for_pos, polygon):
			return
		else:
			keep_shadow_regardless = true
	
	#now do *SIGH* the shadow
	var shadow_strip = strip.duplicate()
	shadow_strip.texture = grass_left_corner_shade if is_left_corner else grass_right_corner_shade
	
	var bottom_intersect = handle_edge_cutoff(
		alt_group.start,
		alt_group.start + alt_group.direction * 2 * alt_group.distance,
		target_strip,
		is_left_corner
	)
	
	if !bottom_intersect || keep_shadow_regardless:
		if !keep_shadow_regardless:
			handle_edge_cutoff(
				alt_group.start,
				alt_group.start + alt_group.direction * 2 * alt_group.distance,
				shadow_strip,
				is_left_corner
			)
		shadow_strip.z_index = -1
		top.add_child(shadow_strip)

func mark_grass():
	var size = poly_groups.size()
	for i in range(size):
		var this_group = poly_groups[i]
		this_group.has_grass = false #set it to false by default
		var angle = this_group.normal.angle_to(up_vector) / PI * 180
		if abs(angle) <= max_angle:
			this_group.has_grass = true

#it's a bit brutal but hey you gotta to what you gotta do
func clear_all_children(parent):
	for child in parent.get_children():
		parent.remove_child(child)

func generate_full():
	ground_shadows.clear()
	
	clear_all_children(top) #first delete all the children
	generate_poly_groups() #get the poly groups
	set_polygon_from_groups() #set the polygon shape
	mark_grass() #mark the grass
	#now determine if the grass should be placed
	var size = poly_groups.size()
	for i in size:
		var left = poly_groups[i]
		var right = poly_groups[(i + 1) % size]
		if left.has_grass && right.has_grass:
			calculate_intersection(left, right)
		#generate the main top
		if left.has_grass:
			generate_grass(left)
		else:
			generate_edge(left)
		#generate the corners
		if right.has_grass && !left.has_grass:
			generate_corner(right, true)
		if left.has_grass && !right.has_grass:
			generate_corner(left, false)

func _draw():
	generate_full()

func __process(_delta):
	base.polygon = polygon
	collision.polygon = polygon
	
