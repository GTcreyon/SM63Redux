extends GridContainer

func find_png_paths(queue: Array) -> Array: #by Poobslag https://godotengine.org/qa/user/Poobslag
	var png_paths = [] # accumulated png paths to return
	var dir_queue = queue # directories remaining to be traversed
	var dir: Directory # current directory being traversed

	var file: String # current file being examined
	while file or not dir_queue.empty():
		# continue looping until there are no files or directories left
		if file:
			# there is another file in this directory
			if dir.current_is_dir():
				# found a directory, append it to the queue.
				dir_queue.append("%s/%s" % [dir.get_current_dir(), file])
			elif file.ends_with(".png.import"):
				# found a .png.import file, append its corresponding png to our results
				png_paths.append("%s/%s" % [dir.get_current_dir(), file.get_basename()])
		else:
			# there are no more files in this directory
			if dir:
				# close the current directory
				dir.list_dir_end()

			if dir_queue.empty():
				# there are no more directories. terminate the loop
				break

			# there are more directories. open the next directory
			dir = Directory.new()
			dir.open(dir_queue.pop_front())
			dir.list_dir_begin(true, true)
		file = dir.get_next()

	return png_paths


func _ready(): #this is temporary
	var files = find_png_paths(["res://actors/items"])
	for file in files:
		var rect = TextureRect.new()
		var tex : ImageTexture = ImageTexture.new()
		var img : Image = Image.new()
		img.load(file)
		img.crop(16, 16)
		tex.create_from_image(img)
		rect.texture = tex
		add_child(rect)
