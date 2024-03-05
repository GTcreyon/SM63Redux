class_name ScrollingParallaxLayer
extends ParallaxLayer
## A parallax layer which automatically scrolls in one direction.

@export var scroll_speed = Vector2.RIGHT

@onready var scroll_state = motion_offset # save initial offset state


func _process(delta):
	# Update scroll.
	scroll_state += scroll_speed * delta * 60
	# Wrap autoscroll position within visible repeat area.
	scroll_state = scroll_state.posmodv(motion_mirroring)
	# Apply.
	motion_offset = scroll_state
	
