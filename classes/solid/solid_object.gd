class_name SolidObject
extends StaticBody2D
## A StaticBody2D which can be disabled in the level designer.
##
## The meaning of "disabled" depends on the value of disable_mode.
## If disable_mode is set to DISABLE_MODE_REMOVE, a disabled object will become
## non-solid (it will be "removed" from the physics simulation). Otherwise,
## the object will remain solid no matter what.

@export var disabled = false: set = set_disabled


func set_disabled(val):
	disabled = val
	
	# Set the object's process mode as appropriate.
	# When disable_mode = DISABLE_MODE_REMOVE, this makes the object
	# non-solid when disabled.
	if disabled:
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = Node.PROCESS_MODE_INHERIT
