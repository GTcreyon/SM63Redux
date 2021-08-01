extends CanvasLayer

#var font_red = BitmapFont.new()

onready var singleton = $"/root/Singleton"
onready var coin_counter = $StatsTL/CoinRow/Count
onready var red_coin_counter = $StatsTL/RedCoinRow/Count

func set_size(size):
	$MeterControl.rect_scale = Vector2.ONE * size
	$StatsTL.rect_scale = Vector2.ONE * size
	$StatsTR.rect_scale = Vector2.ONE * size
	$StatsBL.rect_scale = Vector2.ONE * size

#func _ready():
	#font_red.create_from_fnt("res://fonts/red/gui_red.fnt")
	#coin_counter.set("custom_fonts/font", font_red)


func _process(_delta):
	coin_counter.text = str(singleton.coin_total)
	red_coin_counter.text = str(singleton.red_coin_total)
