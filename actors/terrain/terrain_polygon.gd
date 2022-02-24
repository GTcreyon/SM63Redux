tool
extends Polygon2D

export(Texture) var body
export(Texture) var top
export(Texture) var top_shade
export(Texture) var top_left
export(Texture) var top_left_shade
export(Texture) var top_right
export(Texture) var top_right_shade
export(Texture) var edge
export(Texture) var bottom

export(Vector2) var up_direction = Vector2(0, -1) setget set_down_direction
export(Vector2) var down_direction = Vector2(0, 1) setget set_null
export(int) var max_deviation = 60

onready var decorations = $Decorations

func set_down_direction(new_val):
	up_direction = new_val
	down_direction = new_val.tangent().tangent()

func set_null(_new_val):
	pass

func _draw():
	decorations.update()
