extends Polygon2D

const IN_TIME = 25
const OUT_TIME = 15
const IN_UNIT = 1.0 / IN_TIME
const OUT_UNIT = 1.0 / OUT_TIME
onready var cover = $"../CoverLayer/WarpCover"

var direction = 0
var enter = 0
var set_location = null
var progress : float = 0.0
var scene_path : NodePath = ""

func _ready():
	resize_polygon(1.5)


func resize_polygon(factor):
	invert_border = OS.window_size.x
	var width = OS.window_size.x
	var height = OS.window_size.y
	var star = [
		Vector2(0, height/2),
		Vector2(width/6, height/2 - width/6),
		Vector2(width/6, height/2 - width*2/6),
		Vector2(width*2/6, height/2 - width*2/6),
		Vector2(width/2, height/2 - width/2),
		Vector2(width*4/6, height/2 - width*2/6),
		Vector2(width*5/6, height/2 - width*2/6),
		Vector2(width*5/6, height/2 - width/6),
		Vector2(width, height/2),
		Vector2(width*5/6, height/2 + width/6),
		Vector2(width*5/6, height/2 + width*2/6),
		Vector2(width*4/6, height/2 + width*2/6),
		Vector2(width/2, height/2 + width/2),
		Vector2(width*2/6, height/2 + width*2/6),
		Vector2(width/6, height/2 + width*2/6),
		Vector2(width/6, height/2 + width/6),
	]
	var star_temp = []
	for point in star:
		star_temp.append(point * factor - Vector2(width*(factor-1)/2, height*(factor-1)/2))
	polygon = star_temp


func _process(_delta):
	if enter == 1:
		visible = true
		cover.color.a = progress + IN_UNIT
		if progress >= 1.0 - IN_UNIT:
			if has_node("/root/Main/Player/AnimatedSprite"):
				Singleton.flip = $"/root/Main/Player/AnimatedSprite".flip_h
			else:
				Singleton.flip = false
			Singleton.call_deferred("warp_to", scene_path)
			enter = -1
			progress = 0
		else:
			progress += IN_UNIT
			resize_polygon(1.5 - progress * 1.5)
	elif enter == -1:
		cover.color.a = 1.0 - progress
		if progress >= 1.0:
			enter = 0
			progress = 0
			visible = false
		else:
			progress += OUT_UNIT
			resize_polygon(progress * 1.5)


func warp(location, path):
	enter = 1
	Singleton.set_location = location
	scene_path = path
