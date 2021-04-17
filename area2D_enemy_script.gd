extends Area2D

onready var lm_counter = $"/root/Main/Player".life_meter_counter
onready var lm_gui = $"/root/Main/Player/Camera2D/GUI/Life_meter_counter"

#kind of screwed setup, but basically body's global position
#is compared to object's global position so the collision
#will be triggered if body's is less or greater
#depending on coordinates

func _on_Area2D_body_entered_hurt(body):
	if body.global_position.x < global_position.x && body.global_position.y > global_position.y:
		print("collided from left")
		lm_counter -= 1
		lm_gui.text = str(lm_counter)
		
		$"/root/Main/Player".vel.x = -4
		$"/root/Main/Player".vel.y = -8
	elif body.global_position.x > global_position.x && body.global_position.y > global_position.y:
		print("collided from right")
		lm_counter -= 1
		lm_gui.text = str(lm_counter)
		
		$"/root/Main/Player".vel.x = 4
		$"/root/Main/Player".vel.y = -8
	if body.global_position.y < global_position.y && (body.global_position.x < global_position.x || body.global_position.x > global_position.x):
		$"../Sprite".set_animation("squish")
		$"/root/Main/Player".vel.y = -5
		print("collided from top")


func _on_squished():
	if $"../Sprite".animation == "squish":
		get_parent().queue_free()
