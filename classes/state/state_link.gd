class_name StateLink
extends RefCounted
## Stores connection data between states.

## Cached source state
var _head: State = null

## Cached target state
var _target: State = null

## Path from source state to target state.
var _state_path: Array[State] = []

## Peak index of the path, where it switches from dead to live.
var _peak: int = 0

## Length of the path.
var _length: int = 0


func _init(head, target):
	_head = head
	_target = target
	_generate_path()
	_length = _state_path.size()


## Generate the state path using the source and target node.
func _generate_path() -> void:
	# NodePath from source state to target state
	var path: NodePath = _head.get_path_to(_target)
	
	var concat = path.get_concatenated_names()
	var list = concat.split("/")
	_peak = list.rfind("..")
	
	_state_path.clear()
	
	var current_state: State = _head
	for i in path.get_name_count():
		# Need to coerce this from StringName to String
		# because StringName can't be converted to NodePath
		# Hoping this behavior changes in future versions of Godot
		var name: String = str(path.get_name(i))
		var next_state: State = current_state.get_node(name)
		_state_path.append(next_state)
		current_state = next_state


func get_path() -> Array[State]:
	return _state_path


func get_peak_index() -> int:
	return _peak


func get_length() -> int:
	return _length


func get_target() -> State:
	return _target
