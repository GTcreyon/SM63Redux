class_name Hurtbox
extends Area2D
## An Area2D that receives hits from hitboxes, and relays them to the owner of this hurtbox.

## The owner of the hurtbox. Hits will be relayed to this node.
@export var _target: Node = get_parent()

## The damage types that the hurtbox will detect.
## See the [Hitbox] class for specific explanations.
@export_flags("Generic", "Stomp", "Pound", "Strike", "Burn", "Explosion", "Nudge") var _hurt_mask: int = 1

## If true, the hurtbox will be available to receive hits.
var _enabled: bool = true


## Sets the hurtbox to be enabled or disabled.
func set_enabled(value: bool) -> void:
	_enabled = value
	monitorable = _enabled


## Inflicts a hit on this hurtbox.
func take_hit(damage_type: Hitbox.Type, source: HitHandler) -> Node:
	# Don't allow self-damage.
	if source == _target:
		return null

	# If the given damage type is within the expected damage types, take a hit.
	if damage_type & _hurt_mask:
		assert(_target.has_method("take_hit"))
		if _target.take_hit(damage_type, source):
			return _target
	return null
