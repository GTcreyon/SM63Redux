extends ColorRect

func _process(delta):
	var dmod = 60 * delta
	if Singleton.dead:
		color.a = min(color.a + 1.0/30.0 * dmod, 1)
		if color.a >= 1:
			Singleton.dead = false
			Singleton.hp = 8
			#warning-ignore:RETURN_VALUE_DISCARDED
			Singleton.warp_to(get_tree().get_current_scene().get_filename())
	else:
		color.a = max(color.a - 1.0/30.0 * dmod, 0)
