class_name Koopa
extends EntityEnemyWalk

var SHELL_PREFAB = preload("./koopa_shell.tscn")

var speed = 0.9
var init_position = 0

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

@export var color: ShellColor = 0: set = set_color


func set_color(new_color):
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


func _wander():
	vel.x = -speed if mirror else speed
	
	if (position.x - init_position.x > 100 and vel.x > 0) or (position.x - init_position.x < -100 and vel.x < 0):
		turn_around()


func _hurt_stomp(area):
	var body = area.get_parent()
	body.vel.y = -5
	into_shell(0)


func _hurt_struck(body):
	if struck: # Enemy has already been struck
		return

	struck = true
	if body.global_position.x < global_position.x:
		into_shell(5)
	else:
		into_shell(-5)


func into_shell(vel_x):
	var inst = SHELL_PREFAB.instantiate()
	inst.position = position + Vector2(0, 7.5)
	inst.color = color
	inst.vel = Vector2(vel_x, 0)
	get_parent().call_deferred("add_child", inst)
	queue_free()
