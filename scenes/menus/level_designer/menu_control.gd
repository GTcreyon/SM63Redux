extends Control

const LIST_ITEM = preload("./ldui/list_item.tscn")

const MSG_ICON_LOAD_FAIL = "Failed to load LD item icon from path "

@onready var level_editor := $"/root/Main"
@onready var item_grid = $ItemPane/ItemBlock/ItemDisplay/Back/Base/ItemGrid
@onready var polygon_grid = $ItemPane/ItemBlock/ItemDisplay/Back/Base/PolygonGrid


func fill_grid():
	for item_id in range(level_editor.item_textures.size()):
		if level_editor.item_textures[item_id] != null:
			var button = LIST_ITEM.instantiate()
			var tex: Texture
			
			# Find the path to this item's icon texture.
			var path = level_editor.item_textures[item_id]["List"]
			if path == null:
				path = level_editor.item_textures[item_id]["Placed"]
			
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
			item_grid.add_child(button)

func _on_Mode_pressed():
	item_grid.visible = !item_grid.visible
	polygon_grid.visible = !item_grid.visible
