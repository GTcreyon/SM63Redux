extends KinematicBody2D

const GRAVITY = 10
var speed = 50
const FLOOR = Vector2(0, -1)

var velocity = Vector2()

export var direction = 1

var is_jumping = false #this is for stopping goomba's movement and then
#transition to higher speed.

var dir = 0

func _physics_process(_delta):
	if is_jumping:
		$RayCast2D.set_enabled(false)
		
		var t = Timer.new()
		t.set_wait_time(0.1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		
		position.y += -3.5
	
	velocity.x = speed * direction
	
	velocity.y += GRAVITY
	
	velocity = move_and_slide(velocity, FLOOR)
	
	#raycast2d is used here to detect if the object collided with a wall
	#to change directions
	if !is_jumping:
		if is_on_wall():
			flip_ev()
			speed = 50
		
		if $RayCast2D.is_colliding() == false:
			flip_ev()
		
	if direction == 1:
		$Sprite.flip_h = true
	elif direction == -1:
		$Sprite.flip_h = false

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
		speed = 0
		$Sprite.set_animation("jumping")
		is_jumping = true
		dir = 2
		
		print("mario on the left")
		if direction != -1:
			flip_ev()

	elif body.global_position.x > global_position.x:
		speed = 0
		$Sprite.set_animation("jumping")
		print("mario on the right")
		is_jumping = true
		dir = 1
		
		if direction != 1:
			flip_ev()

func _on_Collision_detect_left(body):
	if body.global_position.x < global_position.x:
		speed = 50
		print("mario went away(left)")
	elif body.global_position.x > global_position.x:
		speed = 50
		print("mario went away(right)")

func _on_Goomba_floor():
	if $Sprite.animation == "jumping":
		speed = 100
		$Sprite.set_animation("walking")
		is_jumping = false
		
		if dir == 1:
			direction = 1
			$RayCast2D.position.x = 1
		elif dir == 2:
			direction = -1
			$RayCast2D.position.x = -1
		
		$RayCast2D.set_enabled(true)

func flip_ev():
	direction *= -1
	$RayCast2D.position.x *= -1
