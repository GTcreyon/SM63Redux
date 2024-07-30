extends JumpFlip


const OFFSET_START = Vector2(-2, -4)
const OFFSET = Vector2(1, -2)
const OFFSET_FLUDD = Vector2(-1, -6)


func _all_ticks():
	super()
	# Update sprite's rotation origin for a nicer looking flip.
	if _flip_frames > 3:
		# TODO: Different origin if wearing FLUDD, for visual balance.
		#if current_nozzle == Singleton.Nozzles.NONE:
			actor.sprite.set_rotation_origin(OFFSET)
		#else:
		#actor.sprite.set_rotation_origin(OFFSET_FLUDD)
	else:
		# Use a slightly different rotation origin in the first 3 frames.
		actor.sprite.set_rotation_origin(OFFSET_START)


func _on_exit():
	super()
	
	# Ensure abnormal rotation origin is cleaned up.
	actor.sprite.clear_rotation_origin()


func _trans_rules():
	if input.buffered_input(&"dive"):
		return &"Dive"
	if _flip_frames >= _flip_time_half and input.buffered_input(&"spin"):
		return &"Spin"
	return super()
