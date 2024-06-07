extends Control

const BYLIGHT = preload("res://fonts/bylight/bylight.otf")
const RUBY = preload("res://fonts/red/gui_red.fnt")


var perm_scale = 1

@onready var level_name = $Divider/MainContainer/LevelNamePanel/ScaleContainer/LevelName


func _process(_delta):
	refresh_caps()


func refresh_caps():
	if TranslationServer.get_locale().substr(0, 2) == "en":
		level_name.add_theme_font_override("font", RUBY)
		level_name.uppercase = true
	else:
		level_name.add_theme_font_override("font", BYLIGHT)
		level_name.uppercase = false
