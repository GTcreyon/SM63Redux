extends Area2D

var crossed_item = false
var mario = null
var timer = 30

func _physics_process(delta):
	if crossed_item:
		if mario.singleton.hp < 8:
			if timer >= 30:
				mario.recieve_health(1)
				timer = 0
			else:
				timer += 1
		else:
			crossed_item = false
			$AnimatedSprite.set_speed_scale(1.0)
			timer = 30
			mario = null

func _on_Heart_body_entered(body):
	crossed_item = true
	mario = body
	$AnimatedSprite.set_speed_scale(5.0)
