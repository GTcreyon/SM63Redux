class_name AVEffect
extends Node
## An audiovisual effect, triggered by the AVManager.


## Trigger the effect with the given name.
func trigger() -> void:
	do_effect()
	sub_effects()


## Behavior of the effect.
func do_effect() -> void:
	pass


## Trigger sub-effects.
## If "" is received as input, trigger all sub-effects.
## Otherwise, trigger only the effect named by the argument.
func sub_effects() -> void:
	for child in get_children():
		child.trigger()
