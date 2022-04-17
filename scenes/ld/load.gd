extends Button

onready var main = $"/root/Main"

var load_dict: Dictionary

func _on_Options_pressed():
	load_dict = JSON.parse(OS.get_clipboard()).result
	var template_items = $"/root/Main/Template/Items"
	for item in load_dict["items"]:
		var inst = main.item_prefab.instance()
		inst.texture = load(main.item_textures[item.name]["Placed"])
		inst.item_name = item.name
		inst.position = str2var(item.position)
		template_items.add_child(inst)
	for poly in load_dict["terrain"]:
		var inst = main.terrain_prefab.instance()
		inst.polygon = str2var(poly)
		template_items.add_child(inst)
