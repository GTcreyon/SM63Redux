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

func _ready():
	# Validate child warp object.
	assert(warp)
	
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
				unwrap_lock()
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


func unwrap_lock():
	# Move warp into lock's parent node, while making sure the global
	# position remains the same.
	var warp_pos = warp.global_position
	remove_child(warp)
	get_parent().add_child(warp)
	warp.global_position = warp_pos
	# Re-enable warp.
	warp.disabled = false
	
	queue_free()
