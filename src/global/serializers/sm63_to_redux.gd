extends Node2D
class_name SM63ToRedux

onready var tile_to_poly: TileToPoly = $TileToPoly

export(String, FILE) var tile_groupings

var version = 0

const REAL_EMPTY_TILE = ""
const TILE_SIZE = Vector2(32, 32)
const TILE_SIZE_X = TILE_SIZE * Vector2(1, 0)
const TILE_SIZE_Y = TILE_SIZE * Vector2(0, 1)

func is_in_bounds(pos, limits):
	return pos.x >= 0 && pos.x < limits.x && pos.y >= 0 && pos.y < limits.y

func flood_fill(tiles, pos, limits):
	if not is_in_bounds(pos, limits):
		return
	
	#create an empty checked tile map
	var checked = []
	for _x in range(limits.x):
		var l = []
		for _y in range(limits.y):
			l.append(REAL_EMPTY_TILE)
		checked.append(l)
	
	var search_for = tiles[pos.x][pos.y]
	var positions_to_fill = [pos]
	
	while !positions_to_fill.empty():
		#get the current pos and tile id
		var current_pos = positions_to_fill.pop_back()
		var current_tile_id = tiles[current_pos.x][current_pos.y]

		checked[current_pos.x][current_pos.y] = search_for
		
		#add new tiles to check in our stack
		for offset in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
			var neighbour_pos = current_pos + offset
			if is_in_bounds(neighbour_pos, limits) && tiles[neighbour_pos.x][neighbour_pos.y] == search_for:
				#make sure we don't check tiles we already checked
				if checked[neighbour_pos.x][neighbour_pos.y] != search_for:
					positions_to_fill.push_back(neighbour_pos)
	return checked

func debug_print_tiles(tiles):
	var did_send = false
	for x in tiles.size():
		if x > 3 && x < tiles.size() - 3:
			if !did_send:
				print("[ -- REDUCED -- ]")
				did_send = true
			continue
		print(tiles[x])

#get the weighted sum for a nodes neighbors for a kernel
func weighted_sum(list, kernel):
	var sum = 0
	for ind in range(list.size()):
		sum += list[ind] * kernel[ind]
	return sum

func serialize():
	pass

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
	
	debug_print_tiles(tiles)
	print()
	debug_print_tiles(normalised_tiles)
	
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
