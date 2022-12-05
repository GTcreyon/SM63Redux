extends InteractableWarp

const TIME_PEAK_JUMP = 30 # Time it takes the animated jump to reach its peak
const TIME_PEAK_SWIM = 20 # Temporary--haven't checked
const TIME_END_LONGJUMP = 8

const TIME_START_SHRINK = 16
const SHRINK_DURATION = 8
const TIME_END_SHRINK = TIME_START_SHRINK + SHRINK_DURATION
const SHRINK_SCALE_MIN = 0.75

const TIME_START_FLASH = TIME_START_SHRINK
const FLASH_DURATION_START = SHRINK_DURATION
const FLASH_DURATION_END = 15
const TIME_PEAK_FLASH = TIME_START_FLASH + FLASH_DURATION_START
const TIME_END_FLASH = TIME_PEAK_FLASH + FLASH_DURATION_END

const RIPPLE_AMPLITUDE = 0.25
const RIPPLE_DECAY_EXPONENT_FAST = 3
const RIPPLE_DECAY_TIME_SLOW = 240
const RIPPLE_DECAY_EXPONENT_SLOW = 1
const RIPPLE_RATE = 0.01

const FINAL_BURNAWAY_DURATION = 21

export var picture: Texture
export var frame: Texture
export var detection_radius = 33 setget set_detection_radius
export var closest_camera_zoom = 0.1

var camera_zoom_start = Vector2.ONE
var camera_focus_start = Vector2.ZERO

onready var picture_sprite = $Picture

func _ready():
	# Load in chosen skins.
	picture_sprite.texture = picture
	$Frame.texture = frame
	
	reset_shader()


func _interact_check() -> bool:
	# If up pressed but NOT lateral move buttons.
	return Input.is_action_just_pressed("up") \
		and !Input.is_action_pressed("left") \
		and !Input.is_action_pressed("right")


func _animation_length() -> int:
	return TIME_PEAK_FLASH + (180 if move_to_scene else 60)


func _begin_animation(_player):
	picture_sprite.material.set_shader_param("texture_resolution", 
		picture_sprite.texture.get_size())
	
	# Ripple origin can be known at this point. Send it to the shader.
	# Begin with player position relative to painting.
	var ripple_origin_x = _player.global_position.x - global_position.x
	# Scale down to UV space.
	ripple_origin_x /= picture_sprite.texture.get_width();
	# Finally, offset to center of painting.
	ripple_origin_x += 0.5
	# Send to shader immediately.
	picture_sprite.material.set_shader_param("ripple_origin", Vector2(
		ripple_origin_x,
		0.5))
	
	# Engage the player's portion of the animation.
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
	
	
	# Do entry flash.
	if _frame > TIME_START_FLASH and _frame <= TIME_END_FLASH:
		# how far along the flash animation we are
		var flash_fac = float(_frame - TIME_START_FLASH) / FLASH_DURATION_START
		# make it fall back to 0 after it hits 1
		if flash_fac > 1:
			# Unpacking this line; let ans = result of last line.
			# (flash_fac - 1) = amount we've gone past 1.
			# 1 - ans = invert that so it goes backwards.
			# max(ans, 0) = let it go down to no-flash, but not darker.
			# pow(ans, 2) = make falloff faster so burnout looks nicer.
			flash_fac = pow(max(1 - (flash_fac - 1), 0), 2)
		
		# Do white flash animation
		picture_sprite.material.set_shader_param("flash_factor", flash_fac)
	
	# Do burnaway after entry.
	if _frame > TIME_PEAK_FLASH and _frame <= TIME_END_FLASH:
		# how far along the burnaway animation we are
		var burn_fac = float(_frame - TIME_PEAK_FLASH) / FLASH_DURATION_END
		
		# Do burnaway animation
		picture_sprite.material.set_shader_param("burnaway_factor", 1 - burn_fac)
	
	# Do ripple effect after the player jumps in.
	if _frame > TIME_PEAK_FLASH:
		var ripple_decay_time
		var ripple_decay_exponent
		if move_to_scene:
			# Ripples to decay to nothing slowly if going to a new scene...
			ripple_decay_time = RIPPLE_DECAY_TIME_SLOW
			# Linear decay.
			ripple_decay_exponent = RIPPLE_DECAY_EXPONENT_SLOW
		else:
			# but quickly otherwise.
			ripple_decay_time = _animation_length() - TIME_PEAK_FLASH
			# Power-function decay looks nicer.
			ripple_decay_exponent = RIPPLE_DECAY_EXPONENT_FAST
		
		# Calculate and apply this frame's ripple amplitude.
		var decay_factor = float(_frame - TIME_PEAK_FLASH) / ripple_decay_time
		picture_sprite.material.set_shader_param("ripple_amplitude", 
			RIPPLE_AMPLITUDE * pow(1 - decay_factor, ripple_decay_exponent))
		
		# Advance ripple phase for the frame.
		picture_sprite.material.set_shader_param("ripple_phase", _frame * RIPPLE_RATE)
	
	if move_to_scene:
		# When the flash happens, the animation is in full swing.
		if _frame == TIME_PEAK_FLASH:
			# Cache player position and starting zoom for future frames.
			camera_focus_start = _player.global_position
			camera_zoom_start = _player.camera.current_zoom
			# Lock the camera, since we're going to be using it real soon.
			_player.camera.cancel_zoom()
			
			# Hide the UI.
			_player.camera.get_node("GUI").visible = false
		# Wrangle the camera's animation.
		elif _frame > TIME_PEAK_FLASH:
			var zoom_factor = float(_frame - TIME_PEAK_FLASH)
			zoom_factor /= _animation_length() - TIME_PEAK_FLASH
			# Let the camera begin zooming in.
			_player.camera.current_zoom = lerp(camera_zoom_start, closest_camera_zoom,
				pow(zoom_factor, 2))
				
			# Slide player to center so we're guaranteed a good zoom.
			_player.global_position = lerp(
				camera_focus_start, picture_sprite.global_position,
				pow(zoom_factor, 2))
		
		# If nearing the end, burnaway to white. This is our in transition.
		if _frame >= _animation_length() - FINAL_BURNAWAY_DURATION:
			var burn_fac : float = _frame - (_animation_length() - FINAL_BURNAWAY_DURATION)
			burn_fac /= FINAL_BURNAWAY_DURATION
			
			# Do burnaway animation
			picture_sprite.material.set_shader_param("burnaway_factor", burn_fac)
		

func _end_animation(_player):
	# Reset player to full size and visibility.
	_player.scale = Vector2(1,1)
	_player.sprite.modulate.a = 1
	
	# Reset shader params, just in case.
	reset_shader()


func _begin_scene_change(dst_pos, dst_scene, in_time, out_time):
	# Fade through white, not black.
	var fade_effect = $"/root/Singleton/WhiteWarp"
	fade_effect.warp(dst_pos, dst_scene, in_time, out_time)


func _transition_in_time() -> int:
	# Fade to white instantly, since the in transition is the final burnaway.
	return 1


func set_detection_radius(val):
	detection_radius = val
	$DetectionArea.shape.extents.x = val


# Reset shader params. (those that have a visible effect anyway.)
func reset_shader():
	picture_sprite.material.set_shader_param("ripple_amplitude", 0)
	picture_sprite.material.set_shader_param("flash_factor", 0)	
	picture_sprite.material.set_shader_param("burnaway_factor", 0)	
