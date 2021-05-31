extends KinematicBody2D

const GRAVITY = 10
var speed = 50
const FLOOR = Vector2(0, -1)

var velocity = Vector2()

export var direction = 1

var is_jumping = false #this is for stopping goomba's movement and then
#transition to higher speed.

var dir = 0
var tracking = false

onready var sprite = $Sprite
onready var raycast = $RayCast2D

var land_timer = 0

func _ready():
	sprite.animation = "walking"


func _physics_process(_delta):
	if !is_on_floor():
		sprite.frame = 1
		raycast.enabled = false
	
	velocity.x = speed * direction
	
	velocity.y += GRAVITY
	
	velocity = move_and_slide(velocity, FLOOR)
	
	if sprite.animation != "squished":
		#raycast2d is used here to detect if the object collided with a wall
		#to change directions
		if direction == 1:
			sprite.flip_h = true
		elif direction == -1:
			sprite.flip_h = false
		
		if is_on_floor():
			if is_on_wall():
				flip_ev()
				speed = 50
			
			if !raycast.is_colliding() && raycast.enabled:
				flip_ev()
				
			if sprite.animation == "jumping":
				if is_jumping:
					speed = 100
					sprite.frame = 2
					land_timer = 0
					is_jumping = false
					
					if dir == 1:
						direction = 1
						raycast.position.x = 9
					elif dir == 2:
						direction = -1
						raycast.position.x = -9
					
					raycast.enabled = true
				
				land_timer += 0.2
				print(str(sprite.frame) + " " + str(land_timer))
				if land_timer >= 1.8:
					sprite.frame = 0
					sprite.animation = "walking"
				else:
					sprite.frame = 2 + land_timer #finish up jumping anim
			
			
#the next signals are used for the aggresive trigger
#behaviour, it changes the velocity and goes towards
#the player, it also changes the raycast2d because
#after mario goes away, the enemy returns to its
#pacific state

#they also use the same trick as the directional collision
#for hurting mario or the enemy itself, but less complicated
#as we need only the x coordinates

func _on_Collision_mario_detected(body):
	if !tracking:
		tracking = true
		if is_on_floor() && sprite.animation != "jumping":
			if body.global_position.x < global_position.x:
				print("mario on the left")
				dir = 2
			elif body.global_position.x > global_position.x:
				print("mario on the right")
				dir = 1
			speed = 0
			sprite.animation = "jumping"
			sprite.frame = 0
			is_jumping = true
			if direction != 1:
				flip_ev()
			velocity.y = -200


func flip_ev():
	direction *= -1
	raycast.position.x *= -1


func _on_AwareArea_body_exited(body):
	tracking = false
	speed = 50
	if body.global_position.x < global_position.x:
		print("mario went away(left)")
	elif body.global_position.x > global_position.x:
		print("mario went away(right)")
