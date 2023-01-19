class_name LockedWarp
extends Interactable

enum LockAnimation {
	NONE,
	UNLOCK,
	JIGGLE
}

export(NodePath) onready var warp = get_node(warp) as InteractableWarp

var current_anim = LockAnimation.NONE
var anim_timer = -1
var player


func _init(target: Interactable):
	
	# Save current position of target.
	var warp_position = target.global_position
	
	# Switch target warp for lock in the hierarchy.
	var warp_parent = target.get_parent()
	warp_parent.remove_child(target)
	warp_parent.add_child(self)
	# Move target warp into lock.
	add_child(target)
	
	# Register target as destination warp.
	warp = target
	
	# Put everything in its right place again.
	global_position = warp_position
	target.global_position = Vector2.ZERO


func _ready():
	# Validate child warp object.
	assert(warp)
	
	if false: # if door is unlocked
		# Destroy lock and leave the warp.
		unlock_instant()
	else:
		# Disable the child warp so it doesn't get used by mistake.
		warp.disabled = true


func _interact_check() -> bool:
	# Passthrough to inner warp's interact check.
	return warp._interact_check()


func _interact_with(body):
	if true: # has key
		begin_unlock(body)
	else:
		# Has not key. Do animation.
		begin_jiggle()


func _physics_override():
	._physics_override()
	
	# Do door opening animation.
	if anim_timer > 0:
		# Update animations.
		match current_anim:
			LockAnimation.UNLOCK:
				pass
			LockAnimation.JIGGLE:
				pass
		
		# Tick anim timer down.
		anim_timer -= 1
	elif anim_timer == 0:
		# End animations
		match current_anim:
			LockAnimation.UNLOCK:
				unlock_instant()
				# Passthrough to inner warp animation.
				warp._interact_with(player)
			LockAnimation.JIGGLE:
				pass
		
		# Tick anim timer down.
		anim_timer -= 1


func begin_unlock(body):
	# Save player for future use.
	player = body
	# Lock player input for the unlock animation.
	player.locked = true
	
	
	# Set animation to begin.
	current_anim = LockAnimation.UNLOCK
	anim_timer = 60


func begin_jiggle():
	# Set animation.
	current_anim = LockAnimation.JIGGLE
	anim_timer = 60


# Instantly destroys the lock and moves the internal warp out.
func unlock_instant():
	# Move warp into lock's parent node, while making sure the global
	# position remains the same.
	var warp_position = warp.global_position
	remove_child(warp)
	get_parent().add_child(warp)
	warp.global_position = warp_position
	# Re-enable warp.
	warp.disabled = false
	
	queue_free()


# Gets the lock's internal warp.
func get_locked_object() -> InteractableWarp:
	return warp
