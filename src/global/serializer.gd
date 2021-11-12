extends Node2D
class_name Serializer

var version = 0

const REAL_EMPTY_TILE = ""

func is_in_bounds(pos, limits):
	return pos.x >= 0 && pos.x < limits.x && pos.y >= 0 && pos.y < limits.y

func flood_fill(tiles, pos, limits):
	if not is_in_bounds(pos, limits):
		return
	
	#create an empty checked tile map
	var checked = []
	for x in range(limits.x):
		var l = []
		for y in range(limits.y):
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
			shapes = null,
			shape_corners = null,
			items = null,
			song = int(result.get_string("song")),
			bg = int(result.get_string("bg")),
			name = result.get_string("name")
		}
		#now handle tiles
		var pointer = Vector2()
		#create a 2D grid
		var tiles = []
		for x in range(level_data.x):
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
			for i in range(amount):
				tiles[pointer.x].append(tile)
				#loop
				pointer.y += 1
				if pointer.y >= level_data.y:
					pointer.x += 1
					pointer.y = 0
		#collect all shapes for the tiles, we use this to get the corners later
		var shapes = {}
		for x in range(level_data.x):
			for y in range(level_data.y):
				var should_fill = true
				var pos = Vector2(x, y)
				#check if we haven't already checked this tile already
				for shape in shapes.values():
					if shape[pos.x][pos.y] != REAL_EMPTY_TILE:
						should_fill = false
						break
				#if we should fill, then get the shape
				if should_fill:
					var shape = flood_fill(tiles, pos, level_data.limits)
					shapes[shape[pos.x][pos.y]] = shape
		#0 is the id for air, we don't care about air! WHO NEEDS AIR ANYWAYS?!
		if shapes.has("0"):
			shapes.erase("0")
		
		#now get the corners of the shapes
		var loop_corner = [
			Vector2(-1, 1), Vector2(0, 1), Vector2(1, 1),
			Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0),
			Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1)
		]
		
		#horizontal kernel
		var k_x = [
			-1, 0, 1,
			-2, 0, 2,
			-1, 0, 1,
		]
		#vertical kernel
		var k_y = [
			1, 2, 1,
			0, 0, 0,
			-1, -2, -1,
		]
		
		#get the corner tiles for each shape, we don't need other tiles
		#they will be extra unneeded vertices
		var shape_corners = {}
		for shape_tile in shapes.keys():
			var shape = shapes[shape_tile]
			var checked = []
			for x in range(level_data.x):
				var l = []
				for y in range(level_data.y):
					l.append(REAL_EMPTY_TILE)
				checked.append(l)
			var corners = []
			
			#Sobel Edge detection implementation
			#but I use it for corners
			#get owned Sobel
			for x in range(level_data.x):
				for y in range(level_data.y):
					#make sure we only check on tiles that equal the shape
					if shape[x][y] != shape_tile:
						continue
					var pos = Vector2(x, y)
					#compile a 1d list of with 0's and 1's
					var list = []
					for offset in loop_corner:
						var real_pos = pos + offset
						if !is_in_bounds(real_pos, level_data.limits):
							list.append(0)
							continue
						if shape[real_pos.x][real_pos.y] != shape_tile:
							list.append(0)
							continue
						list.append(1)
					
					#get the weighted sums of the list combined with both kernels
					var g_x = weighted_sum(list, k_x)
					var g_y = weighted_sum(list, k_y)
					#now add both sums together using pythagoras
					var g = pow(pow(g_x, 2) + pow(g_y, 2), 0.5)
					
					#edges are g = 4, g = 1 is when fully surrounded, so is g = 0
					#so if we skip those, we have corners!
					if g != 0 && g != 4 && g != 1:
						checked[pos.x][pos.y] = g
						corners.append(pos)
			shape_corners[shape_tile] = corners
		#now update lv data
		level_data.shapes = shapes
		level_data.shape_corners = shape_corners
		
		#handle items
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
		#now update lv data
		level_data.items = items
		#our job, is done here.
		return level_data
	else:
		print("Error, couldn't parse SM63 level code.")
