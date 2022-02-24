extends Control

onready var level_editor := $"/root/Main"
onready var ld_camera := $"/root/Main/LDCamera"
onready var background := $"/root/Main/LDCamera/Background"
onready var lv_template := $"/root/Main/LevelTemplate"

var terrain_modifier = {
	state = "idle"
}

#a bad, slow, O(n^2), but easy to implement algorithm
#I should look into better algorithms
#infact, here: https://web.archive.org/web/20141211224415/http://www.lems.brown.edu/~wq/projects/cs252.html
#that is O(n)
#but eh, I'll come back to it
#sometime TM
func polygon_self_intersecting(polygon):
	var p_size = polygon.size()
	var start = polygon[0]
	var end = polygon[p_size - 1]
	for ind in range(p_size):
		var a = polygon[ind]
		var b = polygon[(ind + 1) % p_size]
		
		var result = Geometry.segment_intersects_segment_2d(
			start, end,
			a, b
		)
		
		if result && result != start && result != end:
			draw_circle(result, 5, Color(1, 0, 0))
			return false
	return true

func snap_vector(vec, grid):
	return Vector2(
				floor(vec.x / grid + 0.5) * grid,
				floor(vec.y / grid + 0.5) * grid
			)

func fake_polygon_create():
#	var poly = Polygon2D.new()
#	lv_template.add_child(poly)
#	lv_template.get_parent().print_tree_pretty()
	terrain_modifier.clear()
	terrain_modifier.state = "create"
	terrain_modifier.polygon = [Vector2(0, 0)]
	terrain_modifier.ref = level_editor.place_terrain([Vector2(0, 0)], 0, 0)
#	terrain_modifier.poly = poly

func finish_creating_polygon():
	#level_editor.place_terrain(terrain_modifier.polygon, 0, 0)
	terrain_modifier.ref.polygon = terrain_modifier.polygon
	
	terrain_modifier.clear()
	terrain_modifier.state = "idle"

func _process(_dt):
	background.material.set_shader_param("camera_position", ld_camera.global_position)
	update()

func _draw():
	if terrain_modifier.state == "create":
		var local_poly = PoolVector2Array()
		for vert in terrain_modifier.polygon:
			local_poly.append(
				vert - ld_camera.global_position
			)
		
		var success = true#polygon_self_intersecting(local_poly)
		
		var colors = PoolColorArray()
		for vert in local_poly:
			colors.append(
				Color(0, 1, 0, 0.2) if success else Color(1, 0, 0, 0.2)
			)
		
		terrain_modifier.ref.polygon = terrain_modifier.polygon
		
#		draw_polygon(
#			local_poly,
#			colors
#		)
		
		draw_polyline(
			local_poly,
			Color(0, 0.7, 0) if success else Color(0.7, 0, 0),
			2,
			true
		)
		
		draw_circle(
			local_poly[local_poly.size() - 1],
			3,
			Color(0, 1, 0) if success else Color(1, 0, 0)
		)
		

func _input(event):
	if terrain_modifier.state == "create":
		var grid_px = 16
		
		#have a dynamic moving polygon by updating the last vertex
		if event is InputEventMouseMotion and terrain_modifier.polygon.size() >= 1:
			var real_position = event.position + ld_camera.global_position
			real_position = snap_vector(real_position, grid_px)
			terrain_modifier.polygon[terrain_modifier.polygon.size() - 1] = real_position
			update() #force _draw
		
		#on click, insert a new vert in the polygon
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == 1:
				var real_position = event.position + ld_camera.global_position
				real_position = snap_vector(real_position, grid_px)
				var p_size = terrain_modifier.polygon.size()
				#if we have 2 vertices, cancel the placement, more than 3, we place it down
				if p_size >= 2 && real_position == terrain_modifier.polygon[0]:
					if p_size >= 3:
						finish_creating_polygon()
				else:
					terrain_modifier.polygon.append(real_position)
			elif event.button_index == 2:
				finish_creating_polygon()
			update() #force _draw

func _on_terrain_control_place_pressed():
	print("Place Terrain")
	fake_polygon_create()
	pass # Replace with function body.
