class_name KoopaShell
extends EntityEnemy

var speed = 5

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

enum ShellColor {
	GREEN,
	RED,
}

export(ShellColor) var color = 0 setget set_color


func set_color(new_color):
	for i in range(3):
		material.set_shader_param("color" + str(i), color_presets[new_color][i])
	color = new_color


func physics_step():
	vel.x = lerp(vel.x, 0, 0.00625)
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


func _on_CollisionArea_body_entered(body):
	if body.hitbox.global_position.y + body.hitbox.shape.extents.y < global_position.y && body.vel.y > 0:
		$Kick.play()
		$"/root/Main/Player".vel.y = -5
		if body.global_position.x < global_position.x:
			vel.x = speed
		else:
			vel.x = -speed
	elif body.global_position.x < global_position.x:
		$Kick.play()
		vel.x = speed
	elif body.global_position.x > global_position.x:
		$Kick.play()
		vel.x = -speed
