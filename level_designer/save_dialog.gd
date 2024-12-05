extends FileDialog

var save_dict: Dictionary
@onready var main = $"/root/Main"

func _on_SaveDialog_file_selected(path):
	var serializer = Serializer.new()
	var buffer = serializer.generate_level_binary($"/root/Main/Template/Items".get_children(), $"/root/Main/Template/Terrain".get_children(), main)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(buffer)
	file.close()
