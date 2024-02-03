extends StateManager

@export var _input: PlayerInput = null
@export var _motion: Motion = null


func _custom_passdowns():
	return {
		&"input": _input,
		&"motion": _motion,
	}


var active = true
func _physics_process(_delta):
	if Input.is_action_just_pressed("ld_snap"):
		active = !active
	if !active:
		_motion.set_vel(Vector2.ZERO)
		return
	super(_delta)
