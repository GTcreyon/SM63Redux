extends Control

func _ready():
	resize()


func resize():
	rect_size = OS.window_size
	var scale = floor(OS.window_size.y / 304)
	var topsize = OS.window_size.x / scale - 36 - 30
	var offset = 38 / 2 - floor((int(topsize) % 38) / 2.0)
	$Top.rect_scale = Vector2.ONE * scale
	$Top.rect_size.x = topsize + offset + 19 * scale
	$Top.rect_position.x = 29 * scale - offset * scale - 19 * scale
	$LeftCornerTop.rect_scale = Vector2.ONE * scale
	$LeftCornerBottom.rect_scale = Vector2.ONE * scale
	$RightCornerTop.rect_scale = Vector2.ONE * scale
	$RightCornerBottom.rect_scale = Vector2.ONE * scale
	$Left.rect_scale = Vector2.ONE * scale
	$Left.rect_position.y = 17 * scale
	$Left.rect_size.y = OS.window_size.y / scale - 17 - 33
	$Right.rect_scale = Vector2.ONE * scale
	$Right.rect_position.y = 17 * scale
	$Right.rect_size.y = OS.window_size.y / scale - 17 - 33
	
	$ButtonMap.rect_scale = Vector2.ONE * scale
	$ButtonMap.rect_position.x = 29 * scale
	$ButtonMap.rect_size.x = floor((OS.window_size.x - 61 * scale) / scale / 4)
	
	$ButtonFludd.rect_scale = Vector2.ONE * scale
	$ButtonFludd.rect_position.x = $ButtonMap.rect_position.x + $ButtonMap.rect_size.x * scale - 1 * scale
	$ButtonFludd.rect_size.x = ceil((OS.window_size.x - 61 * scale) / scale / 4)
	
	$ButtonOptions.rect_scale = Vector2.ONE * scale
	$ButtonOptions.rect_position.x = $ButtonFludd.rect_position.x + $ButtonFludd.rect_size.x * scale - 1 * scale
	$ButtonOptions.rect_size.x = floor((OS.window_size.x - 61 * scale) / scale / 4)
	
	$ButtonExit.rect_scale = Vector2.ONE * scale
	$ButtonExit.rect_position.x = $ButtonOptions.rect_position.x + $ButtonOptions.rect_size.x * scale - 1 * scale
	$ButtonExit.rect_size.x = floor((OS.window_size.x - 61 * scale) / scale / 4)
