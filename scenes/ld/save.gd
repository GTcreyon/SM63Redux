extends Button

var save_dict: Dictionary

func _on_File_pressed():
	save_dict = {
		"version": Singleton.VERSION,
		"settings": {
			"name": "XXXXX"
		},
		"items": [],
		"terrain": [],
	}
	
	var template = $"/root/Main/Template"
	for item in template.get_node("Items").get_children():
		var item_dict = {
			"name": item.item_name,
			"position": var2str(item.position),
		}
		save_dict["items"].append(item_dict)
	for poly in template.get_node("Terrain").get_children():
		save_dict["terrain"].append(var2str(poly.polygon))
	OS.set_clipboard(JSON.print(save_dict))
