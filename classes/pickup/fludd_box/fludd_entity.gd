class_name FluddEntity
extends KinematicBody2D


var vel = Vector2()


func _physics_process(_delta):
	if is_on_floor():
		vel.y = 0
	vel.y += 1.67
	# warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide(vel * 60, Vector2.UP, true)
