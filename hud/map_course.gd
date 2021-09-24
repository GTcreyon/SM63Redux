extends Control

onready var coin_group = $CoinGroup
onready var hover = $FluddGroup/Hover
onready var turbo = $FluddGroup/Turbo

func resize(scale):
	if OS.window_size.x / OS.window_size.y > 1.474:
		coin_group.columns = 6
		coin_group.margin_top = 90
		hover.offset = Vector2(-20, 10)
		turbo.offset = Vector2(-21, -10)
	else:
		coin_group.columns = 2
		coin_group.margin_top = 62
		hover.offset = Vector2.ZERO
		turbo.offset = Vector2.ZERO
