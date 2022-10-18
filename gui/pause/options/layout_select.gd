extends OptionButton

func _ready():
	for layout in TouchControls.LAYOUT_PRESETS:
		add_item(layout)


func _on_LayoutSelect_item_selected(index):
	TouchControls.select_layout(get_item_text(index))
