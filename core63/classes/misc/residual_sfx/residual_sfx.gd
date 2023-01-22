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
