extends CanvasLayer

#var font_red = BitmapFont.new()

onready var singleton = $"/root/Singleton"
onready var player = $"/root/Main/Player"
onready var coin_counter = $StatsTL/CoinRow/Count
onready var red_coin_counter = $StatsTL/RedCoinRow/Count
onready var meter = $MeterControl
onready var icon = $MeterControl/Icon

var icon_bob = 0
var pause_offset = 0
var pulse = 0

func _ready():
	set_size(floor(log(floor(OS.window_size.x / 448)) / log(2) + 1), floor(OS.window_size.x / 448))
	var menu = get_tree().get_nodes_in_group("pause")
	for node in menu: #make pause nodes visible but transparent
		node.modulate.a = 0
		node.visible = true


func resize():
	var scale = floor(OS.window_size.y / 304)
	var topsize = OS.window_size.x / scale - 36 - 30
	var offset = 38 / 2 - floor((int(topsize) % 38) / 2.0)
	$BG.rect_size = OS.window_size
	
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
	$ButtonMap/StarsOff.polygon[1].x = $ButtonMap.rect_size.x - 1
	$ButtonMap/StarsOff.polygon[2].x = $ButtonMap.rect_size.x - 1
	$ButtonMap/StarsOn.polygon = $ButtonMap/StarsOff.polygon
	
	$ButtonFludd.rect_scale = Vector2.ONE * scale
	$ButtonFludd.rect_position.x = $ButtonMap.rect_position.x + $ButtonMap.rect_size.x * scale - 1 * scale
	$ButtonFludd.rect_size.x = ceil((OS.window_size.x - 61 * scale) / scale / 4)
	$ButtonFludd/StarsOff.polygon[1].x = $ButtonFludd.rect_size.x - 1
	$ButtonFludd/StarsOff.polygon[2].x = $ButtonFludd.rect_size.x - 1
	$ButtonFludd/StarsOn.polygon = $ButtonFludd/StarsOff.polygon
	
	$ButtonOptions.rect_scale = Vector2.ONE * scale
	$ButtonOptions.rect_position.x = $ButtonFludd.rect_position.x + $ButtonFludd.rect_size.x * scale - 1 * scale
	$ButtonOptions.rect_size.x = floor((OS.window_size.x - 61 * scale) / scale / 4)
	$ButtonOptions/StarsOff.polygon[1].x = $ButtonOptions.rect_size.x - 1
	$ButtonOptions/StarsOff.polygon[2].x = $ButtonOptions.rect_size.x - 1
	$ButtonOptions/StarsOn.polygon = $ButtonOptions/StarsOff.polygon
	
	$ButtonExit.rect_scale = Vector2.ONE * scale
	$ButtonExit.rect_position.x = $ButtonOptions.rect_position.x + $ButtonOptions.rect_size.x * scale - 1 * scale
	$ButtonExit.rect_size.x = floor((OS.window_size.x - 61 * scale) / scale / 4)
	$ButtonExit/StarsOff.polygon[1].x = $ButtonExit.rect_size.x - 1
	$ButtonExit/StarsOff.polygon[2].x = $ButtonExit.rect_size.x - 1
	$ButtonExit/StarsOn.polygon = $ButtonExit/StarsOff.polygon
	
	$LevelInfo.rect_scale = Vector2.ONE * scale
	$LevelInfo.rect_size = OS.window_size / scale
	
	var font = $LevelInfo/LevelName.get_font("font")
	var gap = (OS.window_size.x / scale - font.get_string_size($LevelInfo/LevelName.text.to_upper()).x) / 2
	$LevelInfo/LevelName/Panel.margin_left = gap - 7
	$LevelInfo/LevelName/Panel.margin_right = -gap + 4
	font = $LevelInfo/MissionName.get_font("font")
	gap = (OS.window_size.x / scale - font.get_string_size($LevelInfo/MissionName.text.to_upper()).x) / 2
	$LevelInfo/MissionName/Panel.margin_left = gap - 7
	$LevelInfo/MissionName/Panel.margin_right = -gap + 4
	
	#this is terrible. i wish godot had a way to force controls to update their margins before the frame ends
	var shine_count = 0
	for child in $LevelInfo/CollectRow/ShineRow.get_children():
		if child.visible:
			shine_count += 1
	var shine_width = (shine_count - 1) * $LevelInfo/CollectRow/ShineRow.get_constant("separation")
	var coin_count = 0
	for child in $LevelInfo/CollectRow/CoinRow.get_children():
		if child.visible:
			coin_count += 1
	var coin_width = (coin_count - 1) * $LevelInfo/CollectRow/CoinRow.get_constant("separation")
	$LevelInfo/ShinePanel.margin_left = (OS.window_size.x / scale / 2) - (shine_width + 40 + coin_width) / 2 - 33 / 2 - 4
	$LevelInfo/ShinePanel.margin_right = -((OS.window_size.x / scale / 2) - (shine_width + 40 + coin_width) / 2 - 29 / 2 - 4)
	#$LevelInfo/ShinePanel.margin_left = $LevelInfo/CollectRow/ShineRow.margin_left + 37 - 33 / 2 - 4
	#$LevelInfo/ShinePanel.margin_right = -($LevelInfo/CollectRow.rect_size.x - $LevelInfo/CollectRow/CoinRow.margin_right) - 37 + 29 / 2 + 4

func set_size(size, lin_size):
	#size: general size of UI elements
	#lin_size: linear size (used for elements that look strange when too small, such as the dialog box)
	$MeterControl.rect_scale = Vector2.ONE * size
	$StatsTL.rect_scale = Vector2.ONE * size
	$StatsTR.rect_scale = Vector2.ONE * size
	$StatsBL.rect_scale = Vector2.ONE * size
	$LifeMeter.scale = Vector2.ONE * size
	$LifeMeter.position.x = OS.window_size.x / 2
	$DialogBox.gui_size = lin_size
	$InputDisplay.rect_scale = Vector2.ONE * size
	$InputDisplay.rect_position = Vector2(2 * size, 71 * size)
	resize()


func _process(_delta):
	pulse += 0.1
	$LevelInfo/CollectRow/ShineRow/Shine1/Sprite.material.set_shader_param("outline_color", Color(1, 1, 1, sin(pulse) * 0.25 + 0.5))
	coin_counter.material.set_shader_param("flash_factor", max(coin_counter.material.get_shader_param("flash_factor") - 0.1, 0))
	if coin_counter.text != str(singleton.coin_total):
		coin_counter.material.set_shader_param("flash_factor", 0.5)
		coin_counter.text = str(singleton.coin_total)
		
	red_coin_counter.material.set_shader_param("flash_factor", max(red_coin_counter.material.get_shader_param("flash_factor") - 0.1, 0))
	if red_coin_counter.text != str(singleton.red_coin_total):
		red_coin_counter.material.set_shader_param("flash_factor", 0.5)
		red_coin_counter.text = str(singleton.red_coin_total)
	
	meter.visible = true
	match singleton.nozzle:
		1:
			icon.animation = "hover"
		2:
			icon.animation = "rocket"
		3:
			icon.animation = "turbo"
		_:
			meter.visible = false
	if player.fludd_strain:
		icon_bob = fmod(icon_bob + 0.5, 120)
	else:
		icon_bob = fmod(icon_bob + 0.1, 120)
	icon.offset.y = sin(icon_bob) * 2
	
	var size_changed = false
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		size_changed = true
	if Input.is_action_just_pressed("screen+") && OS.window_size.x + 448 <= OS.get_screen_size().x && OS.window_size.y + 304 <= OS.get_screen_size().y:
		OS.window_size.x += 448
		OS.window_size.y += 304
		size_changed = true
	if Input.is_action_just_pressed("screen-") && OS.window_size.x - 448 >= 448:
		OS.window_size.x -= 448
		OS.window_size.y -= 304
		size_changed = true
	if size_changed:
		$"/root/Main/Bubbles".refresh()
		set_size(floor(log(floor(OS.window_size.x / 448)) / log(2) + 1), floor(OS.window_size.x / 448))
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
	
	var menu = get_tree().get_nodes_in_group("pause")
	var gui_scale = floor(OS.window_size.y / 304)
	if get_tree().paused:
		pause_offset = lerp(pause_offset, 1, 0.5)
		for node in menu:
			node.modulate.a = min(node.modulate.a + 0.2, 1)
	else:
		pause_offset = lerp(pause_offset, 0, 0.5)
		for node in menu:
			node.modulate.a = max(node.modulate.a - 0.2, 0)
	$StatsTL.margin_left = 8 + (37 * gui_scale) * pause_offset
	$StatsTL.margin_top = 8 + (19 * gui_scale) * pause_offset
	$StatsTR.margin_left = -8 - (37 * gui_scale) * pause_offset
	$StatsTR.margin_top = 8 + (19 * gui_scale) * pause_offset
	$StatsBL.margin_left = 8 + (37 * gui_scale) * pause_offset
	$StatsBL.margin_top = -8 - (33 * gui_scale) * pause_offset
	$MeterControl.margin_left = -57 - (37 * gui_scale) * pause_offset
	$MeterControl.margin_top = -113 - (33 * gui_scale) * pause_offset


func _on_ButtonMap_button_down():
	pass # Replace with function body.


func _on_ButtonFludd_button_down():
	pass # Replace with function body.


func _on_ButtonOptions_button_down():
	pass # Replace with function body.


func _on_ButtonExit_button_down():
	pass # Replace with function body.
