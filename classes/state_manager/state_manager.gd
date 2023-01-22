extends Node

class_name StateManager

signal state_changed(current_state_ref)

#Generic multi-purpose state manager class (can be extended!)
#Be sure to call process_state in either _physics_process or _process!

export(NodePath) var default_state

var state_index: Dictionary = {} #index of all states. Updated on every query.

var current_state : State

var state_error_msg: Dictionary = {
State.error.ERROR_START_CONDITIONS_NOT_MET: "Starting conditions for state %s were not met.",
State.error.ERROR_STOP_CONDITIONS_NOT_MET: "Stopping conditions for state %s were not met.",
State.error.ERROR_STATE_BUSY: "State %s has a thread still open",
State.error.ERROR_STATE_BLACKLISTED: "State %s is blacklisted by the current state.",
State.error.ERROR_STATE_NOT_FOUND: "State %s was not found."
}

onready var host = owner #This is the node the state manager will control (default is the state manager's parent node)

func _ready():
	refresh_state_index()
	var state_ref = get_state_by_name(get_node(default_state).name)
	if state_ref:
		current_state = state_ref


func change_state(state_name: String, msg: Dictionary = {}): #see state.gd for more info on `msg`
	if current_state:
		var result = current_state._check_stop_conditions() #TODO: Try to find a way to clean this up...
		if result == true:
			current_state._stop()
			var state_ref = get_state_by_name(state_name)
			if state_ref:
				for i in current_state.blacklist:
					if state_ref.name == i:
						throw_error(state_ref.name, State.error.ERROR_STATE_BLACKLISTED)
				result = state_ref._check_start_conditions()
				if result == true:
					current_state = get_state_by_name(state_name)
					current_state.message = msg
					current_state._start()
					return
				else:
					throw_error(state_ref.name, State.error.ERROR_START_CONDITIONS_NOT_MET)
					return
				throw_error(state_ref.name, result)
				return
			throw_error(state_name, State.error.ERROR_STATE_NOT_FOUND)
		throw_error(current_state.name, result)
		return
	else:
		push_error("(%s) State change failed: current_state was null. Resetting to default state.")
		current_state = default_state


func process_state(delta):
	current_state._update(delta)

func get_state_by_name(state_name: String):#looks up a state name in the state_index
	if state_index.has(state_name):			#and returns a reference to it if it exists
			return state_index[state_name]
	else:
		throw_error(state_name, State.error.ERROR_STATE_NOT_FOUND)

func get_state_category(state_name):
	return state_index[state_name].category


func get_states_by_category(category: String, exclude: PoolStringArray = [""]): #exclude is a list of state names to be excluded from the search
	var rtv: PoolStringArray #rtv = return var; returns an array with the names of states with the same category
	for state in state_index.keys():
		var is_excluded: bool = false
		for string in exclude:
			if state == string:
				is_excluded = true
		if state_index[state].category == category and !is_excluded:
			rtv.append(state)

func refresh_state_index():
	state_index = {} #Does this cause a memory leak? TODO: investigate
	for child in get_children():
		if child is State: #if ref exists (is not null)...
			child.owner = self #set the current parented state manager
			state_index[child.name] = child


func throw_error(state_name: String, error):
	push_error("(%s) State change failed: %s" % [self.name, state_error_msg[error] % state_name])

