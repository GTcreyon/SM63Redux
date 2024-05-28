@tool
extends EditorImportPlugin

enum Presets {
	## The format originally designed for the Tiny Demo.
	FORMAT_V1
}


## Returns the number of presets.
func _get_preset_count():
	return Presets.size()


## Returns the user-facing names of the indexed preset.
func _get_preset_name(preset_index):
	match preset_index:
		Presets.FORMAT_V1:
			return "Tiny Demo-era"
		_:
			return "Unknown"


## Returns the actual parameters of the indexed preset.
func _get_import_options(path, preset_index):
	match preset_index:
		Presets.FORMAT_V1:
			return []
		_: # 
			return []


func _get_importer_name():
	return "63r.terrain_skin"


func _get_visible_name():
	return "Terrain Skin Template"


func _get_recognized_extensions():
	return ["png", "gif"]


func _get_save_extension():
	return "res"


func _get_resource_type():
	return "Tileset"


## Returns true for any option which is visible.
func _get_option_visibility(path, option_name, options):
	return true # Stubbed while no options exist.


func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	# Open the given file (and error if invalid).
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	
	# TODO: Do things with the loaded file.
	# Like validate that it's an image, for example.
	var out_res: Resource
	
	# If there's different variants of this resource for different platforms,
	# push the feature tag to r_platform_variants, then insert the tag between
	# save_path and _get_save_extension() (. separated) when returning.
	
	# If extra files are written outside the import settings, push their paths
	# to r_gen_files.
	
	return ResourceSaver.save(out_res, "%s.%s" % [save_path, _get_save_extension()])
