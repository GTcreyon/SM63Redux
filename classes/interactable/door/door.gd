class_name Door
extends InteractableWarp

const CENTERING_SPEED = 0.25

export var door_graphic : SpriteFrames
export var player_fade_start_time : int = 20
export var player_fade_rate : float = 0.1
export var door_close_start_time : int = 20

func _ready():
	_set_sprite_frames(door_graphic)
	
	# Keep all export variables within sane ranges.
	player_fade_start_time = max(player_fade_start_time, 0)
	player_fade_rate = clamp(player_fade_rate, 0, 1)
	door_close_start_time = max(door_close_start_time, 0)

func _update_animation(_frame: int, _player):
	# Gradually center the player
	#._player_shift_to_position(_player, global_position.x + _player_offset(), CENTERING_SPEED)
	
	if _frame == 0:
		# Start door opening animation
		_door_open()
		# Start player's enter animation
		_player_begin_animation(_player)
	if _frame >= player_fade_start_time:
		# Fade player down a little bit
		_player.sprite.modulate.a -= player_fade_rate
	if _frame == door_close_start_time:
		_door_close()
	if _frame == _animation_length():
		# Reset player to fully opaque
		_player.sprite.modulate.a = 1


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


func _door_open():
	$Sprite.play("opening")

func _door_close():
	$Sprite.play("closing")


func _set_sprite_frames(sprite_frames: SpriteFrames):
	$Sprite.frames = sprite_frames
