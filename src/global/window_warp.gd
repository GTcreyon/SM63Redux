extends Polygon2D

const IN_TIME = 30
const OUT_TIME = 30

var direction = 0
var enter = 0
var set_location = null
var progress : float = 0.0
var scene_path : NodePath = ""

func _ready():
	resize_polygon(1.5)


func resize_polygon(factor):
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
		if progress >= 1.0 - 1.0 / IN_TIME:
			resize_polygon(0)
			if has_node("/root/Main/Player/AnimatedSprite"):
				Singleton.flip = $"/root/Main/Player/AnimatedSprite".flip_h
			else:
				Singleton.flip = false
			Singleton.call_deferred("warp_to", scene_path)
			enter = -1
			progress = 0
		else:
			progress += 1.0 / IN_TIME
			resize_polygon(1.5 - progress * 1.5)
	elif enter == -1:
		if progress >= 1.0:
			enter = 0
			progress = 0
			visible = false
		else:
			progress += 1.0 / OUT_TIME
			resize_polygon(progress * 1.5)


func warp(location, path):
	enter = 1
	Singleton.set_location = location
	scene_path = path
