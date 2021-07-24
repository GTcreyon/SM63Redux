extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)
const sfx = {
	"jump": preload("res://audio/sfx/items/goomba/goomba_jump.ogg"),
	"step": preload("res://audio/sfx/items/goomba/goomba_step.wav"),
	#"squish": preload("res://audio/sfx/items/goomba/goomba_jump.ogg"),
	}

var velocity = Vector2()

export var direction = 1

var is_jumping = false #this is for stopping goomba's movement and then
#transition to higher speed.

var tracking = false
var wander_dist = 0
var stepped = false

onready var sprite = $Sprite
onready var raycast = $RayCast2D
onready var player = $"/root/Main/Player"
onready var sfx_active = $SFXActive
onready var sfx_passive = $SFXPassive

var land_timer = 0

func _ready():
	sprite.animation = "walking"


func _physics_process(_delta):
	if !is_on_floor() && sprite.animation != "squish":
		sprite.frame = 1
		raycast.enabled = false
	
	velocity.y += GRAVITY
	
	if sprite.animation != "squish":
		#raycast2d is used here to detect if the object collided with a wall
		#to change directions
		if direction == 1:
			sprite.flip_h = true
		elif direction == -1:
			sprite.flip_h = false
		
		if is_on_floor():
			if is_on_wall() && !tracking:
				flip_ev()
				wander_dist = 0
			
			if !raycast.is_colliding() && raycast.enabled:
				flip_ev()
				
			if sprite.animation == "jumping":
				if is_jumping:
					sprite.frame = 2
					land_timer = 0
					is_jumping = false
					raycast.enabled = true
				
				land_timer += 0.2
				print(str(sprite.frame) + " " + str(land_timer))
				if land_timer >= 1.8:
					sprite.frame = 0
					sprite.animation = "walking"
				else:
					sprite.frame = 2 + land_timer #finish up jumping anim
			else:
				if sprite.frame == 0 || sprite.frame == 3:
					if !stepped:
						sfx_passive.pitch_scale = rand_range(0.9, 1.1)
						sfx_passive.play()
						stepped = true
				else:
					stepped = false
				if tracking:
					sprite.speed_scale = abs(velocity.x) / 100 + 1
					if player.position.x - position.x < -20 || (player.position.x < position.x && abs(player.position.y - position.y) < 26):
						velocity.x = max(velocity.x - 5, -100)
						direction = -1
						raycast.position.x = -9
						sprite.playing = true
					elif player.position.x - position.x > 20 || (player.position.x > position.x && abs(player.position.y - position.y) < 26):
						velocity.x = min(velocity.x + 5, 100)
						direction = 1
						raycast.position.x = 9
						sprite.playing = true
					else:
						velocity.x *= 0.85
						if sprite.frame == 0:
							sprite.playing = false
				else:
					sprite.speed_scale = 1
					sprite.playing = true
					if direction == 1:
						velocity.x = min(velocity.x + 5, 50)
					else:
						velocity.x = max(velocity.x - 5, -50)
					wander_dist += 1
					if wander_dist >= 120 && sprite.frame == 0:
						wander_dist = 0
						direction *= -1
		else:
			sprite.animation = "jumping"
			if !is_jumping:
				sprite.frame = 1
		
	velocity = move_and_slide(velocity, FLOOR)
#the next signals are used for the aggresive trigger
#behaviour, it changes the velocity and goes towards
#the player, it also changes the raycast2d because
#after mario goes away, the enemy returns to its
#pacific state

#they also use the same trick as the directional collision
#for hurting mario or the enemy itself, but less complicated
#as we need only the x coordinates

func _on_Collision_mario_detected(body):
	if !tracking && sprite.animation != "squish":
		if player.position.x > position.x:
			direction = 1
		else:
			direction = -1
		tracking = true
		if is_on_floor():
			sprite.animation = "jumping"
			sfx_active.stream = sfx["jump"]
			sfx_active.play()
			sprite.frame = 0
			is_jumping = true
			velocity.y = -150
		wander_dist = 0


func flip_ev():
	direction *= -1
	raycast.position.x *= -1


func _on_AwareArea_body_exited(body):
	if body == player:
		print("lost")
		tracking = false
