extends Door

const SINGLE_DOOR_OFFSET = 8
const FACING_BIAS = 2 # If Mario's facing one door, he can enter it this many pixels further away.

# This stores which side we've chosen to enter.
# We need this because Mario's facing direction shifts as he enters
# a door, meaning we can't rely on "is he left of the doors' origin?"
var chosen_side = 0

func _ready():
	$SpriteL.frames = door_graphic
	$SpriteR.frames = door_graphic


func _mario_offset() -> int:
	return SINGLE_DOOR_OFFSET * chosen_side


func _door_begin_animation():
	var should_use_right_door = false
	# Check if Mario is to the right or left of the center.
	# BUT--if Mario is facing one direction or another, he'll be SLIGHTLY more
	# receptive to using the door he's facing towards.
	if mario.sprite.flip_h == false:
		# Mario facing right.
		should_use_right_door = mario.global_position.x > (global_position.x - FACING_BIAS)
	else:
		# Mario facing left.
		should_use_right_door = mario.global_position.x >= (global_position.x + FACING_BIAS)
		
		
	if should_use_right_door == true:
		$SpriteR.play("opening")
		chosen_side = 1
	else:
		$SpriteL.play("opening")
		chosen_side = -1


func _begin_scene_change(target_pos, scene_path):
	# Clobber the destination position so Mario comes out on the left or right.
	._begin_scene_change(target_pos + chosen_door_offset(), scene_path)


func chosen_door_offset() -> Vector2:
	return Vector2(_mario_offset(), 0)
