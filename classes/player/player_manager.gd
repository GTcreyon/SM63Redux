extends StateManager

@export var _input: PlayerInput = null
@export var _motion: Motion = null


func _custom_passdowns():
	return {
		&"input": _input,
		&"motion": _motion,
	}
