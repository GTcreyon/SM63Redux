extends KinematicBody2D

onready var sprite = $AnimatedSprite
var vel
var lifetime = 120

func _physics_process(_delta):
	if is_on_floor():
		vel.x *= 0.75
		vel.y = -0.5 * vel.y
		if round(vel.y) == 0:
			vel.y = 0
	if is_on_ceiling() and vel.y < 0:
		vel.y = 0
	if is_on_wall():
		vel.x = -0.5 * vel.x
	vel.y += 0.17
	sprite.speed_scale = floor(abs(vel.y) * 2)
	# warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide(vel * 60, Vector2.UP)
	lifetime -= 1
	if lifetime <= 0:
		modulate.a -= 0.1
		if modulate.a <= 0:
			queue_free()
