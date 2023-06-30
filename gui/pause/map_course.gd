extends Control

@onready var coin_group = $CoinGroup
@onready var hover = $FluddGroup/Hover
@onready var turbo = $FluddGroup/Turbo


func resize():
	# protect against division-by-zero error i ran into on win7
	# caused by minimizing the window using the button in the right edge of the taskbar
	if get_window().size.y == 0: return
	
	if get_window().size.x / get_window().size.y > 1.474:
		coin_group.columns = 6
		coin_group.offset_top = 90
		hover.offset = Vector2(-20, 10)
		turbo.offset = Vector2(-21, -10)
	else:
		coin_group.columns = 2
		coin_group.offset_top = 62
		hover.offset = Vector2.ZERO
		turbo.offset = Vector2.ZERO
