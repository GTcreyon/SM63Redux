extends AnimatedSprite

const NO_ANIM_CHANGE = ""

const TRIPLE_FLIP_HALFWAY = PlayerCharacter.TRIPLE_FLIP_TIME / 2

const SLOW_SPIN_START_SPEED = 2
const SLOW_SPIN_END_SPEED = 1
const SLOW_SPIN_TIME = 60

const POUND_ORIGIN_OFFSET = Vector2(-2,-3) # Sprite origin is set to this during pound spin
const POUND_SPIN_RISE = 1 # How much the player rises each frame of pound
const POUND_SPIN_RISE_TIME = 15

const SLIDE_MAX_SPEED: float = 5.0

# Keep in sync with parent's default values
var last_state: int = PlayerCharacter.S.NEUTRAL
var last_swimming: bool = false
var last_vel: Vector2 = Vector2.ZERO
var last_grounded: bool = true
var last_flip_ending: bool = false # parent.triple_flip_frames >= TRIPLE_FLIP_HALFWAY
var last_pound_state: int = PlayerCharacter.Pound.SPIN
var last_frame = 0 # Used mainly during walking animation
var slow_spin_timer: float = 0 # Frames of progress through the slow spin

onready var parent: PlayerCharacter = $"../.."
onready var dust = $"../../Dust"


func _ready() -> void:
	playing = true
	# Set up playing next animations when they exist.
	connect("animation_finished", self, "trigger_next_anim")


func _physics_process(_delta):
	rotation = parent.body_rotation
	flip_h = parent.facing_direction == -1
	speed_scale = 1
	
	if (
		# Changed states
		parent.state != last_state
	) or (
		# Changed swimming state
		parent.swimming != last_swimming
	) or (
		# Changed groundedness while underwater
		parent.swimming and parent.grounded != last_grounded
	):
		# Begin new animation.
		trigger_anim(_anim_from_new_state(parent.state, last_state,
			parent.swimming, last_swimming))
	else:
		# Some states have special behavior per-frame. Handle that.
		if parent.swimming and !parent.grounded:
			# No constant update states currently exist when swimming.
			pass
		else:
			match parent.state:
				parent.S.NEUTRAL:
					# Update neutral state.
					trigger_anim(_state_neutral(last_state, last_swimming))
						
					if parent.grounded:
						# Doing walk animation.
						# Set walk speed from parent velocity.
						if int(parent.vel.x) == 0:
							# Not moving. Set animation stopped.
							frame = 0
							speed_scale = 0
							# Play step sound when appropriate.
							if last_frame == 1:
								parent.step_sound()
							# Ensure we end in the right animation.
							if animation == "walk_cycle":
								trigger_anim("walk_neutral")
						else:
							# If we were stopped, jump to first frame of anim.
							if speed_scale == 0:
								frame = 1
							
							# Set speed from velocity.
							speed_scale = min(abs(parent.vel.x / 3.43), 2)
							
							# Play step sound on certain frames.
							if (
								last_frame != frame
								and _is_footstep_frame(frame, animation)
							):
								parent.step_sound()
						
						# Save current anim frame to check against next frame.
						last_frame = frame
					else:
						# Not grounded. Revert any speed changes from walk anim.
						speed_scale = 1
				parent.S.TRIPLE_JUMP:
					# Detect if triple jump is mostly over.
					var flip_ending = parent.triple_flip_frames >= TRIPLE_FLIP_HALFWAY

					if flip_ending and !last_flip_ending:
						# Just crossed the threshold. Switch to fall animation.
						trigger_anim("fall") #"fall_loop")
					
					# Save this frame's flip progress for next frame.
					last_flip_ending = flip_ending
				parent.S.DIVE:
					# TODO: How does this interact with crouching?

					# Offset sprite position down.
					position.y = 7

					if parent.dive_resetting and parent.dive_reset_frames > 0:
						# TODO: Update this thing.
						frame = 0
						if parent.dive_reset_frames >= parent.DIVE_RESET_TIME / 2.0:
							trigger_anim("dive_reset")
							position.y = 0
							if parent.dive_reset_frames >= parent.DIVE_RESET_TIME / 4.0 * 3.0:
								frame = 1
					
					elif parent.grounded and !last_grounded:
						# Became grounded.
						# Should look fine if it cuts off the dive-start animation.
						trigger_anim("dive_ground")
					elif !parent.grounded and last_grounded:
						# Became airborne.
						trigger_anim("dive_air")
					
					if parent.grounded:
						speed_scale = min(abs(parent.vel.x) / SLIDE_MAX_SPEED, 1) * 2
						if abs(parent.vel.x) < 0.5:
							frame = 1
				parent.S.POUND:
					if parent.pound_state != last_pound_state:
						# Pound state changed. Change animation appropriately.
						match parent.pound_state:
							parent.Pound.SPIN:
								# Pound starts in Spin, should be impossible to retrigger.
								push_error("Player %s began pound spin halfway into another state. Is that valid?" % 1)
								pass
							parent.Pound.FALL:
								trigger_anim("pound_fall")
								# Reset rotation origin to normal.
								_clear_rotation_origin()
							parent.Pound.LAND:
								trigger_anim("pound_land")
					elif parent.pound_state == parent.Pound.SPIN:
						# Modify the pound spin animation.
						# TODO: Should be possible to move the spin itself into this script.
						# All body_rotation does in player.gd is set FLUDD spray angle, and you
						# can't FLUDD while beginning a pound anyway.

						# Offset origin's X less at the start of the spin. (Looks better!?)
						position.x *= parent.pound_spin_factor
						
						# A little rising as we wind up makes it look real nice.
						position.y = POUND_ORIGIN_OFFSET.y
						position.y -= POUND_SPIN_RISE * min(parent.pound_spin_frames,
							POUND_SPIN_RISE_TIME)
				parent.S.SPIN:
					match animation:
						"spin_start":
							#frame = float(parent.SPIN_TIME - parent.spin_frames) / float(parent.SPIN_TIME)
							if parent.spin_frames <= 0:
								trigger_anim("spin_cycle")
						"spin_cycle":
							if slow_spin_timer < SLOW_SPIN_TIME:
								slow_spin_timer += 1
							var spin_progress: float = slow_spin_timer / SLOW_SPIN_TIME
							# Lerp speed from fast at the start, to slow at the sustain.
							speed_scale = lerp(SLOW_SPIN_START_SPEED, SLOW_SPIN_END_SPEED, spin_progress)
				parent.S.CROUCH:
					# Recrouch
					if animation == "crouch_end" and !parent.crouch_resetting:
						trigger_anim("crouch_start")
					
					# Uncrouch
					if parent.crouch_resetting and parent.crouch_reset_frames == 0:
						trigger_anim("crouch_end")
	
	# These next things should happen no matter if the animation is new or old.
	
	# If we're flipping, determine flip frame by angle.
	if animation == "flip":
		frame = _get_flip_frame()
	
	# Enable/disable walk dust as appropriate.
	if abs(parent.vel.x) < 2:
		dust.emitting = false
	else:
		dust.emitting = parent.grounded
	# Save this frame's state to check against next time.
	last_state = parent.state
	last_swimming = parent.swimming
	last_vel = parent.vel
	last_grounded = parent.grounded
	last_pound_state = parent.pound_state


func trigger_anim(anim: String):
	if anim != NO_ANIM_CHANGE:
		animation = anim


func trigger_next_anim():
	trigger_anim(_anim_next_for(animation))


func _anim_from_new_state(
	new_state: int, old_state: int,
	swimming: bool, last_swimming: bool
) -> String:
	if swimming:
		match new_state:
			# TODO: Swim stroke anim.
			parent.S.NEUTRAL:
				return "swim_idle"
			parent.S.SPIN:
				# Underwater spin animation should skip fast phase.
				slow_spin_timer = 0
				return "spin_cycle"
			parent.S.HURT:
				return "hurt"
			_:
				# Swimming overrides all other states.
				return "swim_idle"
	else:
		match new_state:
			parent.S.NEUTRAL:
				# Neutral has several substates. Return whichever's appropriate now.
				return _state_neutral(old_state, last_swimming)
			parent.S.TRIPLE_JUMP:
				return "flip"
			parent.S.CROUCH:
				return "crouch_start"
			parent.S.DIVE:
				return "dive_start"
			parent.S.BACKFLIP:
				return "jump_a"
			parent.S.ROLLOUT:
				return "jump_a"
			parent.S.POUND:
				# Move sprite origin for nicer rotation animation
				_set_rotation_origin(parent.facing_direction, POUND_ORIGIN_OFFSET)
				return "flip"
			parent.S.SPIN:
				slow_spin_timer = 0
				return "spin_start"
			parent.S.HURT:
				return "hurt_start"
			_:
				# No other value is valid, I think.
				# But don't crash--just push a warning.
				push_error(
					"Changing player %s's animation state to unimplemented value %s." % [1, new_state]
				)

				# Don't change sprite. What would we change it to?
				return NO_ANIM_CHANGE


func _anim_next_for(current_state: String) -> String:
	match current_state:
		"crouch_end":
			return "walk_neutral"
		"dive_start":
			# Grounded interrupts the start--no need to worry about switching to that.
			return "dive_air"
		"dive_reset":
			return "walk_neutral" #"idle"
		"hurt_start":
			return "hurt_loop"
		"jump_a_start":
			return "jump_a_loop"
		"jump_b_start":
			return "jump_b_loop"
		"jump_double_start":
			return "jump_double_loop"
		"fall_start":
			return "fall_loop"
		"fall_start_double":
			return "fall_loop"
		"landed":
			return "walk_neutral" #"idle"
		"stomp_high":
			return "jump_double_loop"
		"stomp_low":
			return "jump_a_loop"
		"swim_stroke":
			return "swim_idle"
		"walk_neutral":
			return "walk_cycle"
		_:
			return NO_ANIM_CHANGE


func _state_neutral(old_state: int, old_swimming: bool) -> String:
	# Take note if state just changed.
	# (This function is only called when state == neutral, right?)
	var state_changed: bool = old_state != PlayerCharacter.S.NEUTRAL
	# Factor swimming into this change.
	# (This function is only called on land, right?)
	state_changed = state_changed or old_swimming
	
	if (
		# Just hit the ground
		parent.grounded and !last_grounded
	) or (
		# Entered neutral state while grounded
		parent.grounded and state_changed
	):
		# Just landed.
		return "walk_neutral" #"landed"
	else:
		# Store whether a double jump animation is in progress
		var double_jump = parent.double_jump_state == 2
		double_jump = double_jump and !parent.double_anim_cancel
		# Triple jump is handled in its own state, not here.
		
		# If velocity is upward and should change state, do jump.
		if (
			# Velocity just became upward
			parent.vel.y < 0 and last_vel.y >= 0
		) or (
			# Entered neutral state while velocity is upward
			parent.vel.y < 0 and state_changed
		):
			# Trigger jump anims.
			if double_jump:
				return "jump_double"
			else:
				# TODO: jump_b variant
				return "jump_a"
		# If velocity is downward and should change state, begin falling.
		elif (
			# Velocity was upward, just became downward
			parent.vel.y >= 0 and last_vel.y < 0
		) or (
			# Just started falling
			parent.vel.y >= 0 and !parent.grounded and last_grounded
		) or (
			# Entered a neutral state while falling
			parent.vel.y >= 0 and !parent.grounded and state_changed
		):
			# Just began falling. Begin that animation.
			if double_jump:
				return "fall" #"fall_start_double"
			else:
				return "fall" #"fall_start"
		
		# No jump has occurred, neither has any new landing.
		# Hence--no animation change.
		return NO_ANIM_CHANGE


# Returns whether the given frame of the given animation should play a
# footstep sound.
static func _is_footstep_frame (frame: int, anim_name: String) -> bool:
	var valid_frames = []
	
	# Define what is and isn't a step frame for this animation.
	match anim_name:
		"walk_neutral":
			valid_frames = [2, 6]
		"walk_cycle":
			valid_frames = [1, 4]
		_:
			# Not a walk animation.
			pass
	
	# Return whether the passed frame is one of the defined step frames.
	return valid_frames.has(frame)


func _anim_length_gameframes(anim_name: String) -> int:
	var frame_count: float = self.frames.get_frame_count(anim_name)
	var fps: float = self.frames.get_animation_speed(anim_name)
	
	return int((frame_count/fps) * 60)


func _get_flip_frame() -> int:
	return int(abs(rotation) / PI * 2 + 0.5) % 4


func _set_rotation_origin(facing_direction: int, origin: Vector2) -> void:
	# Vector to flip the offset's X, as appropriate.
	var facing = Vector2(facing_direction, 1)
	
	offset = origin * facing
	position = -origin * facing


func _clear_rotation_origin() -> void:
	_set_rotation_origin(1, Vector2.ZERO)