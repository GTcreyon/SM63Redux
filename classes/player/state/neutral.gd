extends PlayerState

@export var hit_handler: HitHandler
@export var water_check: Area2D


func _defer_rules():
	if actor.is_on_floor():
		return &"Floor"
	return &"Air"


func _trans_rules():
	if not water_check.get_overlapping_areas().is_empty():
		return &"Swim"

	if hit_handler.bouncing:
		hit_handler.bouncing = false
		return &"StompBounce"

	return &""
