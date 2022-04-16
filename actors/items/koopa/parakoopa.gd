extends AnimatedSprite
var koopa = preload("koopa.tscn").instance()
var shell = preload("koopa_shell.tscn").instance()

func _ready():
	frame = hash(position.x + position.y * PI) % 6
	playing = true


func _on_TopCollision_body_entered(body):
	if body.is_spinning():
		spawn_shell(body)
	else:
		if body.vel.y > -2:
			$Kick.play()
			koopa.position = Vector2(position.x, body.position.y + 33)
			koopa.vel.y = body.vel.y
			if flip_h:
				koopa.direction = -1
			else:
				koopa.direction = 1
			body.vel.y = -5.5
			body.vel.x *= 1.2
			get_parent().call_deferred("add_child", koopa)
			$TopCollision.set_deferred("monitoring", false)
			$Damage.monitoring = false
			set_deferred("visible", false)
			visible = false


func _on_Kick_finished():
	queue_free()


func _on_Damage_body_entered(body):
	if !body.is_diving(true):
		if body.is_spinning():
			spawn_shell(body)
		else:
			if body.global_position.x < global_position.x:
				#print("collided from left")
				body.take_damage_shove(1, -1)
			elif body.global_position.x > global_position.x:
				#print("collided from right")
				body.take_damage_shove(1, 1)


func spawn_shell(body):
	$Kick.play()
	body.vel.y = -5
	get_parent().call_deferred("add_child", shell)
	shell.position = position + Vector2(0, 7.5)
	if body.global_position.x < global_position.x:
		shell.vel.x = 5
	else:
		shell.vel.x = -5
	$TopCollision.set_deferred("monitoring", false)
	$Damage.monitoring = false
	set_deferred("visible", false)
