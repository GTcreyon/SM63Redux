extends TextureButton


func _on_ResetBinds_pressed():
	Singleton.load_input_map(Singleton.default_input_map)
	Singleton.get_node("SFX/Back").play()
