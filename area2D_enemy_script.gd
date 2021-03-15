extends Area2D

onready var lm_counter = get_node("../../../Player").Life_meter_counter
onready var lm_gui = get_node("../../../Player/Camera2D/GUI/Life_meter_counter")

#kind of screwed setup, but basically body's global position
#is ompared to object's global position so the collision
#will be triggered if bodie's is less or greater
#depending on coordinates

func _on_Area2D_body_entered_hurt(body):
	if body.is_in_group("mario"):
		if body.global_position.x < global_position.x && body.global_position.y > global_position.y:
			print("collided from left")
			lm_counter -= 1
			lm_gui.text = str(lm_counter)
		elif body.global_position.x > global_position.x && body.global_position.y > global_position.y:
			print("collided from right")
			lm_counter -= 1
			lm_gui.text = str(lm_counter)
			
		if body.global_position.y < global_position.y && body.global_position.x < global_position.x:
			print("collided from top")
			queue_free()
		elif body.global_position.y < global_position.y && body.global_position.x > global_position.x:
			print("collided from top")
			queue_free()
		#lm_counter -= 1
		#lm_gui.text = str(lm_counter)
	pass # Replace with function body.
