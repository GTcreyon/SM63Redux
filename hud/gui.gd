extends CanvasLayer

#var font_red = BitmapFont.new()

onready var singleton = $"/root/Singleton"
onready var player = $"/root/Main/Player"
onready var coin_counter = $StatsTL/CoinRow/Count
onready var red_coin_counter = $StatsTL/RedCoinRow/Count
onready var meter = $MeterControl
onready var icon = $MeterControl/Icon

var icon_bob = 0

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


func _process(_delta):
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
	
