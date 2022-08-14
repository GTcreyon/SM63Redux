class_name Koopa
extends EntityEnemyWalk

const KICK_SFX = preload("./shell_kick.ogg")
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

export(ShellColor) var color = 0 setget set_color


func set_color(new_color):
	for i in range(3):
		material.set_shader_param("color" + str(i), COLOR_PRESETS[new_color][i])
	color = new_color


func _ready_override():
	._ready_override()
	init_position = position
	if color != ShellColor.RED:
		edge_check.free()
		edge_check = null


func _wander():
	vel.x = -speed if mirror else speed
	
	if position.x - init_position.x > 100 or position.x - init_position.x < -100:
		turn_around()


func _hurt_stomp(area):
	get_parent().add_child(ResidualSFX.new(KICK_SFX, position))
	var body = area.get_parent()
	body.vel.y = -5
	var inst = SHELL_PREFAB.instance()
	get_parent().call_deferred("add_child", inst)
	inst.position = position + Vector2(0, 7.5)
	inst.color = color
	queue_free()


func _hurt_struck(body):
	get_parent().add_child(ResidualSFX.new(KICK_SFX, position))
	var inst = SHELL_PREFAB.instance()
	inst.position = position + Vector2(0, 7.5)
	if body.global_position.x < global_position.x:
		inst.vel.x = 5
	else:
		inst.vel.x = -5
	get_parent().add_child(inst)
	queue_free()
