extends FileDialog

var save_dict: Dictionary
onready var main = $"/root/Main"

func _on_SaveDialog_file_selected(path):
	var file = File.new()
	var buffer = generate_level_binary()
	file.open(path, File.WRITE)
	file.store_buffer(buffer)
	file.close()


func generate_level_binary() -> PoolByteArray:
	# level info
	var output = store_uint_bytes(Singleton.LD_VERSION, 1)
	output.append_array(store_string_bytes("2 hour blj"))
	output.append_array(store_string_bytes("ben"))
	output.append_array(generate_mission_list([["blj the thwomp's block", "i'm not doing this ben"], ["mission 2", "desc"]]))
	
	# item dictionary
	for item in $"/root/Main/Template/Items".get_children():
		output.append_array(store_uint_bytes(item.item_id, 2))
		for key in item.properties:
			var val = store_value_of_type(main.items[item.item_id].properties[key].type, item.properties[key])
			output.append_array(val)
	output.append_array([255, 255]) # end character, replaces ID
		
	# polygons
	var polygon_list = $"/root/Main/Template/Terrain".get_children()
	output.append_array(store_uint_bytes(polygon_list.size(), 3))
	for polygon in polygon_list:
		output.append_array(store_uint_bytes(0, 2)) # TODO: material
		output.append_array(store_sint_bytes(polygon.z_index, 2))
		output.append_array(store_uint_bytes(polygon.polygon.size() - 1, 2))
		for vertex in polygon.polygon:
			output.append_array(store_vector2_bytes(vertex, 3))
	
	# pipescript
	# TODO
	return output


func store_value_of_type(type: String, val) -> PoolByteArray:
	match type:
		"bool":
			return PoolByteArray([val])
		"int":
			return store_sint_bytes(val, 3)
		"float":
			return store_float_bytes(val, 4)
		"Vector2":
			return store_vector2_bytes(val, 3)
		_:
			printerr("Unknown datatype!")
			return PoolByteArray([])


func store_vector2_bytes(val: Vector2, num: int) -> PoolByteArray:
	var output = store_sint_bytes(int(val.x), num)
	output.append_array(store_sint_bytes(int(val.y), num))
	return output


func store_float_bytes(val: float, num: int) -> PoolByteArray:
	var output = PoolByteArray([])
	if num > 7:
		printerr("Cannot store float in this many bytes due to Godot limitations!")
		num = 7
	
	var arr = var2bytes(val) # cut off icky variant data
	var size = arr.size()
	return arr.subarray(size - num, size - 1)


func store_sint_bytes(val: int, num: int) -> PoolByteArray:
	if abs(val) > (1 << ((num - 1) << 3)):
		printerr(val, " is too big to fit in ", num, " bytes! Corruption may occur!")
	return store_int_bytes(val, num)


func store_int_bytes(val: int, num: int) -> PoolByteArray:
	var output = PoolByteArray([])
	for i in range(num):
		var byte = (
			val >> (
				(
					num - i - 1
				) << 3
			) # cut off everything before this byte
			& 255 # cut off everything after this byte
		)
		output.append(byte)
	return output


func store_uint_bytes(val: int, num: int) -> PoolByteArray:
	# val - value to encode
	# num - number of bytes
	if val < 0:
		printerr(val, " is negative - this is an unsigned integer, and cannot store negative values. Corruption may occur!")
	if abs(val) > (1 << (num << 3)):
		printerr(val, " is too big to fit in ", num, " bytes! Corruption may occur!")
	return store_int_bytes(val, num)


func generate_mission_list(missions: Array) -> PoolByteArray:
	var output = store_uint_bytes(missions.size(), 1)
	for mission in missions:
		output.append_array(store_string_bytes(mission[0]))
		output.append_array(store_string_bytes(mission[1]))
	return output


func store_string_bytes(txt: String) -> PoolByteArray:
	var arr = txt.to_utf8()
	var output = store_uint_bytes(arr.size(), 3)
	output.append_array(arr)
	return output


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
