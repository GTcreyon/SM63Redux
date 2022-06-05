extends FileDialog

var save_dict: Dictionary


func _on_SaveDialog_file_selected(path):
	var file = File.new()
	var buffer = generate_level_binary()
	file.open(path, File.WRITE)
	file.store_buffer(buffer)
	file.close()


func generate_level_binary() -> PoolByteArray:
	var output = PoolByteArray([Singleton.LD_VERSION % 256])
	# level info
	output.append_array(generate_unistring("2 hour blj"))
	output.append_array(generate_unistring("ben"))
	output.append_array(generate_mission_list([["blj the thwomp's block", "i'm not doing this ben"], ["mission 2", "desc"]]))
	
	# item dictionary
	for item in $"/root/Main/Template/Items".get_children():
		output.append_array(store_int_bytes(item.item_id, 2))
		for key in item.properties:
			var val = store_value_of_type(item.properties[key].type, item.properties[key].value)
			output.append_array(val)
		output.append_array([255, 255]) # end character, replaces ID
		
	# polygons
	var polygon_list = $"/root/Main/Template/Terrain".get_children()
	output.append_array(store_int_bytes(polygon_list.size(), 3))
	for polygon in polygon_list:
		output.append_array(store_int_bytes(0, 2)) # TODO: material
		output.append_array(store_int_bytes(polygon.z_index, 2))
		output.append_array(store_int_bytes(polygon.polygon.size(), 2))
		for vertex in polygon.polygon:
			output.append_array(store_vector2_bytes(vertex))
	
	# pipescript
	# TODO
	return output


func store_value_of_type(type: String, val) -> PoolByteArray:
	match type:
		"bool":
			return PoolByteArray([val])
		"int":
			return store_int_bytes(val, 3)
		"float":
			return store_float_bytes(val, 4)
		"Vector2":
			return store_vector2_bytes(val)
		_:
			return PoolByteArray([])


func store_vector2_bytes(val: Vector2) -> PoolByteArray:
	var output = store_int_bytes(int(val.x), 3)
	output.append_array(store_int_bytes(int(val.y), 3))
	return output


func store_float_bytes(val: float, num: int) -> PoolByteArray:
	var output = PoolByteArray([])
	if num > 7:
		printerr("Cannot store float in this many bytes due to Godot limitations!")
		num = 7
	
	var arr = var2bytes(val) # cut off icky variant data
	var size = arr.size()
	return arr.subarray(size - num, size - 1)


func store_int_bytes(val: int, num: int) -> PoolByteArray:
	# val - value to encode
	# num - number of bytes
	var output = PoolByteArray([])
	for i in range(num):
		output.append(
			val >> (
				8 * (
					num - i - 1
				)
			) # cut off everything before this byte
			& 255 # cut off everything after this byte
		)
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
