class_name CheepCheep
extends EntityEnemy

const SPEED = 0.5

var follow_targets = []
var direction = null
var idle_time = 0
var struck_timer = 60
var rng = RandomNumberGenerator.new()


func _physics_step():
	if struck:
		_struck_spin()
	else:
		if _water_bodies > 0:
			_swim()
		else:
			_flounder()
	
	# warning-ignore:RETURN_VALUE_DISCARDED
	set_velocity(vel * 60)
	set_up_direction(Vector2.UP)
	move_and_slide()


func _flounder():
	sprite.play("idle")
	vel.y = min(vel.y + 0.25, 5)
	if is_on_floor():
		vel.y = -2
		vel.x = rng.randf() * 2 - 1
	rotation = lerp_angle(rotation, 0, 0.25)
	mirror = vel.x < 0


func _swim():
	if follow_targets.size() > 0:
		_pursue()
	else:
		_wander()


func _wander():
	if sprite.animation == "chase":
		sprite.play("calmdown")
	vel.y *= 0.85
	sprite.flip_v = false
	if abs(PI - rotation) > abs(rotation):
		rotation = lerp_angle(rotation, 0, 0.25)
	else:
		rotation = lerp_angle(rotation, 0, 0.25)
	idle_time += 1
	if idle_time > 240:
		vel.x = max(vel.x - 0.025, -0.25)
		mirror = true
		if idle_time >= 480:
			idle_time = 0
	else:
		mirror = false
		vel.x = min(vel.x + 0.025, 0.25)
		
	if is_on_wall():
		if vel.x > 0:
			idle_time = 241
		else:
			idle_time = 0
		vel.x = -sign(vel.x)


func _pursue():
	if sprite.animation == "idle":
		sprite.play("notice")
	var target = follow_targets[0]
	direction = target.position - position
	vel = position.direction_to(target.position) * SPEED
	if target.position.x < position.x:
		if !mirror:
			rotation = -rotation
			mirror = true
		rotation = lerp_angle(rotation, direction.angle() - PI, 0.25)
	else:
		if mirror:
			rotation = -rotation
			mirror = false
		rotation = lerp_angle(rotation, direction.angle(), 0.25)


func _struck_spin():
	vel *= 0.9
	rotation += vel.length() * sign(vel.x) * 0.1
	if round(vel.length()) == 0:
		enemy_die()


func _on_AlertArea_body_entered(body):
	follow_targets.append(body)


func _on_AlertArea_body_exited(body):
	follow_targets.erase(body)
	if mirror:
		idle_time = 241
	else:
		idle_time = 0


func _on_WaterCheck_area_exited(_area):
	super(_area)
	vel.y = -5.0


func _hurt_struck(body):
	sprite.play("death")
	struck = true
	if body.position.x < position.x:
		vel.x = 10
	elif body.position.x > position.x:
		vel.x = -10
	vel.y = -1


func _on_AnimatedSprite_animation_finished():
	match sprite.animation:
		"notice":
			sprite.play("chase")
		"calmdown":
			sprite.play("idle")
