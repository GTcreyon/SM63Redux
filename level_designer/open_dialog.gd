extends FileDialog

var load_dict: Dictionary
var pointer: int = 0
var buffer: PoolByteArray
#func _on_Options_pressed():
#	load_dict = JSON.parse(OS.get_clipboard()).result
#	for item in load_dict["items"]:
#		var inst = main.item_prefab.instance()
#		inst.texture = load(main.item_textures[item.name]["Placed"])
#		inst.item_name = item.name
#		inst.position = str2var(item.position)
#		for key in main.items[item.name]:
#			if key != "Position":
#				var property = main.items[item.name][key]
#				property["value"] = item.properties[key]
#				inst.properties[key] = property
#		$"/root/Main/Template/Items".add_child(inst)
#	for poly in load_dict["terrain"]:
#		var inst = main.terrain_prefab.instance()
#		inst.polygon = str2var(poly)
#		$"/root/Main/Template/Terrain".add_child(inst)


func _on_OpenDialog_file_selected(path):
	var file = File.new()
	file.open(path, File.READ)
	buffer = file.get_buffer(file.get_len())
	file.close()
	load_buffer(buffer)


func load_buffer(buffer: PoolByteArray):
	var output = PoolByteArray([Singleton.LD_VERSION % 256])
	# level info
	print("version: ", decode_int_bytes(1))
	print("title: ", decode_string_bytes())
	print("author: ", decode_string_bytes())
	print("missions: ", decode_mission_list())
#	output.append_array(generate_mission_list([["blj the thwomp's block", "i'm not doing this ben"], ["mission 2", "desc"]]))
#
#	# item dictionary
#	for item in $"/root/Main/Template/Items".get_children():
#		output.append_array(store_int_bytes(item.item_id, 2))
#		for key in item.properties:
#			var val = store_value_of_type(item.properties[key].type, item.properties[key].value)
#			output.append_array(val)
#		output.append_array([255, 255]) # end character, replaces ID
#
#	# polygons
#	var polygon_list = $"/root/Main/Template/Terrain".get_children()
#	output.append_array(store_int_bytes(polygon_list.size(), 3))
#	for polygon in polygon_list:
#		output.append_array(store_int_bytes(0, 2)) # TODO: material
#		output.append_array(store_int_bytes(polygon.z_index, 2))
#		output.append_array(store_int_bytes(polygon.polygon.size(), 2))
#		for vertex in polygon.polygon:
#			output.append_array(store_vector2_bytes(vertex))
#
#	# pipescript
#	# TODO
#	return output


#func store_value_of_type(type: String, val) -> PoolByteArray:
#	match type:
#		"bool":
#			return PoolByteArray([val])
#		"int":
#			return store_int_bytes(val, 3)
#		"float":
#			return store_float_bytes(val, 4)
#		"Vector2":
#			return store_vector2_bytes(val)
#		_:
#			return PoolByteArray([])


func decode_vector2_bytes(num: int) -> Vector2:
	return Vector2(decode_int_bytes(3), decode_int_bytes(3))


func decode_float_bytes(num: int) -> float:
	if num > 7:
		printerr("Cannot store float in this many bytes due to Godot limitations!")
		num = 7
	
	var variant_buffer = PoolByteArray([3])
	while variant_buffer.size() + num < 8:
		variant_buffer.append(0)
	variant_buffer.append_array(buffer.subarray(pointer, pointer + num - 1))
	var output = bytes2var(variant_buffer)
	
	pointer += num
	return output


func decode_int_bytes(num: int) -> int:
	var output: int = 0
	var section: PoolByteArray = buffer.subarray(pointer, pointer + num - 1)
	section.invert()
	for i in range(num):
		output += section[i] << (i << 3)
	pointer += num
	return output


func decode_mission_list() -> Array:
	var output = []
	var length = decode_int_bytes(1)
	for i in range(length):
		output.append([decode_string_bytes(), decode_string_bytes()])
	return output


func decode_string_bytes() -> String:
	var length = decode_int_bytes(3)
	var output = buffer.subarray(pointer, pointer + length - 1).get_string_from_utf8()
	pointer += length
	
	return output
