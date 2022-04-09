extends Control

		
func _ready():
	var scalar = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	rect_scale = Vector2.ONE * scalar
	margin_left = 80 * scalar
	visible = false


func _process(_delta):
	visible = $"../FeedbackControl".visible && OS.get_name() == "Android"


func _on_Cancel_pressed():
	visible = false
