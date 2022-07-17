class_name Serializer

var pointer: int = 0
var buffer_to_load: PoolByteArray
var logged_errors = PoolStringArray([])


func generate_level_binary(items, polygons, main) -> PoolByteArray:
	# level info
	var output = encode_uint_bytes(Singleton.LD_VERSION, 1)
	output.append_array(encode_string_bytes("")) # title
	output.append_array(encode_string_bytes("")) # author
	output.append_array(generate_mission_list([["", ""]])) # missions
	
	# item dictionary
	for item in items:
		output.append_array(encode_uint_bytes(item.item_id, 2))
		for key in item.properties:
			var type = main.items[item.item_id].properties[key].type
			var val = encode_value_of_type(item.properties[key], type, get_value_length_from_type(type))
			output.append_array(val)
	output.append_array([255, 255]) # end character, replaces ID
		
	# polygons
	output.append_array(encode_uint_bytes(polygons.size(), 3))
	for polygon in polygons:
		output.append_array(encode_uint_bytes(0, 2)) # TODO: material
		output.append_array(encode_sint_bytes(polygon.z_index, 2))
		output.append_array(encode_uint_bytes(polygon.polygon.size(), 2))
		for vertex in polygon.polygon:
			output.append_array(encode_vector2_bytes(vertex, 6))
	
	# pipescript
	# TODO
	return output


func encode_value_of_type(val, type: String, num: int) -> PoolByteArray:
	match type:
		"bool":
			return PoolByteArray([val])
		"uint":
			return encode_uint_bytes(val, num)
		"sint":
			return encode_sint_bytes(val, num)
		"float":
			return encode_float_bytes(val, num)
		"Vector2":
			return encode_vector2_bytes(val, num)
		"String":
			return encode_string_bytes(val)
		_:
			log_error("Unknown datatype!")
			return PoolByteArray([])


func encode_vector2_bytes(val: Vector2, num: int) -> PoolByteArray:
	var half = num >> 1
	var output = encode_sint_bytes(int(val.x), half)
	output.append_array(encode_sint_bytes(int(val.y), half))
	return output


func encode_float_bytes(val: float, num: int) -> PoolByteArray:
	var output = PoolByteArray([])
	if num > 7:
		log_error("Cannot encode float in this many bytes due to Godot limitations!")
		num = 7
	
	var arr = var2bytes(val) # cut off icky variant data
	var size = arr.size()
	return arr.subarray(size - num, size - 1)


func encode_sint_bytes(val: int, num: int) -> PoolByteArray:
	if abs(val) > (1 << ((num << 3) - 1)):
		log_error("%d is too big to fit in %d bytes! Corruption may occur! Type: sint" % [val, num])
	return encode_int_bytes(val, num)


func encode_int_bytes(val: int, num: int) -> PoolByteArray:
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


func encode_uint_bytes(val: int, num: int) -> PoolByteArray:
	# val - value to encode
	# num - number of bytes
	if val < 0:
		log_error("%d is negative - this is an unsigned integer, and cannot encode negative values. Corruption may occur!" % val)
	if abs(val) >= (1 << (num << 3)):
		log_error("%d is too big to fit in %d bytes! Corruption may occur! Type: uint" % [val, num])
	return encode_int_bytes(val, num)


func generate_mission_list(missions: Array) -> PoolByteArray:
	var output = encode_uint_bytes(missions.size(), 1)
	for mission in missions:
		output.append_array(encode_string_bytes(mission[0]))
		output.append_array(encode_string_bytes(mission[1]))
	return output


func encode_string_bytes(txt: String) -> PoolByteArray:
	var arr = txt.to_utf8()
	var output = encode_uint_bytes(arr.size(), 3)
	output.append_array(arr)
	return output


func load_buffer(buffer: PoolByteArray, target_node: Node):
	buffer_to_load = buffer
	pointer = 0
	# level info
	print("version: ", decode_uint_bytes(read_bytes(1)))
	print("title: ", decode_string_bytes())
	print("author: ", decode_string_bytes())
	print("missions: ", decode_mission_list())

	# item dictionary
	var item_id = decode_uint_bytes(read_bytes(2))
	while item_id != 65535: # end character, [255, 255]
		var inst = target_node.ITEM_PREFAB.instance()
		var props = target_node.items[item_id].properties
		for key in props:
			var val = decode_value_of_type(read_bytes_of_type(props[key]["type"]), props[key]["type"])
			inst.properties[key] = val
			inst.update_visual_property(key, val)
		inst.texture = load(target_node.item_textures[item_id]["Placed"])
		inst.item_id = item_id
		inst.position = inst.properties["Position"]
		target_node.get_node("Template/Items").add_child(inst)
		item_id = decode_uint_bytes(read_bytes(2))
#
#	# polygons
	for i in range(decode_uint_bytes(read_bytes(3))):
		var inst = target_node.TERRAIN_PREFAB.instance()
		inst.terrain_material = decode_uint_bytes(read_bytes(2))
		inst.z_index = decode_sint_bytes(read_bytes(2))
		var polygon = PoolVector2Array([])
		var vert_count = decode_uint_bytes(read_bytes(2))
		print(vert_count)
		for j in range(vert_count):
			polygon.append(decode_vector2_bytes(read_bytes(6)))
		inst.polygon = polygon
		target_node.get_node("Template/Terrain").add_child(inst)
#
#	# pipescript
#	# TODO
#	return output


func get_value_length_from_type(type: String):
	match type:
		"bool":
			return 1
		"uint", "sint":
			return 3
		"float":
			return 4
		"Vector2":
			return 6
		"String":
			return 0
		_:
			log_error("Unknown datatype!")
			return null


func read_bytes_of_type(type: String):
	return read_bytes(get_value_length_from_type(type))


func decode_value_of_type(bytes: PoolByteArray, type: String):
	match type:
		"bool":
			return bool(decode_uint_bytes(bytes))
		"uint":
			return decode_uint_bytes(bytes)
		"sint":
			return decode_sint_bytes(bytes)
		"float":
			return decode_float_bytes(bytes)
		"Vector2":
			return decode_vector2_bytes(bytes)
		"String":
			return decode_string_bytes()
		_:
			log_error("Unknown datatype!")
			return null


func decode_vector2_bytes(bytes: PoolByteArray) -> Vector2:
	var size = bytes.size()
	var half = size / 2 - 1
	return Vector2(
		decode_sint_bytes(
			bytes.subarray(
				0, half
			)
		),
		decode_sint_bytes(
			bytes.subarray(
				half + 1, size - 1
			)
		)
	)


func decode_float_bytes(bytes: PoolByteArray) -> float:
	var size = bytes.size()
	if size > 7:
		log_error("Cannot encode float in this many bytes due to Godot limitations!")
		size = 7
	
	var variant_buffer = PoolByteArray([3])
	while variant_buffer.size() + size < 8:
		variant_buffer.append(0)
	variant_buffer.append_array(bytes)
	var output = bytes2var(variant_buffer)
	return output


func decode_uint_bytes(bytes: PoolByteArray) -> int:
	var output: int = 0
	bytes.invert()
	for i in range(bytes.size()):
		output += bytes[i] << (i << 3)
	return output


func decode_sint_bytes(bytes: PoolByteArray) -> int:
	var size = bytes.size()
	var output: int = 0
	bytes.invert()
	for i in range(size):
		output += bytes[i] << (i << 3)
	var a = ((size << 3) - 1)
	var max_int = 1 << a
	if output >= max_int:
		output = (max_int << 1) - output
		output *= -1
	return output


func decode_mission_list() -> Array:
	var output = []
	var length = decode_uint_bytes(read_bytes(1))
	for i in range(length):
		output.append([decode_string_bytes(), decode_string_bytes()])
	return output


func decode_string_bytes() -> String:
	var length = decode_uint_bytes(read_bytes(3))
	var output = read_bytes(length).get_string_from_utf8()
	return output


func read_bytes(num: int) -> PoolByteArray:
	var output = buffer_to_load.subarray(pointer, pointer + num - 1)
	pointer += num
	return output


func log_error(txt: String):
	printerr(txt)
	logged_errors.append(txt)


func run_tests(verbose: bool): # a set of unit tests to be run to check if the serialisation is working correctly
	# arrange
	print("Serializer tests start! Errors are normal - the tests are checking if the warnings work correctly. Only worry if you see full caps.")
	var fail = false
	var tests = {
		"bool": {
			"bytes": 1,
			"data": {
				"valid": [true, false],
				"error": [],
			},
		},
		"uint": {
			"bytes": 3,
			"data": {
				"valid": [0, 1, 2, 255, (1 << (3 << 3)) - 1],
				"error": [-1, 1 << (3 << 3)],
			},
		},
		"sint": {
			"bytes": 3,
			"data": {
				"valid": [1, 2, -1, -2, -(1 << ((3 << 3) - 1))],
				"error": [1 << ((3 << 3) - 1) + 1],
			},
		},
		"Vector2": {
			"bytes": 6,
			"data": {
				"valid": [Vector2(0, 0), Vector2(-1, -1), Vector2(1, 1)],
				"error": [],
			},
		},
		# do NOT try to test strings, they're handled differently, don't waste your time
		# there's barely anything to test anyway
	}
	# act
	for key in tests:
		if verbose:
			print("Valid tests for ", key, ":")
		for input in tests[key].data.valid:
			fail = fail || test_data(input, key, tests[key].bytes, true, verbose)
		if verbose:
			print("Error tests for ", key, ":")
		for input in tests[key].data.error:
			var test_result = test_data(input, key, tests[key].bytes, false, verbose)
			fail = test_result || fail # done like this to avoid issues with lazy evaluation
	# assert ???
	if fail:
		printerr("SERIALIZER TEST FAILED.")
	else:
		print("Serializer tests OK!")


func test_data(input, type: String, num: int, valid: bool, verbose: bool):
	var fail = false
	var encoded = encode_value_of_type(input, type, num)
	var decoded = decode_value_of_type(encoded, type)
	if valid:
		if decoded != input || logged_errors.size() > 0:
			fail = true
			if verbose:
				printerr("TEST FAIL. Input: ", input, " Encoded: ", encoded, " Decoded: ", decoded)
				printerr("Logged errors: ", logged_errors)
		elif verbose:
			print("Test pass. Input: ", input, " Encoded: ", encoded, " Decoded: ", decoded)
	else:
		if logged_errors.size() == 0:
			fail = true
			if verbose:
				printerr("TEST VOID. Input: ", input, " Encoded: ", encoded, " Decoded: ", decoded)
				printerr("No errors logged, despite data being intentionally invalid.")
		elif verbose:
			print("Test fail as expected. Input: ", input, " Encoded: ", encoded, " Decoded: ", decoded)
	logged_errors = PoolStringArray([])
	return fail
