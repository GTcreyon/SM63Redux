extends StaticBody2D

onready var ride_area = $RideArea

var prev_position = position


func _physics_process(_delta):
	var move_vec = position - prev_position
	for body in ride_area.get_overlapping_bodies():
		if body.is_on_floor():
			body.position += move_vec
	prev_position = position
