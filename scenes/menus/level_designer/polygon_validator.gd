class_name PolygonValidator



func validate_polygon(vertices: PackedVector2Array, dragged_vertex: Vector2):
	if vertices.size() < 3: return false
	if _has_duplicate_vertices(vertices, dragged_vertex): return false
	if _is_polygon_self_intersecting(vertices): return false
	
	return true


# Right now this algorithm is O(n^2) which yeah, is not very optimized.
# A better alternative would be to use the Shamos-Hoey algorithm using sweep-line, 
# which would be O(n log n) or if event stacking is used O(2n)
# Ref (for later):
# https://en.wikipedia.org/wiki/Sweep_line_algorithm
# https://www.webcitation.org/6ahkPQIsN
# https://en.wikipedia.org/wiki/Bentley%E2%80%93Ottmann_algorithm

func _has_duplicate_vertices(vertices: PackedVector2Array, dragged_vertex: Vector2):
	var v = vertices.duplicate()
	v.remove_at(vertices.find(dragged_vertex))
	return true if (dragged_vertex in v) else false

func _is_polygon_self_intersecting(vertices):
	var num_vertices = vertices.size()
	
	for i in range(num_vertices):
		var p1 = vertices[i]
		var p2 = vertices[(i + 1) % num_vertices]
		
		for j in range(i + 1, num_vertices):
			var q1 = vertices[j]
			var q2 = vertices[(j + 1) % num_vertices]
			
			# Skip adjacent segments, which are not considered for self-intersection
			if i == j or i == (j + 1) % num_vertices or (i + 1) % num_vertices == j:
				continue
			
			if _do_segments_intersect(p1, p2, q1, q2):
				return true
				
	return false

func _do_segments_intersect(p1, p2, q1, q2):
	var d1 = (q2 - q1).cross(p1 - q1)
	var d2 = (q2 - q1).cross(p2 - q1)
	var d3 = (p2 - p1).cross(q1 - p1)
	var d4 = (p2 - p1).cross(q2 - p1)
	
	if d1 * d2 < 0 and d3 * d4 < 0:
		return true
	return false
