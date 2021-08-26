extends KinematicBody2D
var speed = 5
var vel = Vector2.ZERO

export var direction = 1

func _physics_process(_delta):
	vel.y = min(vel.y + 0.3, 6)
	# warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide(vel * 60, Vector2.UP)
	vel.x = lerp(vel.x, 0, 0.00625)
	if is_on_floor():
		vel.y = 0
	if is_on_wall(): #flip when hitting wall
		direction *= -1
		vel.x *= -1


func _on_CollisionArea_body_entered(body):
	if body.hitbox.global_position.y + body.hitbox.shape.extents.y < global_position.y && body.vel.y > 0:
		print("collided from top")
		$"/root/Main/Player".vel.y = -5
		if body.global_position.x < global_position.x:
			vel.x = speed
		else:
			vel.x = -speed
	elif body.global_position.x < global_position.x:
		print("collided from left")
		vel.x = speed
	elif body.global_position.x > global_position.x:
		print("collided from right")
		vel.x = -speed
