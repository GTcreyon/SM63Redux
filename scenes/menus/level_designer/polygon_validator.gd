class_name PolygonValidator


static func validate_polygon(vertices: PackedVector2Array, drag_pos = null):
	if vertices.size() < 3: 
		return false
	if _has_duplicate_vertices(vertices, drag_pos):
		return false
	if self_intersecting_edges(vertices).size() > 0:
		return false
	
	return true


static func _has_duplicate_vertices(vertices: PackedVector2Array, dragged_vertex):
	# TODO: Right now this algorithm is O(n^2) which yeah, is not very
	# optimized.
	# A better alternative would be to use the Shamos-Hoey algorithm using 
	# sweep-line, which would be O(n log n) or if event stacking is used O(2n)
	# Ref (for later):
	# https://en.wikipedia.org/wiki/Sweep_line_algorithm
	# https://www.webcitation.org/6ahkPQIsN
	# https://en.wikipedia.org/wiki/Bentley%E2%80%93Ottmann_algorithm

	if !dragged_vertex:
		return false
	
	var v = vertices.duplicate()
	v.remove_at(vertices.find(dragged_vertex))

	return (dragged_vertex in v)


## Finds all edges in this polygon which intersect. Returns an array of their
## starting indices.
static func self_intersecting_edges(vertices) -> Array[int]:
	var num_vertices = vertices.size()
	var intersecting: Array[int] = []
	
	for i in range(num_vertices):
		var p1 = vertices[i]
		var p2 = vertices[(i + 1) % num_vertices]
		
		# Iterate all edges starting after this one.
		# Ones starting before have already been tested, so there's no sense in
		# testing them again.
		for j in range(i + 1, num_vertices):
			var q1 = vertices[j]
			var q2 = vertices[(j + 1) % num_vertices]
			
			# Account for wraparound edge cases:
			# if the vertex after i is i, if i is j's next vert, or if j is i's
			# next vert, skip it.
			# TODO: Is this desirable?
			if i == j or i == (j + 1) % num_vertices or j == (i + 1) % num_vertices:
				continue
			
			# If these two segments intersect, save them BOTH in the output
			# array!
			if _do_segments_intersect(p1, p2, q1, q2):
				# Save only if the value isn't already in the array.
				# TODO: Optimize. Checking has() multiple times can't possibly
				# be the fastest way to get an array with no duplicates.
				if !intersecting.has(i):
					intersecting.append(i)
				if !intersecting.has(j):
					intersecting.append(j)
	
	return intersecting


static func _do_segments_intersect(p1, p2, q1, q2):
	var d1 = (q2 - q1).cross(p1 - q1)
	var d2 = (q2 - q1).cross(p2 - q1)
	var d3 = (p2 - p1).cross(q1 - p1)
	var d4 = (p2 - p1).cross(q2 - p1)
	
	return d1 * d2 < 0 and d3 * d4 < 0
