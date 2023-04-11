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


func _physics_step():
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
	._physics_step()


# Stub the strike check so the player doesn't have to spin to hit the shell
func _strike_check(_body):
	return true


func _hurt_stomp(area):
	stomped = true
	var body = area.get_parent()
	body.vel.y = -5
	if body.position.x < position.x:
		vel.x = speed
	else:
		vel.x = -speed


func _hurt_struck(body):
	if body.position.x < position.x:
		vel.x = speed
	elif body.position.x > position.x:
		vel.x = -speed
