class_name LDMain
extends Node2D
## Manages operations within the Level Designer.
##
## The Main node within the Level Designer has four duties:
## load and parse item definitions for the rest of the designer to use;
## control access to the node tree into which items are added;
## control access to serialization;
## and snap vectors (and the mouse cursor) to the grid.

## Emitted when [member editor_state] is changed.
signal editor_state_changed

const TERRAIN_PREFAB = preload("res://classes/solid/terrain/terrain_polygon.tscn")
const ITEM_PREFAB = preload("res://scenes/menus/level_designer/ld_item/ld_item.tscn")

enum EDITOR_STATE { IDLE, PLACING, SELECTING, DRAGGING, POLYGON_CREATE, POLYGON_EDIT }

## Definitions for base classes that items can implement.
var item_classes = {}
var item_static_properties = {}
## Definitions for each type of item that can be placed.
## Each entry is a dictionary with the following properties:[br]
## - [b]"name":[/b] This item's displayed name.[br]
## - [b]"properties":[/b] A dictionary of the item's editable properties.
##		TODO: This is never actually written, so its format is unclear.
var items: Array[Dictionary] = []
## Graphics for items to use.
## Each entry is a dictionary with the following properties:[br]
## - [b]List:[/b] This item's icon in the placeable-item list.[br]
## - [b]Placed:[/b] The sprite shown where this item is placed in the actual level.[br]
var item_textures: Array[Dictionary] = []
## The scenes corresponding to each item. These can be used to create
## a playable node tree based on the [LDPlacedItem]s in the level.
var item_scenes = []

## Set to [code]true[/code] to enable returning to the level designer
## when [kbd]ld_exit[/kbd] is pressed.
var in_level = false

## The current state (mode) the level editor interface is in.
## Emits [signal editor_state_changed] when changed.
var editor_state: EDITOR_STATE = EDITOR_STATE.IDLE: set = _set_editor_state

## The open-level dialog window.
@onready var open = $"/root/Main/UILayer/OpenDialog"
## Parser that converts original SM63 levels into a Redux-compatible format.
@onready var sm63_to_redux = SM63ToRedux.new()
## The node tree template which level items shall be added to.
@onready var lv_template := preload("./template.tscn")
@onready var ld_camera: Camera2D = $Camera


func _ready():
	var template = lv_template.instantiate()
	add_child(template)
	_read_items()
	var serializer = Serializer.new()
	serializer.run_tests(true)
	
	if Singleton.ld_buffer != PackedByteArray([]):
		serializer.load_level_binary(Singleton.ld_buffer, self)
		Singleton.ld_buffer = PackedByteArray([])


func _process(_dt):
	if Input.is_action_just_pressed("ld_exit"): # Return to designer
		if in_level:
			in_level = false
			get_tree().change_scene_to_file("res://scenes/menus/level_designer/level_designer.tscn")


# Sets the state of the editor.
func _set_editor_state(new: EDITOR_STATE):
	var old = editor_state
	editor_state = new
	emit_signal("editor_state_changed", old, editor_state)


## Gets the currently edited level node tree.
func get_level() -> Node2D:
	return $"/root/Main/Template"


#func is_selected(item):
#	for selected in selection.hit:
#		if selected == item:
#			return true
#	return false


## Snaps a vector to a grid.
## If the input action [kbd]ld_precise[/kbd] is down, grid cells will be
## 1 unit square; otherwise, grid cells will be [param grid]
## units wide.
func snap_vector(vec, grid = 8) -> Vector2:
	if Input.is_action_pressed("ld_precise"):
		grid = 1
	
	return Vector2(
		floor(vec.x / grid + 0.5) * grid,
		floor(vec.y / grid + 0.5) * grid
	)


## Returns the mouse's current position, snapped to the default grid
## (as described in [method snap_vector]).
func get_snapped_mouse_position() -> Vector2:
	return snap_vector(get_global_mouse_position())


## Creates and returns a new terrain lump from the given polygon [param poly].
func place_terrain(poly: PackedVector2Array) -> TerrainPolygon:
	var terrain_ref = TERRAIN_PREFAB.instantiate()
	terrain_ref.polygon = poly
	$Template/Terrain.add_child(terrain_ref)
	return terrain_ref


## Creates and returns a new level-designer item, configured as appropriate
## for ID [param item_id].
## The new item will begin with [member LDPlacedItem.ghost] set to
## [code]true[/code].
func place_item(item_id: int) -> LDPlacedItem:
	_set_editor_state(EDITOR_STATE.PLACING)
	
	# Create and populate loaded item
	var inst = ITEM_PREFAB.instantiate()
	inst.ghost = true
	inst.texture = load(item_textures[item_id]["Placed"])
	inst.item_id = item_id
	
	# Read in this item type's properties
	var properties: Dictionary = items[item_id].properties
	var item_properties: Dictionary = {}
	for propname in properties:
		if properties[propname]["default"] == null:
			item_properties[propname] = default_of_type(properties[propname]["type"])
		else:
			item_properties[propname] = str_to_var(properties[propname]["default"])
	inst.properties = item_properties
	
	# Add item to scene
	$Template/Items.add_child(inst)
	return inst


## Returns a reasonable default value for the type [param type].
func default_of_type(type):
	match type:
		"bool":
			return false
		"uint", "sint":
			return 0
		"float":
			return 0.0
		"Vector2":
			return Vector2.ZERO


func _old_place_item(item):
	var item_ref = ITEM_PREFAB.instantiate()
	item_ref.set("id", item.id)
	item_ref.set("data", item.data)
	item_ref.position = item.pos
	$Template/Items.add_child(item_ref)
	return item_ref


func _disabled_draw():
	var demo_level = "50x30~0*5*2K0*3*2K02K02K*2*0*3*2K*2*02K02K02K02K*2*2M02K*5*0*6*2K*2*02K02K*2*02K02K02K02K02K2M2K0*3*2K0*7*2K0*3*2K*2*0*10*2K2M2K0*4*2K*4*0*3*2K0*15*2K2M0*2*2K02K*2*0*2*2K*2*0*3*2K*3*02K*2*0*7*2K*6*0*2*2K*2*0*2*2K*3*02K*3*0*3*2K0*2*2K*3*02K02K*5*0*2*2K0*3*2K02K*2*02K0*5*2K*3*02K*3*0*2*2K*2*02K0*2*2K0*3*2K02K0*8*2K*2*0*3*2K*2*0*2*2K*2*0*24*2K*2*02K*4*0*2*2K*2*0*3*2K0*5*2K0*3*2K0*2*2K0*2*2K02K*3*2M2K02K0*2*2K0*3*2K02K*3*0*2*2K*2*0*2*2K02K02K02K02K2M2K*3*0*2*2K*2*0*4*2K*3*0*2*2K02K02K02K02K0*3*2K2M02K*2*0*9*2K02K02K02K*3*0*2*2K0*4*2K2M0*4*2K0*5*2K*2*0*2*2K*2*0*3*2K0*8*2K2M0*2*2K02K*2*0*7*2K0*14*2K2M02K*5*0*2*2K*2*0*3*2K*2*0*3*2K0*2*2K*3*02K*2*02K2M2K*4*0*2*2K02K02K02K*3*0*2*2K*2*0*2*2K02K02K*7*02K0*2*2K*3*0*3*2K02K0*2*2K*3*02K02K02K02K*3*0*6*2K0*3*2K*3*02K02K*2*02K*3*0*2*2K0*3*2K2M0*11*2K*2*0*2*2K*6*0*3*2K0*3*2K2M0*11*2K0*3*2K*2*0*3*2K0*7*2K2M2K*2*0*18*2K0*6*2K*2*2M2K*3*0*2*2K*2*0*5*2K0*4*2K0*2*2K*2*02K*2*0*2*2K*2*2M0*2*2K02K*3*0*2*2K*2*02K*3*0*2*2K*2*02K02K*2*02K*2*02K2M0*3*2K*2*0*4*2K*2*02K02K02K02K02K02K*2*02K*2*02K2M0*3*2K*2*0*2*2K0*3*2K0*3*2K*2*02K*3*02K*2*02K*2*02K*2*0*8*2K0*6*2K0*3*2K*2*0*2*2K0*4*2K2M02K0*26*2K2M2K02K0*11*2K0*3*2K*2*0*8*2K2M2K02K02K*2*0*7*2K*5*02K02K*3*0*4*2K2M2K02K02K*3*0*2*2K*2*0*2*2K02K*3*02K02K02K0*2*2K02K*2*0*2*2K*3*02K0*2*2K0*3*2K02K*3*0*2*2K*2*0*2*2K*2*02K*2*2M0*3*2K*2*02K0*4*2K02K0*2*2K0*3*2K*2*0*3*2K02K*2*2M0*12*2K0*11*2K*2*02K*2*2M0*7*2K*2*0*6*2K0*3*2K0*4*2K*7*0*13*2K*2*0*5*2K*2*02K02K*5*0*13*2K*2*0*2*2K*2*02K*2*02K02K*3*2M2K*5*0*2*2K0*2*2K*2*0*2*2K02K*4*02K*2*02K02K*3*2M02K*2*02K02K0*2*2K02K*2*02K02K*2*02K02K02K0*4*2K2M02K*2*0*2*2K*2*0*2*2K0*2*2K*3*02K*2*0*2*2K0*7*2K2M0*5*2K0*10*2K0*11*2K2M0*16*2K*2*0*3*2K0*6*2K*3*0*3*2K0*6*2K*3*02K02K0*2*2K*2*0*2*2K*2*0*2*2K*3*0*2*2K*3*0*3*2K*3*02K02K02K*2*02K02K02K02K02K*2*02K02K0*5*2K*2*0*2*2K*3*0*2*2K*3*02K02K02K*3*2M2K*3*0*3*2K0*7*2K*2*0*6*2K*2*02K*4*2M2K*3*02K*2*0*17*2K*2*02K02K*5*0*2*2K*2*02K*2*0*7*2K0*2*2K*2*0*2*2K02K*4*0*6*2K*5*02K*3*02K02K02K02K02K0*2*2K*2*2M0*2*2K*2*0*3*2K0*2*2K02K02K02K02K*2*0*2*2K*3*0*3*2K2M~1,64,832,0,0,Right~1~1~My Level"
	demo_level = "50x30~0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*24*2W2Y*3*2K2M0*24*2a3d*3*2K2M0*24*2K3d3m*2*2K2M0*24*2b3d*3*2K2M0*24*2X2Z*3*2K2M0*28*2K2M0*21*4K04K*3*0*2*2K2M0*21*4K0*3*4K0*2*2K2M0*21*4K*5*0*2*2K2M0*21*4K0*6*2K2M0*21*4K0*6*2K2M0*28*2K2M0*21*4K*5*0*2*2K2M0*21*4K0*3*4K0*2*2K2M0*21*4K*5*0*2*2K2M0*28*2K2M0*21*4K*5*0*2*2K2M0*21*4K04K04K0*2*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M~1,64,832,0,0,Right~1~1~My%20Level"
	var lv_data = sm63_to_redux.deserialize(demo_level)
	
	for data in lv_data.polygon_data:
		for poly in data.polygons:
			var pool = PackedVector2Array()
			for vec in poly:
				pool.append(vec * 32 - Vector2(48, 48))
#			place_terrain(pool, data.texture_type, data.textures)
	
	for item in lv_data.items:
		place_item(item)


## Loads the item archetypes defined in the item dictionary (found in
## [code]res://scenes/menus/level_designer/items.xml.tres[/code]), so that
## later parts of the level designer can access them.[br]
## All told, the following variables are written:[br]
## - [member items][br]
## - [member item_scenes][br]
## - [member item_textures][br]
## - [member item_classes][br]
## - [member item_static_properties][br]
func _read_items():
	# TODO: JSON is easier (faster) for both humans and computers to read.
	# Consider using that instead?
	# Or maybe just use a resource file? (Can those be made and saved
	# at runtime?)
	var parser = XMLParser.new()
	# TODO: Storing raw XML as a .tres file causes warnings on editor startup.
	parser.open("res://scenes/menus/level_designer/items.xml.tres")
	
	var parent_name
	var parent_subname
	var allow_reparent: bool = true
	# While there's XML nodes left to read, read them and parse them.
	while (!parser.read()):
		var node_type = parser.get_node_type()
		match node_type:
			# Unused nodes
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
			
			# Useful nodes
			parser.NODE_ELEMENT:
				var node_name = parser.get_node_name()
				if parent_name == "class":
					# Parent node is a class. Parse children of a class.
					
					# This doesn't actually do anything. None of these functions
					# return anything or have any side effects.
					# Other than possibly modifying the parser's internal state,
					# which shouldn't happen with normal attribute reads I think.
					match node_name:
						"property":
							register_property(item_classes, parent_subname, parent_name, parser)
						"implement":
							implement_property(item_classes, parent_subname, parent_name, parser)
						"inherit":
							inherit_class(item_classes, parent_subname, parent_name, parser)
					pass
				elif parent_name == "item":
					# Parent node is an item. Parse children of an item.
					match node_name:
						"scene":
							# Save the filepath of the described item's scene.
							var path = parser.get_named_attribute_value_safe("path")
							var item_id = int(parent_subname)
							if item_scenes.size() < item_id + 1:
								item_scenes.resize(item_id + 1)
							item_scenes[item_id] = path
						"property":
							# Does nothing.
							register_property(items, parent_subname, parent_name, parser)
						"texture":
							# Save the filepaths of the described item's
							# placed and in-list graphics.
							
							var item_id = int(parent_subname)
							
							# Item textures dictionary should have been initted
							# when the item was first read in. Assert that.
							assert(not item_textures[item_id].is_empty(),
								"Item %s \"%s\" has no initialized texture dictionary!" % [item_id, items[item_id].name])
							
							var path = parser.get_named_attribute_value_safe("path")
							item_textures[item_id][parser.get_named_attribute_value_safe("tag")] = path
						"implement":
							# Currently does nothing.
							implement_property(items, parent_subname, parent_name, parser)
						"inherit":
							# Currently does nothing.
							inherit_class(items, parent_subname, parent_name, parser)
				
				# Parse object root nodes.
				if allow_reparent:
					# Reparent the node if needed.
					if node_name == "class":
						var subname = parser.get_named_attribute_value_safe("name")
						# Add this subname to class dictionary
						item_classes[subname] = {}
						
						# Save class name as next node's parent subname.
						parent_subname = subname
						allow_reparent = false
					elif node_name == "item":
						# Read item ID
						var subname = parser.get_named_attribute_value_safe("id")
						var item_id = int(subname)
						# Ensure the array can fit item_id as an index.
						if items.size() < item_id + 1:
							items.resize(item_id + 1)
							item_textures.resize(item_id + 1)
						# Add this item to the list.
						items[item_id] = {
							name = parser.get_named_attribute_value_safe("name"),
							properties = {},
						}
						# Initialize item's texture dictionary.
						item_textures[item_id] = {"Placed": null, "List": null}
						
						# Save ID as next node's parent subname.
						parent_subname = subname
						allow_reparent = false
					elif node_name == "static":
						# Load name and properties, simple as that.
						var prop_name = parser.get_named_attribute_value_safe("label")
						item_static_properties[prop_name] = collect_property_values(parser)
						
						# Idk if allow_reparent should be added, don't think so since it's a single tag
					
					# Save this node's name for the next node to use.
					parent_name = node_name
			parser.NODE_ELEMENT_END:
				# Reset allow_reparent for the next XML element.
				var node_name = parser.get_node_name()
				if node_name == "class" or node_name == "item":
					allow_reparent = true


## Returns:
## - Nothing? item_class_properties is declared in-function, never returned....
func register_property(target, subname: String, type: String, parser: XMLParser):
	var item_class_properties
	
	if type == "item":
		item_class_properties = target[int(subname)].properties
	else:
		item_class_properties = target[subname]
	
	item_class_properties[parser.get_named_attribute_value("label")] = collect_property_values(parser)


## Returns:
## Nothing? item_class_properties is declared in-function, never returned....
func implement_property(target, subname: String, type: String, parser: XMLParser):
	var item_class_properties
	
	if type == "item":
		item_class_properties = target[int(subname)].properties
	else:
		item_class_properties = target[subname]
	
	var prop_name = parser.get_named_attribute_value("label")
	var get_prop = parser.get_named_attribute_value("name")
	# NOTE: should we dupe this?
	item_class_properties[prop_name] = item_static_properties[get_prop].duplicate()


## Parses attributes from a single XML node into a dictionary.
func collect_property_values(parser: XMLParser) -> Dictionary:
	var var_txt = parser.get_named_attribute_value_safe("var")
	var default = parser.get_named_attribute_value_safe("default")
	var increment = parser.get_named_attribute_value_safe("increment")
	
	var properties = {
		type = parser.get_named_attribute_value("type"),
		var_name = null if var_txt == "" else var_txt,
		default = null if default == "" else default,
		increment = 1 if increment == "" else increment,
		description = parser.get_named_attribute_value("description")
	}
	
	return properties


## Returns:
## Nothing? item_class_properties is declared in-function, never returned....
func inherit_class(target, subname: String, type: String, parser: XMLParser):
	var item_class_properties
	
	if type == "item":
		item_class_properties = target[int(subname)].properties
	else:
		item_class_properties = target[subname]
	
	var parent_class = item_classes[parser.get_named_attribute_value("name")]
	for key in parent_class:
		item_class_properties[key] = parent_class[key]
