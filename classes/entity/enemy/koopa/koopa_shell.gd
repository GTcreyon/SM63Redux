class_name KoopaShell
extends EntityEnemy

var speed = 5

@export var color: Koopa.ShellColor = Koopa.ShellColor.GREEN: set = set_color
@export var sfx_kick: AudioStreamPlayer2D


func set_color(new_color: Koopa.ShellColor):
	for i in range(3):
		material.set_shader_parameter("color" + str(i), Koopa.COLOR_PRESETS[new_color][i])
	color = new_color


func _physics_step():
	vel.x = lerp(vel.x, 0.0, 0.00625)
	if is_on_floor():
		vel.y = 0
	if is_on_wall(): # flip when hitting wall
		mirror = !mirror
		vel.x *= -1
	sprite.speed_scale = abs(vel.x)
	if vel.x > 0:
		sprite.animation = "counterclockwise"
	else:
		sprite.animation = "clockwise"
	super._physics_step()


func take_hit(type: Hitbox.Type, handler: HitHandler) -> bool:
	if disabled:
		return false

	# Default hurt behavior. Can be overridden.
	match type:
		Hitbox.Type.CRUSH:
			handler.set_vel_component(5, Vector2.UP)
			if handler.get_pos().x < position.x:
				vel.x = speed
			else:
				vel.x = -speed
			sfx_kick.play()
			return true
		Hitbox.Type.STRIKE, Hitbox.Type.NUDGE:
			if handler.get_pos().x < position.x:
				vel.x = speed
			elif handler.get_pos().x > position.x:
				vel.x = -speed
			sfx_kick.play()
			return true
		_:
			return false
