class_name Koopa
extends EntityEnemyWalk

const COOLDOWN_TIME: int = 30
const SHELL_PREFAB = preload("./koopa_shell.tscn")
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

@export var color: ShellColor = ShellColor.GREEN: set = set_color


func set_color(new_color: ShellColor):
	for i in range(3):
		material.set_shader_parameter("color" + str(i), COLOR_PRESETS[new_color][i])
	color = new_color


func _ready_override():
	super._ready_override()
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
	
	if (position.x - init_position.x > 100 and vel.x > 0) or (position.x - init_position.x < -100 and vel.x < 0):
		turn_around()


func _hurt_crush(handler):
	if cooldown_time_left > 0:
		return
	handler.set_vel_component(Vector2.UP, 5)
	into_shell(0)


func _hurt_strike(handler):
	if cooldown_time_left > 0:
		return
	if handler.get_pos().x < handler.get_pos().x:
		into_shell(5)
	else:
		into_shell(-5)


func into_shell(vel_x):
	# Only do anything if this koopa is NOT queued for deletion.
	# If it is, we know it's already been hit by an attack (or it's meant to be
	# outright deleted by next frame).
	# This should fix a bug wherein stomping and spinning the koopa in the same
	# frame spawns two shells, one for each attack that landed.
	if !is_queued_for_deletion():
		# Create a new shell at this koopa's position.
		var inst = SHELL_PREFAB.instantiate()
		inst.position = position + Vector2(0, 7.5)
		inst.color = color
		inst.vel = Vector2(vel_x, 0)
		# Add it to the world.
		get_parent().call_deferred("add_child", inst)
		
		queue_free()
