extends Control

const LIST_ITEM = preload("./ldui/list_item.tscn")
const MSG_ICON_LOAD_FAIL = "Failed to load LD item icon from path \"%s\"."

const SCROLL_SPEED = 9
const GRID_THEME_TYPE = ""

@onready var main: LDMain = $"/root/Main"
@onready var base = $ItemBlock/ItemScroll
@onready var grid = $ItemBlock/ItemScroll/ItemGrid


func _ready():
	# fill_grid has to execute AFTER main is done parsing item icon paths.
	# Thus, call_deferred.
	call_deferred("fill_grid")


func fill_grid():
	for item_id in main.items.keys():
		if main.item_textures[item_id] != null:
			var button: LDListItem = LIST_ITEM.instantiate()
			var tex: Texture
			
			# Find the path to this item's icon texture.
			var path = main.item_textures[item_id]["List"]
			if path == null:
				path = main.item_textures[item_id]["Placed"]
			
			if path == null:
				# No path is defined for this object. Report, then roll with it.
				print_debug("Item \"%s\" has no assigned icon textures." % main.items[item_id].name)
				tex = null
			elif path.ends_with(".png") or path.ends_with(".gif"):
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
				assert(tex != null, MSG_ICON_LOAD_FAIL % path)
			else:
				# Path is to something invalid.
				assert(false, "Path \"%s\" is not to a supported texture file. Supported formats are .png, .gif, and .tres." % path)
			
			button.custom_minimum_size = Vector2(32, 32)
			button.get_node("Icon").texture = tex
			button.item_id = item_id
			grid.add_child(button)
