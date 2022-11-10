class_name InteractableExit
extends Area2D

enum EnterState {
	NONE,
	ENTERING,
	CAN_TRANSITION,
	DONE,
}

const TRANSITION_SPEED_IN = 25
const TRANSITION_SPEED_OUT = 15

export var target_pos = Vector2.ZERO
export var move_to_scene = false
export var scene_path : String

var target = null # This is Mario
var anim_timer = 0 # This goes up by one every frame of the animation
var enter_state = EnterState.NONE # This indicates what phase of animation we're in
var can_warp = false # This becomes true when Mario touches this (reset to false on enter)
var store_state = 0 # This is Mario's current state, updated after begin-warp check

func _physics_process(_delta):
	if can_warp and target.locked == false:
		# Begin entering door if up is pressed (while grounded + standing still)
		if Input.is_action_pressed("up") and store_state == target.S.NEUTRAL and target.is_on_floor():
			# Lock Mario's input so he can't be controlled
			target.locked = true
			
			# Change to "animating" state
			can_warp = false
			enter_state = EnterState.ENTERING
		
		store_state = target.state # for next frame
	
	if enter_state != EnterState.NONE:
		# Run animation
		enter_state = _update_animation(anim_timer, target)
		# Tick the animation timer
		anim_timer += 1
		
	# Begin scene-change transition if the animation is ready for it
	if (enter_state == EnterState.CAN_TRANSITION or enter_state == EnterState.DONE) \
		and move_to_scene == true:
		_scene_transition(target_pos, scene_path)
		
	# If not changing scenes, warp Mario on anim_timer ring
	if enter_state == EnterState.DONE and move_to_scene != true:
		# teleport Mario within the level
		target.position = target_pos
		
		# reset Mario to normal
		target.locked = false
		
		# Reset door to normal
		anim_timer = 0
		enter_state = EnterState.NONE


func _on_mario_touch(body):
	if body.state == body.S.NEUTRAL:
		can_warp = true
		target = body


func _on_mario_off(_body):
	if enter_state == EnterState.NONE: # w/o this check, target will get nulled when animation ends
		can_warp = false # Or else he won't
		target = null


func _update_animation(_frame: int, _mario):
	return EnterState.DONE


func _scene_transition(target_pos, scene_path):
	# Default warp transition is a star iris.
	var sweep_effect = $"/root/Singleton/WindowWarp"
	sweep_effect.warp(target_pos, scene_path, TRANSITION_SPEED_IN, TRANSITION_SPEED_OUT)
