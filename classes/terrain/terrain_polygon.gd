tool
extends Polygon2D

export(Texture) var body
export(Texture) var top
export(Texture) var top_shade
export(Texture) var top_corner
export(Texture) var top_corner_shade
export(Texture) var edge
export(Texture) var bottom

export(int) var terrain_material = 0
export(Vector2) var up_direction = Vector2(0, -1) setget set_down_direction
export(Vector2) var down_direction = Vector2(0, 1) setget set_null
export(int) var max_deviation = 60

export(bool) var shallow = false
export(Color) var shallow_color = Color(1, 1, 1, 0.5)

onready var decorations = $Decorations

func set_down_direction(new_val):
	up_direction = new_val
	down_direction = new_val.tangent().tangent()

func set_null(_new_val):
	pass

func _draw():
	decorations.update()
