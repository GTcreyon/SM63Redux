class_name Serializer

const ITEM_END_MARKER_BYTES = [255, 255]
const ITEM_END_MARKER_VALUE = (255 << 8) | 255 # 255, 255 = 65536

var pointer: int = 0
var buffer_to_load: PackedByteArray
var logged_errors = PackedStringArray([])


## Generates a binary representation of the level.
func generate_level_binary(
	items: Array[Node], polygons: Array[Node], main: LDMain
) -> PackedByteArray:
	var output: PackedByteArray
	
	# Serialize level metadata.
	output = encode_uint_bytes(Singleton.LD_VERSION, 1)
	output.append_array(encode_string_bytes("")) # title
	output.append_array(encode_string_bytes("")) # author
	output.append_array(encode_mission_list([["", ""]])) # missions
	
	# Serialize items in the level.
	for item in items:
		# Item ID.
		output.append_array(encode_uint_bytes(item.item_id, 2))
		# Item's properties.
		for key in item.properties:
			# Get type of property so we know what type to serialize.
			var type = main.items[item.item_id].properties[key].type
			# Serialize value as that type.
			var val = encode_value_of_type(item.properties[key], type, 
				get_value_length_from_type(type))
			output.append_array(val)
	# Mark end of item array.
	output.append_array([255, 255])
		
	# Serialize polygons.
	output.append_array(encode_uint_bytes(polygons.size(), 3))
	for polygon in polygons:
		# Material, for footstep sound purposes.
		# TODO: Temped until this can be set per-polygon.
		output.append_array(encode_uint_bytes(0, 2))
		# Z index.
		output.append_array(encode_sint_bytes(polygon.z_index, 2))
		# Vertex count.
		output.append_array(encode_uint_bytes(polygon.polygon.size(), 2))
		# Individual vertices.
		for vertex in polygon.polygon:
			output.append_array(encode_vector2_bytes(vertex, 6))
	
	# TODO: Serialize Pipescript.
	
	return output


## Loads a level from binary representation, then adds it to the scene template
## inside of [param target_node].
func load_level_binary(binary_level: PackedByteArray, target_node: Node2D):
	# Save class wide
	buffer_to_load = binary_level
	pointer = 0
	
	# Level info has to be read in order for the level data to be read properly.
	# For now, print it to console (since there's nowhere better to put it).
	print("version: ", decode_uint_bytes(read_bytes(1)))
	print("title: ", decode_string_bytes())
	print("author: ", decode_string_bytes())
	print("missions: ", decode_mission_list())

	# Load level's items into nodes.
	
	# Prime the loop....
	var item_id = decode_uint_bytes(read_bytes(2))
	# Loop until we reach the end-of-item-array marker.
	while item_id != ITEM_END_MARKER_VALUE:
		assert(item_id < target_node.items.size(),
			"Loading item with invalid ID %s. Highest valid ID is %s." %
			[item_id, target_node.items.size() - 1])
		
		# Create node for this item.
		var inst = target_node.ITEM_PREFAB.instantiate()
		
		# Load item's properties into their right spot.
		# Begin by getting a copy of this item type's properties dictionary.
		var props = target_node.items[item_id].properties
		# Populate its values from the loaded level data.
		for key in props:
			var val = decode_value_of_type(read_bytes_of_type(props[key]["type"]), props[key]["type"])
			inst.properties[key] = val
			inst.update_visual_property(key, val)
		# Load assorted other important data.
		inst.texture = load(target_node.item_textures[item_id]["Placed"])
		inst.item_id = item_id
		inst.position = inst.properties["Position"]
		
		# Add new item node to the right part of the scene tree.
		target_node.get_node("Template/Items").add_child(inst)
		
		# Fetch next item ID.
		item_id = decode_uint_bytes(read_bytes(2))
	
	# Load polygons into nodes as well.
	# The 3 bytes here tell us how many polygons to load.
	for i in range(decode_uint_bytes(read_bytes(3))):
		# Create node for this polygon.
		var inst = target_node.TERRAIN_PREFAB.instantiate()
		# Load non-polygon data.
		inst.terrain_material = decode_uint_bytes(read_bytes(2))
		inst.z_index = decode_sint_bytes(read_bytes(2))
		
		var polygon = PackedVector2Array([])
		var vert_count = decode_uint_bytes(read_bytes(2))
		print(vert_count)
		# Load actual polygon shape, vertex by vertex.
		for j in range(vert_count):
			polygon.append(decode_vector2_bytes(read_bytes(6)))
		# Assign it to the node.
		inst.polygon = polygon
		
		# Add new terrain node to the right part of the scene tree.
		target_node.get_node("Template/Terrain").add_child(inst)

	# TODO: Load Pipescript.

	#return output


## Returns the byte length of [param type]'s binary representation.
func get_value_length_from_type(type: String):
	# TODO: Function returns null for invalid types.
	# But that makes it impossible to give the function a return type of
	# int, as would be appropriate.
	# Null values are never explicitly handled anyway, though....
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


## Reads enough bytes to contain a value of type [param type].
func read_bytes_of_type(type: String):
	return read_bytes(get_value_length_from_type(type))


## Encodes value in its [param type]'s appropriate binary representation.
func encode_value_of_type(val, type: String, byte_count: int) -> PackedByteArray:
	match type:
		"bool":
			return PackedByteArray([val])
		"uint":
			return encode_uint_bytes(val, byte_count)
		"sint":
			return encode_sint_bytes(val, byte_count)
		"float":
			return encode_float_bytes(val, byte_count)
		"Vector2":
			return encode_vector2_bytes(val, byte_count)
		"String":
			return encode_string_bytes(val)
		_:
			log_error("Unknown datatype!")
			return PackedByteArray([])


## Decodes [param bytes] into a value of type [param type].
func decode_value_of_type(bytes: PackedByteArray, type: String):
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


## Encodes a Vector2 as a binary byte array, discarding the decimal portion.
func encode_vector2_bytes(val: Vector2, byte_count: int) -> PackedByteArray:
	var half = byte_count >> 1
	var output = encode_sint_bytes(int(val.x), half)
	output.append_array(encode_sint_bytes(int(val.y), half))
	return output


## Decodes [param bytes] into a Vector2.
func decode_vector2_bytes(bytes: PackedByteArray) -> Vector2:
	var size = bytes.size()
	var half = size / 2 - 1
	return Vector2(
		decode_sint_bytes(
			bytes.slice(
				0, half
			)
		),
		decode_sint_bytes(
			bytes.slice(
				half + 1, size - 1
			)
		)
	)


## Encodes a float as a binary byte array [param byte_count] bytes long.[br]
## Due to engine limitations, [param byte_count] maxes out at 7 bytes. Any
## larger number of bytes will be clamped.
func encode_float_bytes(val: float, byte_count: int) -> PackedByteArray:
	var output = PackedByteArray([])
	if byte_count > 7:
		log_error("Floats cannot be encoded in more than 7 bytes due to Godot limitations. Reducing to 7 bytes....")
		byte_count = 7
	
	var arr := var_to_bytes(val)
	# cut off icky variant data
	var size = arr.size()
	return arr.slice(size - byte_count, size - 1)


## Decodes [param bytes] into a float.[br]
## Due to engine limitations, floats max out at 7 bytes of useful data. Any
## bytes past that number will be ignored.
func decode_float_bytes(bytes: PackedByteArray) -> float:
	var size = bytes.size()
	if size > 7:
		log_error("Cannot encode float in this many bytes due to Godot limitations!")
		size = 7
	
	# Construct a float from raw bytes.
	# To work as a Godot Variant value, begin with a type marker.
	var variant_buffer = PackedByteArray([TYPE_FLOAT])
	# If the source bytes plus the type marker will total fewer than 8 bytes,
	# pad with zeroes.
	while variant_buffer.size() + size < 8:
		variant_buffer.append(0)
	# Add in the source bytes and convert to a float.
	variant_buffer.append_array(bytes)
	var output = bytes_to_var(variant_buffer)
	
	return output


## Encodes a signed integer as a binary byte array [param byte_count] bytes
## long.
func encode_sint_bytes(val: int, byte_count: int) -> PackedByteArray:
	# Internally, this validates the passed int, then passes it off to
	# _encode_int_bytes(...).
	
	if abs(val) > (1 << ((byte_count << 3) - 1)):
		log_error("%d is too big to fit in %d bytes! Corruption may occur! Type: sint" % [val, byte_count])
	return _encode_int_bytes(val, byte_count)


## Decodes [param bytes] into a signed integer.
func decode_sint_bytes(bytes: PackedByteArray) -> int:
	var size = bytes.size()
	var output: int = 0
	bytes.reverse()
	for i in range(size):
		output += bytes[i] << (i << 3)
	var a = ((size << 3) - 1)
	var max_int = 1 << a
	if output >= max_int:
		output = (max_int << 1) - output
		output *= -1
	return output


## Encodes an unsigned integer as a binary byte array [param byte_count] bytes
## long.
func encode_uint_bytes(val: int, byte_count: int) -> PackedByteArray:
	# Internally, this validates the passed int, then passes it off to
	# _encode_int_bytes(...).
	
	# val - value to encode
	# byte_count - number of bytes
	if val < 0:
		log_error("%d is negative - this is an unsigned integer, and cannot encode negative values. Corruption may occur!" % val)
	if abs(val) >= (1 << (byte_count << 3)):
		log_error("%d is too big to fit in %d bytes! Corruption may occur! Type: uint" % [val, byte_count])
	return _encode_int_bytes(val, byte_count)


## Decodes [param bytes] into an unsigned integer.
func decode_uint_bytes(bytes: PackedByteArray) -> int:
	var output: int = 0
	bytes.reverse()
	for i in range(bytes.size()):
		output += bytes[i] << (i << 3)
	return output


# Internal function that encodes any integer as a binary byte array.
func _encode_int_bytes(val: int, byte_count: int) -> PackedByteArray:
	var output = PackedByteArray([])
	for i in range(byte_count):
		var byte = (
			val >> (
				(
					byte_count - i - 1
				) << 3
			) # cut off everything before this byte
			& 255 # cut off everything after this byte
		)
		output.append(byte)
	return output


## Encodes a string as a binary byte array.[br]
## Result begins with the size of the text (3 bytes),
## followed by the text in UTF-8 format.
func encode_string_bytes(txt: String) -> PackedByteArray:
	var arr = txt.to_utf8_buffer()
	var output = encode_uint_bytes(arr.size(), 3)
	output.append_array(arr)
	return output


## Reads and decodes a UTF-8 string from the loaded level data.[br]
## Begins by reading the size of the text (3 bytes),
## followed by the text in UTF-8 format.
func decode_string_bytes() -> String:
	var length = decode_uint_bytes(read_bytes(3))
	var output = read_bytes(length).get_string_from_utf8()
	return output


## Encodes this level's mission names and descriptions as a binary byte array.[br]
## Result begins with the mission count (1 byte), followed by each mission's
## name as a string, formatted as with [method encode_string_bytes] and [method
## decode_string_bytes].
func encode_mission_list(missions: Array) -> PackedByteArray:
	var output = encode_uint_bytes(missions.size(), 1)
	for mission in missions:
		output.append_array(encode_string_bytes(mission[0]))
		output.append_array(encode_string_bytes(mission[1]))
	return output


## Reads and decodes this level's mission names and descriptions
## from the loaded level data.[br]
## Begins by reading the mission count (1 byte), followed by each mission's
## name as a string, formatted as with [method encode_string_bytes] and [method
## decode_string_bytes].
func decode_mission_list() -> Array:
	var output = []
	var length = decode_uint_bytes(read_bytes(1))
	for i in range(length):
		output.append([decode_string_bytes(), decode_string_bytes()])
	return output


## Reads [param byte_count] bytes from the loaded level data.
func read_bytes(byte_count: int) -> PackedByteArray:
	print_debug("Reading %s bytes." % byte_count)
	# Assert that there's enough bytes left to read.
	assert(pointer + byte_count - 1 < buffer_to_load.size(),
		"Trying to read %s bytes when there's just %s bytes left in the buffer!" %
		[byte_count, buffer_to_load.size() - pointer])
	
	var output = buffer_to_load.slice(pointer, pointer + byte_count - 1)
	pointer += byte_count
	return output


## Prints an error to the console, and saves it in the error log.
func log_error(txt: String):
	printerr(txt)
	logged_errors.append(txt)


## A set of unit tests to be run to check if the serialisation is working
## correctly.
func run_tests(verbose: bool):
	print("Serializer tests start! Errors are normal - the tests are checking if the warnings work correctly. Only worry if you see full caps.")
	var fail = false
	
	# Dictionary of tests to be run.
	# Each type has an entry with the following data:
	# - "bytes": number of bytes in a value of this type.
	# - "data": contains two arrays, "valid" and "error."
	#			"valid" values should pass all tests; "error" values should fail.
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
	for typestring in tests:
		var byte_count = tests[typestring].bytes
		if verbose:
			print("Valid tests for ", typestring, ":")
		# Test valid data.
		for input in tests[typestring].data.valid:
			fail = fail || test_data(input, typestring, byte_count, true, verbose)
		
		if verbose:
			print("Error tests for ", typestring, ":")
		# Test that invalid data errors correctly.
		for input in tests[typestring].data.error:
			var result = test_data(input, typestring, byte_count, false, verbose)
			fail = fail || result
			# done in two steps like this to avoid issues with lazy evaluation.
	# assert ???
	if fail:
		printerr("SERIALIZER TEST FAILED.")
	else:
		print("Serializer tests OK!")


## Tests binary-encoding and -decoding a given [param input].
func test_data(input, type: String, byte_count: int, valid: bool, verbose: bool):
	var fail = false
	
	# Round-trip the value through encoding and decoding.
	var encoded = encode_value_of_type(input, type, byte_count)
	var decoded = decode_value_of_type(encoded, type)
	
	if valid:
		# Given valid data. Expect no errors. 
		
		# If the decoded value doesn't match (or some other error occurred),
		# fail the test.
		if decoded != input or logged_errors.size() > 0:
			fail = true
			
			if verbose:
				printerr("TEST FAIL. Input: ", input, " Encoded: ", encoded, " Decoded: ", decoded)
				printerr("Logged errors: ", logged_errors)
		# No errors found. Report if necessary.
		elif verbose:
			print("Test pass. Input: ", input, " Encoded: ", encoded, " Decoded: ", decoded)
	else:
		# Given invalid data. If errors did NOT occur, fail the test.
		if logged_errors.size() == 0:
			fail = true
			
			if verbose:
				printerr("TEST VOID. Input: ", input, " Encoded: ", encoded, " Decoded: ", decoded)
				printerr("No errors logged, despite data being intentionally invalid.")
		# Errors found, as expected. Report if necessary.
		elif verbose:
			print("Test fail as expected. Input: ", input, " Encoded: ", encoded, " Decoded: ", decoded)
	
	# Clean up after ourselves.
	logged_errors = PackedStringArray([])
	
	return fail
