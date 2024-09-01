extends PlayerState

@export var hurtbox: Hurtbox
@export var water_check: Area2D

var _hit_type: Hit.Type = 0
var _hit_pos: Vector2


func take_hit(hit: Hit) -> bool:
	var type = hit.type
	var handler = hit.source
	_hit_type = type
	_hit_pos = handler.get_pos()
	return true


func _defer_rules():
	return &"Neutral"


func _trans_rules():
	var dir = sign(actor.position.x - _hit_pos.x)
	var state = null
	match _hit_type:
		Hit.Type.STRIKE, Hit.Type.EXPLOSION:
			state = [&"Hurt", dir]
	if state != state:
		_hit_type = 0
		return state
	
	if water_check.has_overlapping_areas():
		return &"Swim"
	
	return &""
