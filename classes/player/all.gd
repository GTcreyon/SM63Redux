extends PlayerState

@export var hit_handler: HitHandler

var _hit_type: Hitbox.Type = 0
var _hit_pos: Vector2


func take_hit(type: Hitbox.Type, handler: HitHandler) -> bool:
	_hit_type = type
	_hit_pos = handler.get_pos()
	return true


func _defer_rules():
	return &"Neutral"


func _trans_rules():
	var dir = sign(actor.position.x - _hit_pos.x)
	var state = &""
	match _hit_type:
		Hitbox.Type.STRIKE, Hitbox.Type.EXPLOSION:
			state = [&"Hurt", dir]
	_hit_type = 0
	return state
