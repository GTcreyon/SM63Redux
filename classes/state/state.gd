class_name State
extends Node
## Abstract state class with behavior that affects a target node.


## The current active substate.
var live_substate: State = null
## The target of this state machine's behavior.
var actor: CharacterBody2D
## The interface to the audiovisual components of this state machine.
var av: AVManager

## The name of the AV effect that this state should trigger.
@export var effect := &""
var links: Array[State] = []
var _link_cache: Dictionary = {}

## True when on the first cycle of the physics loop.
var _first_cycle: bool = true


func _to_string():
	return str(name)


func _ready():
	if true:
		_lazy_link_cache()
	_cache_links()


## Temporary. Do not use for final product.
func _lazy_link_cache():
	var node
	links = []
	var next = [owner.get_node("StateManager")]
	while !next.is_empty():
		node = next.pop_back()
		next.append_array(node.get_children())
		links.append(node)


## Cache links to other states.
func _cache_links() -> void:
	for target in links:
		var link = StateLink.new(self, target)
		_link_cache[target.get_name()] = link


## Called on all cycles of the physics process loop.
func _cycle_tick() -> void:
	pass


## Called on the first cycle of the physics process loop.
func _pre_tick() -> void:
	pass


## Called on subsequent cycles of the physics process loop.
func _post_tick() -> void:
	pass


## Calls the fixed tick functions
func tick_hook() -> void:
	if _first_cycle:
		_pre_tick()
		_first_cycle = false
	else:
		_post_tick()
	
	_cycle_tick()


## Called when the state becomes active.
func _on_enter(_handover: Variant) -> void:
	pass


## Called when the state is deactivated.
func _on_exit() -> void:
	pass


## Return the name of a state for the parent to switch to, or `null` for no change.
## This is called by the parent state during probe_switch() at the start of the physics tick.
## This function should be used to define the transition rules for the state.
func tell_switch() -> Variant:
	return &""


## Return the name of a passthrough state.
## When this state is switched to, immediately switch to that state.
## This means that other states don't have to guess the behavior of this state when switching to a child of it.
func tell_defer() -> StringName:
	return &""


## Probe the active substate for a state to switch to.
## This is based on its transition rules defined in tell_switch().
## If a state is found, switch to that state.
func probe_switch(defer: bool = false) -> void:
	var link_name
	var handover = null
	if defer:
		link_name = tell_defer()
	else:
		var data
		data = tell_switch()
		if data is Array:
			link_name = data[0]
			handover = data[1]
		else:
			link_name = data
	
	# Only switch if we need to
	if link_name != &"":
		var link = get_link(link_name)
		_switch_leaf(link, handover)


## Force a switch to a different state, even if it's not cached.
## Generally avoid using this, since it's not performant.
## Use tell_switch() rules where possible.
func hard_switch(target: State) -> void:
	var target_name = target.name
	var link
	if _link_cache.has(target_name):
		link = _link_cache[target_name]
	else:
		link = StateLink.new(self, target)
		_link_cache[target_name] = link
	_switch_leaf(link)


## Reroute the active path to select a given state as the active leaf.
func _switch_leaf(link: StateLink, handover = null) -> void:
	var path = link.get_path()
	var peak = link.get_peak_index()
	var length = link.get_length()
	var last = length - 1
	var arg = null
	
	var current_state: State = self
	for i in length:
		var next_state: State = path[i]
		
		if i <= peak:
			ditch_state()
		else:
			if i == last:
				arg = handover
			current_state.switch_substate(next_state, arg)
		
		assert(current_state != next_state)
		current_state = next_state
	
	current_state.probe_switch(true)


## Ditch this state and all its descendents,
## making this branch of the state tree inactive.
func ditch_state():
	_on_exit()
	
	# Ditch live descendents
	if live_substate == null: return
	live_substate.ditch_state()
	live_substate = null


## Activate the given state, ditching the current state.
func switch_substate(new_state: State, handover: Variant):
	if new_state == live_substate: return
	if new_state == null: return
	
	if live_substate != null:
		live_substate.ditch_state()
	
	live_substate = new_state
	
	new_state.trigger_enter(handover)


## Trigger entrance events for a new state.
func trigger_enter(handover: Variant):
	_first_cycle = true
	_on_enter(handover)
	
	if av != null and effect != &"":
		av.trigger_effect(effect)


## Call a function on the live substate, but only if there is one.
func call_live(function_name: StringName, arguments := []):
	if live_substate != null:
		live_substate.call_func(function_name, arguments)


## Call a function on this state and all its live descendents.
func recurse_live(function_name: StringName, arguments := []):
	call_func(function_name, arguments)
	call_live(&"recurse_live", [function_name, arguments])


## Call a function on this state and its entire descendant family.
func recurse_descendents(function_name: StringName, arguments := []):
	call_func(function_name, arguments)
	
	for child in get_children():
		child.recurse_descendents(function_name, arguments)


## Call a callable from a function name and given arguments.
func call_func(function_name: StringName, arguments := []):
	var callable := Callable(self, function_name)
	
	callable.callv(arguments)


## Get a link to the given state.
func get_link(key: StringName) -> StateLink:
	assert(_link_cache.has(key), "Link \"%s\" is not cached." % key)
	return _link_cache[key]
