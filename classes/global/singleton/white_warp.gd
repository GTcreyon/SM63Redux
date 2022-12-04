extends Polygon2D

enum EnterState {
	FADE_IN = -1,
	NONE = 0,
	FADE_OUT = 1,
}

var in_time = 25
var out_time = 15
onready var cover = $"../CoverLayer/WarpCover"

var enter = EnterState.NONE
var set_location = null
var progress : float = 0.0
var scene_path : NodePath = ""


func _process(delta):
	var dmod = min(60 * delta, 1)
	var in_unit = 1.0 / in_time
	var out_unit = 1.0 / out_time
	
	if enter == EnterState.FADE_OUT:
		cover.color.a = progress + in_unit
		
		if progress >= 1 - in_unit:
			# Do actual warp.
			if has_node("/root/Main/Player/AnimatedSprite"):
				Singleton.flip = $"/root/Main/Player/AnimatedSprite".flip_h
			else:
				Singleton.flip = false
			Singleton.warp_to(scene_path)
			
			# Prepare to fade in on the other side.
			enter = EnterState.FADE_IN
			progress = 0
		else:
			# Tick progress timer.
			progress += in_unit * dmod
	elif enter == EnterState.FADE_IN:
		cover.color.a = 1.0 - progress
		
		if progress >= 1.0:
			# Transition over, reset to blank state.
			enter = EnterState.NONE
			progress = 0
			visible = false
			cover.visible = visible
			
			# Reset cover to normal color.
			cover.color = Color(0,0,0,0)
		else:
			# Tick progress timer.
			progress += out_unit * dmod
	else:
		pass


func warp(location, path, t_in = 25, t_out = 15):
	in_time = t_in
	out_time = t_out
	
	enter = EnterState.FADE_OUT
	visible = true
	cover.visible = visible
	
	cover.color = Color(1,1,1,0)
	
	Singleton.set_location = location
	scene_path = path
