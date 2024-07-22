class_name Goomba
extends EntityEnemyWalk

enum JumpStates {
	FLOOR,
	LANDING,
	AIRBORNE,
}

var jump_state: JumpStates = JumpStates.FLOOR
var land_timer = 0

@onready var sfx_jump = $SFXJump


func _physics_step():
	if not stomped:
		if not is_on_floor():
			sprite.frame = 1
			sprite.play(&"jumping")
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
						sprite.play(&"walking")
						jump_state = JumpStates.FLOOR
					else:
						sprite.frame = 2 + land_timer # Finish up jumping anim
	
	super._physics_step()


func _target_alert(_body):
	if is_on_floor():
		sprite.animation = "jumping"
		sfx_jump.play()
		sprite.frame = 0
		jump_state = JumpStates.AIRBORNE
		vel.y = -2.5


func _hurt_crush(source: HitHandler):
	source.stomp_bounce()
	_stomp_trigger()


func _stomp_trigger():
	sprite.speed_scale = 1
	sprite.play(&"squish")
	stomped = true
	struck = false
	vel.y = 0


func _hurt_strike(body):
	super._hurt_strike(body)
	sprite.animation = "jumping"
	jump_state = JumpStates.AIRBORNE


func _struck_land():
	target = null
	_stomp_trigger()


func _move_condition() -> bool:
	return jump_state == JumpStates.FLOOR


func _on_animated_sprite_2d_animation_finished():
	if stomped:
		dead = true
		enemy_die()
