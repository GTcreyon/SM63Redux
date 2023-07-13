extends Sprite2D

@onready var bottom = $Bottom
@onready var filler = $Filler
@onready var surface = $Surface
@onready var bubble_mask = $BubbleMask
@onready var bubbles_big = $BubbleMask/BubblesBig
@onready var bubbles_medium = $BubbleMask/BubblesMedium
@onready var bubbles_small = $BubbleMask/BubblesSmall
@onready var label = $WaterMeterLabel
@onready var power_filler = $PowerFiller
@onready var power_filler_cover = $PowerFiller/Cover
@onready var cover = $Cover
@onready var power_mask = $PowerMask
@onready var max_sprite = $Max
@onready var icon = $Icon

@onready var player = $"/root/Main/Player"

var power_prev = 100
var water_prev = 100
var icon_bob = 0
var font_white = FontFile.new()

func refresh():
	visible = true
	match player.current_nozzle:
		1:
			icon.animation = "hover"
		2:
			icon.animation = "rocket"
		3:
			icon.animation = "turbo"
		_:
			visible = false
	if player.water == 100:
		max_sprite.visible = true
		label.visible = false
	else:
		max_sprite.visible = false
		label.visible = true
		if player.water == INF:
			label.text = "INF"
		else:
			# keeps the display in range 1-99
			label.text = str(floor((player.water + 1) / 100 * 99))


func _ready():
	refresh()


func _process(delta):
	var dmod = 60 * delta
	refresh()
	if player.fludd_strain:
		icon_bob = fmod(icon_bob + 0.5 * dmod, 120)
	else:
		icon_bob = fmod(icon_bob + 0.1 * dmod, 120)
	icon.offset.y = sin(icon_bob) * 2
	if player.water == INF:
		filler.scale.y = 79
	else:
		filler.scale.y = player.water * 79 / 100
	bubble_mask.offset_top = 79 - filler.scale.y
	power_filler.scale.y = player.fludd_power * 83 / 100
	if player.water > 0:
		surface.visible = true
		bottom.visible = true
		bubbles_big.visible = true
		bubbles_medium.visible = true
		bubbles_small.visible = true
		if player.water == INF:
			surface.position.y = 0
		else:
			surface.position.y = (100 - player.water) * 79 / 100
	else:
		surface.visible = false
		bottom.visible = false
		bubbles_big.visible = false
		bubbles_medium.visible = false
		bubbles_small.visible = false
		
	power_mask.offset.y -= 1 * dmod
	if(power_mask.offset.y < -83): power_mask.offset.y += 83
	power_mask.energy = 1.4 if player.fludd_strain else 1.0
	if player.fludd_power == 100 and power_prev != 100:
		power_filler_cover.modulate.a = 1
	elif power_filler_cover.modulate.a > 0:
		power_filler_cover.modulate.a -= 0.1 * dmod
	power_prev = player.fludd_power
	
	if player.water > water_prev:
		cover.modulate.a = 1
	elif cover.modulate.a > 0:
		cover.modulate.a -= 0.1 * dmod
	water_prev = player.water
