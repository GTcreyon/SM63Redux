extends Area2D

onready var lm_counter = get_node("../../../Player").Life_meter_counter
onready var lm_gui = get_node("../../../Player/Camera2D/GUI/Life_meter_counter")

func _on_Area2D_body_entered_hurt(body):
	if body.is_in_group("mario"):
		lm_counter -= 1
		lm_gui.text = str(lm_counter)
	pass # Replace with function body.
