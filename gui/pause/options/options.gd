extends Control

onready var camera_fix = $Margin/CameraFix


func _ready():
	camera_fix.pressed = Singleton.disable_limits


func _process(_delta):
	Singleton.disable_limits = camera_fix.pressed
