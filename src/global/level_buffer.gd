extends Node
class_name LevelBuffer

var pointer: int = 0
var buffer_to_load: PoolByteArray


func generate_level_binary(items, polygons, main) -> PoolByteArray:
	# level info
	var output = store_uint_bytes(Singleton.LD_VERSION, 1)
	output.append_array(store_string_bytes("2 hour blj"))
	output.append_array(store_string_bytes("ben"))
	output.append_array(generate_mission_list([["blj the thwomp's block", "i'm not doing this ben"], ["mission 2", "desc"]]))
	
	# item dictionary
	for item in items:
		output.append_array(store_uint_bytes(item.item_id, 2))
		for key in item.properties:
			var val = store_value_of_type(main.items[item.item_id].properties[key].type, item.properties[key])
			output.append_array(val)
	output.append_array([255, 255]) # end character, replaces ID
		
	# polygons
	output.append_array(store_uint_bytes(polygons.size(), 3))
	for polygon in polygons:
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
		"uint":
			return store_uint_bytes(val, 3)
		"sint":
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


func load_buffer(buffer: PoolByteArray):
	var main = $"/root/Main"
	buffer_to_load = buffer
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
		"uint":
			return decode_uint_bytes(3)
		"sint":
			return decode_sint_bytes(3)
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
	variant_buffer.append_array(buffer_to_load.subarray(pointer, pointer + num - 1))
	var output = bytes2var(variant_buffer)
	
	pointer += num
	return output


func decode_uint_bytes(num: int) -> int:
	var output: int = 0
	var section: PoolByteArray = buffer_to_load.subarray(pointer, pointer + num - 1)
	section.invert()
	for i in range(num):
		output += section[i] << (i << 3)
	pointer += num
	return output


func decode_sint_bytes(num: int) -> int:
	var output: int = 0
	var section: PoolByteArray = buffer_to_load.subarray(pointer, pointer + num - 1)
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
	var output = buffer_to_load.subarray(pointer, pointer + length - 1).get_string_from_utf8()
	pointer += length
	
	return output
