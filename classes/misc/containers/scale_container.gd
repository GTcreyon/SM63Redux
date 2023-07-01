@tool
extends Container
# A container that scales up its children by a given factor.

@export var scale_factor: Vector2 = Vector2.ONE: set = set_scale_fac


func _notification(what) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		for child in get_children():
			child.scale = scale_factor
			custom_minimum_size = child.size * scale_factor


func set_scale_fac(new_scale) -> void:
	scale_factor = new_scale
	queue_sort()
