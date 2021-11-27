extends Control

onready var shine_panel = $CollectPanel
onready var shine_row = $CollectRow/ShineRow
onready var coin_row = $CollectRow/CoinRow
onready var level_name = $LevelName
onready var level_name_panel = $LevelName/Panel
onready var mission_name = $MissionName
onready var mission_name_panel = $MissionName/Panel
onready var mission_details = $MissionDetails
onready var mission_details_panel = $DetailsPanel

func resize(scale):
	var font = level_name.get_font("font")

	level_name.rect_pivot_offset.x = (OS.window_size.x / scale - 31 * 2) / 2
	
	if OS.window_fullscreen:
		level_name.rect_scale = Vector2.ONE * 2
	else:
		level_name.rect_scale = Vector2.ONE
	var gap = (OS.window_size.x / scale - font.get_string_size(level_name.text.to_upper()).x - 37 * 2) / 2
	#level_name.margin_left = 0
	level_name_panel.margin_left = gap - 7
	#level_name.margin_right = 0
	level_name_panel.margin_right = -gap + 4
	font = mission_name.get_font("font")
	gap = (OS.window_size.x / scale - font.get_string_size(mission_name.text.to_upper()).x - 37 * 2) / 2
	mission_name.margin_left = gap - 7
	mission_name.margin_right = -gap + 4
	font = mission_details.get_font("font")
	#mission_details_panel.rect_size.x = 256 / scale
	#mission_details_panel.rect_size.y = font.get_wordwrap_string_size(mission_details.text.to_upper(), 256).y
	#mission_details_panel.margin_bottom = -79 + font.get_wordwrap_string_size(mission_details.text, ((OS.window_size.x / scale - 74) - 118)).y# + mission_details.text.count("\n") * font.get_height() + 5
	#mission_details_panel.margin_bottom = -79 + (mission_details.text.count("\n") + 2) * font.get_height()
	
	#absolute bullshit
	#we need to figure out how big to make the mission desc panel
	#for that we need its wordwrap height
	#that's fine, we can get that with Font.get_wordwrap_string_size()
	#a bit of window scaling adjustment to avoid the simulated label width overflowing the frame
	
	#the problem is actually with the bottom margin
	#godot doesn't properly update UI elements or allow you to force an update
	#and we're using anchoring here to allow proper spacing
	#meaning we have to manually account for the anchoring in code
	#that's fine for a set window size, but fullscreen changes the frame-window ratio slightly
	#that causes it to be offset if we don't pay attention
	#so i have to figure out the frame height manually
	#find the window height, divide by scale, then subtract 52 (thickness of the top/bottom bar)
	#then multiply that by the top anchor subtracted from 1
	#that's literally just to figure out where the top margin is
	#which we could figure out with a single reference to mission_details_panel.margin_top
	#except you can't force that to update, so we have to calculate it manually
	
	#we then add the label height to form the panel's height, giving us our final answer
	#with 14 added on because reasons idfk
	
	mission_details_panel.margin_bottom = (8
	- (OS.window_size.y / scale - 52) * 0.3
	+ font.get_wordwrap_string_size(mission_details.text, ((OS.window_size.x / scale - 74) - 118)).y)

	#mission_details_panel.margin_bottom = -79 + (2 + 1) * 14# + mission_details.text.count("\n") * font.get_height() + 5

	#this is terrible. i wish godot had a way to force controls to update their margins before the frame ends
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
