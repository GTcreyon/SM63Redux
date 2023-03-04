extends Control

const TITLE_SCENE: String = "res://scenes/menus/title/title.tscn"

onready var exit_lvl_button = $ButtonExitLevel
onready var to_title_button = $ButtonQuitToTitle
onready var close_game_button = $ButtonCloseGame
onready var transition_out = $"/root/Singleton/WindowWarp"


func _ready():
	# Hide exit-game button for platforms that can't use it
	match OS.get_name():
		"Android", "IOS", "Web":
			_hide_close_button()
		_:
			close_game_button.visible = true


func _on_ButtonQuitToTitle_pressed():
	Singleton.connect("after_scene_change", self, "_reset_to_title_state")
	
	# Force the transition to execute during pause.
	transition_out.pause_mode = Node.PAUSE_MODE_PROCESS
	transition_out.warp(null, TITLE_SCENE)
	# TODO: Wipe inter-scene data at some point b4 resuming gameplay.
	# TODO: Freeze pause menu so it can't close or change mid-exit.
	# TODO: Sound effects!


func _hide_close_button():
	close_game_button.visible = false
	# move the other two buttons down to fill the space
	var button_height = close_game_button.rect_size.y
	exit_lvl_button.rect_position.y += button_height
	to_title_button.rect_position.y += button_height


func _unpause_game():
	# Unpause the game.
	get_tree().paused = false
	Singleton.pause_menu = false
	
	# Revert WindowWarp's pause mode.
	# (Don't want pipe entry to become unpausable after quitting to title!)
	transition_out.pause_mode = Node.PAUSE_MODE_INHERIT


func _reset_to_title_state():
	_unpause_game()
	
	# Clear inter-scene data to make resets work cleanly.
	Singleton.reset_game_state()
