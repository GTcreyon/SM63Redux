extends Control

onready var total = $Total
onready var total_ms = $TotalMS
onready var split = $SplitRect/Split

var frames : int = 0
var split_frames : int = 0
var running = true

#func _ready():
#	total.margin_right = get_font("font").get_string_size("0:00.0000").x + 10

func format_time(overall_seconds):
	var ms = floor(fmod(overall_seconds, 1) * 1000)
	var seconds = floor(fmod(overall_seconds, 60))
	var minutes = floor(fmod(overall_seconds, 3600) / 60)
	var hours = floor(overall_seconds / 3600) * 3600
	
	var ms_str = str(ms)
	var seconds_str = str(seconds)
	var minutes_str = str(minutes)
	var hours_str = str(hours)
	
	if ms < 10:
		ms_str = "00" + str(ms_str)
	elif ms < 100:
		ms_str = "0" + str(ms_str)
		
	if seconds < 10:
		seconds_str = "0" + str(seconds_str)
		
	if minutes < 10 && hours > 0:
		minutes_str = "0" + str(minutes_str)
	
	if hours > 0:
		return ["%s:%s:%s" % [hours_str, minutes_str, seconds_str], ".%s" % ms_str]
	else:
		return ["%s:%s" % [minutes_str, seconds_str], ".%s" % ms_str]


func _process(_delta):
	if Input.is_action_just_pressed("timer_show"):
		visible = !visible
	rect_scale = Vector2.ONE * max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	if !get_tree().paused && running:
		frames += 1
		split_frames += 1
		var txt = format_time(frames / 60.0)
		total.text = txt[0]
		total_ms.text = txt[1]
	
func split_timer():
	var txt = format_time(split_frames / 60.0)
	split.text = txt[0] + txt[1]
	split_frames = 0
