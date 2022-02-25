extends Control

const list_item = preload("res://src/level_designer/list_item.tscn")

onready var level_editor := $"/root/Main"
onready var ld_camera := $"/root/Main/LDCamera"
onready var background := $"/root/Main/LDCamera/Background"
onready var lv_template := preload("res://src/level_designer/template.tscn")
onready var item_grid = $LeftBar/ColorRect/Control/ColorRect3/ColorRect4/ItemGrid

var terrain_modifier = {
	state = "idle"
}

var item_classes = {}
var items = {}
var item_textures = {}

func read_items():
	var parser = XMLParser.new()
	parser.open("res://src/level_designer/items.xml.tres")
	
	var parent_name
	var parent_subname
	var allow_reparent: bool = true
	while (!parser.read()):
		var node_type = parser.get_node_type()
		
		match node_type:
			#unused nodes
			parser.NODE_NONE:
				pass
			parser.NODE_COMMENT:
				pass
			parser.NODE_UNKNOWN:
				pass
			parser.NODE_CDATA:
				pass
			parser.NODE_TEXT:
				pass
			
			#useful nodes
			parser.NODE_ELEMENT:
				var node_name = parser.get_node_name()
				print(node_name)
				#interpret classes
				if parent_name == "class":
					if node_name == "property":
						var item_class = item_classes[parent_subname]
						var link_txt = parser.get_named_attribute_value_safe("link")
						link_txt = "#DEFAULT#" if link_txt == "" else link_txt
						
						var properties = {
							label = parser.get_named_attribute_value("label"),
							type = parser.get_named_attribute_value("type"),
							link = link_txt,
							description = parser.get_named_attribute_value("description")
						}
						
						item_class.append(properties)
				elif parent_name == "item":
					print(node_name)
					match node_name:
						"property":
							var item_class = items[parent_subname]
							var link_txt = parser.get_named_attribute_value_safe("link")
							link_txt = "#DEFAULT#" if link_txt == "" else link_txt
							
							var properties = {
								label = parser.get_named_attribute_value("label"),
								type = parser.get_named_attribute_value("type"),
								link = link_txt,
								description = parser.get_named_attribute_value("description")
							}
							
							item_class.append(properties)
						"texture":
							if !item_textures.has(parent_subname):
								item_textures[parent_subname] = {"Placed": null, "List": null}
							var path = parser.get_named_attribute_value_safe("path")
							item_textures[parent_subname][parser.get_named_attribute_value_safe("tag")] = path
								
						#"inherit":
							
				
				if allow_reparent:
					var subname = parser.get_named_attribute_value_safe("name")
					parent_subname = subname
					if node_name == "class":
						item_classes[subname] = []
					elif node_name == "item":
						items[subname] = []
					parent_name = node_name
					allow_reparent = false
			parser.NODE_ELEMENT_END:
				var node_name = parser.get_node_name()
				if node_name == "class" || node_name == "item":
					allow_reparent = true
	print(item_classes)
	print(items)
	print(item_textures)

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
		
#		if local_poly.size() >= 3:
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


func _ready():
	read_items()
	fill_grid()
	var template = lv_template.instance()
	level_editor.add_child(template)


func fill_grid():
	for key in item_textures.keys():
		var button = list_item.instance()
		var tex : ImageTexture = ImageTexture.new()
		var img : Image = Image.new()
		var path = item_textures[key]["List"]
		if path == null:
			path = item_textures[key]["Placed"]
		if path == null:
			img.create(16, 16, false, Image.FORMAT_RB8)
			img.fill(Color.magenta)
		else:
			img.load(path)
			img.crop(16, 16)
		tex.create_from_image(img)
		button.texture_normal = tex
		button.item_name = key
		item_grid.add_child(button)
