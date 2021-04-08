tool
extends Polygon2D

onready var collision = $Collision/CollisionShape
onready var base = $BaseTexture
onready var top = $Top
var grass_texture = preload("res://actors/terrain/jungle_grass.png")
var poly_old = PoolVector2Array([])

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
	if polygon != poly_old:
		for n in top.get_children():
			top.remove_child(n)
			n.queue_free()
		var offset_sum = 0
		var size = polygon.size()
		var dir = calculate_direction(polygon)
		var test
		var intersect_list = []
		for i in range(size):
			intersect_list.append(null)
		for i in range(size):
			var vert = polygon[i]
			var vert_next = polygon[(i + 1) % size]
			var vert_post = polygon[(i + 2) % size]
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
			var vert = polygon[i]
			var vert_next = polygon[(i + 1) % size]
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
				strip.texture_rotation = -normal.angle() - PI / 2
				
				strip.texture_offset.x = offset_sum
				#print(offset_sum)
				#strip.texture_offset.y = 12 * strip.texture_rotation
				strip.texture_offset.y = (sin(strip.texture_rotation) * -vert.x) - vert.y * cos(strip.texture_rotation)
				offset_sum += vert.distance_squared_to(vert_next) #dunno why this works better than distance_to() but eh
				#strip.texture_offset.y = 3.310345
				#strip.texture_offset.x = $Node2D.position.x
				#$Node2D.position.x = 0

				#print(-normal.angle() - PI / 2)
				top.add_child(strip)
				poly_old = polygon


func _process(_delta):
	base.polygon = polygon
	collision.polygon = polygon
	
