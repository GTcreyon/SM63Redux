class_name DummyJump
extends PlayerState
## General jump action.


## Minimum X velocity required to perform the third consecutive jump.
const TRIPLE_MIN_VEL: float = 1


func _on_enter(_handover):
	motion.consume_coyote_timer()


func _tell_defer():
	if not motion.active_consec_time():
		return &"Jump"

	match motion.consec_jumps:
		2:
			if abs(actor.vel.x) > TRIPLE_MIN_VEL and sign(actor.vel.x) == motion.facing_direction:
				return &"TripleJump"
			else:
				return &"DoubleJump"
		1:
			return &"DoubleJump"
		_:
			return &"Jump"
