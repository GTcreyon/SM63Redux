tool
extends KinematicBody2D

const GRAVITY = 0.17
onready var sprite = $AnimatedSprite
onready var collision_area = $CollisionArea

var speed = 5
var vel = Vector2.ZERO
var water_bodies : int = 0

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
		sprite.playing = !disabled
		sprite.speed_scale = 0

func _physics_process(_delta):
	if !disabled and !Engine.editor_hint:
		physics_step()

func physics_step():
	if water_bodies > 0:
		vel.y = min(vel.y + GRAVITY, 2)
	else:
		vel.y = min(vel.y + GRAVITY, 6)
	# warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide(vel * 60, Vector2.UP)
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


func _on_WaterCheck_area_entered(_area):
	water_bodies += 1


func _on_WaterCheck_area_exited(_area):
	water_bodies -= 1


func set_disabled(val):
	disabled = val
	if collision_area == null:
		collision_area = $CollisionArea
	if sprite == null:
		sprite = $AnimatedSprite
	collision_area.monitoring = !val
	sprite.playing = !val
