extends KinematicBody2D

var player = null
var move = Vector2.ZERO
export var speed = 1
var direction = null

func _physics_process(delta):
	move = Vector2.ZERO
	
	if player != null:
		direction = player.position - position
		move = position.direction_to(player.position) * speed
		rotation = direction.angle()
		if rotation >= 270:
			$Sprite.flip_v = true
	else:
		move = Vector2.ZERO
	
		
	move = move.normalized()
	move = move_and_collide(move)
	

func _on_Following_body_entered(body):
	if body != self:
		player = body


func _on_Following_body_exited(body):
	player = null


func _on_Disable_body_entered(body):
	player = null
