class_name Hurtbox
extends Area2D
## An Area2D that receives hits from hitboxes, and relays them to the owner of this hurtbox.

## The owner of the hurtbox. Hits will be relayed to this node.
## If null, hits will be stored instead to be accessed later.
@export var target: Node = null

## The damage types that the hurtbox will detect.
## See the [Hitbox] class for specific explanations.
@export_flags("Generic", "Stomp", "Pound", "Strike", "Burn", "Explosion", "Nudge") var hurt_mask: int = 1
# NOTE: Unfortunately, setting the variable to type [Hit.Type] removes the
# ability to set multiple flags. This is the only way to do that short of a
# custom property function.

var stored_hits: Array[Hit]

## If true, the hurtbox will be available to receive hits.
var _enabled: bool = true


## Sets the hurtbox to be enabled or disabled.
func set_enabled(value: bool) -> void:
	_enabled = value
	monitorable = _enabled


## Inflicts a hit on this hurtbox.
## Returns a reference to the owner.
func take_hit(hit: Hit) -> Node:
	# If there is no specific target, just store the hit.
	if target == null:
		stored_hits.append(hit)
		return

	# Don't allow self-damage.
	if hit.source == target:
		return null

	# If the given damage type is within the expected damage types, take a hit.
	if hit.type & hurt_mask:
		assert(target.has_method("take_hit"))
		if target.take_hit(hit):
			return target
	
	return null
