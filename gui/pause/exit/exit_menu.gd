extends Control

const TITLE_SCENE: String = "res://scenes/menus/title/title.tscn"

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


func _on_ButtonQuitToTitle_pressed():
	var transition_out = $"/root/Singleton/WindowWarp"
	transition_out.warp(null, TITLE_SCENE)
	# Force the transition to execute.
	transition_out.pause_mode = Node.PAUSE_MODE_PROCESS
	# TODO: Wipe inter-scene data at some point b4 resuming gameplay.
	# TODO: Freeze pause menu so it can't close or change mid-exit,
	# TODO: Create a metapause to ensure no gameplay events can interrupt.
	# TODO: Sound effects!
	

func _hide_close_button():
	close_game_button.visible = false
	# move the other two buttons down to fill the space
	var button_height = close_game_button.rect_size.y
	exit_lvl_button.rect_position.y += button_height
	to_title_button.rect_position.y += button_height
