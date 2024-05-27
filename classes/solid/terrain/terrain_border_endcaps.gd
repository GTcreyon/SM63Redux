@tool
class_name TerrainBorderEndcaps
extends Node2D
# Handles drawing the endcaps of terrain polygons' top edges.

const QUAD_SIZE = 32 #2*TerrainBorder.QUAD_RADIUS

# Queue of areas to be rendered.
# An area is stored as an array with two elements:
# is_left: bool = whether the cap is a left cap.
# area = the data of the adjacent area, which has the following fields:
# 	index: int = which area this is.
#	verts: Array = Vector2 positions of all points in the area,
#	direction: Vector2 = the direction from area's start to end.
#	normal: Vector2 = which direction is "outward" for this area.
#	clock_dir: int = -1 for counterclockwise, +1 for clockwise.
#	type: String = "quad" or "trio" depending on vert count.
@export var area_queue: Array

@onready var root = $".."


func _draw():
	# When we are commanded to, draw everything we have in the queue.
	for data in area_queue:
		add_cap_segment(data[0], data[1])


# Clips a box-shaped polygon to within the bounds of the main polygon.
func polygon_clip_box(verts: Array, uvs: Array):
	var clip_poly = []
	var clip_uv = []
	var r_len = root.polygon.size()
	var c_len = verts.size()
	
	# Iterate all segments in the root polygon.
	for r_ind in r_len:
		# Get the segment starting on this vert (wrapping if necessary).
		var r_vert: Vector2 = root.polygon[r_ind]
		var r_next_vert: Vector2 = root.polygon[(r_ind + 1) % r_len]
		
		# Iterate all points in the endcap.
		for c_ind in c_len:
			# Get the index and the verts of the box
			var c_next_ind = (c_ind + 1) % c_len
			var c_vert: Vector2 = verts[c_ind]
			var c_next_vert: Vector2 = verts[c_next_ind]
			
			# Get the intersection point
			var intersect = Geometry2D.segment_intersects_segment(
				r_vert, r_next_vert,
				c_vert, c_next_vert)
			if intersect:
				# Is the next segment NOT looped around?
				if c_next_ind != 0:
					# Do standard clipping.
					# Make the clipped UV map...
					clip_uv.append(
						uvs[c_ind].move_toward(
							uvs[c_next_ind],
							intersect.distance_to(c_vert) /
								c_vert.distance_to(c_next_vert)
						)
					)
					clip_uv.append(uvs[c_next_ind])
					# ...and the clipped polygon.
					clip_poly.append(intersect)
					clip_poly.append(c_next_vert)
				else:
					# When the segment loops arround, generate the points in a
					# special order.
					
					# Make the clipped UV map...
					clip_uv.append(uvs[c_ind])
					clip_uv.append(
						uvs[c_ind].move_toward(
							uvs[c_next_ind],
							intersect.distance_to(c_vert) /
								c_vert.distance_to(c_next_vert)
						)
					)
					# ...and the clipped polygon.
					clip_poly.append(c_vert)
					clip_poly.append(intersect)
	# Return our new box with 
	return [clip_poly, clip_uv]

func add_cap_segment(is_left, area):
	# Get the correct upper corner & the correct direction
	var corner = area.verts[0] if is_left else area.verts[1]
	var normal_sign = -1 if is_left else 1
	
	# Generate the polygon's verts in a simple box shape.
	var cap_verts = PackedVector2Array([
		corner,
		corner + area.direction * QUAD_SIZE * normal_sign,
		corner + area.direction * QUAD_SIZE * normal_sign - area.normal * QUAD_SIZE,
		corner - area.normal * QUAD_SIZE,
	])
	# Create UV coords for this polygon.
	# (Endcap polygons are always just boxes, so this is really easy.)
	var uvs = PackedVector2Array([
		Vector2(1, 0), Vector2(0, 0),
		Vector2(0, 1), Vector2(1, 1)
	])
	
	var vert_count = cap_verts.size() # TODO: Always == 4 :P
	
	# Check if our cap should have a shadow or not
	var inside_count = 0
	var verts_inside = []
	for vert in cap_verts:
		var is_inside = Geometry2D.is_point_in_polygon(vert, root.polygon)
		if is_inside:
			verts_inside.append(vert)
			inside_count += 1
	
	# Tint the polygon.
	# (TODO: Done differently than in pencil.gd???)
	var base_color = Color(1, 1, 1)
	if root.tint:
		base_color = root.tint_color
	var colors = PackedColorArray([base_color, base_color, base_color, base_color])
	
	# Draw the shadow if there's any point inside the polygon.
	if inside_count > 0:
		# Is the polygon 
		if inside_count != vert_count:
			# Clip the box so it fits in the polygon
			var clip_box = polygon_clip_box(cap_verts, uvs)
			var clip_poly = clip_box[0]
			var clip_uv = clip_box[1]
			# VALIDATE: Make sure the cut box is 4 verts
			if clip_poly.size() == 4:
				draw_polygon(clip_poly, colors, clip_uv, root.skin.top_endcap_shadow)
			else:
				# This should not happen!
				#print("oh no: ", area.index, ": ", clip_poly.size(), " - ", clip_uv.size())
				pass
		# If the polygon is fully surrounded, simply draw the shadow.
		else:
			draw_polygon(cap_verts, colors, uvs, root.skin.top_endcap_shadow)
	
	# Draw the actual endcap on top of the shadow.
	draw_polygon(cap_verts, colors, uvs, root.skin.top_endcap)
