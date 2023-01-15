class_name DeathManager
extends Node

var player_dead = false

onready var cover = $"/root/Singleton/CoverLayer/WarpCover"


func _process(delta):
	var dmod = 60 * delta
	if player_dead:
		cover.visible = true
		# Fade out
		cover.color.a = min(cover.color.a + 1.0/30.0 * dmod, 1)

		# Once the screen is fully black, do death logic.
		if cover.color.a >= 1:
			# Warp to the current scene.
			# TODO: this function creates a split on the speedrun timer. Might not
			# be appropriate for death!
			# warning-ignore:RETURN_VALUE_DISCARDED
			Singleton.warp_to(get_tree().get_current_scene().get_filename(), null)
			
			player_dead = false
	else:
		# Fade in
		cover.color.a = max(cover.color.a - 1.0/30.0 * dmod, 0)
		if cover.color.a <= 0:
			cover.visible = false


func register_player_death(_player):
	# For now, just assume there's one player.
	# Can and should be changed later, of course!

	# Save warp data so when we respawn, state is preserved.
	Singleton.warp_data = InterSceneData.new(_player)
	# Reset player's health so they start full.
	Singleton.warp_data.hp = 8
	# Do NOT set warp location--use the one we entered the room with.

	# Set the death cover to start fading in.
	player_dead = true
