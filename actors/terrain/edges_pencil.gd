tool
extends Node2D

onready var root = $".."

export(Array) var segment_queue

func arr_shift_inc(arr: Array):
	var new_arr = []
	var p_size = arr.size()
	for ind in range(1, p_size + 1):
		new_arr.append(arr[ind % p_size])
	return new_arr

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
	var og_poly = PoolVector2Array(poly)
	var e_size = poly.size()
	
	#check if our edge should have an shade or not
	var inside_counter = 0
	var verts_inside = []
	for vert in poly:
		var is_inside = Geometry.is_point_in_polygon(vert, root.polygon)
		if is_inside:
			verts_inside.append(vert)
			inside_counter += 1
	
	var color_white = Color(1, 1, 1)
	var colors = PoolColorArray([color_white, color_white, color_white, color_white])
	
	#draw the shade
	if inside_counter > 0:
		var new_poly = []
		var new_uv = []
		#if the polygon is fully surrounded, then don't bother with edge checks
		if inside_counter != e_size:
			var p_size = root.polygon.size()
			for p_ind in p_size:
				var p_vert: Vector2 = root.polygon[p_ind]
				var p_next_vert: Vector2 = root.polygon[(p_ind + 1) % p_size]
				for e_ind in e_size:
					var e_next_ind = (e_ind + 1) % e_size
					var e_vert: Vector2 = poly[e_ind]
					var e_next_vert: Vector2 = poly[e_next_ind]
					var intersect = Geometry.segment_intersects_segment_2d(p_vert, p_next_vert, e_vert, e_next_vert)
					
					if intersect:
						if e_next_ind != 0:
							new_uv.append(
								uvs[e_ind].move_toward(uvs[e_next_ind],
									intersect.distance_to(e_vert) /
									e_vert.distance_to(e_next_vert)
								)
							)
							new_uv.append(uvs[e_next_ind])
							new_poly.append(intersect)
							new_poly.append(e_next_vert)
						else:
							new_uv.append(uvs[e_ind])
							new_uv.append(
								uvs[e_ind].move_toward(uvs[e_next_ind],
									intersect.distance_to(e_vert) /
									e_vert.distance_to(e_next_vert)
								)
							)
							new_poly.append(e_vert)
							new_poly.append(intersect)
						#draw_circle(intersect, 1, Color(0, 1, 0))
#		var inc = 0
#		for vert in new_poly:
#			inc += 0.25
#			draw_circle(vert, 2, Color(inc, 0, 0))
		
		#remove duplicate points
#		var points = {}
#		var real_new_poly = []
#		for vec in new_poly:
#			if !points.has(vec):
#				real_new_poly.append(vec)
#			points[vec] = true
		
		if new_poly.size() == 4:
			var target_normal: Vector2 = poly[2].direction_to(poly[3])
			for _ind in 8:
				var current_normal = new_poly[2].direction_to(new_poly[3])
				if !(target_normal.is_equal_approx(current_normal)):
					new_poly = arr_shift_inc(new_poly)
				else:
					print("done :D")
					break
				
			var c = 0
			for vert in poly:
				c += 0.25
				draw_circle(vert, 2, Color(c, 0, 0))
			
			poly = new_poly
				#draw_line(edge[0], edge[1], Color(0, 1, 0), 2)
			#draw the polygon
			draw_polygon(poly, colors, uvs, root.top_left_shade)
	
	var c = 0
	for vert in poly:
		c += 0.25
		draw_circle(vert, 1, Color(0, c, c))
	
	draw_polyline(poly, Color(0, 0, 1))
	
	#draw the actual edge
	#draw_polygon(og_poly, colors, uvs, root.top_left)

func _draw():
	for data in segment_queue:
		add_edge_segment(data[0], data[1])
