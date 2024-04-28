class_name JumpSimple
extends JumpState


func _trans_rules():
	if input.buffered_input(&"dive"):
		return &"Dive"

	if input.buffered_input(&"spin"):
		return &"Spin"

	if input.buffered_input(&"pound"):
		return &"PoundSpin"

	if motion.vel.y > 0:
		return [&"Fall", [trans_anims[_anim_index], false]]

	return &""
