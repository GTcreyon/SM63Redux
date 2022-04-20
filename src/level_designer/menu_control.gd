extends Control

const list_item = preload("res://src/level_designer/list_item.tscn")

onready var level_editor := $"/root/Main"
onready var ld_camera := $"/root/Main/LDCamera"
onready var background := $"/root/Main/LDCamera/Background"
onready var item_grid = $LeftBar/ColorRect/Control/ColorRect3/ColorRect4/ItemGrid

var polygon_modifier = {
	state = "idle", #the state of the polygon editor
	type = "terrain", #the type of polygon (terrain / water / camera limits)
	polygon = [], #the current polygon verts
	ref = null #a reference to the instance
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
	polygon_modifier.clear()
	polygon_modifier.state = "create"
	polygon_modifier.polygon = [Vector2(0, 0)]
#	polygon_modifier.poly = poly

func finish_creating_polygon():
	#make sure the polygon is correctly rotated, which is counter-clockwise
	if Geometry.is_polygon_clockwise(polygon_modifier.polygon):
		polygon_modifier.polygon.invert()
	
	if polygon_modifier.polygon.back() != polygon_modifier.polygon.front():
		polygon_modifier.polygon.append(
			polygon_modifier.polygon.back()
		)
	
	#set the terrain polygon to the actual polygon
	polygon_modifier.ref = level_editor.place_terrain(
		polygon_modifier.polygon,
		0,
		0
	)
	
	#reset the modifier state
	polygon_modifier.clear()
	polygon_modifier.state = "idle"

func get_local_polygon_data():
	var local_poly = PoolVector2Array()
	for vert in polygon_modifier.polygon:
		local_poly.append(
			vert - ld_camera.global_position
		)
	return local_poly

func get_polygon_rect(polygon):
	#get the extends
	var vec_min = Vector2.INF
	var vec_max = -Vector2.INF
	for vert in polygon:
		vec_min.x = min(vec_min.x, vert.x)
		vec_min.y = min(vec_min.y, vert.y)
		vec_max.x = max(vec_max.x, vert.x)
		vec_max.y = max(vec_max.y, vert.y)
	return Rect2(vec_min, vec_max - vec_min)

func draw_editable_rect(poly_rect):
	#draw the extends
	draw_rect(poly_rect, Color(0.6, 0.25, 0.1), false, 2)
	for x in [0, 0.5, 1]:
		for y in [0, 0.5, 1]:
			if x == 0.5 && y == 0.5:
				continue
			var coords = poly_rect.position + poly_rect.size * Vector2(x, y)
			draw_circle(coords, 4, Color(0.6, 0.25, 0.1))
			draw_circle(coords, 3, Color(0.8, 0.35, 0.2))

func draw_editable_polygon(local_poly):
	#draw the polygon outline
	#not using polyline, since it has an ugly inner joint mode
	var p_size = local_poly.size()
	for idx in p_size:
		var n_idx = (idx + 1) % p_size
		draw_line(
			local_poly[idx],
			local_poly[n_idx],
			Color(0.4, 0.2, 0),
			3
		)
		draw_circle(local_poly[idx], 4, Color(0.5, 0.3, 0))
		draw_circle(local_poly[idx], 3, Color(0.8, 0.5, 0.3))

func _draw():
	if polygon_modifier.state == "create":
		var local_poly = get_local_polygon_data()
		var poly_rect = get_polygon_rect(local_poly)
		draw_editable_polygon(local_poly)
		draw_editable_rect(poly_rect)
		
		draw_circle(
			local_poly[local_poly.size() - 1],
			3,
			Color(0, 1, 0)
		)
	elif polygon_modifier.state == "edit":
		var local_poly = get_local_polygon_data()
		var poly_rect = get_polygon_rect(local_poly)
		draw_editable_rect(poly_rect)

func _process(_dt):
	background.material.set_shader_param("camera_position", ld_camera.global_position)
	update()

func _input(event):
	if polygon_modifier.state == "create":
		var grid_px = 8
		
		#have a dynamic moving polygon by updating the last vertex
		if event is InputEventMouseMotion and polygon_modifier.polygon.size() >= 1:
			var real_position = event.position + ld_camera.global_position
			real_position = snap_vector(real_position, grid_px)
			polygon_modifier.polygon[polygon_modifier.polygon.size() - 1] = real_position
			update() #force _draw
		
		#on click, insert a new vert in the polygon
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == 1:
				var real_position = event.position + ld_camera.global_position
				real_position = snap_vector(real_position, grid_px)
				var p_size = polygon_modifier.polygon.size()
				#if we have 2 vertices, cancel the placement, more than 3, we place it down
				if p_size >= 2 && real_position == polygon_modifier.polygon[0]:
					if p_size >= 3:
						finish_creating_polygon()
				else:
					polygon_modifier.polygon.append(real_position)
			elif event.button_index == 2:
				finish_creating_polygon()
			update() #force _draw

func _on_terrain_control_place_pressed():
	print("Place Terrain")
	fake_polygon_create()
	pass # Replace with function body.


func fill_grid():
	for key in level_editor.item_textures.keys():
		var button = list_item.instance()
		var tex : AtlasTexture = AtlasTexture.new()
		
		var path = level_editor.item_textures[key]["List"]
		if path == null:
			path = level_editor.item_textures[key]["Placed"]
		
		var stream: StreamTexture = load(path)
		tex.atlas = stream
		var min_size = Vector2(
			min(
				stream.get_width(),
				16
			),
			min(
				stream.get_height(),
				16
			)
		)
		tex.region = Rect2(
			stream.get_size() / 2 - min_size / 2,
			min_size
		)
			
		button.texture_normal = tex
		button.item_name = key
		item_grid.add_child(button)
