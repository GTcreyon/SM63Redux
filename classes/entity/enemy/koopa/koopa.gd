class_name Koopa
extends EntityEnemyWalk

const HIT_SPEED: int = 5
const COOLDOWN_TIME: int = 30
const COLOR_PRESETS = [
	[ # green
		Color("9cc56d"),
		Color("1f887a"),
		Color("2b4a3d"),
	],
	[ # red
		Color("CB5E09"),
		Color("911230"),
		Color("7A4234"),
	],
]
enum ShellColor {
	GREEN,
	RED,
}

var speed = 0.9
var init_position = 0
var cooldown_time_left: int = 0

@export var shell_scene: PackedScene
@export var color: ShellColor = ShellColor.GREEN: set = set_color
@export var hitbox: Hitbox


func set_color(new_color: ShellColor):
	for i in range(3):
		material.set_shader_parameter("color" + str(i), COLOR_PRESETS[new_color][i])
	color = new_color


func _ready():
	super()
	init_position = position
	if color != ShellColor.RED:
		_edge_check_path = ""
		edge_check.queue_free()
		edge_check = null


func _physics_step():
	super()
	if cooldown_time_left > 0:
		cooldown_time_left -= 1


func hit_cooldown():
	cooldown_time_left = COOLDOWN_TIME


func _wander():
	vel.x = -speed if mirror else speed
	
	var position_offset = position.x - init_position.x
	if position_offset * sign(vel.x) > 100:
		turn_around()


func _hurt_crush(handler, pound):
	hitbox.stop_hit()
	if cooldown_time_left > 0:
		return
	if pound:
		var shell = into_shell(0)
		shell.destroy(handler)
	else:
		handler.set_vel_component(Vector2.UP, 5)
		into_shell(0)


func _hurt_strike(handler):
	hitbox.stop_hit()
	if cooldown_time_left > 0:
		return
	if handler.get_pos().x < position.x:
		into_shell(HIT_SPEED)
	else:
		into_shell(-HIT_SPEED)


func into_shell(vel_x: float) -> Node2D:
	# Only do anything if this koopa is NOT queued for deletion.
	# If it is, we know it's already been hit by an attack (or it's meant to be
	# outright deleted by next frame).
	# This should fix a bug wherein stomping and spinning the koopa in the same
	# frame spawns two shells, one for each attack that landed.
	if is_queued_for_deletion():
		return

	# Create a new shell at this koopa's position.
	var inst = shell_scene.instantiate()
	inst.position = position + Vector2(0, 7.5)
	inst.color = color
	inst.vel = Vector2(vel_x, 0)
	# Add it to the world.
	get_parent().call_deferred("add_child", inst)
	
	queue_free()
	return inst
