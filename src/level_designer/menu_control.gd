extends Control

const list_item = preload("res://src/level_designer/list_item.tscn")

onready var level_editor := $"/root/Main"
onready var ld_camera := $"/root/Main/LDCamera"
onready var background := $"/root/Main/LDCamera/Background"
onready var item_grid = $LeftBar/ColorRect/Control/ColorRect3/ColorRect4/ItemGrid

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
	terrain_modifier.clear()
	terrain_modifier.state = "create"
	terrain_modifier.polygon = [Vector2(0, 0)]
	terrain_modifier.ref = level_editor.place_terrain([Vector2(0, 0)], 0, 0)
	terrain_modifier.ref.shallow = true
#	terrain_modifier.poly = poly

func finish_creating_polygon():
	#make sure the polygon is correctly rotated, which is counter-clockwise
	if Geometry.is_polygon_clockwise(terrain_modifier.polygon):
		terrain_modifier.polygon.invert()
	
	if terrain_modifier.polygon.back() != terrain_modifier.polygon.front():
		print("E")
		terrain_modifier.polygon.append(
			terrain_modifier.polygon.back()
		)
	
	#remove the old reference, this is mainly because the live editor can cause some issues
	terrain_modifier.ref.get_parent().remove_child(terrain_modifier.ref)
	#set the terrain polygon to the actual polygon
	terrain_modifier.ref = level_editor.place_terrain(
		terrain_modifier.polygon,
		0,
		0
	)
	#terrain_modifier.ref.update()
	
	#reset the modifier state
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
		
		if local_poly.size() >= 3:
			#make sure rotation is correct
			var set_poly = PoolVector2Array(terrain_modifier.polygon)
			if Geometry.is_polygon_clockwise(terrain_modifier.polygon):
				set_poly.invert()
			#set the draw polygon
			terrain_modifier.ref.polygon = set_poly
		
#		if local_poly.size() >= 3:
#			draw_polygon(
#				local_poly,
#				colors
#			)
#
#		if local_poly.size() >= 2:
#			draw_polyline(
#				local_poly,
#				Color(0, 0.7, 0) if success else Color(0.7, 0, 0),
#				2,
#				true
#			)
		
		draw_circle(
			local_poly[local_poly.size() - 1],
			3,
			Color(0, 1, 0) if success else Color(1, 0, 0)
		)
		

func _input(event):
	if terrain_modifier.state == "create":
		var grid_px = 8
		
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
