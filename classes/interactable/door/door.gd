class_name Door
extends InteractableExit

const ENTER_LENGTH = 60
const ENTER_BEGIN_TRANSITION = ENTER_LENGTH - TRANSITION_SPEED_IN
const CENTERING_SPEED = 0.25

export var sprite : SpriteFrames

func _ready():
	$DoorSprite.frames = sprite


func _update_animation(_frame: int, _mario):
	# Gradually center Mario
	_mario.global_position.x = lerp(_mario.global_position.x, global_position.x, CENTERING_SPEED)
	
	match _frame:
		ENTER_BEGIN_TRANSITION:
			#Play transition animation
			return EnterState.CAN_TRANSITION
		ENTER_LENGTH:
			return EnterState.DONE
		0:
			# Start Mario's enter animation
			_mario.get_node("Character").set_animation("back")
			# Start door opening animation
			$DoorSprite.play("opening")
			
			return EnterState.ENTERING
		_:
			return EnterState.ENTERING


func _scene_transition(target_pos, scene_path):
	# Default warp transition is a star iris.
	var sweep_effect = $"/root/Singleton/WindowWarp"
	sweep_effect.warp(target_pos, scene_path, TRANSITION_SPEED_IN, TRANSITION_SPEED_OUT)
