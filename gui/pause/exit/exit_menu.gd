extends Control

onready var exit_lvl_button = $ButtonExitLevel
onready var to_title_button = $ButtonQuitToTitle
onready var close_game_button = $ButtonCloseGame


func _ready():
	# Hide exit-game button for platforms that can't use it
	match OS.get_name():
		"Android", "IOS", "Web":
			_hide_close_button()
		_:
			close_game_button.visible = true


func _hide_close_button():
	close_game_button.visible = false
	# move the other two buttons down to fill the space
	var button_height = close_game_button.rect_size.y
	exit_lvl_button.rect_position.y += button_height
	to_title_button.rect_position.y += button_height
