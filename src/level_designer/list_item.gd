extends TextureButton

onready var control = $"/root/Main/UILayer/LDUI"
onready var placed_path = control.item_textures[item_name]["Placed"]

var item_name

func _on_ListItem_pressed():
	if placed_path != null:
		control.spawn_item(placed_path)
