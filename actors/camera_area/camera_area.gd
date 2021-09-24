extends Polygon2D

onready var player = $"/root/Main/Player"
onready var camera: Camera2D = player.get_node("Camera2D")

#return segment-polygon intersection
func intersect_polygon(from, to, poly):
	var hit
	var closest_distance = INF
	var size = poly.size()
	for ind in range(size):
		var this = poly[ind]
		var next = poly[(ind + 1) % size]
		var check_hit = Geometry.segment_intersects_segment_2d(from, to, this, next)
		#if nothing got hit, then skip
		if !check_hit:
			continue
		#make sure the one we return is the closest to the player
		var dist = (check_hit - from).length()
		if dist <= closest_distance:
			closest_distance = dist
			hit = check_hit
	return hit

func set_limits():
	#we multiply by 2 so the camera doesn't *instantly* snaps back once the camera doesn't need to clip anymore
	var screen_size = OS.window_size / camera.get_global_transform().get_scale() * 2
	var player_pos = player.global_position
	
	#transform this polygon into global positions
	var global_polygon = PoolVector2Array()
	for vec in polygon:
		global_polygon.append(vec + global_position)
	
	#set default value
	camera.target_limit_left = player_pos.x + -screen_size.x / 2
	camera.target_limit_right = player_pos.x + screen_size.x / 2
	camera.target_limit_top = player_pos.y + -screen_size.y / 2
	camera.target_limit_bottom = player_pos.y + screen_size.y / 2
	
	#check for 
	var upper_int = intersect_polygon(player_pos, player_pos + Vector2(0, -screen_size.y / 2), global_polygon)
	if upper_int:
		camera.target_limit_top = upper_int.y

	var lower_int = intersect_polygon(player_pos, player_pos + Vector2(0, screen_size.y / 2), global_polygon)
	if lower_int:
		camera.target_limit_bottom = lower_int.y

	var left_int = intersect_polygon(player_pos, player_pos + Vector2(-screen_size.y / 2, 0), global_polygon)
	if left_int:
		camera.target_limit_left = left_int.x

	var right_int = intersect_polygon(player_pos, player_pos + Vector2(screen_size.y / 2, 0), global_polygon)
	if right_int:
		camera.target_limit_right = right_int.x

func _process(_dt):
	set_limits()
