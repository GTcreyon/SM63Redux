extends Node2D

onready var open = $"/root/Main/UILayer/OpenDialog"
onready var sm63_to_redux: SM63ToRedux = Singleton.sm63_to_redux
onready var ld_ui = $UILayer/LDUI
onready var ld_camera = $Camera
onready var lv_template := preload("res://level_designer/template.tscn")

const TERRAIN_PREFAB = preload("res://actors/terrain/terrain_polygon.tscn")
const ITEM_PREFAB = preload("res://actors/items/ld_item.tscn")

signal selection_changed #only gets called when the hash changed
signal selection_event #gets fired always whenever some calculation regarding events is done
signal selection_size_changed #gets fired whenever the selection rect changes

var item_classes = {}
var items = []
var item_textures = []
var item_scenes = []
var in_level = false
var start_pos

var selection = {
	active = [], #a list of all selected items
	head = null, #the main selected item
	
	hit = [], #the array of all hit items on the last selection call
	head_idx = 0, #the index of the head in the hit array
}

var selection_begin
var selection_rect = Rect2()

var last_local_mouse_position = Vector2()

func is_selected(item):
	for selected in selection.hit:
		if selected == item:
			return true
	return false

func snap_vector(vec, grid = 8):
	return Vector2(
		floor(vec.x / grid + 0.5) * grid,
		floor(vec.y / grid + 0.5) * grid
	)


func place_terrain(poly, texture_type, textures):
	var terrain_ref = TERRAIN_PREFAB.instance()
	terrain_ref.polygon = poly
	$Template/Terrain.add_child(terrain_ref)
	return terrain_ref


func place_item(item_id: int):
	var inst = ITEM_PREFAB.instance()
	inst.ghost = true
	inst.texture = load(item_textures[item_id]["Placed"])
	inst.item_id = item_id
	var properties: Dictionary = items[item_id].properties
	var item_properties: Dictionary = {}
	for key in properties:
		if properties[key]["default"] == null:
			item_properties[key] = default_of_type(properties[key]["type"])
		else:
			item_properties[key] = str2var(properties[key]["default"])
	inst.properties = item_properties
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
	var item_ref = ITEM_PREFAB.instance()
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
			var pool = PoolVector2Array()
			for vec in poly:
				pool.append(vec * 32 - Vector2(48, 48))
			place_terrain(pool, data.texture_type, data.textures)
	
	for item in lv_data.items:
		place_item(item)

func read_items():
	var parser = XMLParser.new()
	parser.open("res://level_designer/items.xml.tres")
	
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
				#interpret classes
				if parent_name == "class":
					match node_name:
						"property":
							register_property(item_classes, parent_subname, parent_name, parser)
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
					parent_name = node_name
			parser.NODE_ELEMENT_END:
				var node_name = parser.get_node_name()
				if node_name == "class" || node_name == "item":
					allow_reparent = true
	#print(item_classes)
	#print(items)
	#print(item_textures)

func register_property(target, subname: String, type: String, parser: XMLParser):
	var item_class_properties
	if type == "item":
		item_class_properties = target[int(subname)].properties
	else:
		item_class_properties = target[subname]
	var var_txt = parser.get_named_attribute_value_safe("var")
	var default = parser.get_named_attribute_value_safe("default")
	var properties = {
		type = parser.get_named_attribute_value("type"),
		var_name = null if var_txt == "" else var_txt,
		default = null if default == "" else default,
		description = parser.get_named_attribute_value("description")
	}
	item_class_properties[parser.get_named_attribute_value("label")] = properties


func inherit_class(target, subname: String, type: String, parser: XMLParser):
	var item_class_properties
	if type == "item":
		item_class_properties = target[int(subname)].properties
	else:
		item_class_properties = target[subname]
	var parent_class = item_classes[parser.get_named_attribute_value("name")]
	for key in parent_class:
		item_class_properties[key] = parent_class[key]


func _ready():
	var template = lv_template.instance()
	add_child(template)
	read_items()
	ld_ui.fill_grid()
	var serializer = LevelBuffer.new()
	serializer.run_tests(false)
	
	if Singleton.ld_buffer != PoolByteArray([]):
		serializer.load_buffer(Singleton.ld_buffer, self)
		Singleton.ld_buffer = PoolByteArray([])

func retain_order_by_hash(a, b):
	return hash(a) < hash(b)

func _process(_dt):
	if selection_begin != null:
		var global_mouse_pos = snap_vector(ld_camera.global_position + last_local_mouse_position)
		var min_vec = Vector2(min(selection_begin.x, global_mouse_pos.x), min(selection_begin.y, global_mouse_pos.y))
		var max_vec = Vector2(max(selection_begin.x, global_mouse_pos.x), max(selection_begin.y, global_mouse_pos.y))
		var new = Rect2(min_vec, max_vec - min_vec)
		if !selection_rect.is_equal_approx(new):
			selection_rect = new
			emit_signal("selection_size_changed", selection_rect)
	
	if Input.is_action_just_pressed("LD_exit"): # return to designer
		if in_level:
			in_level = false
			get_tree().change_scene("res://level_designer/level_designer.tscn")

func _input(event):
	if event is InputEventMouse:
		last_local_mouse_position = event.position

func _unhandled_input(event: InputEvent):
	if weakref(ld_camera).get_ref(): # avoid handling input if the ld camera doesn't exist
		handle_mouse_input(event)


func handle_mouse_input(event):
	var global_mouse_pos = ld_camera.global_position + last_local_mouse_position
	
	#key press cycle
	if event.is_action_pressed("LD_queue+") && len(selection.active) == 1 && len(selection.hit) != 1:
		selection.head_idx = (selection.head_idx + 1) % len(selection.hit)
		selection.head = selection.hit[selection.head_idx]
		selection.active = [selection.head]
		emit_signal("selection_changed", selection)
		emit_signal("selection_event", selection)
	
	if event.is_action_pressed("LD_queue-") && len(selection.active) == 1 && len(selection.hit) != 1:
		selection.head_idx = (selection.head_idx - 1) % len(selection.hit)
		selection.head = selection.hit[selection.head_idx]
		selection.active = [selection.head]
		emit_signal("selection_changed", selection)
		emit_signal("selection_event", selection)
	
	#enable rectangle-select
	if event.is_action_pressed("LD_select"):
		selection_begin = global_mouse_pos
	
	#main selection
	if event.is_action_released("LD_select"):
		#end the rectangle select
		selection_begin = null
		var list = []
		
		#rectangle selection must be bigger than 8px, otherwise we assume it's just a simple click
		if (selection_rect.size.length() > 8):
			#welcome to this horrible boilerplate rectangle collision detection!
			var shape = RectangleShape2D.new()
			shape.set_extents(selection_rect.size / 2) #extends is both ways, hence / 2
			var query = Physics2DShapeQueryParameters.new()
			query.collide_with_areas = true
			query.collide_with_bodies = true
			query.set_shape(shape)
			query.transform = Transform2D(0, selection_rect.position + selection_rect.size / 2) #this is the center
			list = get_world_2d().direct_space_state.intersect_shape(query, 32)
		else:
			list = get_world_2d().direct_space_state.intersect_point(global_mouse_pos, 32, [], 0x7FFFFFFF, true, true)
		
		#convert from raw hitboxes to the actual items
		var hit = []
		for selected in list:
			selected = selected.collider
			#find the top most parent of the collider
			#this isn't guaranteed to be just get_parent() as the collider can be nested in several children
			while selected.get_parent():
				selected = selected.get_parent()
				var parent_name = selected.get_parent().name
				if parent_name == "Items" || parent_name == "Terrain" || parent_name == "Water" || parent_name == "CameraLimits":
					hit.append(selected)
					break
		
		#a slow, possibly bad idea, but unless someone stacked like a thousand items under eachother it should be fine
		#we do this so we are sure items are always ordered in the same way
		#this is required so we can reliably switch between items on the queue
		
		#NOTE: change this so it orders by the X, then the Y of the object
		hit.sort_custom(self, "retain_order_by_hash")
		
		selection.hit = hit
		#make sure we don't try to select something in a null table
		if len(selection.hit) == 0:
			var old_hash = selection.hash()
			selection.head_idx = 0
			selection.head = null
			selection.active = []
			if selection.hash() != old_hash:
				#our selection changed, fire selection changed
				emit_signal("selection_changed", selection)
		else:
			var old_hash = selection.hash()
			selection.head_idx = selection.head_idx % len(selection.hit)
			selection.head = selection.hit[selection.head_idx]
			selection.active = hit if selection_rect.size.length() > 8 else [selection.head]
			
			#for the cycle
			selection.head_idx = (selection.head_idx + 1) % len(selection.hit)
			if selection.hash() != old_hash:
				#our selection changed, fire selection changed
				emit_signal("selection_changed", selection)
		emit_signal("selection_event", selection)
		
		#change the selected area to the smallest bounding box of the newly selected items
		if len(selection.active) > 0:
			var min_vec = Vector2.INF
			var max_vec = -Vector2.INF
			for item in selection.active:
				var vectors = []
				#item have a rect, all other types have a polygon
				if item.get_parent().name == "Items":
					vectors = [
						item.position - item.texture.get_size() / 2,
						item.position + item.texture.get_size() / 2
					]
				else:
					vectors = item.polygon

				for vec in vectors:
					min_vec.x = min(vec.x, min_vec.x)
					min_vec.y = min(vec.y, min_vec.y)
					max_vec.x = max(vec.x, max_vec.x)
					max_vec.y = max(vec.y, max_vec.y)
			
			selection_rect = Rect2(min_vec, max_vec - min_vec)
			emit_signal("selection_size_changed", selection_rect)
