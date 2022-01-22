extends Area2D



func _on_Shine_body_entered(body):
	body.static_v = true
	body.collect_pos_final = position
	body.collect_pos_init = body.position
	body.collect_time = 0
	$CollisionShape2D.queue_free()
	$SFX.play()
