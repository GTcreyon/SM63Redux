extends ColorRect

onready var player = $"/root/Main/Player"


func _process(delta):
	var dmod = 60 * delta
	if player.dead:
		visible = true
		# Fade out
		color.a = min(color.a + 1.0/30.0 * dmod, 1)

		# Once the screen is fully black, do death logic.
		if color.a >= 1:
			# Manually save warp data.
			Singleton.warp_data = InterSceneData.new(player)
			# Modify the saved data!
			Singleton.warp_data.hp = 8
			
			# Warp to the current scene.
			# TODO: this function creates a split on the speedrun timer. Might not
			# be appropriate for death!
			# warning-ignore:RETURN_VALUE_DISCARDED
			Singleton.warp_to(get_tree().get_current_scene().get_filename(), null)
			
			#player.dead = false # Scene change resets this.
	else:
		# Fade in
		color.a = max(color.a - 1.0/30.0 * dmod, 0)
		if color.a <= 0:
			visible = false
