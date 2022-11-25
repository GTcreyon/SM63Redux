extends InteractableWarp

const PIPE_HEIGHT = 30
const SLIDE_SPEED = 0.7
const CENTERING_SPEED_SLOW = 0.25
const CENTERING_SPEED_FAST = 0.75

var store_state = 0
var ride_area

onready var sound = $SFX # for sound effect

func _interact_check() -> bool:
	# Interact when Down is pressed.
	# TODO: Find a way to auto-interact if player enters while pounding.
	return Input.is_action_just_pressed("down")


func _animation_length() -> int:
	return 60

func _begin_animation(_player):
	# Center player slightly - REPLACE WITH read_pos_x
	_player.position = Vector2(
		lerp(_player.position.x, global_position.x, CENTERING_SPEED_SLOW),
		global_position.y - PIPE_HEIGHT)
	
	# Give player slide-down animation
	_player.get_node("Character").set_animation("front")
	_player.get_node("Character").rotation = 0 # Keeps player from turning sideways
	_player.get_node("Voice").volume_db = -INF # Keeps player from making dive sounds
	
	# Play pipe-enter sound
	sound.play()
		
func _update_animation(_frame, _player):
	# Slide player a little further into the pipe.
	if _player.state == 7: # Not a valid value
		_player.position.y = global_position.y
		_player.position.x = lerp(_player.position.x, global_position.x, CENTERING_SPEED_FAST)
	else:
		_player.position.x = lerp(_player.position.x, global_position.x, CENTERING_SPEED_SLOW)
		if _player.position.y < global_position.y:
			_player.position.y += SLIDE_SPEED


func _end_animation(_player):
	# Reset player's voice clips to normal volume.
	_player.get_node("Voice").volume_db = -5
	
	_player.switch_state(_player.S.NEUTRAL)
	_player.switch_anim("walk")
	_player.dive_correct(0)

	# Force end pipe sound, just in case.
	sound.stop()

func set_disabled(val):
	disabled = val
	set_collision_layer_bit(0, 0 if val else 1)
	if ride_area == null:
		ride_area = self
	ride_area.monitoring = !val
