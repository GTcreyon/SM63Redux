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
			return [
				{
					"name": "external_textures",
					"default_value": false
				},
				{
					"name": "Texture Rects",
					"default_value": null,
					"usage": PROPERTY_USAGE_GROUP,
				},
				{
					"name": "body",
					"default_value": Rect2(36, 3, 32, 32)
				},
				{
					"name": "top",
					"default_value": Rect2(105, 3, 32, 32)
				},
				{
					"name": "top_endcap",
					"default_value": Rect2(72, 3, 32, 32)
				},
				{
					"name": "top_clip",
					"default_value": Rect2(105, 36, 32, 32)
				},
				{
					"name": "top_endcap_clip",
					"default_value": Rect2(72, 36, 32, 32)
				},
				{
					"name": "side",
					"default_value": Rect2(3, 3, 32, 32)
				},
				{
					"name": "bottom",
					"default_value": Rect2(36, 36, 32, 32)
				},

			]
		_: # 
			return []


func _get_importer_name():
	return "63r.terrain_skin"


func _get_visible_name():
	return "Terrain Skin Template"


func _get_recognized_extensions():
	return ["bmp", "png", "jpg", "jpeg", "tga", "webp"]


func _get_save_extension():
	return "res"


func _get_resource_type():
	return "Resource"


func _get_import_order():
	return 0

## Returns true for any option which is visible.
func _get_option_visibility(path, option_name, options):
	return true # Stubbed while no options exist.


func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	# Open the given file (and error if invalid).
	var file := FileAccess.get_file_as_bytes(source_file)
	if file == null:
		return FileAccess.get_open_error()
	
	# Load image data from the bytes.
	var img := Image.new()
	var parse_result
	match source_file.get_extension().to_lower() :
		"bmp":
			parse_result = img.load_bmp_from_buffer(file)
		"png":
			parse_result = img.load_png_from_buffer(file)
		"jpg", "jpeg":
			# Not an ideal format, but heck, no reason to prevent it
			parse_result = img.load_jpg_from_buffer(file)
		"tga":
			parse_result = img.load_tga_from_buffer(file)
		"webp": # why
			parse_result = img.load_webp_from_buffer(file)
		_:
			parse_result = ERR_INVALID_DATA
	# Abort if the load failed.
	if parse_result != OK:
		return parse_result
	
	# Create output file.
	var out_res := TerrainSkin.new()

	# Get the raw source filename.
	var in_extension = source_file.get_extension()
	var tex_name = source_file.get_file()
	# Remove the extension from the end of name.
	tex_name = tex_name.erase(
		tex_name.length() - (in_extension.length() + 1),
		in_extension.length() + 1
	)
	
	out_res.resource_name = tex_name
	out_res.resource_path = "%s.%s" % [save_path, _get_save_extension()]

	# Needed when "External Textures" is checked.
	var tex_folder: String
	var editor_fs: EditorFileSystem
	if options["external_textures"]:
		# Create a folder to store the separated texture resources.
		tex_folder = "%s/%s" % [source_file.get_base_dir(), tex_name]
		DirAccess.make_dir_absolute(tex_folder)

		# Get access to the editor filesystem--need this to make the editor
		# acknowledge newly created files.
		editor_fs = EditorInterface.get_resource_filesystem()
		
		# Make the editor acknowledge the textures directory.
		editor_fs.update_file(tex_folder)
		

	# Slice each non-zero-sized texture from the spritesheet.
	# (Can't just use atlas textures, they don't loop like we need.)
	for tex_type in [
		"body",
		"top", "top_clip",
		"top_endcap", "top_endcap_clip",
		"side", "bottom"
	]:
		if options[tex_type].size.x > 0 and options[tex_type].size.y > 0:
			var slice = img.get_region(options[tex_type])
			# If the slice has any visible pixels...
			if !slice.is_invisible():
				# ...create a texture from it.
				var tex = ImageTexture.create_from_image(slice)

				# Name the texture resource.
				tex.resource_name = "%s_%s" % [tex_name, tex_type]

				# If we want separate texture files, save those. 
				if options["external_textures"]:
					var tex_path = "%s/%s.png" % \
						[tex_folder, tex_type]

					# If the file's been modified outside the importer,
					# do not save over it.
					var overwrite_safe := true
					if ResourceLoader.exists(tex_path):
						var existing = ResourceLoader.load(tex_path)

						# Check when the imported resource was last modified.
						# If it exists. Otherwise it's 0.
						var last_imp_time = 0
						if FileAccess.file_exists(out_res.resource_path):
							last_imp_time = FileAccess.get_modified_time(out_res.resource_path)
						
						# Check the texture's current modify time.
						var modified_time = FileAccess.get_modified_time(tex_path)

						# If the texture's modify time is unset or mismatches
						# the resource file, the texture has been modified
						# externally and is not safe to replace.
						if modified_time == 0 or modified_time != last_imp_time:
							overwrite_safe = false
							push_warning(
								"%s's %s texture appears to have been externally modified. Skipping over it."
								% [
									tex_name, tex_type.capitalize()
								]
							)
					
					# If it's safe to overwrite, save this texture into that folder.
					if overwrite_safe:
						# Write the texture.
						var save_result = ResourceSaver.save(tex, tex_path)
						if save_result != OK:
							push_error("Failed to write to %s: %s" % [
								tex_path, 
								error_string(save_result),
							])
							continue

						# Tell the editor this file exists.
						editor_fs.update_file(tex_path)

						# Try importing the sliced texture. 
						var imp_result = append_import_external_resource(tex_path)
						# If import failed, report and leave the texture blank.
						if imp_result != OK:
							push_error("%s's %s texture failed to import: %s" % [
								tex_name, tex_type.capitalize(), 
								error_string(imp_result)
							])
							continue

						# Register this as one of the generated files.
						r_gen_files.push_back(tex_path)
				
				# Separate or embedded, save it to the resource.
				out_res.set(tex_type, tex)
	
	# If there's different variants of this resource for different platforms,
	# push the feature tag to r_platform_variants, then insert the tag between
	# save_path and _get_save_extension() (. separated) when saving the files.
	
	return ResourceSaver.save(out_res)
