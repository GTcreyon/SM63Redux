class_name JSONSerializer
extends Node

const LD_ITEM = preload("res://scenes/menus/level_designer/ld_item/ld_item.tscn")
const LD_TERRAIN = preload("res://classes/solid/terrain/terrain_polygon.tscn")


## Generates a JSON representation of the level.
func generate_level_json(main: LDMain, level: Node2D) -> String:
	var save_json := {}
	
	# Level info
	save_json.info = {
		title = "",
		author = "",
		missions = [],
		# used for forward/backward compat between at least published demos
		format_ver = Singleton.LD_VERSION,
	}
	# Editor state saved between sessions (maybe strip in minified exports?)
	save_json.editor = _generate_editor_json(main)
	assert(save_json.editor)
	# All entities / items loaded
	save_json.items = _generate_items_json(level)
	# All polygons loaded
	save_json.polygons = _generate_polygons_json(level)
	
	print(save_json)
	return JSON.stringify(save_json)


func load_level_json(file_content, main: LDMain):
	var file_json = JSON.parse_string(file_content)
	
	# Load file format version as semantic version.
	var fmt_ver: SemVer
	# VERSION: if the file format is stored as a number, interpret that
	# number as the patch release.
	# This is for compatibility with the oldest JSON LD files, made while
	# developing the JSON serializer. Their version is 0--not even "0.0.0",
	# just 0.
	if file_json.info.format_ver is float:
		fmt_ver = SemVer.new(0,0,file_json.info.format_ver)
	else:
		fmt_ver = SemVer.from_string(file_json.info.format_ver)
	print("File is format version ", fmt_ver)
	
	_load_editor_json(file_json.editor, main, fmt_ver)
	
	# Create a parallel item tree to load into, just in case level loading
	# fails at any point.
	var new_level = Node2D.new()
	new_level.name = "Template"
	
	# Load the items from the JSON file.
	var item_tree = _load_items_json(file_json.items, main, fmt_ver)
	# Error code handling goes here....
	# Items loaded successfully. Add to new-level tree.
	new_level.add_child(item_tree)
	
	# Load the polygons in similar fashion.
	var poly_trees = _load_polygons_json(file_json.polygons, main, fmt_ver)
	# Error code handling goes here....
	# Polygons loaded successfully. One root per type; add them all to the tree.
	for polyset in poly_trees:
		new_level.add_child(polyset)
	
	# TODO: Add the rest of the template's node tree to avoid future errors.
	
	# TODO: Emit signal before despawning the old tree, so that Selection
	# has a chance to deselect everything from the old tree.
	
	# If we didn't hit any errors during loading, the new level is correctly
	# enough loaded to be displayed. Swap the trees.
	var old_level = main.get_node("Template")
	main.remove_child(old_level)
	main.add_child(new_level)
	
	# If there's any errors, this is the user's last chance to abort.
	# Manual error resolution goes here.
	
	# Ditch the old tree. Loading is complete.
	old_level.queue_free()


func _generate_items_json(main: LDMain, level: Node) -> Dictionary:
	var scene_items = level.get_node("Items").get_children()
	var item_json = {}

	# Don't even bother running if there are no items placed
	if !scene_items.size(): return {} 

	for item: LDPlacedItem in scene_items:
		var item_id = item.item_id
		var item_properties = _only_modified_props(item.properties, main, item_id)
		item_properties.erase("Position")
		var item_data := [item.position.x, item.position.y, item_properties]
			
		if item_id not in item_json.keys():
			item_json[item_id] = [item_data] # add new item key if it doesn't exist yet
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


func _generate_editor_json(main: LDMain) -> Dictionary: # better logic can be added later
	var camera: Camera2D = main.get_node("Camera")
	return {
		"last_camera_pos": Vector2(camera.position.x, camera.position.y)
	}


func _load_items_json(items_json: Dictionary, main: LDMain, fmt_ver: SemVer):
	# Create a parallel Items tree to load into, just in case level loading
	# fails at any point.
	var new_items_parent = Node2D.new()
	new_items_parent.name = "Items"
	
	for item_id: String in items_json.keys():
		print("Loading all ", item_id)
		for inst_data: Array in items_json[item_id]:
			var inst: LDPlacedItem = LD_ITEM.instantiate()
			
			inst.item_id = item_id
			inst.texture = load(main.item_textures[item_id]["Placed"])
			
			var inst_props: Dictionary
			if len(inst_data) < 3:
				push_warning("Instance has no properties.")
				inst_props = {}
			else:
				inst_props = inst_data[2]
			
			# Load item's properties into their right spot.
			# Begin by getting a copy of this item type's property metadata.
			var prop_meta = main.items[item_id].properties
			# Populate the placed item from the loaded level data.
			for propname: String in prop_meta.keys():
				#print("Parse prop ", propname)
				
				# Parse the value if it exists; use the default if not.
				var val
				if inst_props.has(propname):
					var prop_type = prop_meta[propname].type
					val = _decode_value_of_type(inst_props[propname], prop_type)
					#print(val)
				else:
					val = _decode_value_of_type(
						main.default_of_property(prop_meta[propname]),
						prop_meta[propname].type)
					#print("Unset, prop default ", val)
				
				inst.properties[propname] = val
				inst.update_visual_property(propname, val)
			
			# Set position specially, since it's stored separately.
			inst.position = Vector2(inst_data[0], inst_data[1])
			inst.properties["Position"] = inst.position
			
			new_items_parent.add_child(inst)
	
	return new_items_parent


func _load_polygons_json(polygons_json: Dictionary, main: LDMain, fmt_ver: SemVer) -> Array[Node2D]:
	var polygon_sets: Array[Node2D] = []
	
	for polygon_type: String in polygons_json:
		# Create a parent to save polygons of this type into.
		var poly_type_parent := Node2D.new()
		poly_type_parent.name = polygon_type.to_pascal_case()
		
		for loaded_poly: Dictionary in polygons_json[polygon_type]:
			# Skip malformed polygons with too few verts.
			if loaded_poly.vertices.size() < 3:
				push_warning("Found ", polygon_type, " with too few verts: ", loaded_poly)
				continue
			
			# Duplicate the correct polygon instance for the type.
			var inst: Polygon2D
			match polygon_type:
				"terrain": inst = LD_TERRAIN.instantiate()
				"water": pass # TODO: water not ready yet

			inst.position = _str_to_vec2(loaded_poly.position)
			# inst.properties = polygon.properties

			# Load the deserialized verts into the instance node.
			var new_polygon_vertices := PackedVector2Array()
			for vertex in loaded_poly.vertices:
				# Convert the deserialized string into a valid Vector2.
				new_polygon_vertices.append(_str_to_vec2(vertex))
			inst.polygon = new_polygon_vertices
			
			# Add the instance to the type's parent.
			poly_type_parent.add_child(inst)
		
		# This poly-type's loading is done, no errors. Add it to the output array.
		polygon_sets.append(poly_type_parent)
	
	return polygon_sets


func _load_editor_json(editor_json, main: LDMain, fmt_ver: SemVer):
	var Camera = main.get_node("Camera")
	Camera.position = _str_to_vec2(editor_json.last_camera_pos)


## Removes properties which are set to their default values, returning
## only the properties with changed values.
func _only_modified_props(instance: Dictionary, main: LDMain, item_id: StringName):
	# Fetch this item's property metadata.
	var prop_meta = main.items[item_id].properties
	
	var not_default = {}
	for propname: String in instance.keys():
		var prop_default = _decode_value_of_type(
			main.default_of_property(prop_meta[propname]), prop_meta[propname].type)
		# If the property is NOT its default value, add it to the output dict.
		if instance[propname] != prop_default:
			not_default[propname] = instance[propname]
	
	return not_default


func _decode_value_of_type(value, type: String):
	if value is String:
		# Try and convert the string to the requested type.
		match type:
			"Vector2":
				return _str_to_vec2(value)
			"String":
				# It's a string already, silly. No need to convert.
				return value
			_:
				return str_to_var(value)
	else:
		return value


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
	if "Vector2(" in str:
		return str_to_var(str)
	elif "(" in str:
		var new_str = str
		new_str = new_str.erase(0, 1)
		new_str = new_str.erase(new_str.length() -1, 1)
		var array = new_str.split(", ")
		return Vector2(int(array[0]), int(array[1]))
	return Vector2.ZERO
