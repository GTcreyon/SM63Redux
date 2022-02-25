extends TextureButton

const ld_item = preload("res://actors/items/ld_item.tscn")

onready var main = $"/root/Main"
onready var control = $"/root/Main/UILayer/LDUI"
onready var placed_path = control.item_textures[item_name]["Placed"]

var item_name

func _on_ListItem_pressed():
	if placed_path != null:
		var inst = ld_item.instance()
		inst.position = Vector2.ONE * 40
		inst.texture = load(placed_path)
		main.add_child(inst)
