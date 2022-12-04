class_name InteractableWarp
extends Interactable
# A variant of Interactable that warps the player somewhere,
# either to another scene or someplace in the current one.
# 
# Functions which child classes SHOULD implement:
# - _animation_length() -> int:
#		returns the expected duration of the animation. This does NOT include
#		the frame after the animation ends!
# - _begin_animation(_player):
#		sets the initial state of the enter animation.
#		This includes changing the player's animation, setting read_pos_x so the
#		player gradually drifts to the center, etc.
# - _update_animation(_frame, _player):
#		updates the enter animation for the given frame.
#		This function does run on the final frame of the animation. In this case,
#		_frame will be equal to _animation_length(). This function will run
#		before _end_animation() does.
# - _end_animation(_player):
#		at the end of the animation, resets any state that the animation set.
#		This function runs after _update_animation() on the animation's final
#		frame, EXCEPT if the warp is to a different scene.

# Functions which child classes MAY implement:
# -	_interact_check() -> bool:
# 		checks whatever is meant to trigger the interaction.
#		For InteractableWarp, the default check is whether "up" is pressed.
# - _begin_scene_change(target_pos, scene_pos):
#		begins whatever screen transition this exit requires.
#		The default behavior is to begin a scene change via WindowWarp, which
#		produces a star iris transition.
#		Please note that if the particular warp is set to move to a different scene,
#		the exit transition will begin TRANSITION_SPEED_IN frames before the end of
#		the animation.
# - _bypass_transition() -> bool:
#		returns true if no transition is desired even in move-to-scene mode.
# -	_exit_pos_offset() -> Vector2:
#		shifts the destination position by some amount.
#		The value returned will be added to target_pos.

const TRANSITION_SPEED_IN = 25
const TRANSITION_SPEED_OUT = 15

export var target_pos = Vector2.ZERO
export var move_to_scene = false
export var scene_path : String

var player = null # This holds a reference to player object during the animation
var anim_timer = -1 # This goes down by one every frame of the animation

func _ready():
	# Always run before player code.
	# Normally, putting a door after the player in the hierarchy makes the door
	# run its code after the player...which means pressing up makes the player
	# jump (and become unable to use warps) BEFORE the warp has a chance to
	# make the player enter, and by the time it tries the player is no longer
	# grounded. In other words, warps only work if they're placed ABOVE the
	# player in the scene tree.
	# This line of code fixes that.
	process_priority = -1


# When interacted, go into play-animation state
func _interact_with(body):
	player = body
	
	# Zero player's velocity so they doesn't keep kicking up dust
	player.vel = Vector2.ZERO
	# Lock player's input so they can't be controlled
	player.locked = true
	
	# Change to "animating" state
	anim_timer = _animation_length()
	_begin_animation(player)


func _physics_override():
	._physics_override()
	
	# Run frame-by-frame animation logic.
	if anim_timer > -1:
		# Step the animation one frame forward.
		# Pass it an inverted timer so people inheriting this class can work
		# with frames-elapsed instead of frames-left.
		_update_animation(_animation_length() - anim_timer, player)
		
		# Begin scene-change transition if the animation is ready
		if anim_timer == min(TRANSITION_SPEED_IN, _animation_length()) \
			and move_to_scene == true and _bypass_transition() == false:
			_begin_scene_change(target_pos + _exit_pos_offset(), scene_path)
		
		# When timer rings...
		if anim_timer == 0:
			if move_to_scene and _bypass_transition():
				Singleton.set_location = target_pos
				Singleton.flip = player.sprite.flip_h
				Singleton.warp_to(scene_path)
			else:
				# We're not scene-changing. Finalize the warp.
				# Set player at the destination, ready to move.
				player.position = target_pos + _exit_pos_offset()
				player.locked = false
				# TODO: Find a way to make exit animations!
				
				# Finalize the animation.
				_end_animation(player)
				
				# No longer need this reference, let's drop it.
				player = null
		
		# Tick the animation timer.
		# This is also what stops the timer when it runs out--
		# when the timer is 0 and the warp happens, the timer will
		# tick down to -1 (the "not running" value) and stop.
		anim_timer -= 1


# Will be added to destination position.
func _exit_pos_offset() -> Vector2:
	return Vector2(0,0)


# Checks if player is in a state where they can interact
func _state_check(body) -> bool:
	return !body.locked and ._state_check(body) and body.is_on_floor()


# Checks if the trigger button was pressed
func _interact_check() -> bool:
	# Use Up by default, not the read-sign button (can be changed later)
	return Input.is_action_just_pressed("up")


func _animation_length() -> int:
	return 0


func _begin_animation(_player):
	pass


func _update_animation(_frame: int, _player):
	pass


func _end_animation(_player):
	pass


# Begins the exit transition. Called TRANSITION_SPEED_IN frames BEFORE the animation ends!
func _begin_scene_change(dst_pos: Vector2, dst_scene: String):
	# Default warp transition is a star iris
	var sweep_effect = $"/root/Singleton/WindowWarp"
	sweep_effect.warp(dst_pos, dst_scene, TRANSITION_SPEED_IN, TRANSITION_SPEED_OUT)


# Should the exit transition be skipped?
func _bypass_transition() -> bool:
	return false


#func _player_shift_to_position(player, position, shift_rate):
#	player.global_position.x = lerp(player.global_position.x, position, shift_rate)
