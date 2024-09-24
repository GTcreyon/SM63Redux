extends Polygon2D

enum EnterState {
	FADE_OUT = -1,
	NONE = 0,
	FADE_IN = 1,
}

var in_time = 25
var out_time = 15
onready var cover = $"../CoverLayer/WarpCover"

var enter = EnterState.NONE
var progress : float = 0.0
var scene_path : NodePath = ""


func _process(delta):
	var dmod = min(60 * delta, 1)
	var in_unit = 1.0 / in_time
	var out_unit = 1.0 / out_time
	
	if enter == EnterState.FADE_IN:
		cover.color.a = progress + in_unit
		
		if progress >= 1 - in_unit:
			# WindowWarp is used in main menu, not just in levels.
			# Only find player if there actually is a player.
			var player: PlayerCharacter = null
			if has_node("/root/Main/Player"):
				player = $"/root/Main/Player"
			# Change scenes, using location we set in warp(...).
			Singleton.call_deferred("warp_to", scene_path, player)
			
			# Prepare to fade in on the other side.
			enter = EnterState.FADE_OUT
			progress = 0
		else:
			# Tick progress timer.
			progress += in_unit * dmod
	elif enter == EnterState.FADE_OUT:
		cover.color.a = 1.0 - progress
		
		if progress >= 1.0:
			# Transition over, reset to blank state.
			enter = EnterState.NONE
			progress = 0
			visible = false
			
			# Reset cover to normal color.
			cover.color = Color(0,0,0,0)
		else:
			# Tick progress timer.
			progress += out_unit * dmod
	else:
		pass
	
	# Have to set this every frame. Weird.
	cover.visible = visible


func warp(location: Vector2, path: String, t_in = 25, t_out = 15):
	in_time = t_in
	out_time = t_out
	
	enter = EnterState.FADE_IN
	visible = true
	
	cover.color = Color(1,1,1,1)
	
	Singleton.warp_location = location
	scene_path = path
