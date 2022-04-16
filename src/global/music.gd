extends AudioStreamPlayer

func _ready():
	if get_tree().get_current_scene().get_filename().count("tutorial"):
		play()


func _process(_delta):
	var current_scene = get_tree().get_current_scene()
	if current_scene != null:
		if current_scene.get_filename().count("tutorial") && !playing && $"/root/Main/Player".collect_pos_final == Vector2():
			play()
		if !current_scene.get_filename().count("tutorial") || $"/root/Main/Player".collect_pos_final != Vector2():
			stop()
