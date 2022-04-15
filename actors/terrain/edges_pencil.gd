tool
extends Node2D

onready var root = $".."

export(Array) var segment_queue

func polygon_cut_box(box: Array, uvs: Array, box_size: int):
	var new_poly = []
	var new_uv = []
	var p_size = root.polygon.size()
	for p_ind in p_size:
		#get verts of this polygon
		var p_vert: Vector2 = root.polygon[p_ind]
		var p_next_vert: Vector2 = root.polygon[(p_ind + 1) % p_size]
		for e_ind in box_size:
			#get the index and the verts of the box
			var e_next_ind = (e_ind + 1) % box_size
			var e_vert: Vector2 = box[e_ind]
			var e_next_vert: Vector2 = box[e_next_ind]
			
			#get the intersection point
			var intersect = Geometry.segment_intersects_segment_2d(p_vert, p_next_vert, e_vert, e_next_vert)
			if intersect:
				if e_next_ind != 0:
					#if this is the egde which loops arround, there is a special case
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
					#make sure we generate the correct uv map
					new_uv.append(uvs[e_ind])
					new_uv.append(
						uvs[e_ind].move_toward(uvs[e_next_ind],
							intersect.distance_to(e_vert) /
							e_vert.distance_to(e_next_vert)
						)
					)
					#add the new vertices in the new polygon
					new_poly.append(e_vert)
					new_poly.append(intersect)
	#return our new box with 
	return [new_poly, new_uv]

func add_edge_segment(is_left, group):
	#get the correct corner & the correct direction
	var corner = group.verts[0] if is_left else group.verts[1]
	var normal_sign = -1 if is_left else 1
	
	#the uv for our box
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
	var e_size = poly.size()
	
	#check if our edge should have an shade or not
	var inside_counter = 0
	var verts_inside = []
	for vert in poly:
		var is_inside = Geometry.is_point_in_polygon(vert, root.polygon)
		if is_inside:
			verts_inside.append(vert)
			inside_counter += 1
	
	var base_color = Color(1, 1, 1)
	if root.shallow:
		base_color = root.shallow_color
	var colors = PoolColorArray([base_color, base_color, base_color, base_color])
	
	#draw the shade
	if inside_counter > 0:
		#if the polygon is fully surrounded, then don't bother with edge checks
		if inside_counter != e_size:
			#cut the box so it fits in the polygon
			var cut_box = polygon_cut_box(poly, uvs, e_size)
			var new_poly = cut_box[0]
			var new_uv = cut_box[1]
			#make sure the cut box is 4 verts
			if new_poly.size() == 4:
#				colors = []
#				for v in new_poly:
#					colors.append(color_white)
				#print("success: ", group.index)
				draw_polygon(new_poly, colors, new_uv, root.top_corner_shade)
			#else:
				#print("oh no: ", group.index, ": ", new_poly.size(), " - ", new_uv.size())
		else:
			#since we're fully surrounded, simply draw the shade with no issues
			draw_polygon(poly, colors, uvs, root.top_corner_shade)
	
	#draw the actual edge
	draw_polygon(poly, colors, uvs, root.top_corner)

func _draw():
	#when we are commanded to, draw everything we have in the queue
	for data in segment_queue:
		add_edge_segment(data[0], data[1])
