class_name JSONSerializer
extends Node

var json = JSON.new()
var save_json := {}

var LDItem = preload("res://scenes/menus/level_designer/ld_item/ld_item.tscn").instantiate()
var LDTerrain = preload("res://classes/solid/terrain/terrain_polygon.tscn").instantiate()

## Generates a JSON representation of the level.

func generate_level_json(editor: Node) -> String:
	
	var items_json = generate_items_json(editor)             	# All entities / items loaded
	var polygons_json = generate_polygons_json(editor)       	# All polygons loaded
	var editor_json = generate_editor_json(editor)           	# Extra data (Editor version, Last camera position, etc.)
	
	# Optimization: Only add dictionaries with content in them 
	if items_json: save_json.items = items_json 
	if polygons_json: save_json.polygons = polygons_json
	
	# Editor metadata has to be saved though
	assert(editor_json)
	save_json.editor = editor_json
	
	print(save_json)
	return json.stringify(save_json)

func generate_items_json(editor: Node) -> Dictionary:
	var scene_items = editor.get_node("Items").get_children()
	var item_json = {}

	if !scene_items.size(): return {} # Don't even bother running if there are no items placed

	var item_properties = null # This can probably fetch an item's properties (as a dictionary) in the future

	for item in scene_items:
		var item_id = item.item_id
		if typeof(item.item_id == TYPE_INT): item_id = translate_id(item.item_id) # This line & function can be removed once string IDs are implemented
		var item_data = [item.position.x, item.position.y, item_properties] # item_properties will prob. be a dictionary with extra data like rotation, scale, etc.
		if !item_data[-1]: item_data.pop_back() # Delete the last element if no extra properties exist (will always do this right now bc properties aren't implemented)
		if item_id not in item_json.keys(): item_json[item_id] = [item_data] # add new item key if it doesn't exist yet
		else: item_json[item_id].append(item_data) # append if the key exists

	return item_json

func generate_polygons_json(editor: Node) -> Dictionary:
	var terrain_polygons = editor.get_node("Terrain").get_children()
	var water_polygons = editor.get_node("Water").get_children()

	var scene_polygons = {
		"terrain": terrain_polygons, 
		"water": water_polygons,
		}

	var polygons_json = {}

	if !(terrain_polygons.size() or water_polygons.size()): return {} # Don't even bother running if there are no polygons placed

	# This part is practically identical to the item generator, except dictionaries are used.
	for polygon_type in scene_polygons:
		if scene_polygons[polygon_type]: polygons_json[polygon_type] = [] # Prepare list if there are polygons of this type
		for polygon in scene_polygons[polygon_type]:
			var polygon_properties = fetch_polygon_properties(polygon)
			polygons_json[polygon_type].append(polygon_properties)
	return polygons_json

func generate_editor_json(editor: Node) -> Dictionary: # better logic can be added later
	var camera: Camera2D = editor.get_node("../Camera")
	return {
		"version": Singleton.LD_VERSION,
		"last_camera_pos": Vector2(camera.position.x, camera.position.y)
	}



func load_level_json(file_content, editor: Node) -> void:
	var file_json = json.parse_string(file_content)
	
	load_items_json(file_json.items, editor)
	load_polygons_json(file_json.polygons, editor)
	load_editor_json(file_json.editor, editor)

func load_items_json(items_json, editor: Node) -> void:
	
	var Main = editor.get_node("/root/Main")
	var new_items_parent = Node2D.new()
	
	for item_type in items_json:
		var item_id = translate_id(item_type) # Yet again, will not be necessary after string id implementation
		for item in items_json[item_type]:
			var new_item = LDItem.duplicate()
			new_item.item_id = int(item_id)
			new_item.position = Vector2(item[0], item[1])
			new_item.texture = load(Main.item_textures[item_id]["Placed"])
			# item[2] would be properties, which can be applied once that is up and working
			new_items_parent.add_child(new_item)
			
# This approach makes sure everything ran fine before loading the new items
	editor.remove_child(editor.get_node("Items"))
	new_items_parent.name = "Items"
	editor.add_child(new_items_parent) 

func load_polygons_json(polygons_json, editor: Node) -> void:
	var Main = editor.get_node("/root/Main")
	var new_polygon_parent = Node2D.new()
	
	for polygon_type in polygons_json: 
		for polygon in polygons_json[polygon_type]:

			var new_polygon_vertices: PackedVector2Array
			var new_polygon = Polygon2D.new()

			match polygon_type:
				"terrain": new_polygon = LDTerrain.duplicate()
				"water": pass # TODO: water not ready yet

			new_polygon.position = str_to_vec2(polygon.position)
			# new_polygon.properties = polygon.properties

			for vertex in polygon.vertices:
				if polygon.vertices.size() < 3: break
				new_polygon_vertices.append(str_to_vec2(vertex))

			new_polygon.polygon = new_polygon_vertices

			new_polygon_parent.add_child(new_polygon)

		editor.remove_child(editor.get_node(polygon_type.to_pascal_case()))
		new_polygon_parent.name = polygon_type.to_pascal_case()
		editor.add_child(new_polygon_parent)

func load_editor_json(editor_json, editor: Node) -> void:
	var Camera = editor.get_node("../Camera")
	Camera.position = str_to_vec2(editor_json.last_camera_pos)


## EXTRA STUFF

func fetch_polygon_properties(polygon: Node) -> Dictionary:
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

func str_to_vec2(str := "") -> Vector2: # t
	var new_str = str
	new_str = new_str.erase(0, 1)
	new_str = new_str.erase(new_str.length() -1, 1)
	var array = new_str.split(", ")
	return Vector2(int(array[0]),int(array[1]))

## TODO: Everything under this line will most likely be removed once string IDs are properly implemented

func translate_id(item_id):
	# NUMBER -> STRING
	if typeof(item_id) == TYPE_INT:
		return item_mapping[item_id]

	# STRING -> NUMBER
	elif typeof(item_id) == TYPE_STRING:
		for item in item_mapping.keys():
			if item_mapping[item] == item_id: return item

	return null

var item_mapping = {
	0: "coin",
	1: "red_coin",
	2: "blue_coin",
	3: "silver_shine",
	4: "shine_sprite",
	5: "spin_block",
	6: "log",
	7: "falling_log",
	8: "tipping_log",
	9: "cloud_middle",
	10: "wood_platform",
	11: "pipe",
	12: "goomba",
	13: "parakoopa",
	14: "koopa",
	15: "koopashell",
	16: "bobomb",
	17: "cheep_cheep",
	18: "goonie",
	19: "butterfly",
	20: "sign",
	21: "water_bottle_small",
	22: "water_bottle_big",
	23: "hover_fludd_box",
	24: "big_tree",
	25: "small_tree",
	26: "big_rock",
	27: "arrow",
	28: "twirl_heart",
	29: "breakable_box",
}
