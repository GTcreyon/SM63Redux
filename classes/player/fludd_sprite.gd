extends AnimatedSprite
# FLUDD pack visuals

onready var player_sprite = $".."
onready var player_body = $"../.."

var _nozzle: String = "hover"
var _facing_front: bool = false


func _process(_delta) -> void:
	# Visible if a nozzle is out
	visible = player_body.current_nozzle != Singleton.Nozzles.NONE
	
	# Flip based on character orientation
	flip_h = player_sprite.flip_h
	
	# Behind the player sprite by default
	z_index = 0
	if player_sprite.animation.begins_with("spin_fast"):
		match player_sprite.frame:
			1:
				_facing_front = true
			2:
				_facing_front = false
				flip_h = !player_sprite.flip_h
	elif player_sprite.animation.begins_with("back"):
		_facing_front = true
		# Layer in front of the player sprite
		z_index = 1
	else:
		_facing_front = false
	
	
	if _facing_front:
		animation = _nozzle + "_front"
		offset.x = 0
	else:
		animation = _nozzle
		if flip_h:
			offset.x = 2
		else:
			offset.x = -2


func switch_nozzle(current_nozzle: int) -> void:
	match current_nozzle:
		Singleton.Nozzles.HOVER:
			_nozzle = "hover"
		Singleton.Nozzles.ROCKET:
			_nozzle = "rocket"
		Singleton.Nozzles.TURBO:
			_nozzle = "turbo"
