extends PlayerState

@export var hit_handler: HitHandler


func _defer_rules():
	if actor.is_on_floor():
		return &"Floor"
	return &"Air"


func _trans_rules():
	if hit_handler.bouncing:
		hit_handler.bouncing = false
		return &"StompBounce"

	return &""
