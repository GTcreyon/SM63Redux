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
const TIME_END_FLASH = TIME_PEAK_FLASH + FLASH_DURATION_HALF

const RIPPLE_AMPLITUDE = 0.1
const RIPPLE_DECAY_TIME_SLOW = 80
const RIPPLE_RATE = 0.01

export var picture: Texture
export var frame: Texture
export var detection_radius = 33 setget set_detection_radius

onready var picture_sprite = $Picture

func _ready():
	picture_sprite.texture = picture
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
	
	
	# Do initial white flash.
	if _frame > TIME_START_FLASH and _frame <= TIME_END_FLASH:
		# how far along the flash animation we are
		var flash_fac = float(_frame - TIME_START_FLASH) / FLASH_DURATION_HALF
		# make it fall back to 0 after it hits 1
		if flash_fac > 1:
			flash_fac = max(1 - (flash_fac - 1), 0)
		
		# Do white flash animation
		picture_sprite.material.set_shader_param("flash_factor", flash_fac)
	
	# Do ripple effect after the player jumps in.
	if _frame > TIME_PEAK_FLASH:
		var ripple_decay_time
		if move_to_scene:
			# Ripples to decay to nothing slowly if going to a new scene...
			ripple_decay_time = RIPPLE_DECAY_TIME_SLOW
		else:
			# but quickly otherwise.
			ripple_decay_time = _animation_length() - TIME_PEAK_FLASH
		
		# Calculate and apply this frame's ripple amplitude.
		var decay_factor = float(_frame - TIME_PEAK_FLASH) / ripple_decay_time
		picture_sprite.material.set_shader_param("ripple_amplitude", 
			RIPPLE_AMPLITUDE * (1 - decay_factor))
		
		# Advance ripple phase for the frame.
		picture_sprite.material.set_shader_param("ripple_phase", _frame * RIPPLE_RATE)

func _end_animation(_player):
	# Reset player to full size and visibility.
	_player.scale = Vector2(1,1)
	_player.sprite.modulate.a = 1


func set_detection_radius(val):
	detection_radius = val
	$DetectionArea.shape.extents.x = val
