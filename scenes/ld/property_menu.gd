extends Panel

const TICKBOX = preload("res://actors/debug/tickbox_ld.tscn")
var properties: Dictionary = {}
var target_node: Node = null
onready var list: VBoxContainer = $PropertyList


func _on_CloseButton_pressed():
	hide()


func hide():
	visible = false


func show():
	visible = true
	var pos = get_global_mouse_position()
	rect_position = pos


func clear_children():
	for child in list.get_children(): # clear previous properties
		list.remove_child(child)
		child.queue_free()


func set_properties(new_properties, node):
	properties = new_properties
	clear_children()
	
	for key in new_properties:
		var inst = null
		match new_properties[key]["type"]:
			"bool":
				inst = TICKBOX.instance()
				inst.get_node("Label").text = key
				inst.pressed = new_properties[key]["value"]
		if inst != null:
			list.add_child(inst)
	
	target_node = node
	
	call_deferred("resize_box")


func resize_box():
	rect_size = Vector2(list.rect_size.x + 36, list.rect_size.y + 36)


func on_value_changed(label, value):
	target_node.properties[label]["value"] = value
