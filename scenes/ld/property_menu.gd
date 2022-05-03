extends Panel

const TICKBOX = preload("res://actors/debug/tickbox_ld.tscn")
var properties: Array = []
onready var list: VBoxContainer = $PropertyList


func _on_CloseButton_pressed():
	hide()


func hide():
	visible = false
	clear_children()


func show():
	visible = true
	var pos = get_global_mouse_position()
	rect_position = pos


func clear_children():
	for child in list.get_children(): # clear previous properties
		list.remove_child(child)
		child.queue_free()


func set_properties(new_properties):
	if properties != new_properties:
		properties = new_properties
		clear_children()
		
		for property in new_properties:
			var inst = null
			match property["type"]:
				"bool":
					inst = TICKBOX.instance()
					inst.get_node("Label").text = property["label"]
			if inst != null:
				list.add_child(inst)
		call_deferred("resize_box")


func resize_box():
	print(list.margin_right)
	rect_size = Vector2(list.rect_size.x + 36, list.rect_size.y + 36)


