extends Control

onready var courses = $Courses
onready var scroll = $ScrollHandle

const main_count = 2
const mini_count = 1

var max_height = main_count * 166 + mini_count * 113
var target_scroll = 0
var gui_scale = 1


func _process(_delta):
	if Input.is_action_just_released("scroll_down"):
		target_scroll = max(courses.margin_top - 20, -max_height)
	if Input.is_action_just_released("scroll_up"):
		target_scroll = min(courses.margin_top + 20, 0)
	courses.margin_top = lerp(courses.margin_top, target_scroll, 0.5)
	refresh_scroll()


func refresh_scroll():
	if max_height != 0:
		scroll.margin_top = 1-(courses.margin_top / max_height) * (OS.window_size.y / gui_scale - 54 - 51)


func resize(scale):
	gui_scale = scale
	max_height = main_count * 166 + mini_count * 113 - (OS.window_size.y / scale - 54)
	refresh_scroll()
	$Courses/MainCourses/BoB.resize()
	$Courses/MainCourses/SL.resize()
