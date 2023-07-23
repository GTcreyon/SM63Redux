extends Control

const TITLE_SCENE: String = "res://scenes/menus/title/title.tscn"

@onready var exit_lvl_button = $VBoxContainer/VBoxContainer/ButtonExit
@onready var to_title_button = $VBoxContainer/VBoxContainer/ButtonQuit
@onready var close_game_button = $VBoxContainer/VBoxContainer/ButtonClose
@onready var transition_out = $"/root/Singleton/WindowWarp"


func _ready():
	# Hide exit-game button for platforms that can't use it
	match OS.get_name():
		"Android", "IOS", "HTML5":
			_hide_close_button()
		_:
			close_game_button.visible = true


func _on_ButtonExitLevel_pressed():
	# Stubbed.
	
	#Singleton.connect("after_scene_change", self, "who even knows yet")
	_do_transition_out("")


func _on_ButtonQuitToTitle_pressed():
	# Reset game state once scene change is over.
	Singleton.connect("after_scene_change", Callable(self, "_reset_to_title_state"))
	# Do scene change.
	_do_transition_out(TITLE_SCENE, 1)


func _on_ButtonCloseGame_pressed():
	# Close game before actually changing scenes.
	Singleton.connect("before_scene_change", Callable(self, "_close_game"))
	# Do the transition though.
	_do_transition_out(TITLE_SCENE) #this path just because why not


func _hide_close_button():
	close_game_button.visible = false
	# move the other two buttons down to fill the space
	var button_height = close_game_button.size.y
	exit_lvl_button.position.y += button_height
	to_title_button.position.y += button_height


func _do_transition_out(scene: String, transition_out_time = 15):
	# TODO: Sound effects!
	# TODO: Freeze pause menu so it can't close or change mid-exit.
	
	# Force the transition to execute during pause.
	transition_out.process_mode = Node.PROCESS_MODE_ALWAYS
	
	transition_out.warp(null, scene, 25, transition_out_time)


func _unpause_game():
	# Unpause the game.
	get_tree().paused = false
	Singleton.pause_menu = false
	
	# Revert WindowWarp's pause mode.
	# (Don't want pipe entry to become unpausable after quitting to title!)
	transition_out.process_mode = Node.PROCESS_MODE_INHERIT


func _reset_to_title_state():
	_unpause_game()
	
	Singleton.prepare_exit_game()


func _close_game():
	get_tree().quit()
