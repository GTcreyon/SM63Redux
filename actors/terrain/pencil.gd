tool
extends Node2D

onready var root = $".."
onready var collision = $"../Static/Collision"
onready var main_texture = $"../Body"
onready var inside_checker = $"../Check"

func add_edge_segment(is_left, group):
	#get the correct corner & the correct direction
	var corner = group.verts[0] if is_left else group.verts[1]
	var normal_sign = -1 if is_left else 1

	var uvs = PoolVector2Array([
		Vector2(1, 0), Vector2(0, 0),
		Vector2(0, 1), Vector2(1, 1)
	])
	#calculate the corners for the edge polygon
	var poly = PoolVector2Array([
		corner,
		corner + group.direction * 4 * normal_sign,
		corner + group.direction * 4 * normal_sign - group.normal * 18,
		corner - group.normal * 18,
	])
	var color_white = Color(1, 1, 1)
	var colors = PoolColorArray([color_white, color_white, color_white, color_white])
	#draw it
	
#	var poly2d = Polygon2D.new()
#	poly2d.uv = uvs
#	poly2d.texture = root.top_left
#	poly2d.polygon = poly
#	add_child(poly2d)
	
	draw_polygon(poly, colors, uvs, root.top_left)

func add_in_between_segment(areas, start: Vector2, end: Vector2, circumcenter: Vector2):
	var verts = [start]
	var s_unit = circumcenter.direction_to(start)
	var s_angle = atan2(s_unit.y, s_unit.x)
	var e_unit = circumcenter.direction_to(end)
	var e_angle = atan2(e_unit.y, e_unit.x)
	
	var delta = (e_angle - s_angle) / 5.0
	var distance = circumcenter.distance_to(start)
	var angle = s_angle
	
	#cicular edges, this doesn't work rn, I'll work on it later
	
#    #for if e_angle > s_angle
#    while angle < e_angle:
#        angle += delta
#        var vert = circumcenter + Vector2(cos(angle), sin(angle)) * distance
#        verts.append(vert)
#    #for if e_angle < s_angle
#    angle = s_angle
#    while angle > e_angle:
#        angle += delta
#        var vert = circumcenter + Vector2(cos(angle), sin(angle)) * distance
#        verts.append(vert)
	
	verts.append(end)
	verts.append(circumcenter)
	areas.append({
		verts = verts,
		normal = start.direction_to(end).rotated(-PI / 2),
		clock_dir = sign(delta),
		type = "trio"
	})

func draw_top_from_connected_lines(lines):
	#first collect everything into groups of verts
	var groups = []
	var p_size = lines.size()
	for ind in range(p_size):
		var current: Vector2 = lines[ind]
		var next: Vector2 = lines[(ind + 1) % p_size]
		var dir := current.direction_to(next)
		var normal := dir.tangent()
		var off_up := normal * 12
		var off_down := normal * -6
		
		var verts = [
			current + off_up,
			next + off_up,
			next + off_down,
			current + off_down
		]
		
		groups.append(verts)
	
	#create areas for every group
	var areas = []
	for ind in range(p_size - 1):
		var cur_group = groups[ind]
		var next_group = groups[(ind + 1) % p_size]
		
		#draw this group
		areas.append({
			verts = cur_group,
			direction = cur_group[0].direction_to(cur_group[1]),
			normal = cur_group[0].direction_to(cur_group[1]).tangent(),
			clock_dir = 1,
			type = "quad"
		})
		
		#if this is the last entry in the group, then don't make any intersections
		if ind == p_size - 2:
			break
		
		#top intersection
		var top_intersect = Geometry.segment_intersects_segment_2d(
			cur_group[0], cur_group[1],
			next_group[0], next_group[1]
		)
		if top_intersect:
			var cur_ind = 1
			var next_ind = 0
			#set the colliding points to the same point
			cur_group[cur_ind] = top_intersect
			next_group[next_ind] = top_intersect
			
			var opp_cur_ind = 2
			var opp_next_ind = 3
			add_in_between_segment(
				areas,
				cur_group[opp_cur_ind],
				next_group[opp_next_ind],
				top_intersect
			)
		
		#bottom intersection
		var bottom_intersect = Geometry.segment_intersects_segment_2d(
			cur_group[2], cur_group[3],
			next_group[2], next_group[3]
		)
		if bottom_intersect:
			var cur_ind = 2
			var next_ind = 3
			#set the colliding points to the same point
			cur_group[cur_ind] = bottom_intersect
			next_group[next_ind] = bottom_intersect
			
			var opp_cur_ind = 1
			var opp_next_ind = 0
			add_in_between_segment(
				areas,
				cur_group[opp_cur_ind],
				next_group[opp_next_ind],
				bottom_intersect
			)
	
	#draw everything
	#draw the left edge
	add_edge_segment(true, areas.front())
	#draw all areas
	for area in areas:
#		var colors = []
#		for v in area.verts:
#			colors.append(Color(1, 1, 1, 1))
#		var uvs = [
#			Vector2(0, 0), Vector2(1, 0),
#			Vector2(1, 1), Vector2(0, 1)
#		]
#
#		if area.type == "trio":
#			var vert_y = 1 if area.clock_dir == -1 else 0
#			var inv_vert_y = 1 - vert_y
#			uvs = [Vector2(0, vert_y)]
#			var v_size = area.verts.size()
#			for ind in range(1, v_size - 2):
#				uvs.append(Vector2(1, vert_y))
#			uvs.append(Vector2(1, vert_y))
#			uvs.append(Vector2(0.5, inv_vert_y))
#
#		draw_polygon(area.verts, colors, uvs, root.top)
		#create the polygon
		var poly2d = Polygon2D.new()
		poly2d.texture = root.top
		poly2d.polygon = area.verts
		poly2d.texture_rotation = -area.normal.angle() - PI / 2

		#OFFSET MATH YAAAAAAAAAY
		var unit = Vector2(sin(poly2d.texture_rotation), cos(poly2d.texture_rotation))
		var pos = area.verts[0] if area.type == "quad" else area.verts[area.verts.size() - 2]
		var text_offset = Vector2(0, 0)

		#get the target pos depending on which type of area we're rendering
		if area.type == "trio":
			var dist = area.verts[0].distance_to(area.verts.back())
			poly2d.texture_scale.y = 18 / dist
		if area.clock_dir == -1 && area.type == "trio":
			pos = area.verts[0]

		#set the offset
		poly2d.texture_offset.x = -unit.y * pos.x + unit.x * pos.y - text_offset.x
		poly2d.texture_offset.y = -unit.x * pos.x - unit.y * pos.y - text_offset.y
		poly2d.material = material
		add_child(poly2d)

	#draw the right area
	add_edge_segment(false, areas.back())

#child murder ;-;
func oof_children():
	for child in get_children():
		remove_child(child)

#this will add the grass to the top of the polygon
func add_top_pass(lines, poly, start):
	var p_size = poly.size()
	var added = false
	for ind in range(start, p_size):
		var vert: Vector2 = poly[ind]
		var next: Vector2 = poly[(ind + 1) % p_size]
		var normal: Vector2 = vert.direction_to(next).tangent()
		var angle: float = normal.angle_to(root.up_direction) / PI * 180
		
		if angle >= -root.max_deviation && angle <= root.max_deviation:
			added = true
			lines.append(vert)
		elif added:
			lines.append(vert)
			return ind
	return null

#add the grass to 
func add_top_full(poly):
	var latest_index = 0
	while latest_index != null:
		var lines = []
		latest_index = add_top_pass(lines, poly, latest_index)
		if lines.size() >= 2:
			draw_top_from_connected_lines(lines)

func _draw():
	oof_children()
	main_texture.texture = root.body
	main_texture.polygon = root.polygon
	
	inside_checker.polygon = root.polygon
	
	add_top_full(root.polygon)
	if !Engine.editor_hint:
		collision.polygon = root.polygon

