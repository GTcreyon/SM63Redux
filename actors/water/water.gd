extends Area2D

func _process(dt):
	var pos = get_global_transform_with_canvas().origin #get the position
	var size = OS.get_window_size() #normalise the object
	pos.y = size.y - pos.y #inverse the y
	material.set_shader_param("object_pos", pos / size) #give the object position to the shader
