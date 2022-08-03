class_name Goomba
extends EntityEnemyTarget

enum JumpStates {
	FLOOR,
	LANDING,
	AIRBORNE,
}

var jump_state: int = JumpStates.FLOOR
var land_timer = 0

onready var sfx_jump = $SFXJump


func _physics_step():
	if stomped:
		if dead:
			enemy_die()
		else:
			dead = sprite.frame >= 3
	else:
		if !is_on_floor():
			sprite.frame = 1
			sprite.animation = "jumping"
			jump_state = JumpStates.AIRBORNE
		
		if !struck:
			if is_on_floor():
				if jump_state != JumpStates.FLOOR:
					if jump_state != JumpStates.LANDING:
						sprite.frame = 2
						land_timer = 0
						jump_state = JumpStates.LANDING
					
					land_timer += 0.2
					if land_timer >= 1.8:
						sprite.frame = 0
						sprite.animation = "walking"
						jump_state = JumpStates.FLOOR
					else:
						sprite.frame = 2 + land_timer # finish up jumping anim
	
	
	if is_on_floor() && struck && !stomped && vel.y > 0:
		stomped = true
		sprite.animation = "squish"
		sprite.frame = 0
		sprite.playing = true
	
	_entity_enemy_target_physics_step()


func _target_alert(_body):
	if is_on_floor():
		sprite.animation = "jumping"
		sfx_jump.play()
		sprite.frame = 0
		jump_state = JumpStates.AIRBORNE
		vel.y = -2.5


func _hurt_stomp(area):
	sprite.animation = "squish"
	struck = false
	vel.y = 0
	sprite.frame = 0
	sprite.playing = true
	if area != null:
		var body = area.get_parent()
		if body.state == body.S.DIVE:
			if Input.is_action_pressed("down"):
				_hurt_struck(body)
			else:
				body.start_bounce()
		else:
			body.start_bounce()


func _hurt_struck(body):
	_default_enemy_struck(body)
	sprite.animation = "jumping"
	jump_state = JumpStates.AIRBORNE


func _struck_land():
	target = null
	stomped = true
	_hurt_stomp(null)


func _move_condition() -> bool:
	return jump_state == JumpStates.FLOOR
