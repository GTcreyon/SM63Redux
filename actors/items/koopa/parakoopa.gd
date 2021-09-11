extends AnimatedSprite
onready var player = $"/root/Main/Player"
var koopa = preload("koopa.tscn").instance()


func _on_KoopaCollision_body_entered(_body):
	$Kick.play()
	koopa.position = position + Vector2(0, 4)
	koopa.vel.y = player.vel.y
	if flip_h:
		koopa.direction = 1
	else:
		koopa.direction = -1
	player.vel.y = -5
	get_parent().call_deferred("add_child", koopa)
	$KoopaCollision.set_deferred("monitoring", false)
	set_deferred("visible", false)
	visible = false


func _on_Kick_finished():
	queue_free()


func _on_Damage_body_entered(body):
	if body.global_position.x < global_position.x && body.global_position.y > global_position.y:
		print("collided from left")
		player.take_damage_shove(1, -1)
	elif body.global_position.x > global_position.x && body.global_position.y > global_position.y:
		print("collided from right")
		player.take_damage_shove(1, 1)
