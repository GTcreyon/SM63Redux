class_name InteractableWarp
extends Interactable
# A variant of Interactable that warps Mario somewhere,
# either to another scene or someplace in the current one.
# 
# To implement this base class, there are two functions to extend:
# - _animation_length() returns the expected duration of the animation
#   as an int.
# - _update_animation(_frame, _mario) updates the enter animation for the
#   given frame.
# For further customization, you can override _interact_check() if you want
# it to respond to a different button than "up",
# or override _begin_scene_change(target_pos, scene_pos) to change what
# transition will be used on scene change (star iris out by default).
# 
# Please note that if the particular warp is set to move to a different scene,
# the exit transition will begin TRANSITION_SPEED_IN frames before the end of
# the animation.

const TRANSITION_SPEED_IN = 25
const TRANSITION_SPEED_OUT = 15

export var target_pos = Vector2.ZERO
export var move_to_scene = false
export var scene_path : String

var mario = null # This holds a reference to Mario during the animation
var anim_timer = -1 # This goes down by one every frame of the animation


# When interacted, go into play-animation state
func _interact_with(body):
	mario = body
	
	# Lock Mario's input so he can't be controlled
	mario.locked = true
	
	# Change to "animating" state
	anim_timer = _animation_length()


func _physics_override():
	._physics_override()
	
	# Run frame-by-frame animation logic.
	if anim_timer > -1:
		# Step the animation one frame forward.
		# Pass it an inverted timer so people inheriting this class can work
		# with frames-elapsed instead of frames-left.
		_update_animation(_animation_length() - anim_timer, mario)
		
		# Begin scene-change transition if the animation is ready
		if anim_timer == min(TRANSITION_SPEED_IN, _animation_length()) and move_to_scene == true:
			_begin_scene_change(target_pos, scene_path)
			
		# If not changing scenes, warp Mario when the timer rings
		if anim_timer == 0 and move_to_scene != true:
			mario.position = target_pos
			mario.locked = false
			
			# No longer need this reference, let's drop it.
			mario = null
		
		# Tick the animation timer.
		# This is also what stops the timer when it runs out--
		# when the timer is 0 and Mario warps, the timer will
		# tick down to -1 (the "not running" value) and stop.
		anim_timer -= 1


# Checks if Mario is in a state where he can interact
func _state_check(body) -> bool:
	return !body.locked and ._state_check(body) and body.is_on_floor()


# Checks if the trigger button was pressed
func _interact_check() -> bool:
	# Use Up by default, not the read-sign button (can be changed later)
	return Input.is_action_just_pressed("up")


func _animation_length() -> int:
	return 0


func _update_animation(_frame: int, _mario):
	pass


# Begins the exit transition. Called TRANSITION_SPEED_IN frames BEFORE the animation ends!
func _begin_scene_change(target_pos, scene_path):
	# Default warp transition is a star iris
	var sweep_effect = $"/root/Singleton/WindowWarp"
	sweep_effect.warp(target_pos, scene_path, TRANSITION_SPEED_IN, TRANSITION_SPEED_OUT)
