extends Door

const SINGLE_DOOR_OFFSET = 8
const FACING_BIAS = 2 # If player's facing one door, they can enter it this many pixels further away.

export var force_exact_target = false

# This stores which side we've chosen to enter.
# We need this because the player's facing direction shifts as they enter
# a door, meaning we can't rely on "are they left of the doors' origin?"
var chosen_side = 0

func _set_sprite_frames(sprite_frames: SpriteFrames):
	$SpriteL.frames = sprite_frames
	$SpriteR.frames = sprite_frames


func _enter_pos_offset_x() -> int:
	return SINGLE_DOOR_OFFSET * chosen_side


func _exit_pos_offset() -> Vector2:
	return Vector2(_enter_pos_offset_x(), 0) if !force_exact_target else Vector2(0,0)


func _door_open():
	var should_use_right_door = false
	# Check if player is to the right or left of the center.
	# BUT--if player is facing one direction or another, be SLIGHTLY more
	# receptive to using the door they're facing towards.
	if player.sprite.flip_h == false:
		# Player is facing right.
		should_use_right_door = player.global_position.x > (global_position.x - FACING_BIAS)
	else:
		# Player is facing left.
		# Comparison operator is different than when facing right--
		# this is intentional, because it shifts the comparison
		# over by one unit.
		should_use_right_door = player.global_position.x >= (global_position.x + FACING_BIAS)
		
		
	if should_use_right_door == true:
		$SpriteR.play("opening")
		chosen_side = 1
	else:
		$SpriteL.play("opening")
		chosen_side = -1


func _door_close():
	# Close whichever door was opened.
	if chosen_side == 1:
		$SpriteR.play("closing")
	else:
		$SpriteL.play("closing")
