extends Node2D

onready var singleton = $"/root/Singleton"
onready var serializer: Serializer = singleton.serializer

const item_prefab = preload("res://actors/items/ld_item.tscn")

func place_item(item):
	var item_ref = item_prefab.instance()
	item_ref.set("id", item.id)
	item_ref.set("data", item.data)
	item_ref.position = item.pos
	add_child(item_ref)

func _ready():
	var demo_level = "25x25~0*78*2M*2*0*2*2M*3*0*17*2M*4*02M*4*0*17*2M*6*0*19*2M*6*0*19*2M*6*0*20*2M*2*0*419*~1,64,672,0,0,Right|2,48,78|2,48,111|2,49,210|2,48,240|2,48,273|2,113,176|2,80,177|2,79,142~1~1~My%20Level"
	var lv_data = serializer.deserialize(demo_level)
	#print(lv_data.shape_corners)
	#print(lv_data.items)
	for item in lv_data.items:
		place_item(item)
