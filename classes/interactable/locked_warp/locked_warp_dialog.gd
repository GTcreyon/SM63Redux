extends InteractableDialog

export(NodePath) onready var warp = get_node(warp) as InteractableWarp

func _ready():
	# Validate child warp object.
	assert(warp)
	
	# Disable the child warp so it doesn't get used by mistake.
	warp.disabled = true


func _interact_check() -> bool:
	# Passthrough to inner warp's interact check.
	return warp._interact_check()


func _interact_with(body):
	if false: # has key
		# TODO: Unlock sequence.
		
		# Passthrough to inner warp's interaction.
		warp._interact_with(body)
	else:
		# Has not key. Use base interaction.
		._interact_with(body)
