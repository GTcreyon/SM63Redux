extends Polygon2D



var in_time = 25
var out_time = 15
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
		var dist = (point - Vector2(width/2, height/2)).length()
		var angle = (point - Vector2(width/2, height/2)).angle()
		var angle_offset = progress * 2 * PI / 8
		star_temp.append(
			Vector2(width/2, height/2)
			+ (Vector2(cos(angle + angle_offset), sin(angle + angle_offset)) * dist * factor)
			
		)
		#point * factor - Vector2(width*(factor-1)/2, height*(factor-1)/2)
	polygon = star_temp


func _process(delta):
	var dmod = min(60 * delta, 1)
	var in_unit = 1.0 / in_time
	var out_unit = 1.0 / out_time
	if enter == 1:
		visible = true
		cover.color.a = progress + in_unit
		if progress >= 1 - in_unit:
			if has_node("/root/Main/Player/AnimatedSprite"):
				Singleton.flip = $"/root/Main/Player/AnimatedSprite".flip_h
			else:
				Singleton.flip = false
			Singleton.call_deferred("warp_to", scene_path)
			enter = -1
			progress = 0
		else:
			progress += in_unit * dmod
			resize_polygon(1.5 - progress * 1.5)
	elif enter == -1:
		cover.color.a = 1.0 - progress
		if progress >= 1.0:
			enter = 0
			progress = 0
			visible = false
		else:
			progress += out_unit * dmod
			resize_polygon(progress * 1.5)
	elif enter == 0:
		visible = false


func warp(location, path, t_in = 25, t_out = 15):
	in_time = t_in
	out_time = t_out
	enter = 1
	Singleton.set_location = location
	scene_path = path
