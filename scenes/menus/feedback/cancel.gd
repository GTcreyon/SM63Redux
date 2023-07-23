extends Control


func _ready():
	visible = false


func _process(_delta):
	var scalar = Singleton.get_screen_scale()
	scale = Vector2.ONE * scalar
	offset_left = 40 * scalar
	visible = Singleton.touch_control
