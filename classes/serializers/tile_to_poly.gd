extends Node2D
class_name TileToPoly

# The max supported tiles
const MAX_TILES = Vector2(8192, 8192)

# It is VERY important all of these values are in THIS EXACT order
# Otherwise the glueing together of parts will not work
const contour_lines = [
	[],
	[[Vector2(0, 0.5), Vector2(0.49, 0.51), Vector2(0.5, 1)]],
	[[Vector2(0.5, 1), Vector2(0.51, 0.51), Vector2(1, 0.5)]],
	[[Vector2(0, 0.5), Vector2(1, 0.5)]],

	[[Vector2(1, 0.5), Vector2(0.51, 0.49), Vector2(0.5, 0)]],
	[
		[Vector2(1, 0.5), Vector2(0.51, 0.49), Vector2(0.5, 0)],
		[Vector2(0, 0.5), Vector2(0.49, 0.51), Vector2(0.5, 1)]
	],
	[[Vector2(0.5, 1), Vector2(0.5, 0)]],
	[[Vector2(0, 0.5), Vector2(0.49, 0.49), Vector2(0.5, 0)]],

	[[Vector2(0.5, 0), Vector2(0.49, 0.49), Vector2(0, 0.5)]],
	[[Vector2(0.5, 0), Vector2(0.5, 1)]],
	[
		[Vector2(0.5, 0), Vector2(0.49, 0.49), Vector2(0, 0.5)],
		[Vector2(0.5, 1), Vector2(0.51, 0.51), Vector2(1, 0.5)]
	],
	[[Vector2(0.5, 0), Vector2(0.51, 0.49), Vector2(1, 0.5)]],

	[[Vector2(1, 0.5), Vector2(0, 0.5)]],
	[[Vector2(1, 0.5), Vector2(0.51, 0.51), Vector2(0.5, 1)]],
	[[Vector2(0.5, 1), Vector2(0.49, 0.51), Vector2(0, 0.5)]],
	[]

	# Reference:
	# https://upload.wikimedia.org/wikipedia/commons/0/00/Marching_squares_algorithm.svg

	# Note, case 10 and case 5 are swapped
	# Normally it would be considered one shape
	# But that is not what we want, so it's switched so that it generates seperate shapes instead
]

# == Basic grid manipulation ==

# Create a grid
func create_2d_grid(w, h, i = 0):
	var grid = []
	for x in range(w):
		grid.append([])
		for _y in range(h):
			grid[x].append(i)
	return grid

# Increase & shift the size of a 2d grid
# NOTE: this function DOES NOT create a new grid
# So it will MODIFY the grid you pass it
# This function DOES NOT support negative increments
# It can only increase the size not decrease
func shift_and_incease_2d_grid(grid, i_w, i_h, i = 0):
	var g_w = grid.size()
	var g_h = grid[0].size()
	# Append to the bottom of the grid
	for x in range(0, g_w):
		for _y in range(g_h, g_h + i_h):
			grid[x].append(i)
	# Append to the right of the grid
	for x in range(g_w, g_w + i_w):
		grid.append([])
		for _y in range(g_h + i_h):
			grid[x].append(i)
	
	# Now shift everything
	for x in range(g_w + i_w - 1, i_w - 1, -1):
		for y in range(g_h + i_h - 1, i_h - 1, -1):
			grid[x][y] = grid[x - i_w][y - i_h]
	
	# Clear old tiles
	for x in range(0, i_w):
		for y in range(0, g_h):
			grid[x][y] = i
	for x in range(0, g_w):
		for y in range(0, i_h):
			grid[x][y] = i

# == INCOMING A LOT OF DEBUG STUFF ==

# Transform normalized vector to a more visible size
func debug_vec_deform(vec):
	return vec * 50 + Vector2(10, 10)

# Draw a grid
func draw_grid(grid, corner = Vector2(10, 10), mul = 5):
	# Corner += Vector2(mul / 2, mul / 2) * 2
	var trans = 0.2
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			if grid[x][y]:
				draw_circle(corner + Vector2(x, y) * mul, mul / 2, Color(1, 1, 1, trans))
			else:
				draw_circle(corner + Vector2(x, y) * mul, mul / 2, Color(1, 0, 0, trans))

# Draw the contour edges
func debug_draw_edges(sorted, offset = Vector2(10, 10)):
	var e_size = sorted.size()
	var colors = PoolColorArray()
	var verts = PoolVector2Array()
	var color = Color(randf(), randf(), randf(), 0.2)
	var t_offset = {}
	var mul = 32
	for ind in range(e_size):
		var a = sorted[ind] * mul + offset
		var b = sorted[(ind + 1) % e_size] * mul + offset
		var _c = sorted[(ind + 2) % e_size] * mul + offset
		
		verts.append(a)
		colors.append(color)
		
		if !t_offset.has(a):
			t_offset[a] = -1
		
		t_offset[a] += 1
		
		draw_line(a, b, Color(0, 0, 1))
		draw_circle(a, 2, Color(0, 0, ind / float(e_size)))
		
		var _n = 1 - t_offset[a] / 3.0
		#draw_string(font, a + Vector2(0, 10) * t_offset[a], str(ind), Color(n, 1, 1))
		
	draw_polygon(verts, colors)

# == Get contour & glue them together ==

# Get a contour from the grid, returns a list seperated of edges
func get_contour_from_grid(grid):
	# Form the edges using Marching Squares
	var edges = []
	for x in range(grid.size() - 1):
		for y in range(grid[x].size() - 1):
			var d1 = grid[x][y]
			var d2 = grid[x + 1][y]
			var d3 = grid[x + 1][y + 1]
			var d4 = grid[x][y + 1]
			# Calculate the value for this tile
			var value = d1 * 8 + d2 * 4 + d3 * 2 + d4
			
			# Once we have the contour from our value, append all it's lins to our edges
			var contour = contour_lines[value]
			for lines in contour:
				var real_line = []
				for vec in lines:
					real_line.append(Vector2(x, y) + vec)
				edges.append(real_line)
	return edges

# Glue together a list of seperated edges returned by get_contour_from_grid()
func glue_together_contour(edges):
	# Glue the edges together
	var sorted_edges = []
	var watched_edges = {}
	var s_ind = 0
	while (true):
		# Add the line to our contour
		var line = edges[s_ind]
		watched_edges[s_ind] = 1
		sorted_edges.append_array(line)
		var next_line = null
		# Search for the duplicated edge
		for c_ind in range(edges.size()):
			if line[line.size() - 1].is_equal_approx(edges[c_ind][0]):
				next_line = c_ind
		# If we looped all lines, break
		if !next_line:
			break
		s_ind = next_line
	return [sorted_edges, watched_edges]

# Get all of the contours of a grid rather than just one
# This is important to also get the contour of the holes in a shape
func get_all_contours(grid):
	var all_contours = []
	var edges = get_contour_from_grid(grid)
	var contour_data = glue_together_contour(edges)
	var sorted_edges = contour_data[0]
	var remove_indices = contour_data[1]
	
	while (edges.size()):
		all_contours.append(sorted_edges)
		
		# Remove duplicate edges
		var new_edges = []
		for ind in edges.size():
			if !remove_indices.has(ind):
				new_edges.append(edges[ind])
		edges = new_edges
		
		# If we don't have any edges left cancel
		if !edges.size():
			break
		
		# Get the new data
		contour_data = glue_together_contour(edges)
		sorted_edges = contour_data[0]
		remove_indices = contour_data[1]
	return all_contours

# == Vertices math ==

# Remove any duplicate points which are next to eachother
func remove_duplicate_points(input):
	# First remove any duplicate point
	var polygon = []
	var input_size = input.size()
	for ind in range(input_size):
		# We only delete duplicate points which are after the current point
		# This prevents the deletion of injected points
		var this = input[ind]
		var next = input[(ind + 1) % input_size]
		if !this.is_equal_approx(next):
			polygon.append(this)
	return polygon

# Remove any collinear points
func remove_collinear_points(polygon):
	# Once we deleted duplicate point, remove all collinear points
	var new_polygon = polygon
	var build_poly = []
	var new_size = new_polygon.size()
	for ind in range(new_size):
		# Get the points
		var this = new_polygon[ind]
		var next = new_polygon[(ind + 1) % new_size]
		var third = new_polygon[(ind + 2) % new_size]
		# Get the directions
		var dir = this.direction_to(next)
		var cur_dir = next.direction_to(third)
		# If the two directions are equal, it's collinear
		if !dir.is_equal_approx(cur_dir):
			build_poly.append(next)
	return build_poly

# Check if 2 polygons are inside of eachother
func are_polygons_inside_eachother(a, b):
	var a_succes = true
	for vec in a:
		if !Geometry.is_point_in_polygon(vec, b):
			a_succes = false
			break
	var b_succes = true
	for vec in b:
		if !Geometry.is_point_in_polygon(vec, a):
			b_succes = false
			break
	return [a_succes, b_succes]

# Intersect a polygon with a ray, and automatically insert a new vertex there
# Used to merge polygons with holes
func intersect_and_inject_polygon(start_pos, end_pos, polygon, exclude_start = false):
	var p_size = polygon.size()
	var injection_point
	var injection_index
	var nearest_injection = INF
	var start_ind
	# Calculate which points are inside intersect the polygon
	for ind in range(p_size):
		var p_start = polygon[ind]
		var p_end = polygon[(ind + 1) % p_size]
		# Keep track of which position is the start index
		if p_start.is_equal_approx(start_pos):
			start_ind = ind
		# Thanks godot for confusing me with segment and line for 15 minutes lol
		# Check if there's an intersection, if so, check if it is the nearest one
		var point = Geometry.segment_intersects_segment_2d(
			start_pos,
			end_pos,
			p_start,
			p_end
		)
		# Draw_line(debug_vec_deform(start_pos), debug_vec_deform(end_pos), Color(1, 0, 1), 2)
		if point:
			# If we marked the start for exclusion, don't add it
			if exclude_start and point.is_equal_approx(start_pos):
				continue
			var dist = (point - start_pos).length()
			if dist <= nearest_injection:
				nearest_injection = dist
				injection_index = ind
				injection_point = point
	# Backup for no other point was found
	if injection_index == null: # We specifically check for null, because !0 = true
		injection_index = start_ind
		injection_point = start_pos
	if injection_index == null:
		injection_index = 0
		injection_point = polygon[0]
	# Rebuild the polygon
	injection_index += 1
	polygon.insert(injection_index, injection_point)
	return injection_index

# Merge a polygon-hole pair
func split_polygon_with_holes(polygon, hole):
	var target_vec = hole[0] # We will slice the polygon through here
	# Get our target point
	var nearest_dist = INF
	var nearest_vec
	for vec in polygon:
		var dist = (target_vec - vec).length()
		if dist <= nearest_dist:
			nearest_vec = vec
			nearest_dist = dist
	
	# Get the inner & outer injection point
	var inner_injection = intersect_and_inject_polygon(target_vec, nearest_vec, hole, true)
	target_vec = hole[inner_injection]
	var outer_injection = intersect_and_inject_polygon(target_vec, nearest_vec, polygon)
	
	# Duplicate the inserted point
	polygon.insert(outer_injection, polygon[outer_injection])
	# Insert all of the hole verts in our new polygon
	var h_size = hole.size()
	for counter in range(h_size + 1):
		# We add +1 because we want to loop through the starting point twice
		var ind = (inner_injection + counter) % h_size
		var hole_vec = hole[ind]
		polygon.insert(outer_injection + counter + 1, hole_vec)

# Calculate how many times a line at this vert intersects the body polygon
# This is used to calculate if the vert is a hole or not
func get_intersection_count(vert, other_polygons):
	# Some omega big number, this number is the max allowed tiles
	# Possible optimisation: make this the max x of the grid, rather than the global max
	var end_vert = vert + Vector2(MAX_TILES.x, 0)
	var intersection_count = 0
	for poly in other_polygons:
		var p_size = poly.size()
		for ind in range(p_size):
			if Geometry.segment_intersects_segment_2d(
				vert,
				end_vert,
				poly[ind],
				poly[(ind + 1) % p_size]
			):
				intersection_count += 1
	return intersection_count

# Get single connected shape from the grid
# Returns a copy of the grid where the only filled values are the shape itself
# If no shape was found, returns nil
func get_individual_shape(grid, filter, set_after = 0):
	# Duplicate the grid
	var filtered = create_2d_grid(grid.size(), grid[0].size())	
	
	# First we have to find a corner to start the flood fill in
	var corner
	for x in range(grid.size()):
		if corner:
			break
		for y in range(grid[x].size()):
			if grid[x][y] == filter:
				corner = Vector2(x, y)
				break
	
	if !corner:
		return
	
	# Flood fill algorithm
	var check_queue = [corner]
	while true:
		# Stop if the stack is equal to 0, aka, no more stack :(
		var queue_size = check_queue.size()
		if !queue_size:
			break
		
		# Get the current stack item + pop the top of the stack
		var current = check_queue[0]
		check_queue.pop_front()
		
		# Make sure we don't double check already existing items
		if filtered[current.x] and filtered[current.x][current.y]:
			continue
		
		# Make sure this current item is the one we're searching for
		if grid[current.x] and grid[current.x][current.y] == filter:
			# Add it to our filtered list
			filtered[current.x][current.y] = 1
			# Set the grid to our new value
			grid[current.x][current.y] = set_after
			# Update the stack
			check_queue.append_array([
				current + Vector2(1, 0),
				current + Vector2(-1, 0),
				current + Vector2(0, 1),
				current + Vector2(0, -1),
			])
	# Return our shape
	return filtered

# Gets a list of vertices which can be used to generate a polygon from the grid
# This only returns ONE polygon
# If no shape was found it returns nil
func step_get_polygon_from_grid(grid, filter):
	var shape = get_individual_shape(grid, filter, 0)
	# Check if there's even a shape
	if !shape:
		return
	# If there is, shift the grid for marching squares to work properly
	shift_and_incease_2d_grid(shape, 1, 1)
	
	# Get all of the contours
	var contours = get_all_contours(shape)
	
	# Determine which contours are holes which ones are not
	var holes = []
	var non_holes = []
	var c_size = contours.size()
	for c_ind in range(c_size):
		var alternatives = []
		for a_ind in range(c_size):
			if a_ind != c_ind:
				alternatives.append(contours[a_ind])
		var intersection_count = get_intersection_count(contours[c_ind][0], alternatives)
		if intersection_count % 2:
			holes.append(c_ind)
		else:
			non_holes.append(c_ind)
	
	# Merge body contours with holes
	var real_contours = []
	for body_ind in non_holes:
		var _has_holes = false
		for hole_ind in holes:
			var is_inside = are_polygons_inside_eachother(contours[body_ind], contours[hole_ind])
			if is_inside[0] or is_inside[1]:
				_has_holes = true
				# Split modifies the reference, does not recreate the polygon, so yeah
				split_polygon_with_holes(contours[body_ind], contours[hole_ind])
		real_contours.append(contours[body_ind])
	
	# Remove duplicate & collinear points
	for ind in real_contours.size():
		real_contours[ind] = remove_duplicate_points(real_contours[ind])
		real_contours[ind] = remove_collinear_points(real_contours[ind])
	
	return real_contours

# Returns a list of polygons from a specific filter from the shape
func get_all_polygons_from_grid(grid, filter):
	var polygons = []
	while true:
		var collection = step_get_polygon_from_grid(grid, filter)
		if !collection:
			break
		for poly in collection:
			polygons.append(poly)
	return polygons
