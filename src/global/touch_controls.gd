extends Control

func _init():
	visible = false


func _ready():
	var scale = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	var button_scale = min(floor(OS.window_size.x / (120 * scale)), floor(OS.window_size.y / (42 * scale)))
	$TouchArrows.rect_scale = Vector2.ONE * scale * button_scale
	$TouchAction.rect_scale = Vector2.ONE * scale * button_scale
	$TouchFeedback.rect_scale = Vector2.ONE * scale
	$TouchFeedback.margin_left = 80 * scale


func _process(_delta):
	visible = Singleton.touch_controls()


func _on_Left_pressed():
	Input.action_press("left")


func _on_Left_released():
	Input.action_release("left")


func _on_Right_pressed():
	Input.action_press("right")


func _on_Right_released():
	Input.action_release("right")


func _on_Up_pressed():
	Input.action_press("up")
	Input.action_press("jump")


func _on_Up_released():
	Input.action_release("up")
	Input.action_release("jump")


func _on_Down_pressed():
	Input.action_press("down")
	Input.action_press("dive")


func _on_Down_released():
	Input.action_release("down")
	Input.action_release("dive")


func _on_Z_pressed():
	Input.action_press("pound")
	Input.action_press("interact")


func _on_Z_released():
	Input.action_release("pound")
	Input.action_release("interact")


func _on_X_pressed():
	Input.action_press("spin")
	Input.action_press("skip")


func _on_X_released():
	Input.action_release("spin")
	Input.action_release("skip")


func _on_C_pressed():
	Input.action_press("fludd")


func _on_C_released():
	Input.action_release("fludd")


func _on_Shift_pressed():
	Input.action_press("switch_fludd")


func _on_Shift_released():
	Input.action_release("switch_fludd")


func _on_P_pressed():
	Input.action_press("pause")


func _on_P_released():
	Input.action_release("pause")
