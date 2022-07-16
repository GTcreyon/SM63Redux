extends Control

		
func _ready():
	var scalar = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	rect_scale = Vector2.ONE * scalar
	margin_left = 40 * scalar
	visible = false


func _process(_delta):
	visible = $"../FeedbackControl".visible && Singleton.touch_controls()


func _on_Cancel_pressed():
	visible = false
