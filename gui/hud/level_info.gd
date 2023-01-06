extends Control

const BYLIGHT = preload("res://fonts/bylight/bylight.tres")
const RUBY = preload("res://fonts/red/gui_red.fnt")

onready var shine_panel = $CollectPanel
onready var shine_row = $CollectRow/ShineRow
onready var coin_row = $CollectRow/CoinRow
onready var level_name = $LevelName
onready var level_name_panel = $LevelName/Panel
onready var mission_name = $MissionName
onready var mission_name_panel = $MissionName/Panel
onready var mission_details = $MissionDetails
onready var mission_details_panel = $DetailsPanel

var perm_scale = 1


func resize(scale):
	perm_scale = scale
	var font = level_name.get_font("font")

	level_name.rect_pivot_offset.x = ((OS.window_size.x / scale - 31 * 2) - 16) / 2
	
#	if OS.window_fullscreen:
#		level_name.rect_scale = Vector2.ONE * 2
#	else:
#		level_name.rect_scale = Vector2.ONE
	var gap = (OS.window_size.x / scale - font.get_string_size(TranslationServer.translate(level_name.text).to_upper()).x - 37 * 2) / 2
	#level_name.margin_left = 0
	level_name_panel.margin_left = gap - 7
	#level_name.margin_right = 0
	level_name_panel.margin_right = -gap + 4
	font = mission_name.get_font("font")
	gap = (OS.window_size.x / scale - font.get_string_size(TranslationServer.translate(mission_name.text).to_upper()).x - 37 * 2) / 2
	mission_name.margin_left = gap - 7
	mission_name.margin_right = -gap + 4
	font = mission_details.get_font("font")
	#mission_details_panel.rect_size.x = 256 / scale
	#mission_details_panel.rect_size.y = font.get_wordwrap_string_size(mission_details.text.to_upper(), 256).y
	#mission_details_panel.margin_bottom = -79 + font.get_wordwrap_string_size(mission_details.text, ((OS.window_size.x / scale - 74) - 118)).y# + mission_details.text.count("\n") * font.get_height() + 5
	#mission_details_panel.margin_bottom = -79 + (mission_details.text.count("\n") + 2) * font.get_height()
	
	# We need to figure out how big to make the mission desc panel
	# For that we need its wordwrap height
	# That's fine, we can get that with Font.get_wordwrap_string_size()
	# A bit of window scaling adjustment to avoid the simulated label width overflowing the frame
	
	# The problem is actually with the bottom margin
	# Godot doesn't properly update UI elements or allow you to force an update
	# And we're using anchoring here to allow proper spacing
	# Meaning we have to manually account for the anchoring in code
	# That's fine for a set window size, but fullscreen changes the frame-window ratio slightly
	# That causes it to be offset if we don't pay attention
	# So we have to figure out the frame height manually
	# Find the window height, divide by scale, then subtract 52 (thickness of the top/bottom bar)
	# Then multiply that by the top anchor subtracted from 1
	# That's just to figure out where the top margin is
	# Which we could figure out with a single reference to mission_details_panel.margin_top
	# Except you can't force that to update, so we have to calculate it manually
	
	# We then add the label height to form the panel's height, giving us our final answer
	# With 14 added on because reasons idfk
	mission_details_panel.margin_bottom = (8
	- (OS.window_size.y / scale - 52) * 0.3
	+ font.get_wordwrap_string_size(TranslationServer.translate(mission_details.text), ((OS.window_size.x / scale - 74) - 118)).y)

	# Mission_details_panel.margin_bottom = -79 + (2 + 1) * 14# + mission_details.text.count("\n") * font.get_height() + 5

	# Would be useful if Godot had a way to force controls to update margins before the frame ends
	var shine_count = 0
	for child in shine_row.get_children():
		if child.visible:
			shine_count += 1
	var shine_width = (shine_count - 1) * shine_row.get_constant("separation")
	var coin_count = 0
	for child in coin_row.get_children():
		if child.visible:
			coin_count += 1
	var coin_width = (coin_count - 1) * coin_row.get_constant("separation")
	shine_panel.margin_left = (OS.window_size.x / scale / 2) - (shine_width + 40 + coin_width) / 2 - 33 / 2 - 4 - 37
	shine_panel.margin_right = -((OS.window_size.x / scale / 2) - (shine_width + 40 + coin_width) / 2 - 29 / 2 - 4) + 37
#	#$ShinePanel.margin_left = $CollectRow/ShineRow.margin_left + 37 - 33 / 2 - 4
#	#$ShinePanel.margin_right = -($CollectRow.rect_size.x - $CollectRow/CoinRow.margin_right) - 37 + 29 / 2 + 4


func refresh_caps():
	if TranslationServer.get_locale().substr(0, 2) == "en":
		level_name.add_font_override("font", RUBY)
		level_name.uppercase = true
		resize(perm_scale)
	else:
		level_name.add_font_override("font", BYLIGHT)
		level_name.uppercase = false
		resize(perm_scale)


func _process(_delta):
	refresh_caps()
