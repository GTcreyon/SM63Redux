extends Node

var tiles = preload("res://src/level_designer/codes/tiles.gd").new()
var levels = preload("res://src/level_designer/codes/levels.gd").new()

onready var ld_tile_map = $TileMap
#var ld_tile_map = TileMap.new()

var level_width = 0
var level_height = 0
var level_name = ""

var song_id = 0
var bg_id = 0

var start_pos = Vector2(0, 0)

const item = preload("res://actors/items/ld_item.tscn")

#this now requires the tile_num and does not rely on the inner tile_num variable anymore (which is now deleted)
func place_tile_id(tile_num, tile_id):
	var x = floor(float(tile_num) / float(level_height))
	var y = tile_num % level_height
	#ld_tile_map.set_cell(x, y, tiles.decode[tile_id] - 1)
	var subtile = tiles.decode[tile_id] - 1
	if subtile > 46:
		if subtile > 75:
			subtile -= 24
	ld_tile_map.set_cell(x, y, 0, false, false, false, Vector2(subtile % 24, floor(subtile / 24)))

func place_item(item_code):
	var item_ref = item.instance()
	item_ref.set("code", item_code)
	add_child(item_ref)

#save the current level
#wip
func save_code():
	var code = str(level_width) + "x" + str(level_height) + "~"
	var n = 0
	var tile_a
	var tile_b = tiles.encode[str(ld_tile_map.get_cellv(Vector2(0, 0)) + 1)]
	var multiplier = 0
	while n < level_width * level_height - 1:
		tile_a = tile_b
		code += tile_a
		n += 1
		tile_b = tiles.encode[str(ld_tile_map.get_cellv(Vector2(n / level_height, n % level_height)) + 1)]
		if tile_a == tile_b:
			while tile_a == tile_b && n < level_width * level_height:
				multiplier += 1
				tile_a = tiles.encode[str(ld_tile_map.get_cellv(Vector2(n / level_height, n % level_height)) + 1)]
				n += 1
			if (n == level_width * level_height):
				if (tile_a == tile_b):
					multiplier += 1
					code += "*" + str(multiplier) + "*"
				else:
					code += "*" + str(multiplier) + "*" + tile_a
			else:
				code += "*" + str(multiplier) + "*"
			multiplier = 0
			tile_b = tile_a
			n -= 1
	code += "~"
	#print(get_children())
	#for child in get_children():
	#	if child != map && child != self && child != music:
	#		code += child.code + "|"
	code.erase(code.length() - 1, 1)
	code += "~" + song_id + "~" + bg_id + "~" + level_name
	return code

#I made this into a function, it's prettier and easier to use
func load_level_code(code):
	var tile_num = 0
	var read_phase = 0
	var read_num = 0
	var tile_id = ""
	var current_char
	var multiplier = ""
	var item_code = ""
	var item_ref
	var temp_width = ""
	var temp_height = ""

	var n = 0
	while n < code.length():
		current_char = code.substr(n, 1)
		if current_char == "~" && read_phase == 2:
			n += 1
			read_phase = 4
		match read_phase:
			0: #get level width
				if current_char == "x":
					level_width = int(temp_width)
					read_phase = 1
				else:
					temp_width += current_char
			1: #get level height
				if current_char == "~":
					level_height = int(temp_height)
					read_phase = 2
				else:
					temp_height += current_char
			2: #read all level tiles (and place them directly)
				tile_id += current_char
				read_num += 1
				if read_num == 2 || tile_id == "0":
					read_num = 0
					if code.substr(n+1, 1) == "*":
						read_phase = 3
						n += 1
						multiplier = ""
					else:
						place_tile_id(tile_num, tile_id)
						tile_num += 1
						tile_id = ""
			3: #same as 2
				while code.substr(n, 1) != "*":
					multiplier += code.substr(n, 1)
					n+=1
				for _i in range(int(multiplier)):
					place_tile_id(tile_num, tile_id)
					tile_num += 1
				tile_id = ""
				read_phase = 2
			4: #place down all level items
				while code.substr(n, 1) != "|" && code.substr(n, 1) != "~":
					item_code += code.substr(n, 1)
					n+=1
				if code.substr(n, 1) == "~":
					read_phase = 5
				
				item_code = ""
			5: #song id & background id
				while code.substr(n, 1) != "~":
					song_id += code.substr(n, 1)
					n += 1
				n += 1
				while code.substr(n, 1) != "~":
					bg_id += code.substr(n, 1)
					n += 1
				read_phase = 6
			6: #levelname
				level_name += current_char
		n += 1 #Increment

func _ready():
	load_level_code(levels.test_code)
	#print(save_code())
