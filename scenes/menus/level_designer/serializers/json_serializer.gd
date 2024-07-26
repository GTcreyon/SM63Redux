class_name JSONSerializer
extends Node

const LD_TEMPLATE = preload("res://scenes/menus/level_designer/template.tscn")
const LD_ITEM = preload("res://scenes/menus/level_designer/ld_item/ld_item.tscn")
const POLYGON_PREFABS = {
	"Terrain": preload("res://classes/solid/terrain/terrain_polygon.tscn"),
	"Water": preload("res://classes/water/water.tscn"),
	"CameraLimits": preload("res://classes/zone/camera_area/camera_area.tscn")
}


## Generates a JSON representation of the level.
func generate_level_json(main: LDMain, level: Node2D) -> String:
	main.save_level_started.emit()
	
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
	save_json.items = _generate_items_json(main, level)
	# All polygons loaded
	save_json.polygons = _generate_polygons_json(level)
	
	main.save_level_finished.emit()
	
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
	var new_level = LD_TEMPLATE.instantiate()
	
	# Load the items from the JSON file.
	var new_items = _load_items_json(file_json.items, main, fmt_ver)
	# Error code handling goes here....
	# Items loaded successfully. Add to new-level tree.
	var item_tree = new_level.get_node("Items")
	for item in new_items:
		item_tree.add_child(item)
	
	# Load the polygons in similar fashion.
	for poly_type: String in POLYGON_PREFABS.keys():
		# VALIDATE: Does this JSON file have a dictionary of this type of
		# polygon?
		var poly_type_snakecase = poly_type.to_snake_case()
		if not file_json.polygons.has(poly_type_snakecase):
			# Not a deal breaker. Just skip to the next dictionary.
			print("No section for ", poly_type, " polygons found")
			continue
		
		# Load polygons of this type, if any.
		var polygons = _load_polygons_json(
			file_json.polygons[poly_type_snakecase], POLYGON_PREFABS[poly_type],
			fmt_ver, poly_type)
		
		# Error code handling goes here....
		
		# Polygons loaded successfully. Get the type's root and add them
		# to the tree.
		# NOTE: This will crash if template.tscn doesn't have the needed
		# root. That's intentional. Better to see a blaring warning so we know
		# to fix something (e.g. add versioning code) than to brush it under
		# the rug so nobody ever knows there's a problem.
		var poly_type_parent = new_level.get_node(poly_type)
		for polygon in polygons:
			poly_type_parent.add_child(polygon)
	
	# TODO: Add the rest of the template's node tree to avoid future errors.
	
	# If we didn't hit any errors during loading, the new level is correctly
	# enough loaded to be displayed.
	# Emit signal saying so.
	main.loaded_level_ready.emit(new_level)
	# Swap the trees.
	var old_level = main.get_node("Template")
	main.remove_child(old_level)
	main.add_child(new_level)
	
	# If there's any errors, this is the user's last chance to abort.
	# Emit a signal saying so.
	# Manual error resolution goes here.
	main.loaded_level_shown.emit()
	
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


func _generate_polygons_json(level: Node) -> Dictionary:
	var terrain_polygons = level.get_node("Terrain").get_children()
	var water_polygons = level.get_node("Water").get_children()

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


func _load_items_json(items_json: Dictionary, main: LDMain, _fmt_ver: SemVer):
	var new_items = []
	
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
			
			new_items.append(inst)
	
	return new_items


## Load polygons of a specific type
func _load_polygons_json(
	instances_json, prefab: PackedScene, _fmt_ver: SemVer,
	debug_name: String) -> Array[Node2D]:
	var polygons: Array[Node2D] = []
	
	for loaded_poly: Dictionary in instances_json:
		# Skip malformed polygons with too few verts.
		if loaded_poly.vertices.size() < 3:
			push_warning("Found ", debug_name, " with too few verts: ", loaded_poly)
			continue
		
		# Duplicate the correct polygon instance for the type.
		var inst: Polygon2D = prefab.instantiate()

		inst.position = _str_to_vec2(loaded_poly.position)
		# inst.properties = polygon.properties

		# Load the deserialized verts into the instance node.
		var new_polygon_vertices := PackedVector2Array()
		for vertex in loaded_poly.vertices:
			# Convert the deserialized string into a valid Vector2.
			new_polygon_vertices.append(_str_to_vec2(vertex))
		inst.polygon = new_polygon_vertices
		
		# Add the instance to the type's parent.
		polygons.append(inst)
	
	return polygons


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
