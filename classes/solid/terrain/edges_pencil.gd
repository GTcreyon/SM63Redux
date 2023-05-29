tool
class_name EdgePencil
# TODO: "Edge" means something different. Consider "endcap" or "cap" instead?
extends Node2D

const QUAD_SIZE = 32 #2*TerrainPencil.QUAD_RADIUS

# Queue of areas to be rendered.
# An area is stored as an array with two elements:
# is_left: bool = whether the edge is a left edge.
# area = the data of the adjacent area, which has the following fields:
# 	index: int = which area this is.
#	verts: Array = Vector2 positions of all points in the area,
#	direction: Vector2 = the direction from area's start to end.
#	normal: Vector2 = which direction is "outward" for this area.
#	clock_dir: int = -1 for counterclockwise, +1 for clockwise.
#	type: String = "quad" or "trio" depending on vert count.
export var area_queue: Array

onready var root = $".."


# Clips a box-shaped polygon to within the bounds of the main polygon.
func polygon_clip_box(verts: Array, uvs: Array):
	var clip_poly = []
	var clip_uv = []
	var r_len = root.polygon.size()
	var e_len = verts.size()
	
	# Iterate all segments in the root polygon.
	for r_ind in r_len:
		# Get the segment starting on this vert (wrapping if necessary).
		var r_vert: Vector2 = root.polygon[r_ind]
		var r_next_vert: Vector2 = root.polygon[(r_ind + 1) % r_len]
		
		# Iterate all points in the edge.
		for e_ind in e_len:
			# Get the index and the verts of the box
			var e_next_ind = (e_ind + 1) % e_len
			var e_vert: Vector2 = verts[e_ind]
			var e_next_vert: Vector2 = verts[e_next_ind]
			
			# Get the intersection point
			var intersect = Geometry.segment_intersects_segment_2d(
				r_vert, r_next_vert,
				e_vert, e_next_vert)
			if intersect:
				# Is the next edge NOT looped around?
				if e_next_ind != 0:
					# Do standard clipping.
					# Make the clipped UV map...
					clip_uv.append(
						uvs[e_ind].move_toward(
							uvs[e_next_ind],
							intersect.distance_to(e_vert) /
								e_vert.distance_to(e_next_vert)
						)
					)
					clip_uv.append(uvs[e_next_ind])
					# ...and the clipped polygon.
					clip_poly.append(intersect)
					clip_poly.append(e_next_vert)
				else:
					# When the edge loops arround, generate the points in a
					# special order.
					
					# Make the clipped UV map...
					clip_uv.append(uvs[e_ind])
					clip_uv.append(
						uvs[e_ind].move_toward(
							uvs[e_next_ind],
							intersect.distance_to(e_vert) /
								e_vert.distance_to(e_next_vert)
						)
					)
					# ...and the clipped polygon.
					clip_poly.append(e_vert)
					clip_poly.append(intersect)
	# Return our new box with 
	return [clip_poly, clip_uv]

func add_edge_segment(is_left, area):
	# Get the correct upper corner & the correct direction
	var corner = area.verts[0] if is_left else area.verts[1]
	var normal_sign = -1 if is_left else 1
	
	# Generate the polygon's verts in a simple box shape.
	var edge_verts = PoolVector2Array([
		corner,
		corner + area.direction * QUAD_SIZE * normal_sign,
		corner + area.direction * QUAD_SIZE * normal_sign - area.normal * QUAD_SIZE,
		corner - area.normal * QUAD_SIZE,
	])
	# Create UV coords for this polygon.
	# (Edge polygons are always just boxes, so this is really easy.)
	var uvs = PoolVector2Array([
		Vector2(1, 0), Vector2(0, 0),
		Vector2(0, 1), Vector2(1, 1)
	])
	
	var vert_count = edge_verts.size() # TODO: Always == 4 :P
	
	# Check if our edge should have a shadow or not
	var inside_count = 0
	var verts_inside = []
	for vert in edge_verts:
		var is_inside = Geometry.is_point_in_polygon(vert, root.polygon)
		if is_inside:
			verts_inside.append(vert)
			inside_count += 1
	
	# Tint the polygon.
	# (TODO: Done differently than in pencil.gd???)
	var base_color = Color(1, 1, 1)
	if root.shallow:
		base_color = root.shallow_color
	var colors = PoolColorArray([base_color, base_color, base_color, base_color])
	
	# Draw the shadow if there's any point inside the polygon.
	if inside_count > 0:
		# Is the polygon 
		if inside_count != vert_count:
			# Clip the box so it fits in the polygon
			var clip_box = polygon_clip_box(edge_verts, uvs)
			var clip_poly = clip_box[0]
			var clip_uv = clip_box[1]
			# VALIDATE: Make sure the cut box is 4 verts
			if clip_poly.size() == 4:
				draw_polygon(clip_poly, colors, clip_uv, root.top_corner_shade)
			else:
				# This should not happen!
				#print("oh no: ", area.index, ": ", clip_poly.size(), " - ", clip_uv.size())
				pass
		# If the polygon is fully surrounded, simply draw the shadow.
		else:
			draw_polygon(edge_verts, colors, uvs, root.top_corner_shade)
	
	# Draw the actual edge on top of the shadow.
	draw_polygon(edge_verts, colors, uvs, root.top_corner)


func _draw():
	# When we are commanded to, draw everything we have in the queue
	for data in area_queue:
		add_edge_segment(data[0], data[1])
