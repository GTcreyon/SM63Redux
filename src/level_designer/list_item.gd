extends TextureButton

onready var main = $"/root/Main"
onready var control = $"/root/Main/UILayer/LDUI"
onready var placed_path = control.item_textures[item_name]["Placed"]

var item_name

func _on_ListItem_pressed():
	if placed_path != null:
		main.place_item(placed_path)
