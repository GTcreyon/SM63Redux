class_name Door
extends Area2D

const ENTER_LENGTH = 60
const CENTERING_SPEED = 0.25

const TRANSITION_SPEED_IN = 15
const TRANSITION_SPEED_OUT = 15

export var sprite : SpriteFrames
export var target_pos = Vector2.ZERO
export var move_to_scene = false
export var scene_path : String

var timer = 0
var entering = false
var can_warp = false
var target = null
var store_state = 0

onready var sweep_effect = $"/root/Singleton/WindowWarp"

func _ready():
	$DoorSprite.frames = sprite

func _physics_process(_delta):
	if entering:
		target.position.x = lerp(target.position.x, global_position.x, CENTERING_SPEED)
		# Do entering animation
		pass
	
	if can_warp and target.locked == false:
		# Begin entering door if up is pressed (while grounded + standing still)
		if Input.is_action_pressed("up") and store_state == target.S.NEUTRAL and target.is_on_floor():
			# Set Mario to entering-door animation
			target.locked = true
			target.get_node("Character").set_animation("back")
			
			$DoorSprite.play("opening")
			can_warp = false
			entering = true
		
		store_state = target.state # for next frame
		
	# Tick the animation timer
	if entering == true:
		timer += 1
		
	# Begin scene-change transition early if needed (looks better that way)
	if timer == ENTER_LENGTH - TRANSITION_SPEED_IN and move_to_scene == true:
		sweep_effect.warp(target_pos, scene_path, TRANSITION_SPEED_IN, TRANSITION_SPEED_OUT)
		
	# If not changing scenes, warp Mario on timer ring
	if timer == ENTER_LENGTH and move_to_scene != true:
		# teleport Mario within the level
		target.position = target_pos
		
		# reset Mario to normal
		target.locked = false
		
		# Reset door to normal
		timer = 0
		entering = false


func _on_mario_touch(body):
	if body.state == body.S.NEUTRAL:
		can_warp = true
		target = body


func _on_mario_off(_body):
	if !entering: # w/o this check, target will get nulled when animation ends
		can_warp = false # Or else he won't
		target = null
