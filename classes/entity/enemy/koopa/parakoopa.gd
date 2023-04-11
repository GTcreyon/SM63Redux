tool
extends AnimatedSprite

onready var hurtbox = $Damage
onready var top_collision = $TopCollision

var koopa = preload("koopa.tscn").instance()
var shell = preload("koopa_shell.tscn").instance()

const color_presets = [
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

export var disabled = false setget set_disabled
export var mirror = false
export(int, "green", "red") var color = 0 setget set_color


func set_color(new_color):
	for i in range(3):
		material.set_shader_param("color" + str(i), color_presets[new_color][i])
	color = new_color


func _ready():
	if !Engine.editor_hint:
		flip_h = mirror
		frame = hash(position.x + position.y * PI) % 6
		playing = !disabled


func _exit_tree():
	# Prevent memory leak
	if is_instance_valid(koopa):
		koopa.queue_free()
	if is_instance_valid(shell):
		shell.queue_free()


func _on_TopCollision_body_entered(body):
	if body.is_spinning():
		spawn_shell(body)
	else:
		if body.vel.y > -2:
			$Kick.play()
			koopa.position = Vector2(position.x, body.position.y + 33)
			koopa.vel.y = body.vel.y
			koopa.mirror = flip_h
			koopa.color = color
			body.vel.y = -5.5
			body.vel.x *= 1.2
			get_parent().call_deferred("add_child", koopa)
			$TopCollision.set_deferred("monitoring", false)
			$Damage.monitoring = false
			set_deferred("visible", false)
			visible = false


func _on_Kick_finished():
	queue_free()


func _on_Damage_body_entered(body):
	if !body.is_diving(true):
		if body.is_spinning():
			spawn_shell(body)
		else:
			if body.global_position.x < global_position.x:
				body.take_damage_shove(1, -1)
			elif body.global_position.x > global_position.x:
				body.take_damage_shove(1, 1)


func spawn_shell(body):
	$Kick.play()
	body.vel.y = -5
	get_parent().call_deferred("add_child", shell)
	shell.position = position + Vector2(0, 7.5)
	shell.color = color
	if body.global_position.x < global_position.x:
		shell.vel.x = 5
	else:
		shell.vel.x = -5
	$TopCollision.set_deferred("monitoring", false)
	$Damage.monitoring = false
	set_deferred("visible", false)


func set_disabled(val):
	disabled = val
	if hurtbox == null:
		hurtbox = $Damage
	if top_collision == null:
		top_collision = $TopCollision
	hurtbox.monitoring = !val
	top_collision.monitoring = !val
	if !Engine.editor_hint:
		playing = !val
