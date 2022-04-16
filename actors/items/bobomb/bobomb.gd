extends KinematicBody2D

const GRAVITY = 0.17
const coin = preload("res://actors/items/coin/coin_yellow.tscn")
const explosion = preload("res://actors/items/bobomb/explosion.tscn")
const sfx = {
	"jump": preload("res://audio/sfx/items/goomba/goomba_jump.ogg"),
	"step": preload("res://audio/sfx/items/goomba/goomba_step.wav"),
	#"squish": preload("res://audio/sfx/items/goomba/goomba_jump.ogg"),
	}

var vel = Vector2.ZERO

export var direction = 1

var tracking = false
var wander_dist = 0
var stepped = false
var full_jump = false
var dead = false
var struck = false
var fuse_time = 240
var collect_id
var water_bodies : int = 0

onready var hurtbox = $Hurtbox
onready var base = $Sprites/Base
onready var fuse = $Sprites/Fuse
onready var key = $Sprites/Key
onready var raycast = $RayCast2D
onready var player = $"/root/Main/Player"
onready var sfx_active = $SFXActive
onready var sfx_passive = $SFXPassive
onready var main = $"/root/Main"
onready var lm_counter = $"/root/Singleton".hp


func _ready():
	collect_id = Singleton.get_collect_id()
	base.play()
	fuse.play()
	key.play()


func _process(_delta):
	if [1, 2, 5, 6].find(base.frame) == -1: #offset the fuse and key when the bobomb steps
		fuse.offset.y = 0
		key.offset.y = 0
	else:
		fuse.offset.y = 1
		key.offset.y = 1


func _physics_process(_delta):
	if !is_on_floor():
		raycast.enabled = false
	
	if water_bodies > 0:
		vel.y = min(vel.y + GRAVITY, 2)
	else:
		vel.y = min(vel.y + GRAVITY, 6)
	
	if !struck:
		#raycast2d is used here to detect if the object collided with a wall
		#to change directions
		if direction == 1:
			base.flip_h = true
			fuse.flip_h = true
			if tracking:
				fuse.offset.x = -1
			else:
				fuse.offset.x = -4
			key.flip_h = true
			key.offset.x = -22
		elif direction == -1:
			base.flip_h = false
			fuse.flip_h = false
			fuse.offset.x = 0
			key.flip_h = false
			key.offset.x = 0
		
		if is_on_floor():
			vel.y = GRAVITY
			if is_on_wall() && !tracking:
				vel.x = 0
				flip_ev()
				wander_dist = 0
			
			if !raycast.is_colliding() && raycast.enabled:
				flip_ev()
				
			if base.frame == 1 || base.frame == 5:
				if !stepped:
					sfx_passive.pitch_scale = rand_range(0.9, 1.1)
					sfx_passive.play()
					stepped = true
			else:
				stepped = false
			if tracking:
				base.speed_scale = abs(vel.x) / 2 + 1
				if player.position.x - position.x < -20 || (player.position.x < position.x && abs(player.position.y - position.y) < 26):
					vel.x = max(vel.x - 0.1, -2)
					direction = -1
					raycast.position.x = -9
					base.playing = true
				elif player.position.x - position.x > 20 || (player.position.x > position.x && abs(player.position.y - position.y) < 26):
					vel.x = min(vel.x + 0.1, 2)
					direction = 1
					raycast.position.x = 9
					base.playing = true
				else:
					vel.x *= 0.85
					if base.frame == 0:
						base.playing = false
			else:
				base.speed_scale = 1
				base.playing = true
				if direction == 1:
					vel.x = min(vel.x + 0.1, 1)
				else:
					vel.x = max(vel.x - 0.1, -1)
				wander_dist += 1
				if wander_dist >= 120 && base.frame == 0:
					wander_dist = 0
					direction *= -1
	
	var snap
	if !is_on_floor() || base.animation == "struck":
		snap = Vector2.ZERO
	else:
		snap = Vector2(0, 4)
	#warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide_with_snap(vel * 60, snap, Vector2.UP, true)
	
	if fuse.animation == "lit":
		fuse_time -= 1
		
	if (is_on_floor() && struck) || fuse_time <= 0:
		var spawn = explosion.instance()
		spawn.position = position
		main.add_child(spawn)
		if Singleton.request_coin(collect_id):
			spawn = coin.instance()
			spawn.position = position
			spawn.dropped = true
			main.add_child(spawn)
		queue_free()
	
	for body in hurtbox.get_overlapping_bodies(): #done in process not signals cuz bobombs can be walked through
		if !struck && (body.is_spinning() || (body.is_diving(true) && abs(body.vel.x) > 1)):
			struck = true
			vel.y -= 2.63
			base.animation = "struck"
			fuse.visible = false
			key.visible = false
			vel.x = max((12 + abs(vel.x) / 1.5), 0) * 5.4 * sign(position.x - body.position.x) / 10 * 1.5
		
#the next signals are used for the aggresive trigger
#behaviour, it changes the vel and goes towards
#the player, it also changes the raycast2d because
#after mario goes away, the enemy returns to its
#pacific state

#they also use the same trick as the directional collision
#for hurting mario or the enemy itself, but less complicated
#as we need only the x coordinates


func flip_ev():
	direction *= -1
	raycast.position.x *= -1


func _on_AlertArea_body_entered(body):
	if !tracking:
		if body.position.x > position.x:
			direction = 1
		else:
			direction = -1
		tracking = true
		fuse.animation = "lit"
		wander_dist = 0


func _on_WaterCheck_area_entered(_area):
	water_bodies += 1


func _on_WaterCheck_area_exited(_area):
	water_bodies -= 1
