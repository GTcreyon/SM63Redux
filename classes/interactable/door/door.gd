class_name Door
extends InteractableWarp

const CENTERING_SPEED = 0.25

export var doorGraphic : SpriteFrames

func _ready():
	$DoorSprite.frames = doorGraphic


func _update_animation(_frame: int, _mario):
	# Gradually center Mario
	_mario.global_position.x = lerp(_mario.global_position.x, global_position.x, CENTERING_SPEED)
	
	if _frame == 0:
		# Start Mario's enter animation
		_mario.get_node("Character").set_animation("back")
		# Start door opening animation
		$DoorSprite.play("opening")


func _animation_length():
	return 60
