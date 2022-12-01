extends InteractableWarp

const TIME_PEAK_JUMP = 30 # Time it takes the animated jump to reach its peak
const TIME_PEAK_SWIM = 20 # Temporary--haven't checked
const TIME_END_LONGJUMP = 8
const TIME_START_SHRINK = 16
const SHRINK_DURATION = 8
const TIME_END_SHRINK = TIME_START_SHRINK + SHRINK_DURATION
const SHRINK_SCALE_MIN = 0.75
const TIME_START_FLASH = TIME_START_SHRINK
const FLASH_DURATION_HALF = SHRINK_DURATION
const TIME_PEAK_FLASH = TIME_START_FLASH + FLASH_DURATION_HALF
#const TIME_END_FLASH = TIME_PEAK_FLASH + FLASH_DURATION_HALF

export var picture: Texture
export var frame: Texture
export var detection_radius = 33 setget set_detection_radius

onready var white_flash = $Picture/WhiteFlash

func _ready():
	$Picture.texture = picture
	$Frame.texture = frame


func _interact_check() -> bool:
	# If up pressed but NOT lateral move buttons.
	return Input.is_action_just_pressed("up") \
		and !Input.is_action_pressed("left") \
		and !Input.is_action_pressed("right")


func _animation_length() -> int:
	return 90 if move_to_scene else 60


func _begin_animation(_player):
	if !_player.swimming:
		# Force a single jump.
		_player.double_jump_state = 0
		_player.action_jump()
	
		# Set appropriate animation.
		# TODO: Control this animation manually.
		_player.airborne_anim()
	else:
		# Force a swim upward.
		_player.action_swim()


func _update_animation(_frame, _player):
	# Jump into painting
	if _frame < TIME_PEAK_JUMP:
		# Simulate a player jump.
		# TODO: Player falls differently underwater.
		# Account for this.
		
		# Apply gravity.
		_player.player_fall()
		
		# For a while, hold jump button to give extra height.
		if _frame < TIME_END_LONGJUMP:
			_player.player_jump_vary_height()
		
		# Apply movement.
		_player.player_move()
	# When this duration passes, player will hang in midair.
	
	# Shrink player into the painting.
	if _frame > TIME_START_SHRINK:
		# how far along the shrink animation we are
		var shrink_fac = float(_frame - TIME_START_SHRINK) / SHRINK_DURATION
		# do actual shrink
		_player.scale = Vector2.ONE * lerp(1, SHRINK_SCALE_MIN, shrink_fac)
	
	# Once shrink is over, hide player.
	if _frame == TIME_END_SHRINK:
		_player.sprite.modulate.a = 0
	
	
	# Flash the painting white.
	if _frame > TIME_START_FLASH:
		# how far along the flash animation we are
		var flash_fac = float(_frame - TIME_START_FLASH) / FLASH_DURATION_HALF
		# make it fall back to 0 after it hits 1
		if flash_fac > 1:
			flash_fac = 1 - (flash_fac - 1)
		
		# Begin white flash animation
		white_flash.modulate.a = flash_fac

func _end_animation(_player):
	#Reset player to full size and visibility.
	_player.scale = Vector2(1,1)
	_player.sprite.modulate.a = 1


func set_detection_radius (val):
	detection_radius = val
	$DetectionArea.shape.extents.x = val
