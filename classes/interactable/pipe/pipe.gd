extends InteractableWarp

const PLAYER_STOP_HEIGHT = 15
const SLIDE_SPEED = 0.7
const SLIDE_SPEED_FAST = 1.4


var store_state = 0
var ride_area
var begin_pound = false # Did we land a pound this frame?
var continue_pound = false # Did a pound send us down this pipe?

onready var sound = $SFX # for sound effect

# This function is part of an ugly hack to make quick-pipe work.
# With quick-pipe, the pipe activates if the player is grounded AND either
# a button is pressed OR the player is pounding.
# Unfortunately, the base Interactable class runs its activation code if
# button is pressed AND player is grounded...and there's no way to check
# the player state in the button-press half of the code.
# So rather than add a player variable to the button press check (that's this
# function), which would make life hard for other Interactables for no reason,
# we instead rely on the AND structure of the base interactable check:
# return unconditionally true from this function, then do all the logic we
# actually care about in the other side, including the button check.
# Ugly? Yes. Future-proof? Absolutely not.
# Works? Currently, yes :)
func _interact_check() -> bool:
	return true

# Here's the other half of that ugly hack. Perform input-checking logic (which
# includes grounded check), then AND that with the actual state check
# from the base class.
func _state_check(player) -> bool:
	# Interact when Down is pressed.
	var interact_check = Input.is_action_just_pressed("down")
	# Also interact if player hits the pipe whilst pounding.
	begin_pound = player.state == player.S.POUND and player.pound_state != player.Pound.SPIN
	
	return (interact_check and ._state_check(player)) or begin_pound


func _animation_length() -> int:
	if begin_pound or continue_pound:
		return 30
	else:
		return 60


func _begin_animation(_player):
	# Set player to center gradually
	_player.read_pos_x = global_position.x
	
	# Give player slide-down animation
	if not begin_pound:
		_player.switch_anim("front")
	else:
		# TODO: non-fall pound animation may be best?
		_player.switch_anim("pound_fall")
	
	_player.sprite.rotation = 0 # Keeps player from turning sideways
	_player.voice.volume_db = -INF # Keeps player from making dive sounds
	
	# End pound state so the pipe doesn't retrigger endlessly
	_player.switch_state(_player.S.NEUTRAL)
	# ...but if it was there, save it so we can check against it later!
	continue_pound = begin_pound
	
	# Play pipe-enter sound
	sound.play()


func _update_animation(_frame, _player):
	# Slide player a little further into the pipe.
	# Go faster if pounding.
	if continue_pound:
		_player.position.y += SLIDE_SPEED_FAST
	else:
		_player.position.y += SLIDE_SPEED
	
	# Don't let player go below the pipe's end!
	_player.position.y = min(_player.position.y, 
		global_position.y - PLAYER_STOP_HEIGHT)


func _end_animation(_player):
	# Reset player's voice clips to normal volume.
	_player.voice.volume_db = -5
	
	_player.switch_state(_player.S.NEUTRAL)
	_player.switch_anim("walk")

	# Force end pipe sound, just in case.
	sound.stop()
	
	# Forget pound state, lest it bleed into future animation-length checks.
	continue_pound = false


func set_disabled(val):
	.set_disabled(val)
	$StaticBody2D.set_collision_layer_bit(0, 0 if val else 1)
