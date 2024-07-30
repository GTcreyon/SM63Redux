extends JumpFlip


const OFFSET = Vector2(1, -2)
const OFFSET_FLUDD = Vector2(-1, -6)


func _all_ticks():
	super()
	# Update sprite's rotation origin for a nicer looking flip.
	# TODO: Different origin if wearing FLUDD, for visual balance.
	#if current_nozzle == Singleton.Nozzles.NONE:
	actor.sprite.set_rotation_origin(OFFSET)
	#else:
		#actor.sprite.set_rotation_origin(OFFSET_FLUDD)


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
