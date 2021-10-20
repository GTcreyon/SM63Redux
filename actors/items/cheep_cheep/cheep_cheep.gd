extends KinematicBody2D

const speed = 32.0/60.0

var follow = false
var can_follow = false
var vel = Vector2.ZERO
var direction = null
var idle_time = 0
var in_water = true
onready var player = $"/root/Main/Player"
onready var sprite = $Sprite

func _physics_process(_delta):
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
			follow = abs(vel.y) < 1 && can_follow
	else:
		vel.y += 0.25
		
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
	if body.global_position.x < global_position.x && body.global_position.y > global_position.y:
		#print("collided from left")
		player.take_damage_shove(1, -1)
	elif body.global_position.x > global_position.x && body.global_position.y > global_position.y:
		#print("collided from right")
		player.take_damage_shove(1, 1)


func _on_WaterCheck_area_entered(_area):
	in_water = true


func _on_WaterCheck_area_exited(_area):
	in_water = false
	follow = false
	can_follow = false
	vel.y = -5.0
