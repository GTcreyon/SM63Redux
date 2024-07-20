extends FileDialog

func _on_SaveDialog_file_selected(path):
	var serializer = JSONSerializer.new()
	var template = get_node("/root/Main/Template")
	
	var level_json = serializer.generate_level_json(template)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(level_json)
	file.close()
