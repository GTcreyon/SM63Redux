extends AnimatedSprite
onready var player = $"/root/Main/Player"
var koopa = preload("koopa.tscn").instance()
var shell = preload("koopa_shell.tscn").instance()


func _on_KoopaCollision_body_entered(_body):
	if player.is_spinning():
		spawn_shell()
	else:
		if player.position.y < position.y:
			$Kick.play()
			koopa.position = Vector2(position.x, player.position.y + 33)
			koopa.vel.y = player.vel.y
			if flip_h:
				koopa.direction = 1
			else:
				koopa.direction = -1
			player.vel.y = -5
			get_parent().call_deferred("add_child", koopa)
			$KoopaCollision.set_deferred("monitoring", false)
			$Damage.monitoring = false
			set_deferred("visible", false)
			visible = false


func _on_Kick_finished():
	queue_free()


func _on_Damage_body_entered(body):
	if player.is_spinning():
		spawn_shell()
	else:
		if body.global_position.x < global_position.x:
			#print("collided from left")
			player.take_damage_shove(1, -1)
		elif body.global_position.x > global_position.x:
			#print("collided from right")
			player.take_damage_shove(1, 1)


func spawn_shell():
	$Kick.play()
	$"/root/Main/Player".vel.y = -5
	get_parent().call_deferred("add_child", shell)
	shell.position = position + Vector2(0, 7.5)
	if player.global_position.x < global_position.x:
		shell.vel.x = 5
	else:
		shell.vel.x = -5
	$KoopaCollision.set_deferred("monitoring", false)
	$Damage.monitoring = false
	set_deferred("visible", false)
