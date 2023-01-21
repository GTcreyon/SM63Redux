extends Control

const BYLIGHT = preload("res://fonts/bylight/bylight.tres")
const RUBY = preload("res://fonts/red/gui_red.fnt")

onready var level_name = $Divider/MainContainer/LevelNamePanel/ScaleContainer/LevelName

var perm_scale = 1


func refresh_caps():
	if TranslationServer.get_locale().substr(0, 2) == "en":
		level_name.add_font_override("font", RUBY)
		level_name.uppercase = true
	else:
		level_name.add_font_override("font", BYLIGHT)
		level_name.uppercase = false


func _process(_delta):
	refresh_caps()
