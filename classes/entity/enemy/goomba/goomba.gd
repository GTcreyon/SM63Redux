class_name Goomba
extends EntityEnemyTarget

var is_jumping = false
var full_jump = false
var land_timer = 0

onready var sfx_jump = $SFXJump


func _physics_step():
	if target != null && target.locked:
		target = null
	if sprite.animation == "squish":
		if dead:
			if Singleton.request_coin(collect_id):
				var spawn = coin.instance()
				spawn.position = position
				spawn.dropped = true
				get_parent().add_child(spawn)
			queue_free()
		else:
			if sprite.frame == 3:
				dead = true

	if !is_on_floor() && sprite.animation != "squish":
		sprite.frame = 1
		edge_check.enabled = false
	
	if sprite.animation != "squish" && !struck:
		# raycast2d is used here to detect if the object collided with a wall
		# to change directions
		sprite.flip_h = mirror
		
		if is_on_floor():
			if is_on_wall() && target == null:
				vel.x = 0
				flip_ev()
				wander_dist = 0
			
			if !edge_check.is_colliding() && edge_check.enabled:
				flip_ev()
				
			if sprite.animation == "jumping":
				if is_jumping:
					sprite.frame = 2
					land_timer = 0
					is_jumping = false
					edge_check.enabled = true
				
				land_timer += 0.2
				if land_timer >= 1.8:
					sprite.frame = 0
					sprite.animation = "walking"
				else:
					sprite.frame = 2 + land_timer # finish up jumping anim
			else:
				vel.y = GRAVITY
				if sprite.frame == 0 || sprite.frame == 3:
					if !stepped:
						sfx_step.pitch_scale = rand_range(0.9, 1.1)
						sfx_step.play()
						stepped = true
				else:
					stepped = false
				if target != null:
					sprite.speed_scale = abs(vel.x) / 2 + 1
					if target.position.x - position.x < -20 || (target.position.x < position.x && abs(target.position.y - position.y) < 26):
						vel.x = max(vel.x - 0.1, -2)
						mirror = true
						edge_check.position.x = -9
						sprite.playing = true
					elif target.position.x - position.x > 20 || (target.position.x > position.x && abs(target.position.y - position.y) < 26):
						vel.x = min(vel.x + 0.1, 2)
						mirror = false
						edge_check.position.x = 9
						sprite.playing = true
					else:
						vel.x *= 0.85
						if sprite.frame == 0:
							sprite.playing = false
				else:
					sprite.speed_scale = 1
					sprite.playing = true
					if mirror:
						vel.x = max(vel.x - 0.1, -1)
					else:
						vel.x = min(vel.x + 0.1, 1)
					wander_dist += 1
					if wander_dist >= 120 && sprite.frame == 0:
						wander_dist = 0
						mirror = !mirror
		else:
			sprite.animation = "jumping"
			if !is_jumping:
				sprite.frame = 1
#		var bodies = hurtbox.get_overlapping_bodies()
#		if bodies.size() > 0:
#			_damage_check(bodies[0])
	
	
	if is_on_floor() && struck && sprite.animation != "squish":
		sprite.animation = "squish"
		sprite.frame = 0
		sprite.playing = true
	
	_entity_physics_step()


func _target_alert():
	if is_on_floor():
		sprite.animation = "jumping"
		sfx_jump.play()
		sprite.frame = 0
		is_jumping = true
		vel.y = -2.5


func _hurt_stomp(area):
	var body = area.get_parent()
	sprite.animation = "squish"
	struck = false
	vel.y = 0
	sprite.frame = 0
	sprite.playing = true
	if body.state == body.S.DIVE:
		if Input.is_action_pressed("down"):
			_hurt_struck(body)
		else:
			body.start_bounce()
	else:
		body.start_bounce()


func _hurt_struck(body):
	vel.y -= 2.63
	sprite.animation = "jumping"
	vel.x = max((12 + abs(vel.x) / 1.5), 0) * 5.4 * sign(position.x - body.position.x) / 10 / 1.5


func flip_ev():
	mirror = !mirror
	edge_check.position.x *= -1
