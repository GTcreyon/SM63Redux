extends Control

const FADE_SPEED = 1 / pow(2, 4)

@onready var menu = $Menu
@onready var logo = $Logo
@onready var text = $StartText
@onready var title_song = $TitleLoop
@onready var menu_song = $MenuLoop
@onready var version = $Version

var volume_balance = 0
var dampen = false
var scale_vec
func _process(delta):
	var dmod = 60 * delta
	var window_size = Vector2(get_window().size) # convert to float vector - avoids int div warning
	scale_vec = Vector2.ONE * max(
		1,
		min(
			round(window_size.x / Singleton.DEFAULT_SIZE.x),
			round(window_size.y / Singleton.DEFAULT_SIZE.y)
		)
	)
	if Input.is_action_just_pressed("interact") and !menu.visible:
		menu.visible = true
		Singleton.get_node("SFX/Confirm").play()
	if dampen:
		menu_song.volume_db -= 1 * dmod
	else:
		if menu.visible:
			volume_balance = min(volume_balance + FADE_SPEED * dmod, 1)
			if !menu_song.playing and volume_balance >= 1:
				menu_song.play()
			logo.modulate.a = max(logo.modulate.a - 0.125 * dmod, 0)
			text.modulate.a = max(text.modulate.a - 0.125 * dmod, 0)
		else:
			volume_balance = max(volume_balance - FADE_SPEED * dmod, 0)
			logo.modulate.a = min(logo.modulate.a + 0.125 * dmod, 1)
			text.modulate.a = min(text.modulate.a + 0.125 * dmod, 1)
		title_song.volume_db = -8 - (volume_balance * 60)
		menu_song.volume_db = -8 - 60 + (volume_balance * 60)
	version.scale = scale_vec
	version.text = Singleton.VERSION


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and !menu.visible:
			menu.visible = true
			Singleton.get_node("SFX/Confirm").play()
