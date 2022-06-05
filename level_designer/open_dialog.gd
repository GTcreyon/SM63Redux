extends FileDialog

onready var main = $"/root/Main"
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
	pointer = 0
	# level info
	print("version: ", decode_uint_bytes(1))
	print("title: ", decode_string_bytes())
	print("author: ", decode_string_bytes())
	print("missions: ", decode_mission_list())

	# item dictionary
	var item_id = decode_uint_bytes(2)
	while item_id != 65535: # end character, [255, 255]
		var inst = main.ITEM_PREFAB.instance()
		var props = main.items[item_id].properties
		for key in props:
			var val = decode_value_of_type(props[key]["type"])
			inst.properties[key] = val
			inst.update_visual_property(key, val)
		inst.texture = load(main.item_textures[item_id]["Placed"])
		inst.item_id = item_id
		inst.position = inst.properties["Position"]
		$"/root/Main/Template/Items".add_child(inst)
		item_id = decode_uint_bytes(2)
#
#	# polygons
	for i in range(decode_uint_bytes(3)):
		var inst = main.TERRAIN_PREFAB.instance()
		inst.terrain_material = decode_uint_bytes(2)
		inst.z_index = decode_sint_bytes(2)
		var polygon = PoolVector2Array([])
		for j in range(decode_uint_bytes(2)):
			polygon.append(decode_vector2_bytes(3))
		inst.polygon = polygon
		$"/root/Main/Template/Terrain".add_child(inst)
#
#	# pipescript
#	# TODO
#	return output


func decode_value_of_type(type: String):
	match type:
		"bool":
			return bool(decode_uint_bytes(1))
		"int":
			return decode_uint_bytes(3)
		"float":
			return decode_float_bytes(4)
		"Vector2":
			return decode_vector2_bytes(3)
		_:
			printerr("Unknown datatype!")
			return null


func decode_vector2_bytes(num: int) -> Vector2:
	return Vector2(decode_sint_bytes(3), decode_sint_bytes(3))


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


func decode_uint_bytes(num: int) -> int:
	var output: int = 0
	var section: PoolByteArray = buffer.subarray(pointer, pointer + num - 1)
	section.invert()
	for i in range(num):
		output += section[i] << (i << 3)
	pointer += num
	return output


func decode_sint_bytes(num: int) -> int:
	var output: int = 0
	var section: PoolByteArray = buffer.subarray(pointer, pointer + num - 1)
	section.invert()
	for i in range(num):
		output += section[i] << (i << 3)
	var max_int = 1 << ((num << 3) - 1)
	if output > max_int:
		output = (max_int << 1) - output
		output *= -1
	pointer += num
	return output


func decode_mission_list() -> Array:
	var output = []
	var length = decode_uint_bytes(1)
	for i in range(length):
		output.append([decode_string_bytes(), decode_string_bytes()])
	return output


func decode_string_bytes() -> String:
	var length = decode_uint_bytes(3)
	var output = buffer.subarray(pointer, pointer + length - 1).get_string_from_utf8()
	pointer += length
	
	return output
