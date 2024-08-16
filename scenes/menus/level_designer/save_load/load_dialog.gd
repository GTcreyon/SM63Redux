extends FileDialog

func _on_OpenDialog_file_selected(path):
	var serializer = JSONSerializer.new()
	var file = FileAccess.open(path, FileAccess.READ)
	
	serializer.load_level_json(file.get_as_text(), get_node("/root/Main"))
