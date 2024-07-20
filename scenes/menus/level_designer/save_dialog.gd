extends FileDialog

func _on_SaveDialog_file_selected(path):
	var serializer = Serializer.new()
	var EditorRoot = get_node("/root/Main/Template")
	
	var level_json = serializer.generate_level_json(EditorRoot)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(level_json)
	file.close()
