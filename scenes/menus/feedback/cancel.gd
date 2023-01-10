extends Control

		
func _ready():
	var scalar = Singleton.get_screen_scale()
	rect_scale = Vector2.ONE * scalar
	margin_left = 40 * scalar
	visible = false


func _process(_delta):
	visible = $"../FeedbackControl".visible and Singleton.touch_control


func _on_Cancel_pressed():
	visible = false
