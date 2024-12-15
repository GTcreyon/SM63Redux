@tool
extends Container

class_name OutlineContainer

@export var anchor_around: PackedVector2Array = []: set = set_anchor_around
@export var px_offset: PackedVector2Array = []: set = set_px_offset
@export var item_anchor: PackedVector2Array = []: set = set_item_anchor


func set_anchor_around(new):
	anchor_around = new
	queue_sort()

func set_item_anchor(new):
	item_anchor = new
	queue_sort()

func set_px_offset(new):
	px_offset = new
	queue_sort()

func _notification(what):
	if what != NOTIFICATION_SORT_CHILDREN:
		return
	
	if len(anchor_around) < get_child_count():
		for _idx in range(len(anchor_around), get_child_count()):
			anchor_around.append(Vector2(0, 0))
	if len(item_anchor) < get_child_count():
		for _idx in range(len(item_anchor), get_child_count()):
			item_anchor.append(Vector2(0.5, 0.5))
	if len(px_offset) < get_child_count():
		for _idx in range(len(px_offset), get_child_count()):
			px_offset.append(Vector2(0, 0))
	
	for idx in get_child_count():
		var child = get_child(idx)
		if child.size_flags_horizontal == SIZE_FILL:
			child.set_size(Vector2(size.x, child.size.y))
		if child.size_flags_vertical == SIZE_FILL:
			child.set_size(Vector2(child.size.x, size.y))
		child.set_position(
			size * anchor_around[idx] - child.size * item_anchor[idx] + px_offset[idx]
		)
