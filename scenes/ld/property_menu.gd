extends Panel

const TICKBOX = preload("res://actors/debug/tickbox_ld.tscn")
var properties: Array = []
onready var list: VBoxContainer = $PropertyList

func show():
	visible = true
	var pos = get_global_mouse_position()
	margin_left = pos.x
	margin_top = pos.y


func set_properties(new_properties):
	properties = new_properties
	for child in list.get_children(): # clear previous properties
		list.remove_child(child)
	
	for property in new_properties:
		var inst = null
		match property["type"]:
			"bool":
				inst = TICKBOX.instance()
				inst.get_node("Label").text = property["label"]
		if inst != null:
			list.add_child(inst)
