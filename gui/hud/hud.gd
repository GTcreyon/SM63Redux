extends Control

# Absolute cache
onready var player = $"/root/Main/Player"

# HUD cache
onready var dialog_box = $DialogBox
onready var coin_counter = $Stats/StatsTL/CoinRow/Count
onready var red_coin_counter = $Stats/StatsTL/RedCoinRow/Count
onready var silver_counter = $Stats/StatsTL/SilverShineRow/Count
onready var shine_counter = $Stats/StatsTR/ShineRow/Count
onready var shine_coin_counter = $Stats/StatsTR/ShineCoinRow/Count
onready var life_meter = $LifeMeter
onready var water_meter = $MeterControl
onready var icon = $MeterControl/WaterMeter/Icon
onready var stats = $Stats

onready var pause_menu = $PauseMenu

onready var warp = $"/root/Singleton/Warp"

var pause_offset = 0
var pulse = 0
var last_size = Vector2.ZERO
var temp_locale = "en"


func _ready():
	coin_counter.text = str(Singleton.coin_total)
	red_coin_counter.text = str(0)
	silver_counter.text = str(0)
	shine_counter.text = str(0)
	shine_coin_counter.text = str(0)
	#change_size(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x))
	var menu = get_tree().get_nodes_in_group("pause")
	for node in menu: # Make pause nodes visible but transparent
		node.modulate.a = 0
		node.visible = true
	pause_menu.modulate.a = 0
	pause_menu.visible = true


func resize():
	var scale_factor = Singleton.get_screen_scale(-1)
#	var topsize = OS.window_size.x / scale - 36 - 30
#	var offset = 38 / 2 - floor((int(topsize) % 38) / 2.0)
	rect_scale = Vector2.ONE * scale_factor
	rect_size = OS.window_size / scale_factor
	pause_menu.resize(scale_factor)


func _process(delta):
	var dmod = 60 * delta
	var new_locale = TranslationServer.get_locale()
	if new_locale != temp_locale:
		resize()
		temp_locale = new_locale
	pulse += 0.1 * dmod
	#$PauseContent/LevelInfo/CollectRow/ShineRow/Shine1/Sprite.material.set_shader_param("outline_color", Color(1, 1, 1, sin(pulse) * 0.25 + 0.5))
	coin_counter.material.set_shader_param("flash_factor", max(coin_counter.material.get_shader_param("flash_factor") - 0.1, 0))
	if coin_counter.text != str(Singleton.coin_total):
		coin_counter.material.set_shader_param("flash_factor", 0.5)
		coin_counter.text = str(Singleton.coin_total)
		
	#red_coin_counter.material.set_shader_param("flash_factor", max(red_coin_counter.material.get_shader_param("flash_factor") - 0.1, 0))
	if red_coin_counter.text != str(Singleton.red_coin_total):
		#red_coin_counter.material.set_shader_param("flash_factor", 0.5)
		red_coin_counter.text = str(Singleton.red_coin_total)
	
	#if last_size != OS.window_size:
	$"/root/Main/Bubbles".refresh()#
	resize()
	#change_size(max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1))
	last_size = OS.window_size
	
	if Input.is_action_just_pressed("pause"):
		if Singleton.pause_menu:
			Singleton.pause_menu = false
			get_tree().paused = false
		else:
			if !get_tree().paused:
				Singleton.pause_menu = true
				get_tree().paused = true
		
	
	var menu = get_tree().get_nodes_in_group("pause")
	var gui_scale = Singleton.get_screen_scale()
	if Singleton.pause_menu:
		pause_offset = lerp(pause_offset, 1, 0.5)
		pause_menu.modulate.a = min(pause_menu.modulate.a + 0.2 * dmod, 1)
	else:
		pause_offset = lerp(pause_offset, 0, 0.5)
		pause_menu.modulate.a = max(pause_menu.modulate.a - 0.2 * dmod, 0)
	stats.margin_top = 19 * pause_offset
	stats.margin_left = 37 * pause_offset
	stats.margin_right = -37 * pause_offset
	water_meter.margin_left = -57 - (37 * pause_offset)
	water_meter.margin_top = -113 - (33 * pause_offset)
