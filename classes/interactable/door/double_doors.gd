extends InteractableWarp

const CENTERING_SPEED = Door.CENTERING_SPEED
const SINGLE_DOOR_OFFSET = 8
const FACING_BIAS = 2 # If Mario's facing one door, he can enter it this many pixels further away.

export var door_graphic : SpriteFrames

# This stores which side we've chosen to enter.
# We need this because Mario's facing direction shifts as he enters
# a door, meaning we can't rely on "is he left of the doors' origin?"
var chosen_side = 0

func _draw():
	# For debugging, render the split point for which door Mario will enter.
	draw_line(global_position + mario_offset(),
		global_position + mario_offset() + Vector2(0, 2),
		Color(0.1, 1.0, 0.2))

func _ready():
	$SpriteL.frames = door_graphic
	$SpriteR.frames = door_graphic


func _update_animation(_frame: int, _mario):
	# Gradually center Mario over one of the doors
	_mario.global_position.x = lerp(_mario.global_position.x,
		global_position.x + mario_offset().x, CENTERING_SPEED)
	
	if _frame == 0:
		# Start Mario's enter animation
		_mario.get_node("Character").set_animation("back")
		# Start door opening animation on the appropriate door
		if should_use_right_door() == true:
			$SpriteR.play("opening")
			chosen_side = 1
		else:
			$SpriteL.play("opening")
			chosen_side = -1


func _animation_length():
	return 60


func _begin_scene_change(target_pos, scene_path):
	# Clobber the destination position so Mario comes out on the left or right.
	._begin_scene_change(target_pos + mario_offset(), scene_path)


func mario_offset() -> Vector2:
	return Vector2(SINGLE_DOOR_OFFSET * chosen_side, 0)


func should_use_right_door() -> bool:
	# Broadly, this checks if Mario is to the right or left of the center.
	# BUT--if Mario is facing one direction or another, he'll be SLIGHTLY more
	# receptive to using the door he's facing towards.
	if mario.sprite.flip_h == false:
		# Mario facing right.
		return mario.global_position.x > (global_position.x - FACING_BIAS)
	else:
		# Mario facing left.
		return mario.global_position.x >= (global_position.x + FACING_BIAS)
