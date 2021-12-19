extends Node2D
class_name SM63ToRedux

onready var tile_to_poly: TileToPoly = $"../TileToPoly"

export(String, FILE) var tile_groupings

const REAL_EMPTY_TILE = ""
const TILE_SIZE = Vector2(32, 32)
const TILE_SIZE_X = TILE_SIZE * Vector2(1, 0)
const TILE_SIZE_Y = TILE_SIZE * Vector2(0, 1)

func debug_print_tiles(tiles):
	var did_send = false
	for x in tiles.size():
		if x > 3 && x < tiles.size() - 3:
			if !did_send:
				print("[ -- REDUCED -- ]")
				did_send = true
			continue
		print(tiles[x])

func convert_xml_to_readable():
	var root = {
		root_dir = "tilesets/legacy",
		groups = []
	}
	var is_in_textures = false
	
	var parser := XMLParser.new()
	parser.open(tile_groupings)
	
	var node_name = ""
	while (!parser.read()):
		var node_type = parser.get_node_type()
		var current_group = root.groups.back()
		
		if node_type == 1:
			node_name = parser.get_node_name()
			
			#we ignore tilE groupings tag
			if node_name == "tile_groupings":
				pass
			
			#if it's a group, create the group and stall execution
			if node_name == "grouping":
				root.groups.append({
					do_not_convert = false,
					texture_directory = "",
					texture_type = "terrain",
					textures = {},
					ids = {}
				})
				continue
			
			if node_name == "textures":
				is_in_textures = true
				continue
			
			if is_in_textures:
				pass
			
		elif node_type == 3:
			var node_data = parser.get_node_data()
			#make sure we only include actual data, not any 0 width ones
			node_data = node_data.replace("\n", "")
			node_data = node_data.replace("\t", "")
			node_data = node_data.replace("\r", "")
			node_data = node_data.replace(" ", "")
			#skip non-data
			if len(node_data) == 0:
				continue
			
			if node_name == "texture_dir":
				current_group.texture_directory = root.root_dir + "/" + node_data
				print(current_group.texture_directory)
			
		elif node_type == 2:
			node_name = parser.get_node_name()
			if node_name == "textures":
				is_in_textures = false
	return root

func deserialize_tiles(level_data):
	#create an tile array
	var pointer = Vector2()
	var tiles = []
	for _x in range(level_data.x):
		tiles.append([])
	#read the tiles
	var tiles_expression = RegEx.new()
	tiles_expression.compile("(?<tile>0|..)(\\*(?<amount>\\d+)\\*)?")
	for tile_data in tiles_expression.search_all(level_data.tiles_txt):
		#get the amount for each tile, if it is missing or less than 1 then set it to 1
		var amount = int(tile_data.get_string("amount"))
		amount = 1 if amount <= 0 else amount
		#get the tile id
		var tile = tile_data.get_string("tile")
		for _i in range(amount):
			tiles[pointer.x].append(tile)
			#loop
			pointer.y += 1
			if pointer.y >= level_data.y:
				pointer.x += 1
				pointer.y = 0
	
	var normalised_tiles = tile_to_poly.create_2d_grid(level_data.x + 1, level_data.y + 1)
	
	for x in range(tiles.size()):
		for y in range(tiles[x].size()):
			if tiles[x][y] != "0":
				normalised_tiles[x][y] = 1
	
	#debug_print_tiles(tiles)
	#print()
	#debug_print_tiles(normalised_tiles)
	
	var polygons = tile_to_poly.get_all_polygons_from_grid(normalised_tiles, 1)
	return polygons

func deserialize_items(level_data):
	var items_expression = RegEx.new()
	items_expression.compile("(?<id>\\d+),(?<x>\\d+),(?<y>\\d+),?(?<item>.*?)(\\||$)")
	var data_expression = RegEx.new()
	data_expression.compile("(.+?)(,|$)")
	var items = []
	for item_data in items_expression.search_all(level_data.items_txt):
		#split the extra data into a list
		var extra_data = []
		for extra in data_expression.search_all(item_data.get_string("item")):
			extra_data.append(extra.get_string(1))
		#now append the item to the list of items
		items.append({
			id = int(item_data.get_string("id")),
			pos = Vector2(
				int(item_data.get_string("x")),
				int(item_data.get_string("y"))
			),
			data = extra_data
		})
	return items

func deserialize(lvl_text):
	convert_xml_to_readable()
	
	#first seperate the level into several segments
	var expression = RegEx.new()
	expression.compile("(?<x>\\d+)x(?<y>\\d+)~(?<tiles>.+?)~(?<items>.+?)~(?<song>\\d+)~(?<bg>\\d+)~(?<name>.+)")
	var result = expression.search(lvl_text)
	#if we don't have a result, that means *something* went wrong
	if result:
		#put the level data into a nice dictionary
		var level_data = {
			x = int(result.get_string("x")),
			y = int(result.get_string("y")),
			limits = Vector2(int(result.get_string("x")), int(result.get_string("y"))),
			tiles_txt = result.get_string("tiles"),
			items_txt = result.get_string("items"),
			polygons = null,
			items = null,
			song = int(result.get_string("song")),
			bg = int(result.get_string("bg")),
			name = result.get_string("name")
		}
		level_data.polygons = deserialize_tiles(level_data)
		level_data.shape_corners = []
		level_data.items = deserialize_items(level_data)
		#our job, is done here.
		return level_data
	else:
		print("Error, couldn't parse SM63 level code.")
