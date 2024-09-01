class_name KoopaShell
extends EntityEnemy

const HIT_SPEED: int = 5

@export var color: Koopa.ShellColor = Koopa.ShellColor.GREEN: set = set_color
@export var sfx_kick: AudioStreamPlayer2D
@export var collision: CollisionShape2D
@export var on_screen: VisibleOnScreenNotifier2D

var _destroyed: bool = false


func set_color(new_color: Koopa.ShellColor):
	for i in range(3):
		material.set_shader_parameter("color" + str(i), Koopa.COLOR_PRESETS[new_color][i])
	color = new_color


func _physics_step():
	if _destroyed:
		if not on_screen.is_on_screen():
			queue_free()

		var rotation_speed = 1.0
		if _water_bodies > 0:
			vel.x = sign(vel.x) * 1.5
			rotation_speed = 0.5
		rotation -= TAU / 30.0 * sign(vel.x) * rotation_speed
	else:
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
	super()


func take_hit(hit: Hit) -> bool:
	var type = hit.type
	var handler = hit.source
	if disabled or _destroyed:
		return false

	# Default hurt behavior. Can be overridden.
	match type:
		Hit.Type.POUND:
			destroy(handler)
			return true
		Hit.Type.STOMP:
			handler.set_vel_component(Vector2.UP, 5)
			_kick(handler)
			return true
		Hit.Type.STRIKE, Hit.Type.NUDGE:
			_kick(handler)
			return true
		_:
			return false


func destroy(handler: HitHandler):
	_destroyed = true
	var direction = 1
	if handler.get_pos() > position:
		direction = -1
	vel = Vector2(3 * direction, -3)
	collision.set_deferred(&"disabled", true)


func _kick(handler: HitHandler):
	if handler.get_pos().x < position.x:
		vel.x = HIT_SPEED
	else:
		vel.x = -HIT_SPEED
	sfx_kick.play()
