extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)
const coin = preload("res://actors/items/coin/coin_yellow.tscn")
const sfx = {
	"jump": preload("res://audio/sfx/items/goomba/goomba_jump.ogg"),
	"step": preload("res://audio/sfx/items/goomba/goomba_step.wav"),
	#"squish": preload("res://audio/sfx/items/goomba/goomba_jump.ogg"),
	}

var vel = Vector2()

export var direction = 1

var is_jumping = false #this is for stopping goomba's movement and then
#transition to higher speed.

var tracking = false
var wander_dist = 0
var stepped = false
var full_jump = false
var dead = false
var struck = false

onready var sprite = $Sprite
onready var raycast = $RayCast2D
onready var player = $"/root/Main/Player"
onready var sfx_active = $SFXActive
onready var sfx_passive = $SFXPassive
onready var main = $"/root/Main"
onready var lm_counter = player.life_meter_counter
onready var lm_gui = $"/root/Main/Player/Camera2D/GUI/LifeMeterCounter"
var land_timer = 0

func _ready():
	sprite.animation = "walking"


func _physics_process(_delta):
	if sprite.animation == "squish":
		if dead:
			var spawn = coin.instance()
			spawn.position = position
			spawn.dropped = true
			main.add_child(spawn)
			queue_free()
		elif !struck:
			if player.position.y + 16 > global_position.y - 10:
				player.vel.y = 0
				player.position.y += 0.5
			if Input.is_action_just_pressed("jump"):
				full_jump = true
			
		if sprite.frame == 3:
			if !struck:
				if Input.is_action_pressed("jump"):
					if full_jump:
						player.vel.y = -6.5
					else:
						player.vel.y = -6
				else:
					player.vel.y = -5
				player.switch_state(player.s.walk)
			dead = true #apparently queue_free() doesn't cancel the current cycle
			
	#code to push enemies apart - maybe come back to later?
#	for area in get_overlapping_areas():
#		if area != player:
#			if global_position.x > area.global_position.x || (global_position.x == area.global_position.x && id > area.id):
#				get_parent().vel.x += 7.5
#			else:
#				get_parent().vel.x -= 7.5

	if !is_on_floor() && sprite.animation != "squish":
		sprite.frame = 1
		raycast.enabled = false
	
	vel.y += GRAVITY
	
	if sprite.animation != "squish" && !struck:
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
					sprite.speed_scale = abs(vel.x) / 100 + 1
					if player.position.x - position.x < -20 || (player.position.x < position.x && abs(player.position.y - position.y) < 26):
						vel.x = max(vel.x - 5, -100)
						direction = -1
						raycast.position.x = -9
						sprite.playing = true
					elif player.position.x - position.x > 20 || (player.position.x > position.x && abs(player.position.y - position.y) < 26):
						vel.x = min(vel.x + 5, 100)
						direction = 1
						raycast.position.x = 9
						sprite.playing = true
					else:
						vel.x *= 0.85
						if sprite.frame == 0:
							sprite.playing = false
				else:
					sprite.speed_scale = 1
					sprite.playing = true
					if direction == 1:
						vel.x = min(vel.x + 5, 50)
					else:
						vel.x = max(vel.x - 5, -50)
					wander_dist += 1
					if wander_dist >= 120 && sprite.frame == 0:
						wander_dist = 0
						direction *= -1
		else:
			sprite.animation = "jumping"
			if !is_jumping:
				sprite.frame = 1
		
	vel = move_and_slide(vel, FLOOR)
	if is_on_floor() && struck && sprite.animation != "squish":
		sprite.animation = "squish"
		sprite.frame = 0
		sprite.playing = true
		
#the next signals are used for the aggresive trigger
#behaviour, it changes the vel and goes towards
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
			vel.y = -150
		wander_dist = 0


func flip_ev():
	direction *= -1
	raycast.position.x *= -1


func _on_AwareArea_body_exited(body):
	if body == player:
		tracking = false


func _on_Area2D_body_entered_hurt(body):
	if body == player:
		if sprite.animation != "squish":
			if body.hitbox.global_position.y + body.hitbox.shape.extents.y - body.vel.y - 6 < position.y && body.vel.y > 0:
				sprite.animation = "squish"
				struck = false
				vel.y = 0
				sprite.frame = 0
				sprite.playing = true
				player.switch_state(player.s.ejump)
			elif !struck:
				if player.state == player.s.spin && player.spin_timer > 0:
					struck = true
					vel.y -= 158
					sprite.animation = "jumping"
					vel.x += max((12 + vel.x * sign(player.position.x - position.x) / 1.5), 0) * 5.4 
				else:
					lm_counter -= 1
					lm_gui.text = str(lm_counter)
					
					player.vel.x += 4 * sign(body.position.x - position.x)
					player.vel.y += -8

