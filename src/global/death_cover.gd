extends ColorRect

onready var singleton = get_parent()

func _process(_delta):
	if singleton.dead:
		color.a = min(color.a + 1.0/30.0, 1)
		if color.a >= 1:
			singleton.dead = false
			singleton.hp = 8
			#warning-ignore:RETURN_VALUE_DISCARDED
			Singleton.warp_to(get_tree().get_current_scene().get_filename())
	else:
		color.a = max(color.a - 1.0/30.0, 0)
