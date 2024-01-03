class_name StateManager
extends State
## Root node of a state machine.
## Manages the execution of hook functions in the machine.


@export var target_actor: Node = null
@export var initial_state: State = null


func _ready():
	var pass_downs = {
		&"actor": target_actor,
		&"manager": self,
	}

	pass_downs.merge(_custom_passdowns())

	for key in pass_downs:
		recurse_descendents(&"set", [key, pass_downs[key]])

	await target_actor.ready

	# Switch to and initialise the initial state, if there is one.
	if initial_state != null:
		var link = StateLink.new(self, initial_state)
		_switch_leaf(link)
		live_substate.trigger_enter(null)


func _physics_process(_delta):
	recurse_live("probe_switch", [], true)

	if live_substate != null:
		# Call the tick hook function.
		live_substate.recurse_live("tick_hook")


func _custom_passdowns() -> Dictionary:
	return {}
