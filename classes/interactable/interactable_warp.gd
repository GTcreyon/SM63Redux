class_name InteractableWarp
extends Interactable
# A variant of Interactable that warps the player somewhere,
# either to another scene or someplace in the current one.
# 
# To implement this base class, there are two functions to extend:
# - _animation_length() returns the expected duration of the animation
#   as an int.
# - _update_animation(_frame, _player) updates the enter animation for the
#   given frame.
# For further customization, you can override _interact_check() if you want
# it to respond to a different button than "up",
# or override _begin_scene_change(target_pos, scene_pos) to change what
# transition will be used on scene change (star iris out by default).
# 
# Please note that if the particular warp is set to move to a different scene,
# the exit transition will begin TRANSITION_SPEED_IN frames before the end of
# the animation.
#
# For convenience, an animation function is included to shift the player slowly
# to a position. This is meant to be run once per frame, probably in the
# entry animation, and should be useful for centering the player to the right
# spot.

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


func _physics_override():
	._physics_override()
	
	# Run frame-by-frame animation logic.
	if anim_timer > -1:
		# Step the animation one frame forward.
		# Pass it an inverted timer so people inheriting this class can work
		# with frames-elapsed instead of frames-left.
		_update_animation(_animation_length() - anim_timer, player)
		
		# Begin scene-change transition if the animation is ready
		if anim_timer == min(TRANSITION_SPEED_IN, _animation_length()) and move_to_scene == true:
			_begin_scene_change(target_pos, scene_path)
			
		# If not changing scenes, warp player when the timer rings
		if anim_timer == 0 and move_to_scene != true:
			player.position = target_pos
			player.locked = false
			
			# No longer need this reference, let's drop it.
			player = null
		
		# Tick the animation timer.
		# This is also what stops the timer when it runs out--
		# when the timer is 0 and the warp happens, the timer will
		# tick down to -1 (the "not running" value) and stop.
		anim_timer -= 1


# Checks if player is in a state where they can interact
func _state_check(body) -> bool:
	return !body.locked and ._state_check(body) and body.is_on_floor()


# Checks if the trigger button was pressed
func _interact_check() -> bool:
	# Use Up by default, not the read-sign button (can be changed later)
	return Input.is_action_just_pressed("up")


func _animation_length() -> int:
	return 0


func _update_animation(_frame: int, _player):
	pass


# Begins the exit transition. Called TRANSITION_SPEED_IN frames BEFORE the animation ends!
func _begin_scene_change(dst_pos: Vector2, dst_scene: String):
	# Default warp transition is a star iris
	var sweep_effect = $"/root/Singleton/WindowWarp"
	sweep_effect.warp(dst_pos, dst_scene, TRANSITION_SPEED_IN, TRANSITION_SPEED_OUT)


#func _player_shift_to_position(player, position, shift_rate):
#	player.global_position.x = lerp(player.global_position.x, position, shift_rate)
