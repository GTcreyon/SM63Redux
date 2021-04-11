extends Area2D

#settings for water
export var water_segment_size = 20 #in pixels, this works regardless of water scale.

#private variables
onready var texture = $Texture

#utility functions
func set_polys(polys): #set the shape of the water for the collision and texture
	var shape = shape_owner_get_shape(0, 0)
	shape.set_point_cloud(polys)
	texture.polygon = polys

func subdivide_surface(): #subdivide the water surface
	var polys = PoolVector2Array()
	for x in range(0, 32 * scale.x, water_segment_size):
		polys.append(Vector2(x / scale.x, 0))
	if !polys[polys.size() - 1].is_equal_approx(Vector2(32, 0)):
		polys.append(Vector2(32, 0))
	polys.append(Vector2(32, 32))
	polys.append(Vector2(0, 32))
	set_polys(polys)

func _ready():
	subdivide_surface()

#update the shader with the latest information
func _process(dt):
	var pos = get_global_transform_with_canvas().origin #get the position
	var size = OS.get_window_size() #normalise the object
	pos.y = size.y - pos.y #inverse the y
	material.set_shader_param("object_pos", pos / size) #give the object position to the shader
