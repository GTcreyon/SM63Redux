tool
extends Container

class_name OutlineContainer

export(PoolVector2Array) var anchor_around = [] setget set_anchor_around
export(PoolVector2Array) var px_offset = [] setget set_px_offset
export(PoolVector2Array) var item_anchor = [] setget set_item_anchor


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
			child.set_size(Vector2(rect_size.x, child.rect_size.y))
		if child.size_flags_vertical == SIZE_FILL:
			child.set_size(Vector2(child.rect_size.x, rect_size.y))
		child.set_position(
			rect_size * anchor_around[idx] - child.rect_size * item_anchor[idx] + px_offset[idx]
		)
