extends Control

const LIST_ITEM = preload("./ldui/list_item.tscn")
const MSG_ICON_LOAD_FAIL = "Failed to load LD item icon from path "

const SCROLL_SPEED = 9
const GRID_THEME_TYPE = ""

@onready var main = $"/root/Main"
@onready var base = $ItemBlock/ItemDisplay/Back/Base
@onready var grid = $ItemBlock/ItemDisplay/Back/Base/ItemGrid


func _ready():
	# fill_grid has to execute AFTER main is done parsing item icon paths.
	# Thus, call_deferred.
	call_deferred("fill_grid")


func fill_grid():
	for item_id in range(main.item_textures.size()):
		if main.item_textures[item_id] != null:
			var button = LIST_ITEM.instantiate()
			var tex: Texture
			
			# Find the path to this item's icon texture.
			var path = main.item_textures[item_id]["List"]
			if path == null:
				path = main.item_textures[item_id]["Placed"]
			
			if path.ends_with(".png") or path.ends_with(".gif"):
				# Path is to an image file. Attempt opening it.
				var stream: CompressedTexture2D = load(path)
				assert(stream != null, MSG_ICON_LOAD_FAIL + path)
				
				# Create an atlas texture around it.
				tex = AtlasTexture.new()
				tex.atlas = stream
				var min_size = Vector2(
					min(
						stream.get_width(),
						32
					),
					min(
						stream.get_height(),
						32
					)
				)
				tex.region = Rect2(
					stream.get_size() / 2 - min_size / 2,
					min_size
				)
			elif path.ends_with(".tres"):
				# Path is to a texture resource. Open it directly,
				tex = load(path) as Texture
				assert(tex != null, MSG_ICON_LOAD_FAIL + path)
			
			button.custom_minimum_size = Vector2(32, 32)
			button.get_node("Icon").texture = tex
			button.item_id = item_id
			grid.add_child(button)


func _on_LeftBar_gui_input(event):
	# Calculate the full height of all cells on top of each other.
	# Start with the total number of items.
	var full_height = ceil(main.items.size() / 2)
	# Find height of one cell plus padding.
	var cell_height = 32 + grid.theme.get_constant("v_separation", GRID_THEME_TYPE)
	full_height *= cell_height
	# Add some padding to the margins.
	# offset_top is the actual scrolled position; read offset_left instead.
	full_height -= grid.offset_left + base.size.y - 2
	
	# Cache the amount of movement in the checked event.
	# (If there's no amount listed, use 1.)
	var factor
	if event.factor == 0:
		factor = 1
	else:
		factor = event.factor
	
	# Shift grid down in response to mouse wheel events.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			grid.offset_top = max(grid.offset_top - SCROLL_SPEED * factor, -full_height)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			grid.offset_top = min(grid.offset_top + SCROLL_SPEED * factor, grid.offset_left)
