extends Control

onready var exit_button = $ButtonCloseGame


func _ready():
	# Hide exit-game button for platforms that can't use it
	match OS.get_name():
		"Android", "IOS", "Web":
			exit_button.visible = false
		_:
			exit_button.visible = true
