extends Node
# Singleton server for boolean flags that persist between rooms in a level.
# This could maybe be accessed via Pipescript.
#
# Internally, the FlagServer keeps a dictionary of arrays, keyed by the
# room ID (which currently equals the scene filename, although this will have
# to be changed to make the level designer work.).


var _assign_id: int = 0 # First unused index in the current room's flag array.
var _flag_dict: Dictionary = {} # Dictionary of flag arrays, keyed by room.


# Creates a flag in the current room's dictionary entry, and returns its ID.
func claim_flag_id() -> int:
	# TODO: Make this apply to room IDs, not scene paths
	# This will be used on custom levels, which don't have scene paths
	var room = _get_room_id()
	
	_add_flag(room)
	# _add_flag increments the assign ID. Return non-incremented version.
	return _assign_id - 1


# Claim an array of IDs. Useful for entities that drop multiple pickups.
func claim_flag_id_array(num) -> Array:
	var output = []
	for _i in range(num):
		output.append(claim_flag_id())
	return output


# Reset the assign ID.
# Used when re-entering a room, to ensure entities have their IDs properly re-assigned.
func reset_assign_id() -> void:
	_assign_id = 0


# Resets the whole dictionary.
func reset_flag_dict() -> void:
	_flag_dict = {}


# Get the state of a flag with a given ID.
func get_flag_state(id: int) -> bool:
	var room = _get_room_id()
	return _flag_dict[room][id]


# Set the state of a flag with a given ID.
func set_flag_state(id: int, val: bool) -> void:
	var room = _get_room_id()
	_flag_dict[room][id] = val


# Add a flag to a room entry in the dictionary. Create a room entry if it doesn't exist.
func _add_flag(room: String, val: bool = false):
	if _flag_dict.has(room):
		# Add value to existing room array.
		_flag_dict[room].append(val)
	else:
		# Room array does not exist. Create it with the value inside.
		_flag_dict[room] = [val]
	_assign_id += 1


# Get the ID of the current room.
func _get_room_id() -> String:
	return get_tree().get_current_scene().get_scene_file_path()
