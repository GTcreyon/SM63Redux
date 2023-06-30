class_name Door
extends InteractableWarp

@export var door_graphic : SpriteFrames

var player_fade_start_time : int
var player_fade_rate : float
var door_close_start_time : int


func _ready():
	_set_sprite_frames(door_graphic)
	
	# Load animation timings
	if door_graphic is DoorSkin:
		# Resource has animation timings saved in it; load them.
		player_fade_start_time = door_graphic.player_fade_start_time
		player_fade_rate = door_graphic.player_fade_rate
		door_close_start_time = door_graphic.door_close_start_time
	else:
		# Resource has no timings baked into it; use defaults.
		player_fade_start_time = DoorSkin.DEFAULT_PLAYER_FADE_START
		player_fade_rate = DoorSkin.DEFAULT_PLAYER_FADE_RATE
		door_close_start_time = DoorSkin.DEFAULT_DOOR_CLOSE_START


func _update_animation(_frame: int, _player):	
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


func _enter_pos_offset_x() -> int:
	return 0


func _player_begin_animation(player):
	# TODO: Fix for new player sprite system
	#player.switch_anim("back")
	
	# Set player to gradually move onto the door.
	# NOTE: read_pos_x movement currently has a lerp factor of 0.75 per frame.
	# Door entry may feel smoother with a factor of 0.25
	# (more consistent with player movement).
	player.read_pos_x = global_position.x + _enter_pos_offset_x()


func _door_open():
	$Sprite2D.play("opening")


func _door_close():
	$Sprite2D.play("closing")


func _set_sprite_frames(sprite_frames: SpriteFrames):
	$Sprite2D.frames = sprite_frames
