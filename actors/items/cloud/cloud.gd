tool
extends StaticBody2D

export var width = 1 setget set_width

func set_width(new_width):
	width = new_width
	if width <= 0:
		$Middle.visible = false
		$MiddleCollision.disabled = true
	else:
		$Middle.visible = true
		$MiddleCollision.disabled = false
		$Middle.rect_size.x = 16 * width
		$MiddleCollision.shape.extents.x = 8 * width
		$MiddleCollision.position.x = 8 * width + 16
	$Right.position.x = 16 * width + 24
	$RightCollision.position.x = 16 * width + 23
	
