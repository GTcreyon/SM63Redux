extends Control

const LIST_ITEM = preload("./ldui/list_item.tscn")

onready var level_editor := $"/root/Main"
onready var ld_camera := $"/root/Main/Camera"
onready var background := $"/root/Main/BGT1/BGGrid"
onready var hover_ui := get_parent().get_node("HoverUI")
#onready var selection_ui := hover_ui.get_node("SelectionControl")
onready var editable_rect := hover_ui.get_node("Dragger")
onready var rect_controls := hover_ui.get_node("Dragger").get_node("SelectionControl")
onready var item_grid = $ItemPane/ItemBlock/ItemDisplay/Back/Base/ItemGrid

func fill_grid():
	for item_id in range(level_editor.item_textures.size()):
		if level_editor.item_textures[item_id] != null:
			var button = LIST_ITEM.instance()
			var tex : AtlasTexture = AtlasTexture.new()
			
			var path = level_editor.item_textures[item_id]["List"]
			if path == null:
				path = level_editor.item_textures[item_id]["Placed"]
			
			var stream: StreamTexture = load(path)
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
