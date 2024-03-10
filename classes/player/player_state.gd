class_name PlayerState
extends State
## State class specific to the player.


var input: PlayerInput = null
var motion: Motion = null


func _anim(anim_name: StringName) -> void:
	if not actor.sprite.is_connected(&"animation_finished", _anim_finished):
		actor.sprite.connect(&"animation_finished", _anim_finished)
	actor.sprite.play(anim_name)


func _anim_finished() -> void:
	pass
