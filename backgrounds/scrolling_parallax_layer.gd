class_name ScrollingParallaxLayer
extends ParallaxLayer
## A parallax layer which automatically scrolls in one direction.

@export var scroll_speed = Vector2.RIGHT

@onready var scroll_state = motion_offset # save initial offset state


func _process(delta):
	# Update scroll.
	scroll_state += scroll_speed * delta * 60
	# Wrap autoscroll position within visible repeat area (unless there's no
	# repetition).
	# Done per-axis to avoid dividing by zero (
	if motion_mirroring.x != 0:
		scroll_state.x = fposmod(scroll_state.x, motion_mirroring.x)
	if motion_mirroring.y != 0:
		scroll_state.y = fposmod(scroll_state.y, motion_mirroring.y)
	# Apply.
	motion_offset = scroll_state
	
