extends AudioStreamPlayer


func _ready():
	if get_tree().get_current_scene().get_scene_file_path().count("tutorial"):
		play()


func _process(_delta):
	var current_scene = get_tree().get_current_scene()
	if current_scene != null:
		if current_scene.get_scene_file_path().count("tutorial") and !playing:
			play()
		if !current_scene.get_scene_file_path().count("tutorial"):
			stop()
