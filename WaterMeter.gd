extends Sprite

onready var bottom = $Bottom
onready var filler = $Filler
onready var mask_filler = $BubbleMask/BubbleMaskFiller
onready var surface = $Surface
onready var bubbles_big = $BubblesBig
onready var bubbles_medium = $BubblesMedium
onready var bubbles_small = $BubblesSmall
onready var label = $WaterMeterLabel
onready var power_filler = $PowerFiller

onready var player = $"../../../../Player"

var font_white = BitmapFont.new()

func _ready():
	font_white.create_from_fnt("res://fonts/white/gui_white.fnt")
	label.set("custom_fonts/font", font_white)

func _process(_delta):
	filler.scale.y = player.water * 79 / 100
	mask_filler.scale.y = -filler.scale.y
	power_filler.scale.y = player.power * 83 / 100
	if player.water > 0:
		surface.visible = true
		bottom.visible = true
		bubbles_big.visible = true
		bubbles_medium.visible = true
		bubbles_small.visible = true
		surface.position.y = (100 - player.water) * 79 / 100
	else:
		surface.visible = false
		bottom.visible = false
		bubbles_big.visible = false
		bubbles_medium.visible = false
		bubbles_small.visible = false
	if player.water == 100:
		$Max.visible = true
		label.visible = false
	else:
		$Max.visible = false
		label.visible = true
		label.text = str(floor(player.water))
