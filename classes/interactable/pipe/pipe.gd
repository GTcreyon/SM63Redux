extends StaticBody2D

const PIPE_HEIGHT = 30
const SLIDE_SPEED = 0.7
const SLIDE_LENGTH = 60
const CENTERING_SPEED_SLOW = 0.25
const CENTERING_SPEED_FAST = 0.75

const TRANSITION_SPEED_IN = 15
const TRANSITION_SPEED_OUT = 15

export var disabled = false setget set_disabled
export var target_pos = Vector2.ZERO
export var move_to_scene = false
export var scene_path : String

var can_warp = false # this variable is changed when mario enters the pipe's small area2D
var slid = false # this is true while Mario is sliding into the pipe
var slide_timer = 0 # This counts up while Mario slides until he reaches the end
var store_state = 0
var target = null

onready var sweep_effect = $"/root/Singleton/WindowWarp"
onready var sound = $SFX # for sound effect
onready var ride_area = $Area2D

func _physics_process(_delta):
	if slid:
		# Slide Mario down into the pipe
		if target.state == 7:
			target.position.y = position.y
			target.position.x = lerp(target.position.x, position.x, CENTERING_SPEED_FAST)
		else:
			target.position.x = lerp(target.position.x, position.x, CENTERING_SPEED_SLOW)
			if target.position.y < position.y:
				target.position.y += SLIDE_SPEED
	
	if can_warp:
		# Begin entering pipe if down is pressed 
		if Input.is_action_pressed("down") and store_state == target.S.NEUTRAL and target.is_on_floor():
			target.get_node("Voice").volume_db = -INF # Dumb solution to mario making dive sounds
			target.get_node("Character").set_animation("front")
			target.dive_correct(0)
			
			sound.play()
			target.locked = true # Affects mario's whole input process
			target.position = Vector2(
				lerp(target.position.x, position.x, CENTERING_SPEED_SLOW),
				position.y - PIPE_HEIGHT)
			
			# Warping will be disabled, then increment will start as mario slides down
			can_warp = false
			slid = true
		# Begin entering pipe if ground pounding
		elif (target.state == target.S.POUND and target.pound_state != target.Pound.SPIN):
			sound.play()
			target.locked = true # Affects mario's whole input process
			#target.position = Vector2(position.x, position.y - 30)
			target.position = Vector2(
				lerp(target.position.x, position.x, CENTERING_SPEED_FAST),
				position.y - PIPE_HEIGHT)
			
			# Warping will be disabled, then timer will start as mario slides down
			can_warp = false
			slid = true
	
		store_state = target.state # for next frame
	
	# Tick the slide timer
	if slid:
		slide_timer += 1
		
	# Begin scene-change transition early if needed (looks better that way)
	if slide_timer == SLIDE_LENGTH - TRANSITION_SPEED_IN and move_to_scene:
			sweep_effect.warp(target_pos, scene_path, TRANSITION_SPEED_IN, TRANSITION_SPEED_OUT)
	
	# If not changing scenes, warp Mario on timer ring
	if slide_timer == SLIDE_LENGTH and move_to_scene != true:
		# Teleport Mario someplace within the level
		target.position = target_pos
			
		# Reset Mario to normal
		target.get_node("Voice").volume_db = -5
		target.locked = false
		target.switch_state(target.S.NEUTRAL)
		target.switch_anim("walk")
		target.dive_correct(0)
		
		# Reset this pipe to ready
		sound.stop()
		slide_timer = 0
		slid = false


func _on_mario_top(body):
	if body.global_position.y < global_position.y:
		if body.state == body.S.NEUTRAL:
			can_warp = true
			target = body


func _on_mario_off(_body):
	if !slid: # w/o this check, target will get nulled during the slide
		can_warp = false # Or else he won't
		target = null


func set_disabled(val):
	disabled = val
	set_collision_layer_bit(0, 0 if val else 1)
	if ride_area == null:
		ride_area = $Area2D
	ride_area.monitoring = !val
