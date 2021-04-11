extends Area2D

onready var texture = $Texture
onready var collision = $Collision
onready var mat = texture.material

func _process(dt):
	var pos = global_position #get the position
	var size = OS.get_window_size() #normalise the object
	pos.y = size.y - pos.y #inverse the y
	mat.set_shader_param("object_pos", pos / size) #give the object position to the shader
