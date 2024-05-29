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
	if options["body"].size.x > 0 and options["body"].size.y > 0:
		var slice = img.get_region(options["body"])
		# If the slice has any visible pixels...
		if !slice.is_invisible():
			# ...save it to the resource.
			out_res.body = ImageTexture.create_from_image(slice)
			# Then name them and give them a path (in an unsuccessful attempt to allow
			# TerrainPolygon to reference these rather than storing a copy of the
			# texture data in its scene file).
			out_res.body.resource_name = "%s_body" % tex_name
			out_res.body.resource_path = "%s::body" % out_res.resource_path
	# Do the same for every texture.
	if options["side"].size.x > 0 and options["side"].size.y > 0:
		var slice = img.get_region(options["side"])
		if !slice.is_invisible():
			out_res.side = ImageTexture.create_from_image(slice)
			out_res.side.resource_name = "%s_side" % tex_name
			out_res.side.resource_path = "%s::side" % out_res.resource_path
	if options["bottom"].size.x > 0 and options["bottom"].size.y > 0:
		var slice = img.get_region(options["bottom"])
		if !slice.is_invisible():
			out_res.bottom = ImageTexture.create_from_image(slice)
			out_res.bottom.resource_name = "%s_bottom" % tex_name
			out_res.bottom.resource_path = "%s::bottom" % out_res.resource_path

	if options["top"].size.x > 0 and options["top"].size.y > 0:
		var slice = img.get_region(options["top"])
		if !slice.is_invisible():
			out_res.top = ImageTexture.create_from_image(slice)
			out_res.top.resource_name = "%s_top" % tex_name
			out_res.top.resource_path = "%s::top" % out_res.resource_path
	if options["top_endcap"].size.x > 0 and options["top_endcap"].size.y > 0:
		var slice = img.get_region(options["top_endcap"])
		if !slice.is_invisible():
			out_res.top_endcap = ImageTexture.create_from_image(slice)
			out_res.top_endcap.resource_name = "%s_top_endcap" % tex_name
			out_res.top_endcap.resource_path = "%s::top_endcap" % out_res.resource_path
	if options["top_clip"].size.x > 0 and options["top_clip"].size.y > 0:
		var slice = img.get_region(options["top_clip"])
		if !slice.is_invisible():
			out_res.top_clip = ImageTexture.create_from_image(slice)
			out_res.top_clip.resource_name = "%s_top_clip" % tex_name
			out_res.top_clip.resource_path = "%s::top_clip" % out_res.resource_path
	if options["top_endcap_clip"].size.x > 0 and options["top_endcap_clip"].size.y > 0:
		var slice = img.get_region(options["top_endcap_clip"])
		if !slice.is_invisible():
			out_res.top_endcap_clip = ImageTexture.create_from_image(slice)
			out_res.top_endcap_clip.resource_name = "%s_top_endcap_clip" % tex_name
			out_res.top_endcap_clip.resource_path = "%s::top_endcap_clip" % out_res.resource_path
	
	# If we want to save the sliced textures separately, use ResourceSaver,
	# then push their paths to r_gen_files.
	
	# If there's different variants of this resource for different platforms,
	# push the feature tag to r_platform_variants, then insert the tag between
	# save_path and _get_save_extension() (. separated) when saving the files.
	
	return ResourceSaver.save(out_res, "%s.%s" % [save_path, _get_save_extension()])
