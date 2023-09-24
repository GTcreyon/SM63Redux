extends Button

var item_id

@onready var main = $"/root/Main"
@onready var placed_path = main.item_textures[item_id]["Placed"]

func _on_ListItem_pressed():
	if placed_path != null:
		main.place_item(item_id)
