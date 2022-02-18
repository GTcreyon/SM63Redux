tool
extends Node2D

onready var root = $".."

export(Array) var segment_queue

func add_edge_segment(is_left, group):
	print("EE")
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

func _draw():
	for data in segment_queue:
		add_edge_segment(data[0], data[1])
