extends Control

onready var main = $"/root/Main"
onready var base = $"/root/Main/UILayer/LDUI/ItemPane/ItemBlock/ItemDisplay/Back/Base"
onready var grid = $"/root/Main/UILayer/LDUI/ItemPane/ItemBlock/ItemDisplay/Back/Base/ItemGrid" # ew
onready var region = get_parent()

func _process(delta):
	var content_height = ceil(main.items.size() / 2) * (32 + grid.get_constant("vseparation"))
	var scroll_height = content_height - base.rect_size.y + 2
	var region_height = region.rect_size.y
	var scroll_position = -(grid.margin_top - 3) / scroll_height
	if content_height * region_height != 0:
		rect_size.y = base.rect_size.y / content_height * region_height
	var scroll_space = region_height - rect_size.y
	rect_position.y = scroll_space * scroll_position
