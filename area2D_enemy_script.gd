extends Area2D

onready var player = $"/root/Main/Player"
onready var sprite = get_owner().get_node("Sprite")
onready var lm_counter = player.life_meter_counter
onready var lm_gui = $"/root/Main/Player/Camera2D/GUI/Life_meter_counter"

#kind of screwed setup, but basically body's global position
#is compared to object's global position so the collision
#will be triggered if body's is less or greater
#depending on coordinates

func _on_Area2D_body_entered_hurt(body):
	if body.hitbox.global_position.y + body.hitbox.shape.extents.y < global_position.y && body.vel.y > 0:# && (body.global_position.x < global_position.x || body.global_position.x > global_position.x):
		sprite.animation = "squish"
		player.vel.y = -5
		print("collided from top")
	elif body.global_position.x < global_position.x:# && body.global_position.y > global_position.y:
		print("collided from left")
		lm_counter -= 1
		lm_gui.text = str(lm_counter)
		
		player.vel.x += -4
		player.vel.y += -8
	elif body.global_position.x > global_position.x:# && body.global_position.y > global_position.y:
		print("collided from right")
		lm_counter -= 1
		lm_gui.text = str(lm_counter)
		
		player.vel.x += 4
		player.vel.y += -8


func _on_squished():
	if sprite.animation == "squish":
		get_parent().queue_free()
