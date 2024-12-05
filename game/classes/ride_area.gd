class_name RideArea
extends Area2D
# Area that detects bodies standing within it. Detects feet if the body has them.
# A "rider" is a body that is standing on ground within the area.

# Returns an array of detected riding bodies.
func get_riding_bodies() -> Array:
	var riders = []
	for body in get_overlapping_bodies():
		if _check_feet(body) and body.is_on_floor():
			riders.append(body)
	return riders


# Returns true if a rider is present.
func has_rider() -> bool:
	return !get_riding_bodies().is_empty()


# If the body does not have a feet area, return true.
# Else, check if we overlap the feet area.
# This allows us to be accurate for entities with defined feet, but fall back on their whole body if needed.
func _check_feet(body) -> bool:
	var feet = body.get("feet_area")
	return feet == null or overlaps_area(feet)
