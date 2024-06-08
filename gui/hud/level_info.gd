extends Control

const BYLIGHT = preload("res://fonts/bylight/bylight.otf")
const RUBY = preload("res://fonts/red/gui_red.fnt")


var perm_scale = 1

@onready var level_name = $Divider/MainContainer/LevelNamePanel/ScaleContainer/LevelName


func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		match TranslationServer.get_locale().substr(0, 2):
			"en":
				# Fancy display font has all needed characters.
				# Use it for the level name.
				level_name.add_theme_font_override("font", RUBY)
				# Display font has only uppercase glyphs.
				level_name.uppercase = true
			_:
				# Display font may not have all needed characters.
				# Use the standard font.
				level_name.add_theme_font_override("font", BYLIGHT)
				level_name.uppercase = false
