tool
extends Polygon2D

export var up_vector = Vector2(0, -1)
export var max_angle = 45

onready var collision = $Collision/CollisionShape
onready var base = $BaseTexture
onready var top = $Top
var grass_texture = preload("res://actors/terrain/jungle_grass.png")
var poly_old = PoolVector2Array([])
var poly_groups = []

#func calculate_direction(poly):
#	var i = 0
#	var size = poly.size()
#	var sum = 0
#	while i < size:
#		var vert = poly[i]
#		var vert_next = poly[(i + 1) % size]
#		sum += (vert_next.x - vert.x) * (vert_next.y + vert.y)
#		i += 1
#	return sum > 0 #True if clockwise

func generate_poly_groups():
	poly_groups = []
	var size = polygon.size()
	#create polygon groups
	for i in range(size):
		var start_vert = polygon[i] #get the current and the next poly
		var end_vert = polygon[(i + 1) % size]
		var data = { #the group it self, this precalculates a lot of stuff so yeah
			"start": start_vert,
			"end": end_vert,
			"left_overwrite": null, #these overwrites are being used with intersections, if null there's no intersection
			"right_overwrite": null,
			"direction": start_vert.direction_to(end_vert),
			"has_grass": false
		}
		if i == 0 || i == 1:
			data.has_grass = true
		data.angle = data.direction.angle()
		data.normal = data.direction.tangent()
		data.normal_angle = data.normal.angle()
		poly_groups.append(data)

#this function takes 2 poly groups and calculates the intersection points (automatically sets the overwrite points)
func calculate_intersection(left, right):
	var half = ((left.direction + right.direction) / 2).tangent().normalized() #split vector
	var angle = half.angle_to(right.direction)
	var intersect = half * (12 / sin(angle)) * sign(half.angle())
	#2/3 is 8 pixels and 1/3 is 4 pixels
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
		group.start + group.normal * 4,
		group.end + group.normal * 4,
		group.end - group.normal * 8,
		group.start - group.normal * 8
	])
	if group.left_overwrite:
		strip.polygon[3] = group.left_overwrite[0]
		strip.polygon[0] = group.left_overwrite[1]
	if group.right_overwrite:
		strip.polygon[2] = group.right_overwrite[0]
		strip.polygon[1] = group.right_overwrite[1]
	strip.texture = grass_texture
	strip.texture_rotation = -group.normal_angle - PI / 2
	#strip.texture_offset.x = offset_sum
	strip.texture_offset.y = (sin(strip.texture_rotation) * -group.start.x) - group.start.y * cos(strip.texture_rotation) + 4
	#offset_sum += vert.distance_to(vert_next) #dunno why this works better than distance_to() but eh
	top.add_child(strip)

func generate_full():
	set_polygon_from_groups()
	var size = poly_groups.size()
	for i in size:
		var left = poly_groups[i]
		var right = poly_groups[(i + 1) % size]
		if left.has_grass && right.has_grass:
			calculate_intersection(left, right)
		if left.has_grass:
			generate_grass(left)

func _draw():
	generate_poly_groups()
	generate_full()

func __process(_delta):
	base.polygon = polygon
	collision.polygon = polygon
	
