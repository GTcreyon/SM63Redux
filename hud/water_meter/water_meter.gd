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
onready var power_filler_cover = $PowerFiller/Cover
onready var cover = $Cover
onready var power_mask = $PowerMask
onready var max_sprite = $Max
onready var tween = $Tween

onready var singleton = $"/root/Singleton"
onready var player = $"/root/Main/Player"

var power_prev = 100
var water_prev = 100

var font_white = BitmapFont.new()

func _ready():
	font_white.create_from_fnt("res://fonts/white/gui_white.fnt")
	label.set("custom_fonts/font", font_white)

func _process(_delta):
	filler.scale.y = singleton.water * 79 / 100
	mask_filler.scale.y = -filler.scale.y
	power_filler.scale.y = singleton.power * 83 / 100
	if singleton.water > 0:
		surface.visible = true
		bottom.visible = true
		bubbles_big.visible = true
		bubbles_medium.visible = true
		bubbles_small.visible = true
		surface.position.y = (100 - singleton.water) * 79 / 100
	else:
		surface.visible = false
		bottom.visible = false
		bubbles_big.visible = false
		bubbles_medium.visible = false
		bubbles_small.visible = false
	if singleton.water == 100:
		max_sprite.visible = true
		label.visible = false
	else:
		max_sprite.visible = false
		label.visible = true
		label.text = str(floor(singleton.water))
		
	power_mask.offset.y = int(power_mask.offset.y - 1) % 83
	power_mask.energy = 1.4 if player.fludd_strain else 1.0
	if singleton.power == 100 && power_prev != 100:
		power_filler_cover.modulate.a = 1
	elif power_filler_cover.modulate.a > 0:
		power_filler_cover.modulate.a -= 0.1
	power_prev = singleton.power
	
	if singleton.water > water_prev:
		cover.modulate.a = 1
	elif cover.modulate.a > 0:
		cover.modulate.a -= 0.1
	water_prev = singleton.water
