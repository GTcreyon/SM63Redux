extends Control

const FADE_SPEED = 1 / pow(2, 4)

onready var menu = $Menu
onready var logo = $Logo
onready var text = $StartText
onready var title_song = $TitleLoop
onready var menu_song = $MenuLoop
onready var version = $Version

var volume_balance = 0
var dampen = false
var scale
func _process(delta):
	scale = Vector2.ONE * max(
		1,
		min(
			round(OS.window_size.x / Singleton.DEFAULT_SIZE.x),
			round(OS.window_size.y / Singleton.DEFAULT_SIZE.y)
		)
	)
	if Input.is_action_just_pressed("interact") && !menu.visible:
		menu.visible = true
		Singleton.get_node("SFX/Confirm").play()
	if dampen:
		menu_song.volume_db -= 1 * 60 * delta
	else:
		if menu.visible:
			volume_balance = min(volume_balance + FADE_SPEED, 1)
			if !menu_song.playing && volume_balance >= 1:
				menu_song.play()
			logo.modulate.a = max(logo.modulate.a - 0.125, 0)
			text.modulate.a = max(text.modulate.a - 0.125, 0)
		else:
			volume_balance = max(volume_balance - FADE_SPEED, 0)
			logo.modulate.a = min(logo.modulate.a + 0.125, 1)
			text.modulate.a = min(text.modulate.a + 0.125, 1)
		title_song.volume_db = -8 - (volume_balance * 60)
		menu_song.volume_db = -8 - 60 + (volume_balance * 60)
	version.rect_scale = scale
	version.text = Singleton.VERSION


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed && !menu.visible:
			menu.visible = true
			Singleton.get_node("SFX/Confirm").play()
