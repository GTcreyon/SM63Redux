extends KinematicBody2D

const coin = preload("res://actors/items/coin/coin_yellow.tscn")
const speed = 32.0/60.0

var follow_targets = []
var vel = Vector2.ZERO
var direction = null
var idle_time = 0
var in_water = false
var struck = false
var struck_timer = 60
var collect_id
var rng = RandomNumberGenerator.new()

onready var sprite = $AnimatedSprite
onready var hurtbox = $Damage
onready var follow_area = $FollowArea

export var disabled = false setget set_disabled
export var mirror = false

func _ready():
	sprite.flip_h = mirror
	collect_id = Singleton.get_collect_id()
	rng.seed = hash(position.x + position.y * PI)
	sprite.frame = rng.seed % 2


func _physics_process(_delta):
	if !disabled:
		physics_step()


func physics_step():
	if struck:
		vel *= 0.9
		rotation += vel.length() * sign(vel.x) * 0.1
		if round(vel.length()) == 0:
			if Singleton.request_coin(collect_id):
				var spawn = coin.instance()
				spawn.position = position
				spawn.dropped = true
				$"/root/Main".add_child(spawn)
			queue_free()
	else:
		if in_water:
			if follow_targets.size() > 0:
				var target = follow_targets[0]
				direction = target.position - position
				vel = position.direction_to(target.position) * speed
				if target.position.x < position.x:
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
					vel.x = -sign(vel.x)
		else:
			vel.y = min(vel.y + 0.25, 5)
			if is_on_floor():
				vel.y = -2
				vel.x = rng.randf() * 2 - 1
			rotation = lerp_angle(rotation, 0, 0.25)
			sprite.flip_h = vel.x < 0
		var bodies = hurtbox.get_overlapping_bodies()
		if bodies.size() > 0:
			damage_check(bodies[0])
		
	#warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide(vel * 60, Vector2.UP)


func _on_Following_body_entered(body):
	follow_targets.append(body)


func _on_Following_body_exited(body):
	follow_targets.erase(body)
	if sprite.flip_h:
		idle_time = 241
	else:
		idle_time = 0


func _on_Damage_body_entered(body):
	if !struck:
		damage_check(body)


func _on_WaterCheck_area_entered(_area):
	in_water = true


func _on_WaterCheck_area_exited(_area):
	in_water = false
	vel.y = -5.0


func damage_check(body):
	if body.is_spinning(true):
		struck = true
		if body.position.x < position.x:
			vel.x = 10
		elif body.position.x > position.x:
			vel.x = -10
		vel.y = -1
	else:
		if body.position.x < position.x:
			body.take_damage_shove(1, -1)
		elif body.position.x > position.x:
			body.take_damage_shove(1, 1)


func set_disabled(val):
	disabled = val
	if hurtbox == null:
		hurtbox = $Damage
	if follow_area == null:
		follow_area = $FollowArea
	if sprite == null:
		sprite = $AnimatedSprite
	hurtbox.monitoring = !val
	follow_area.monitoring = !val
	sprite.playing = !val
