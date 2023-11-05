class_name StateManager
extends State
## Root node of a state machine.
## Manages the execution of hook functions in the machine.

@export var target_actor: Node = owner
@export var target_av: AVManager = null
@export var initial_state: State = null


func _ready():
	recurse_descendents(&"set", [&"actor", target_actor])
	recurse_descendents(&"set", [&"av", target_av])
	await target_actor.ready
	
	# Switch to and initialise the initial state, if there is one.
	if initial_state != null:
		var link = StateLink.new(self, initial_state)
		_switch_leaf(link)
		live_substate.trigger_enter(null)


func _physics_process(_delta):
	recurse_live("probe_switch")

	if live_substate != null:
		# Call the tick hook function.
		live_substate.recurse_live("tick_hook")
