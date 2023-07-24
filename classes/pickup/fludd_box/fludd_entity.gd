class_name FluddEntity
extends CharacterBody2D


var vel = Vector2()


func _physics_process(_delta):
	if is_on_floor():
		vel.y = 0
	vel.y += 1.67
	# warning-ignore:RETURN_VALUE_DISCARDED
	set_velocity(vel * 60)
	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()
