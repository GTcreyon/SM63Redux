@tool
extends EditorPlugin

# Declared here so it can be cleaned up in _exit_tree().
var plugin


func _enter_tree():
	# Load and instantiate the actual script.
	plugin = preload("res://addons/tileset_from_image/tileset_from_image.gd").new()
	add_import_plugin(plugin)


func _exit_tree():
	remove_import_plugin(plugin)
