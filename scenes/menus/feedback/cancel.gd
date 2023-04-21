extends Control


func _ready():
	visible = false


func _process(_delta):
	var scalar = Singleton.get_screen_scale()
	rect_scale = Vector2.ONE * scalar
	margin_left = 40 * scalar
	visible = Singleton.touch_control
