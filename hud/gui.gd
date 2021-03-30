extends CanvasLayer

var font_red = BitmapFont.new()

func _ready():
	font_red.create_from_fnt("res://fonts/red/gui_red.fnt")
	$Coin_counter.set("custom_fonts/font", font_red)
	#$DebugLabel.set("custom_fonts/font", font_red)
