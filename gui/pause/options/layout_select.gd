extends OptionButton


func _ready():
	for layout in TouchControls.LAYOUT_PRESETS:
		var clean_name = " " + layout[0].to_upper() + layout.substr(1)
		add_item(clean_name)


func _on_LayoutSelect_item_selected(index):
	TouchControls.select_layout(get_item_text(index).substr(1).to_lower())
