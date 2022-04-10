extends Control

onready var camera_fix = $Margin/CameraFix
onready var touch_controls = $Margin/TouchControls


func _ready():
	camera_fix.pressed = Singleton.disable_limits
	touch_controls.pressed = Singleton.touch_controls()
	$Margin/TouchControls/Sprite.playing = touch_controls.pressed


func _process(_delta):
	Singleton.disable_limits = camera_fix.pressed
	Singleton.force_touch = touch_controls.pressed
