extends Control

const LIST_ITEM = preload("./ldui/list_item.tscn")

onready var level_editor := $"/root/Main"
onready var item_grid = $ItemPane/ItemBlock/ItemDisplay/Back/Base/ItemGrid
onready var polygon_grid = $ItemPane/ItemBlock/ItemDisplay/Back/Base/PolygonGrid


func fill_grid():
	for item_id in range(level_editor.item_textures.size()):
		if level_editor.item_textures[item_id] != null:
			var button = LIST_ITEM.instance()
			var tex: AtlasTexture = AtlasTexture.new()
			
			var path = level_editor.item_textures[item_id]["List"]
			if path == null:
				path = level_editor.item_textures[item_id]["Placed"]
			
			var stream: StreamTexture = load(path)
			assert(stream != null, "Failed to load LD item icon from path " + path)
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
			button.rect_min_size = Vector2(32, 32)
			button.get_node("Icon").texture = tex
			button.item_id = item_id
			item_grid.add_child(button)

func _on_Mode_pressed():
	item_grid.visible = !item_grid.visible
	polygon_grid.visible = !item_grid.visible
