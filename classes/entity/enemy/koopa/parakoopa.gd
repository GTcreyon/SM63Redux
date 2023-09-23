extends AnimatedSprite2D

@onready var hurtbox = $Damage
@onready var top_collision = $TopCollision

var koopa = preload("koopa.tscn").instantiate()
var shell = preload("koopa_shell.tscn").instantiate()

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

@export var disabled = false: set = set_disabled
@export var mirror = false
@export var color := Koopa.ShellColor.GREEN


func set_color(new_color):
	for i in range(3):
		material.set_shader_parameter("color" + str(i), color_presets[new_color][i])
	koopa.color = color
	shell.color = color


func _ready():
	# Ensure that the material is unique so we can set its parameters.
	# "Local to scene" causes issues with source control, because UIDs are refreshed on loading the scene.
	# This method refreshes them at runtime instead of in the editor.
	material = material.duplicate()
	
	set_color(color)
	
	flip_h = mirror
	frame = hash(position.x + position.y * PI) % 6
	if not disabled:
		play()


func _exit_tree():
	# Prevent memory leak
	if is_instance_valid(koopa):
		koopa.queue_free()
	if is_instance_valid(shell):
		shell.queue_free()


func _on_TopCollision_body_entered(body):
	if body.is_spinning():
		spawn_shell(body)
	elif body.vel.y > -2:
		defeat()
		get_parent().call_deferred("add_child", koopa)
		koopa.position = Vector2(position.x, body.position.y + 33)
		koopa.vel.y = body.vel.y
		koopa.mirror = flip_h
		body.vel.y = -5
		body.vel.x *= 1.2


func _on_Damage_body_entered(body):
	# Parakoopa was already defeated, return early
	if !visible:
		return
	
	if !body.is_diving(true):
		if body.is_spinning():
			spawn_shell(body)
		else:
			if body.global_position.x < global_position.x:
				body.take_damage_shove(1, -1)
			elif body.global_position.x > global_position.x:
				body.take_damage_shove(1, 1)


func spawn_shell(body):
	defeat()
	body.vel.y = -5
	get_parent().call_deferred("add_child", shell)
	shell.position = position + Vector2(0, 7.5)
	if body.global_position.x < global_position.x:
		shell.vel.x = 5
	else:
		shell.vel.x = -5


# Called when the parakoopa loses its wings
func defeat():
	$Kick.play()
	top_collision.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitoring", false)
	visible = false


func set_disabled(val):
	disabled = val
	hurtbox.monitoring = !val
	top_collision.monitoring = !val
	if disabled:
		stop()
	else:
		play()
