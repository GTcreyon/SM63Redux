extends TextureButton

onready var main = $"/root/Main"
onready var placed_path = main.item_textures[item_name]["Placed"]

var item_name

func _on_ListItem_pressed():
	if placed_path != null:
		main.place_item(item_name)
