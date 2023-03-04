class_name ResidualSFX
extends AudioStreamPlayer2D
# A standalone sound player that self-destructs when the clip ends.
# Useful for things that need to play a sound as they're destroyed
# (which would destroy any sound nodes contained inside the object).


func _ready():
	# Set self up to self-destruct once the sound is finished.
	# warning-ignore:return_value_discarded
	connect("finished", self, "_on_ResidualSFX_finished")
	play()


func _on_ResidualSFX_finished():
	queue_free()


func _init(sound: AudioStream, pos: Vector2):
	position = pos
	stream = sound


# Takes an existing AudioStreamPlayer2D and makes it act like a ResidualSFX
# (outlive its parent, optionally destroy on finish).
static func new_from_existing (
	sfx: AudioStreamPlayer2D,
	scene_root: Node,
	destroy_on_finished = true
):
	# Reparent to scene root, while preserving global position.
	var sound_pos = sfx.global_position
	sfx.get_parent().remove_child(sfx)
	scene_root.add_child(sfx)
	sfx.global_position = sound_pos
	
	# Make the sfx player destroy on playback (if desired)
	if destroy_on_finished:
		sfx.connect("finished", sfx, "queue_free")
	# Lesgo
	sfx.play()
