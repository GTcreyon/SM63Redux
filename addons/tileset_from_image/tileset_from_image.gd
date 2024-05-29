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
					"name": "Texture Rects",
					"default_value": null,
					"usage": PROPERTY_USAGE_GROUP | PROPERTY_USAGE_INTERNAL,
				},
				{
					"name": "body",
					"default_value": Rect2(36, 3, 32, 32)
				},
				{
					"name": "side",
					"default_value": Rect2(3, 3, 32, 32)
				},
				{
					"name": "bottom",
					"default_value": Rect2(36, 36, 32, 32)
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
	
	var out_res := TerrainSkin.new()
	out_res.resource_path = "%s.%s" % [save_path, _get_save_extension()]
	var tex_name = source_file.get_file()
	out_res.resource_name = tex_name
	
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
				# ...save it to the resource.
				out_res.set(tex_type, ImageTexture.create_from_image(slice))
				# Then name it.
				out_res.get(tex_type).resource_name = "%s_%s" % \
					[tex_name, tex_type]
	
	# If we want to save the sliced textures separately, use ResourceSaver,
	# then push their paths to r_gen_files.
	
	# If there's different variants of this resource for different platforms,
	# push the feature tag to r_platform_variants, then insert the tag between
	# save_path and _get_save_extension() (. separated) when saving the files.
	
	return ResourceSaver.save(out_res, "%s.%s" % [save_path, _get_save_extension()])
