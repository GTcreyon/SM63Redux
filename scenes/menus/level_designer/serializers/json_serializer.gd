class_name JSONSerializer
extends Node

const LD_ITEM = preload("res://scenes/menus/level_designer/ld_item/ld_item.tscn")
const LD_TERRAIN = preload("res://classes/solid/terrain/terrain_polygon.tscn")


## Generates a JSON representation of the level.
func generate_level_json(editor: Node) -> String:
	var save_json := {}
	
	# Level info
	save_json.info = {
		title = "",
		author = "",
		missions = [],
		# used for forward/backward compat between at least published demos
		format_ver = Singleton.LD_VERSION
	}
	# Editor state saved between sessions (maybe strip in minified exports?)
	save_json.editor = _generate_editor_json(editor)
	assert(save_json.editor)
	# All entities / items loaded
	save_json.items = _generate_items_json(editor)
	# All polygons loaded
	save_json.polygons = _generate_polygons_json(editor)
	
	print(save_json)
	return JSON.stringify(save_json)


func load_level_json(file_content, editor: Node):
	var file_json = JSON.parse_string(file_content)
	
	_load_items_json(file_json.items, editor)
	_load_polygons_json(file_json.polygons, editor)
	_load_editor_json(file_json.editor, editor)


func _generate_items_json(editor: Node) -> Dictionary:
	var scene_items = editor.get_node("Items").get_children()
	var item_json = {}

	if !scene_items.size(): 
		return {} # Don't even bother running if there are no items placed

	# This can probably fetch an item's properties (as a dictionary) in the future
	var item_properties = null

	for item in scene_items:
		var item_id = item.item_id
		# item_properties will prob. be a dictionary with extra data like rotation, scale, etc.
		var item_data = [item.position.x, item.position.y, item_properties]
		if !item_data[-1]:
			# Delete the last element if no extra properties exist
			# (will always do this right now bc properties aren't implemented)
			item_data.pop_back()
		if item_id not in item_json.keys():
			# add new item key if it doesn't exist yet
			item_json[item_id] = [item_data]
		else:
			item_json[item_id].append(item_data) # append if the key exists

	return item_json


func _generate_polygons_json(editor: Node) -> Dictionary:
	var terrain_polygons = editor.get_node("Terrain").get_children()
	var water_polygons = editor.get_node("Water").get_children()

	var scene_polygons = {
		"terrain": terrain_polygons, 
		"water": water_polygons,
	}

	var polygons_json = {}

	if !(terrain_polygons.size() or water_polygons.size()):
		# Don't even bother running if there are no polygons placed
		return {}

	# This part is practically identical to the item generator, except dictionaries are used.
	for polygon_type in scene_polygons:
		if scene_polygons[polygon_type]:
			# Prepare list if there are polygons of this type
			polygons_json[polygon_type] = []
		for polygon in scene_polygons[polygon_type]:
			var polygon_properties = _fetch_polygon_properties(polygon)
			polygons_json[polygon_type].append(polygon_properties)
	return polygons_json


func _generate_editor_json(editor: Node) -> Dictionary: # better logic can be added later
	var camera: Camera2D = editor.get_node("../Camera")
	return {
		"last_camera_pos": Vector2(camera.position.x, camera.position.y)
	}


func _load_items_json(items_json, editor: Node):
	var main = editor.get_node("/root/Main")
	var new_items_parent = Node2D.new()
	
	for item_id in items_json:
		for inst in items_json[item_id]:
			var new_item = LD_ITEM.instantiate()
			new_item.item_id = item_id
			new_item.position = Vector2(inst[0], inst[1])
			new_item.texture = load(main.item_textures[item_id]["Placed"])
			# inst[2] would be properties, which can be applied once that is up and working
			new_items_parent.add_child(new_item)
			
	# This approach makes sure everything ran fine before loading the new items
	editor.remove_child(editor.get_node("Items"))
	new_items_parent.name = "Items"
	editor.add_child(new_items_parent) 


func _load_polygons_json(polygons_json, editor: Node):
	var main = editor.get_node("/root/Main")
	var new_polygon_parent = Node2D.new()
	
	for polygon_type in polygons_json: 
		for polygon in polygons_json[polygon_type]:

			var new_polygon_vertices: PackedVector2Array
			var new_polygon = Polygon2D.new()

			match polygon_type:
				"terrain": new_polygon = LD_TERRAIN.instantiate()
				"water": pass # TODO: water not ready yet

			new_polygon.position = _str_to_vec2(polygon.position)
			# new_polygon.properties = polygon.properties

			for vertex in polygon.vertices:
				if polygon.vertices.size() < 3:
					break
				new_polygon_vertices.append(_str_to_vec2(vertex))

			new_polygon.polygon = new_polygon_vertices

			new_polygon_parent.add_child(new_polygon)

		editor.remove_child(editor.get_node(polygon_type.to_pascal_case()))
		new_polygon_parent.name = polygon_type.to_pascal_case()
		editor.add_child(new_polygon_parent)


func _load_editor_json(editor_json, editor: Node):
	var Camera = editor.get_node("../Camera")
	Camera.position = _str_to_vec2(editor_json.last_camera_pos)


# EXTRA STUFF

func _fetch_polygon_properties(polygon: Node) -> Dictionary:
	var polygon_properties = {}
	
	# Store position
	var position = Vector2(polygon.position.x, polygon.position.y)
	
	# Store vertices
	var vertices = []
	for polygon_vertex in polygon.collision_shape.polygon:
		vertices.append(Vector2(polygon_vertex.x, polygon_vertex.y))
	if vertices.size() < 3: vertices = null # Return null if there are less than 3 vertices

	# TODO: Add more properties like tileset/texture and stuff

	polygon_properties["position"] = position
	polygon_properties["vertices"] = vertices
	return polygon_properties


func _str_to_vec2(str := "") -> Vector2: # t
	var new_str = str
	new_str = new_str.erase(0, 1)
	new_str = new_str.erase(new_str.length() -1, 1)
	var array = new_str.split(", ")
	return Vector2(int(array[0]), int(array[1]))