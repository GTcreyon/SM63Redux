extends AnimatedSprite
# FLUDD pack visuals

# Data about FLUDD's orientation
enum Orient {
	# "Meaning bits" - components of facing directions
	X_FLIP = 1, # flip opposite player sprite, instead of with
	SORT_ABOVE = 2,
	SIDE = 4, # hover heads are exactly aligned, only one visible
	FACING = 8, # hover heads are on the camera plane - used for back too
	THREE_QTR = 4 | 8,
	
	# Definitions of FLUDD's placement for each player orientation
	# For these, facing right = unflipped.
	FRONT = 8,
	FRONT_RIGHT = 4 | 8,
	RIGHT = 4,
	BACK_RIGHT = 4 | 8 | 2,
	BACK = 8 | 2,
	BACK_LEFT = 4 | 8 | 1 | 2,
	LEFT = 4 | 1,
	FRONT_LEFT = 4 | 8 | 1,
}

# FLUDD's orientation is overridden for these player animations.
# (Default is Orient.FRONT_RIGHT)
# Each frame should have one array entry.
# (NOTE: No reason to include the non-FLUDD variants, since FLUDD is
# hidden when those are in use!)
const ORIENT_FRAMES = {
	"back_fludd": Orient.BACK,
	"front_fludd": Orient.FRONT,
	"spin_fast_fludd": [ # 3 frames
		Orient.FRONT_RIGHT,
		Orient.FRONT,
		Orient.FRONT_LEFT
	],
	"spin_slow_fludd": [ # 8 frames, starts facing back, ccw rotation
		Orient.BACK,
		Orient.BACK_LEFT,
		Orient.LEFT,
		Orient.FRONT_LEFT,
		Orient.FRONT,
		Orient.FRONT_RIGHT,
		Orient.RIGHT,
		Orient.BACK_RIGHT,
	],
}

onready var player_sprite = $".."
onready var player_body = $"../../.."

var _nozzle: String = "hover"
var _facing_front: bool = false


func _process(_delta) -> void:
	# Visible if a nozzle is out
	visible = player_body.current_nozzle != Singleton.Nozzles.NONE
	
	# Flip based on character orientation
	flip_h = player_sprite.flip_h
	
	# Behind the player sprite by default
	z_index = 0
	if player_sprite.animation.begins_with("spin"):
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
