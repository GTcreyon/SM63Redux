extends TextureButton

## Emitted immediately after the bindings have been reset.
signal reset


func _on_ResetBinds_pressed():
	# Revert the input mapping, both in memory and on disk.
	var map = Singleton.default_input_map
	Singleton.load_input_map(map)
	Singleton.save_input_map(map)
	
	# Announce to listeners that the map's been reset.
	reset.emit()
	
	# Play a confirmation sound.
	Singleton.get_node("SFX/Back").play()
