extends Panel

const TICKBOX = preload("../fields/boolean/tickbox_ld.tscn")
const INPUT_NUMBER = preload("../fields/number/input_number.tscn")
const INPUT_VECTOR2 = preload("../fields/vector2/input_vector2.tscn")
var properties: Dictionary = {}
var target_node: Node = null
@onready var list: VBoxContainer = $PropertyList
@onready var main = $"/root/Main"


func _input(event):
	if event is InputEventMouseMotion:
		position += event.relative


func hide_menu():
	visible = false


func show_menu():
	visible = true
	var pos = get_global_mouse_position()
	position = pos
	set_process_input(false)


func clear_children():
	for child in list.get_children(): # clear previous properties
		list.remove_child(child)
		child.queue_free()


func set_properties(new_properties, node):
	properties = new_properties
	clear_children()
	
	for key in new_properties:
		var inst = null
		var val = new_properties[key]
		match main.items[node.item_id].properties[key]["type"]:
			"Vector2":
				inst = INPUT_VECTOR2.instantiate()
				inst.get_node("Label").text = key
				inst.pre_value = Vector2.ZERO if val == null else new_properties[key]
			"bool":
				inst = TICKBOX.instantiate()
				inst.get_node("Label").text = key
				inst.button_pressed = new_properties[key]
			"uint", "sint":
				inst = INPUT_NUMBER.instantiate()
				inst.get_node("Label").text = key
				inst.pre_text = str(0 if val == null else val)
			"float":
				inst = INPUT_NUMBER.instantiate()
				inst.get_node("Label").text = key
				inst.pre_text = str(0 if val == null else val)
		if inst != null:
			list.add_child(inst)
	
	target_node = node
	
	call_deferred("resize_box")


func resize_box():
	size = Vector2(list.size.x + 36, list.size.y + 36)


func on_value_changed(label, value):
	target_node.set_property(label, value)


func _on_CloseButton_pressed():
	hide_menu()


#TODO: make the dragger cross device
func _on_Dragger_button_down():
	set_process_input(true)


func _on_Dragger_button_up():
	set_process_input(false)
