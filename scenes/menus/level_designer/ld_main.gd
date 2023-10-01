extends Node2D

signal editor_state_changed

const TERRAIN_PREFAB = preload("res://classes/solid/terrain/terrain_polygon.tscn")
const ITEM_PREFAB = preload("res://classes/ld_item/ld_item.tscn")

enum EDITOR_STATE { IDLE, PLACING, SELECTING, DRAGGING, POLYGON_CREATE, POLYGON_EDIT }

var item_classes = {}
var item_static_properties = {}
var items = []
var item_textures = []
var item_scenes = []
var in_level = false

var editor_state = EDITOR_STATE.IDLE: set = set_editor_state

@onready var open = $"/root/Main/UILayer/OpenDialog"
@onready var sm63_to_redux = SM63ToRedux.new()
@onready var lv_template := preload("./template.tscn")
@onready var ld_ui = $UILayer/LDUI
@onready var ld_camera = $Camera


func _ready():
	var template = lv_template.instantiate()
	add_child(template)
	read_items()
	ld_ui.fill_grid()
	var serializer = Serializer.new()
	serializer.run_tests(false)
	
	if Singleton.ld_buffer != PackedByteArray([]):
		serializer.load_buffer(Singleton.ld_buffer, self)
		Singleton.ld_buffer = PackedByteArray([])


func _process(_dt):
	if Input.is_action_just_pressed("ld_exit"): # Return to designer
		if in_level:
			in_level = false
			get_tree().change_scene_to_file("res://scenes/menus/level_designer/level_designer.tscn")


# Set the state of the editor
func set_editor_state(new):
	var old = editor_state
	editor_state = new
	emit_signal("editor_state_changed", old, editor_state)


# Retrieve the current level in the editor
func get_level():
	return $"/root/Main/Template"


#func is_selected(item):
#	for selected in selection.hit:
#		if selected == item:
#			return true
#	return false


func snap_vector(vec, grid = 8):
	if Input.is_action_pressed("ld_precise"):
		grid = 1
	
	return Vector2(
		floor(vec.x / grid + 0.5) * grid,
		floor(vec.y / grid + 0.5) * grid
	)


func get_snapped_mouse_position():
	return snap_vector(get_global_mouse_position())


func place_terrain(poly):
	var terrain_ref = TERRAIN_PREFAB.instantiate()
	terrain_ref.polygon = poly
	$Template/Terrain.add_child(terrain_ref)
	return terrain_ref


func place_item(item_id: int):
	set_editor_state(EDITOR_STATE.PLACING)
	
	# Create and populate loaded item
	var inst = ITEM_PREFAB.instantiate()
	inst.ghost = true
	inst.texture = load(item_textures[item_id]["Placed"])
	inst.item_id = item_id
	
	# Read in this item type's properties
	var properties: Dictionary = items[item_id].properties
	var item_properties: Dictionary = {}
	for key in properties:
		if properties[key]["default"] == null:
			item_properties[key] = default_of_type(properties[key]["type"])
		else:
			item_properties[key] = str_to_var(properties[key]["default"])
	inst.properties = item_properties
	
	# Add item to scene
	$Template/Items.add_child(inst)
	return inst


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


func read_items():
	var parser = XMLParser.new()
	parser.open("res://scenes/menus/level_designer/items.xml.tres")
	
	var parent_name
	var parent_subname
	var allow_reparent: bool = true
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
				# Interpret classes
				if parent_name == "class":
					match node_name:
						"property":
							register_property(item_classes, parent_subname, parent_name, parser)
						"implement":
							implement_property(item_classes, parent_subname, parent_name, parser)
						"inherit":
							inherit_class(item_classes, parent_subname, parent_name, parser)
				elif parent_name == "item":
					match node_name:
						"scene":
							var path = parser.get_named_attribute_value_safe("path")
							var item_id = int(parent_subname)
							if item_scenes.size() < item_id + 1:
								item_scenes.resize(item_id + 1)
							item_scenes[item_id] = path
						"property":
							register_property(items, parent_subname, parent_name, parser)
						"texture":
							var item_id = int(parent_subname)
							if item_textures.size() < item_id + 1:
								item_textures.resize(item_id + 1)
							if item_textures[item_id] == null:
								item_textures[item_id] = {"Placed": null, "List": null}
							var path = parser.get_named_attribute_value_safe("path")
							item_textures[item_id][parser.get_named_attribute_value_safe("tag")] = path
						"implement":
							implement_property(items, parent_subname, parent_name, parser)
						"inherit":
							inherit_class(items, parent_subname, parent_name, parser)
				
				if allow_reparent:
					if node_name == "class":
						var subname = parser.get_named_attribute_value_safe("name")
						parent_subname = subname
						item_classes[subname] = {}
						allow_reparent = false
					elif node_name == "item":
						var subname = parser.get_named_attribute_value_safe("id")
						parent_subname = subname
						var item_id = int(subname)
						if items.size() < item_id + 1:
							items.resize(item_id + 1)
						items[item_id] = {
							name = parser.get_named_attribute_value_safe("name"),
							properties = {},
						}
						allow_reparent = false
					elif node_name == "static":
						var prop_name = parser.get_named_attribute_value_safe("label")
						item_static_properties[prop_name] = collect_property_values(parser)
						# Idk if allow_reparent should be added, don't think so since it's a single tag
					parent_name = node_name
			parser.NODE_ELEMENT_END:
				var node_name = parser.get_node_name()
				if node_name == "class" or node_name == "item":
					allow_reparent = true


func register_property(target, subname: String, type: String, parser: XMLParser):
	var item_class_properties
	if type == "item":
		item_class_properties = target[int(subname)].properties
	else:
		item_class_properties = target[subname]
	item_class_properties[parser.get_named_attribute_value("label")] = collect_property_values(parser)


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


func collect_property_values(parser: XMLParser):
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


func inherit_class(target, subname: String, type: String, parser: XMLParser):
	var item_class_properties
	if type == "item":
		item_class_properties = target[int(subname)].properties
	else:
		item_class_properties = target[subname]
	var parent_class = item_classes[parser.get_named_attribute_value("name")]
	for key in parent_class:
		item_class_properties[key] = parent_class[key]
