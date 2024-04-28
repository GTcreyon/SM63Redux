extends AirborneState

var _stylish: bool

func _on_enter(handover):
	_stylish = false
	if handover == null:
		_anim(&"fall")
	else:
		_anim(handover[0])
		_stylish = handover[1]


func _all_ticks():
	super()
	if Input.is_action_pressed("jump"):
		motion.legacy_accel_y(-0.1, true)
	motion.apply_gravity(1.0, true)
	if motion.vel.y > 0:
		motion.legacy_friction_y(0.2, 1.05)


func _trans_rules():
	if input.buffered_input(&"spin"):
		return &"Spin"

	if actor.is_on_floor():
		if _stylish:
			return &"StylishLand"
		else:
			return &"Land"

	if input.buffered_input(&"dive"):
		return &"Dive"

	if input.buffered_input(&"pound"):
		return &"PoundSpin"

	return &""
