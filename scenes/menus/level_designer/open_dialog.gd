extends FileDialog

var load_dict: Dictionary
var pointer: int = 0
var buffer: PackedByteArray

@onready var main = $"/root/Main"


func _on_OpenDialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	buffer = file.get_buffer(file.get_length())
	file.close()
	var serializer = Serializer.new()
	serializer.load_level_binary(buffer, main)
