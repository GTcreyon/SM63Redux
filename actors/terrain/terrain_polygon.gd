tool
extends Polygon2D

export(Texture) var body
export(Texture) var top
export(Texture) var top_left
export(Texture) var top_right

export(Vector2) var up_direction = Vector2(0, -1)
export(int) var max_deviation = 60

onready var decorations = $Decorations

func _draw():
	decorations.update()
