class_name HitHandler
extends Node
## Handles responses from [Hurtbox]es that have been hit by [Hitbox]es.
##
## The standard system of [Hitbox]es and [Hurtbox]es can detect when a hit occurs.
## This is sufficient in cases where the result is simply to take damage and/or die.
## [br][br]
## However, the recipient must often react according to the attacker's current state.
## For example, a shell needs to know whether the attacker is on the left or right side,
## in order to decide whether to move left or right as a result.
## [br][br]
## Additionally, when a hit lands, the attacker often receives some kind of feedback for the action.
## For example, when a player lands on a shell, the player bounces up.
## This behavior is generally defined by the recipient, rather than the attacker.
## Otherwise, the attacker would need to define responses for all possible recipients.
## [br][br]
## Both of these processes require access to properties and methods on the attacker.
## The shell must know the player's position relative to it in order to decide which direction to
## move, and the shell must also be able to influence the player's velocity in order to make them
## bounce upwards.
## One approach is to access these resources directly. For example:
## [codeblock]
## func _on_Area2D_body_entered(body):
##     velocity = speed * sign(position - body.position)
##     body.velocity = -5
## [/codeblock]
## However, this approach assumes that [code]body[/code] has both a [code]position[/code] and
## [code]velocity[/code] property at its root.
## This assumption forces attackers to provide these two exact identifiers at their root, which
## might not be convenient depending on the structure of the attacker's scripts.
## Additionally, if more complex behavior - such as that of the player bouncing on a Goomba - is
## required, there may be need for a function call that does not exist for other attackers.
## [br][br]
## In some cases, this can be resolved by calling [method Object.has_method], like so:
## [codeblock]
## func _on_Area2D_body_entered(body):
##     if body.has_method("bounce"):
##         body.bounce()
## [/codeblock]
## However, this approach complicates the recipient script by giving it the responsibility of
## determining the capabilities of the attacker.
## [br][br]
## The HitHandler is an intermediate party that can help resolve these conflicts.
## It acts as an interface, defining a set of mutually-agreed methods for manipulating the attacker.
## [br][br]
## This simplifies recipient scripts, as they can rely on HitHandler methods being properly defined,
## negating the need for [method Object.has_method] checks and allowing code completion to work.
## The attacker only needs to override HitHandler methods to define behavior.
## This allows code completion, and avoids having to know the requirements of every recipient.
## Additionally, HitHandler provides default methods that apply in most cases.
## [br][br]
## For example, when a shell is stomped, it calls [method get_pos] on the source's HitHandler.
## The HitHandler returns the attacker's position, and the shell uses that to decide its direction
## of motion.
## It can then call [method set_vel_component] on the HitHandler to apply upwards velocity to the
## attacker, simulating an upwards bounce.
## The default behavior for [method get_pos] works well, so it can be left unchanged.
## [method set_vel_component] or [method set_vel] can be overridden to call [method Motion.set_vel],
## resolving the issue of there being no [code]velocity[/code] property in the root player script.

## The main source node for the hit that is being handled.
@export var _source: Node2D = get_parent()


## Returns the position of the source.
func get_pos() -> Vector2:
	return _source.position


## Sets the velocity of the source.
func set_vel(vel: Vector2) -> void:
	if &"vel" in _source:
		_source.vel = vel
		return
	_fallback_failed("set_vel")


## Gets the velocity of the source.
func get_vel() -> Vector2:
	if &"vel" in _source:
		return _source.vel
	_fallback_failed("get_vel")
	return Vector2.ZERO


## Sets the source's speed in the given [param direction] to the given scalar [param amount].
func set_vel_component(direction: Vector2, amount: float) -> void:
	var vel = get_vel()
	set_vel(direction * amount + vel.slide(direction))


## Initiates a stomp bounce. Optional.
func stomp_bounce() -> void:
	pass


## Prints a warning that a fallback method failed.
func _fallback_failed(funcname: String) -> void:
	push_warning("Fallback for '%s()' on %s failed." % [funcname, _source.name])
