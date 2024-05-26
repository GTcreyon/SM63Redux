extends JumpFlip

func _on_enter(handover):
	# Force application of 8 frames of friction.
	# When chaining dives, Redux only has the player on the ground for a single frame.
	# The original game keeps the player on the ground significantly longer.
	# This causes additional frames of friction to be applied (about 4).
	# Additionally, a single frame in Redux is worth about half of one in the original.
	# So we need double the required friction.
	# I hope so, at least.
	for i in 8:
		motion.legacy_friction_x(0.2, 1.05)
	super(handover)


func _trans_rules():
	if input.buffered_input(&"dive") and _flip_frames > _flip_time_half:
		return &"Dive"
	if input.buffered_input(&"spin"):
		return &"Spin"
	return super()
