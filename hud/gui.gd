extends CanvasLayer

var font_red = BitmapFont.new()

onready var singleton = $"/root/Singleton"
onready var coin_counter = $CoinCounter
onready var red_coin_counter = $RedCoinCounter

func _ready():
	font_red.create_from_fnt("res://fonts/red/gui_red.fnt")
	coin_counter.set("custom_fonts/font", font_red)


func _process(_delta):
	coin_counter.text = str(singleton.coin_total)
	red_coin_counter.text = str(singleton.red_coin_total)
