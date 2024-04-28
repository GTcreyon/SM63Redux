class_name DummyJump
extends PlayerState
## General jump action.


## Minimum X velocity required to perform the third consecutive jump.
const TRIPLE_MIN_VEL: float = 1


func _on_enter(_handover):
	motion.consume_coyote_timer()


func _defer_rules():
	if not motion.active_consec_time():
		return &"Jump"

	match motion.consec_jumps:
		2:
			var x_dir = input.get_x()
			if abs(motion.vel.x) > TRIPLE_MIN_VEL and sign(motion.vel.x) == x_dir:
				return &"JumpTriple"
			else:
				return &"JumpDouble"
		1:
			return &"JumpDouble"
		_:
			return &"Jump"
