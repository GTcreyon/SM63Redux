class_name SpeedrunTimer
extends Control

const RESET_SCENE_PATH = "res://scenes/levels/tutorial_1/tutorial_1_1.tscn"

@onready var total = $Total
@onready var total_ms = $TotalMS
@onready var split_ref = $SplitRect/Split

var frames: int = 0
var split_frames: int = 0
var running = false


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
		
	if minutes < 10 and hours > 0:
		minutes_str = "0" + str(minutes_str)
	
	if hours > 0:
		return ["%s:%s:%s" % [hours_str, minutes_str, seconds_str], ".%s" % ms_str]
	else:
		return ["%s:%s" % [minutes_str, seconds_str], ".%s" % ms_str]


func _physics_process(_delta):
	if Input.is_action_just_pressed("timer_show"):
		visible = !visible
	
	if Input.is_action_just_pressed("reset") and get_tree().get_current_scene().get_scene_file_path().count("tutorial") and !get_tree().paused and Singleton.timer.visible:
		Singleton.get_node("Timer").frames = 0
		Singleton.get_node("Timer").split_frames = 0
		Singleton.get_node("Timer").running = true
		Singleton.warp_location = Vector2(110, 153)
		FlagServer.reset_flag_dict()
		Singleton.warp_to(RESET_SCENE_PATH, null)
	
	scale = Vector2.ONE * max(floor(get_window().size.x / Singleton.DEFAULT_SIZE.x), 1)
	if !Singleton.meta_paused and running:
		frames += 1
		split_frames += 1
		var txt = format_time(round(frames / 60.0 * 1000.0) / 1000.0)
		total.text = txt[0]
		total_ms.text = txt[1]


func split_timer():
	var txt = format_time(split_frames / 60.0)
	split_ref.text = txt[0] + txt[1]
	split_frames = 0
