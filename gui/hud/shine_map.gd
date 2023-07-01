extends Control

@onready var courses = $Courses
@onready var scroll = $ScrollHandle

const main_count = 2
const mini_count = 1

var max_height = main_count * 166 + mini_count * 113
var target_scroll = 0
var gui_scale = 1


func _process(_delta):
	if Input.is_action_just_released("scroll_down"):
		target_scroll = max(courses.offset_top - 20, -max_height)
	if Input.is_action_just_released("scroll_up"):
		target_scroll = min(courses.offset_top + 20, 0)
	courses.offset_top = lerp(courses.offset_top, float(target_scroll), 0.5)
	refresh_scroll()


func refresh_scroll():
	if max_height != 0:
		scroll.offset_top = 1-(courses.offset_top / max_height) * (get_window().size.y / gui_scale - 54 - 51)
