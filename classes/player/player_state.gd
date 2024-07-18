class_name PlayerState
extends State
## State class specific to the player.

enum CollisionBox {
	NORMAL,
	SMALL,
	DIVE,
}

## The hitbox that this state uses.
@export var hitbox := CollisionBox.NORMAL

## Interface for player input
var input: PlayerInput = null

## Shared node handling the player's motion
var motion: Motion = null

## Stores the previous animation for ease of use in _anim_finished calls
var _last_anim: StringName

## Dictionary of all hitboxes
@onready var _hitboxes = null

func _anim(anim_name: StringName) -> void:
	if not actor.sprite.is_connected(&"animation_finished", _anim_finished):
		actor.sprite.connect(&"animation_finished", _anim_finished)
	_last_anim = anim_name
	actor.sprite.play(anim_name)


func _anim_finished() -> void:
	pass


func trigger_enter(handover: Variant):
	if _hitboxes == null:
		# Initialise the hitbox dictionary.
		# Have to do this here because the actor node isn't ready by the time the state is.
		# Maybe improvable, but this seems fine.
		_hitboxes = {
			CollisionBox.NORMAL: actor.get_node(^"CollisionStand"),
			CollisionBox.SMALL: actor.get_node(^"CollisionSmall"),
			CollisionBox.DIVE: actor.get_node(^"CollisionDive"),
		}

	# Enable the correct hitbox, disable all others.
	for key in _hitboxes:
		_hitboxes[key].disabled = true
	_hitboxes[hitbox].disabled = false
	super(handover)


func trigger_exit():
	if actor.sprite.is_connected(&"animation_finished", _anim_finished):
		actor.sprite.disconnect(&"animation_finished", _anim_finished)
	super()


func _update_facing():
	var dir = input.get_x_dir()
	if dir != 0:
		motion.set_facing(dir)
