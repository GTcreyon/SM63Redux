extends Node2D

onready var singleton = $"/root/Singleton"
onready var sm63_to_redux: SM63ToRedux = singleton.sm63_to_redux

const ld_item = preload("res://actors/items/ld_item.tscn")
const terrain_prefab = preload("res://actors/terrain/terrain_polygon.tscn")
const item_prefab = preload("res://actors/items/ld_item.tscn")

export(Dictionary) var item_classes = {}
export(Dictionary) var items = {}
export(Dictionary) var item_textures = {}

var start_pos

func place_terrain(poly, texture_type, textures):
	var terrain_ref = terrain_prefab.instance()
	terrain_ref.polygon = poly
	$Template/Terrain.add_child(terrain_ref)
	return terrain_ref

func place_item(path):
	var inst = ld_item.instance()
	inst.ghost = true
	inst.texture = load(path)
	$Template/Items.add_child(inst)
	return inst

func _old_place_item(item):
	var item_ref = item_prefab.instance()
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

func _ready():
	read_items()
