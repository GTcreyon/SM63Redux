extends Button

var save_dict: Dictionary

func _on_File_pressed():
	var file = File.new()
	file.open("user://lvl.63r", File.WRITE)
	file.store_buffer(generate_level_binary())
	file.close()


func generate_level_binary() -> PoolByteArray:
	var output = PoolByteArray([Singleton.LD_VERSION % 256])
	# level info
	output.append_array(generate_unistring("2 hour blj"))
	output.append_array(generate_unistring("ben"))
	output.append_array(generate_mission_list([["blj the thwomp's block", "i'm not doing this ben"], ["mission 2", "desc"]]))
	
	# item dictionary
	# TODO
	
	# polygons
	# TODO
	
	# pipescript
	# TODO
	return output


func generate_mission_list(missions: Array) -> PoolByteArray:
	var arr = PoolByteArray([])
	for mission in missions:
		arr.append_array(generate_unistring(mission[0]))
		arr.append_array(generate_unistring(mission[1]))
	arr.append(0)
	return arr


func generate_unistring(txt: String) -> PoolByteArray:
	var arr = txt.to_utf8()
	arr.append(0) # terminating character
	return arr


func save_json():
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
		var props = {}
		var item_dict = {
			"name": item.item_name,
			"position": var2str(item.position),
			"properties": props,
		}
		for key in item.properties:
			if key != "Position":
				props[key] = item.properties[key]["value"]
		save_dict["items"].append(item_dict)
	for poly in template.get_node("Terrain").get_children():
		save_dict["terrain"].append(var2str(poly.polygon))
	OS.set_clipboard(JSON.print(save_dict))
