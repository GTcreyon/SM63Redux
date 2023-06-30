extends FileDialog

@onready var main = $"/root/Main"
var load_dict: Dictionary
var pointer: int = 0
var buffer: PackedByteArray


func _on_OpenDialog_file_selected(path):
	var file = FileAccess.open(path, File.READ)
	buffer = file.get_buffer(file.get_length())
	file.close()
	var serializer = Serializer.new()
	serializer.load_buffer(buffer, main)
