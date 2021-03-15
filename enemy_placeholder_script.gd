extends KinematicBody2D

const GRAVITY = 10
const SPEED = 50
const FLOOR = Vector2(0, -1)

var velocity = Vector2()

var direction = 1

func _physics_process(_delta):
	
	velocity.x = SPEED * direction
	
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
	
	pass


#kind of screwed setup, but basically body's global position
#is ompared to object's global position so the collision
#will be triggered if bodie's is less or greater
#depending on coordinates

func _on_Area2D_body_entered_for_deletion(body):
	if body.is_in_group("mario"):
		if body.global_position.y < global_position.y && body.global_position.x < global_position.x:
			print("collided from top")
			queue_free()
		elif body.global_position.y < global_position.y && body.global_position.x > global_position.x:
			print("collided from top")
			queue_free()
	pass # Replace with function body.
