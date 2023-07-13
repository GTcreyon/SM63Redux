extends Control

const GRID_THEME_TYPE = ""

@onready var main = $"/root/Main"
@onready var base = $"/root/Main/UILayer/LDUI/ItemPane/ItemBlock/ItemDisplay/Back/Base"
@onready var grid: GridContainer = $"/root/Main/UILayer/LDUI/ItemPane/ItemBlock/ItemDisplay/Back/Base/ItemGrid" # ew
@onready var region = get_parent()

func _process(_delta):
	var content_height = ceil(main.items.size() / 2) * (32 + grid.theme.get_constant("v_separation", GRID_THEME_TYPE))
	var scroll_height = content_height - base.size.y + 2
	var region_height = region.size.y
	var scroll_position = -(grid.offset_top - 3) / scroll_height
	if content_height * region_height != 0:
		size.y = base.size.y / content_height * region_height
	var scroll_space = region_height - size.y
	position.y = scroll_space * scroll_position
