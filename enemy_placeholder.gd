extends KinematicBody2D

const GRAVITY = 10
var speed = 50
const FLOOR = Vector2(0, -1)

var velocity = Vector2()

export var direction = 1

func _physics_process(_delta):
	
	velocity.x = speed * direction
	
	velocity.y += GRAVITY
	
	velocity = move_and_slide(velocity, FLOOR)
	
	#raycast2d is used here to detect if the object collided with a wall
	#to change directions
	if is_on_wall():
		direction *= -1
		$RayCast2D.position.x *= -1
	
	if $RayCast2D.is_colliding() == false:
		direction *= -1
		$RayCast2D.position.x *= -1

#the next signals are used for the aggresive trigger
#behaviour, it changes the velocity and goes towards
#the player, it also changes the raycast2d because
#after mario goes away, the enemy returns to its
#pacific state

#they also use the same trick as the directional collision
#for hurting mario or the enemy itself, but less complicated
#as we need only the x coordinates

func _on_Collision_mario_detected(body):
	if body.global_position.x < global_position.x:
		speed = 100
		print("mario on the left")
		if direction != -1:
			direction *= -1
			$RayCast2D.position.x *= -1
	elif body.global_position.x > global_position.x:
		speed = 100
		print("mario on the right")
		if direction != 1:
			direction *= -1
			$RayCast2D.position.x *= -1
	pass # Replace with function body.


func _on_Collision_detect_left(body):
	if body.global_position.x < global_position.x:
		speed = 50
		print("mario went away(left)")
	elif body.global_position.x > global_position.x:
		speed = 50
		print("mario went away(right)")
	pass # Replace with function body.
