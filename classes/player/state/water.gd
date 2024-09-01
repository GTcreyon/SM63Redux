extends PlayerState

@export var water_check: Area2D

func _trans_rules():
	if not water_check.has_overlapping_areas():
		if Input.is_action_pressed(&"swim"):
			motion.vel.y = 0
			return &"WaterEscape"
		return &"Air"
	if input.buffered_input(&"spin"):
		return &"SpinWater"
	return &""
