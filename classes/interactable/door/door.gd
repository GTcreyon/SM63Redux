class_name Door
extends InteractableWarp

const CENTERING_SPEED = 0.25

export var door_graphic : SpriteFrames

func _ready():
	$DoorSprite.frames = door_graphic


func _update_animation(_frame: int, _mario):
	# Gradually center Mario
	._mario_shift_to_position(_mario, global_position.x + _mario_offset(), CENTERING_SPEED)
	
	if _frame == 0:
		# Start Mario's enter animation
		_mario_begin_animation(_mario)
		# Start door opening animation
		_door_begin_animation()


func _animation_length():
	return 60


func _mario_offset() -> int:
	return 0


func _mario_begin_animation(mario):
	mario.get_node("Character").set_animation("back")


func _door_begin_animation():
	$DoorSprite.play("opening")
