class_name PlayerState
extends State
## State class specific to the player.


## Interface for player input
var input: PlayerInput = null

## Shared node handling the player's motion
var motion: Motion = null

## Stores the previous animation for ease of use in _anim_finished calls
var _last_anim: StringName


func _anim(anim_name: StringName) -> void:
	if not actor.sprite.is_connected(&"animation_finished", _anim_finished):
		actor.sprite.connect(&"animation_finished", _anim_finished)
	_last_anim = anim_name
	actor.sprite.play(anim_name)


func _anim_finished() -> void:
	pass


func trigger_exit():
	if actor.sprite.is_connected(&"animation_finished", _anim_finished):
		actor.sprite.disconnect(&"animation_finished", _anim_finished)
	super()


func _update_facing():
	actor.sprite.flip_h = input.get_last_x() == -1
