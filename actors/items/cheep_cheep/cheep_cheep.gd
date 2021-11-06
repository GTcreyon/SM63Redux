extends KinematicBody2D

const coin = preload("res://actors/items/coin/coin_yellow.tscn")
const speed = 32.0/60.0

var follow = false
var can_follow = false
var vel = Vector2.ZERO
var direction = null
var idle_time = 0
var in_water = false
var struck = false
var struck_timer = 60
onready var player = $"/root/Main/Player"
onready var sprite = $AnimatedSprite
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash(position.x + position.y * PI)
	sprite.frame = rng.seed % 2
	sprite.playing = true


func _physics_process(_delta):
	if struck:
		vel *= 0.9
		rotation += vel.length() * sign(vel.x) * 0.1
		if round(vel.length()) == 0:
			var spawn = coin.instance()
			spawn.position = position
			spawn.dropped = true
			$"/root/Main".add_child(spawn)
			queue_free()
	else:
		if in_water:
			if follow:
				direction = player.position - position
				vel = position.direction_to(player.position) * speed
				if player.position.x < position.x:
					if !sprite.flip_h:
						rotation = -rotation
						sprite.flip_h = true
					rotation = lerp_angle(rotation, direction.angle() - PI, 0.25)
				else:
					if sprite.flip_h:
						rotation = -rotation
						sprite.flip_h = false
					rotation = lerp_angle(rotation, direction.angle(), 0.25)
			else:
				vel.y *= 0.85
				sprite.flip_v = false
				if abs(PI - rotation) > abs(rotation):
					rotation = lerp_angle(rotation, 0, 0.25)
				else:
					rotation = lerp_angle(rotation, 0, 0.25)
				idle_time += 1
				if idle_time > 240:
					vel.x = max(vel.x - 0.025, -0.25)
					sprite.flip_h = true
					if idle_time >= 480:
						idle_time = 0
				else:
					sprite.flip_h = false
					vel.x = min(vel.x + 0.025, 0.25)
					
				if is_on_wall():
					if vel.x > 0:
						idle_time = 241
					else:
						idle_time = 0
					vel.x = 0
					
				follow = abs(vel.y) < 1 && can_follow
		else:
			vel.y += 0.25
			if is_on_floor():
				vel.y = -2
				vel.x = rng.randf() * 2 - 1
			rotation = lerp_angle(rotation, 0, 0.25)
			sprite.flip_h = vel.x < 0
		
	#warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide(vel * 60, Vector2.UP)


func _on_Following_body_entered(_body):
	can_follow = true


func _on_Following_body_exited(_body):
	can_follow = false
	follow = false
	if sprite.flip_h:
		idle_time = 241
	else:
		idle_time = 0


func _on_Damage_body_entered(body):
	if body.is_spinning():
		struck = true
		if body.position.x < position.x:
			vel.x = 10
		elif body.position.x > position.x:
			vel.x = -10
		vel.y = -1
	else:
		if body.position.x < position.x:
			player.take_damage_shove(1, -1)
		elif body.position.x > position.x:
			player.take_damage_shove(1, 1)


func _on_WaterCheck_area_entered(_area):
	in_water = true


func _on_WaterCheck_area_exited(_area):
	in_water = false
	follow = false
	can_follow = false
	vel.y = -5.0
