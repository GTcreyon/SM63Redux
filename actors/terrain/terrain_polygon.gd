tool
extends StaticBody2D

onready var collision = $Collision
onready var base = $BaseTexture
onready var top = $Top
var grass_texture = preload("res://actors/terrain/jungle_grass.png")

func bsign(x): #either + or -, 0 is not here
	if x >= 0:
		return 1
	else:
		return -1
		
func calculate_direction(poly):
	var i = 0
	var size = poly.size()
	var sum = 0
	while i < size:
		var vert = poly[i]
		var vert_next = poly[(i + 1) % size]
		sum += (vert_next.x - vert.x) * (vert_next.y + vert.y)
		i += 1
	return sum > 0 #True if clockwise


func _draw():
	var poly = collision.polygon
	var size = poly.size()
	var dir = calculate_direction(poly)
	var test
	var intersect_list = []
	for i in range(size):
		intersect_list.append(null)
	for i in range(size):
		var vert = poly[i]
		var vert_next = poly[(i + 1) % size]
		var vert_post = poly[(i + 2) % size]
		#print(vert)
		if (vert.x >= vert_next.x) == dir:
			#var normal = vert.direction_to(vert_next).tangent()
			if intersect_list[i] == null:
				intersect_list[i] = Vector2.INF #Used to represent a grass vertex at the end of a quad
			if (vert_next.x >= vert_post.x) == dir:
				var half = ((vert.direction_to(vert_next) + vert_next.direction_to(vert_post)) / 2).tangent().normalized() #split vector

				var angle = half.angle_to(vert_next.direction_to(vert_post))
				var intersect = half * (12 / sin(angle)) * sign(half.angle())

				intersect_list[(i + 1) % size] = vert_next + intersect
		
	for i in range(size):
		var strip = Polygon2D.new()
		var vert = poly[i]
		var vert_next = poly[(i + 1) % size]
		var splitter = intersect_list[i]
		if splitter != null:
			var normal = vert.direction_to(vert_next).tangent()
			strip.polygon = (PoolVector2Array([
				vert,
				vert_next,
				vert_next - normal * 12,
				vert - normal * 12
				]))
			strip.texture = grass_texture
			
			var splitter_next = intersect_list[(i + 1) % size]
			if splitter != null && splitter != Vector2.INF:
				#print("a" + str(splitter))
				strip.polygon[3] = splitter
			if splitter_next != null && splitter_next != Vector2.INF:
				#print("b" + str(splitter_next))
				strip.polygon[2] = splitter_next
			var testA = strip.polygon
			strip.texture_rotation = -normal.angle() - PI / 2
			#strip.offset.y = -4
			strip.texture_offset.y = 12 * strip.texture_rotation
			print(-normal.angle() - PI / 2)
			top.add_child(strip)


func _process(_delta):
	base.polygon = collision.polygon
	
