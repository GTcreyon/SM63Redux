class_name Door
extends InteractableWarp

const CENTERING_SPEED = 0.25

export var door_graphic : SpriteFrames

func _ready():
	_set_sprite_frames(door_graphic)


func _update_animation(_frame: int, _player):
	# Gradually center the player
	#._player_shift_to_position(_player, global_position.x + _player_offset(), CENTERING_SPEED)
	
	if _frame == 0:
		# Start door opening animation
		_door_begin_animation()
		# Start player's enter animation
		_player_begin_animation(_player)


func _animation_length():
	return 60


func _player_offset() -> int:
	return 0


func _player_begin_animation(player):
	player.switch_anim("back")
	# Set player to gradually move onto the door.
	# NOTE: last I checked, this movement has a lerp factor of
	# 0.75 per frame. Door entry feels smoother with a factor
	# of 0.25 (more consistent with player movement).
	player.read_pos_x = global_position.x + _player_offset()


func _door_begin_animation():
	$Sprite.play("opening")


func _set_sprite_frames(sprite_frames: SpriteFrames):
	$Sprite.frames = sprite_frames
