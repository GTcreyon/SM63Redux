extends Camera2D

const ZOOM_TIME = 0.5

const ZOOM_MAX = 4
const ZOOM_MIN = 1


var current_zoom: float = 1
var prev_zoom: float = 1
var target_zoom: float = 1

## True when a zoom in/out animation is going.
var rezooming: bool = false
var zoom_timer: float = 0

var target_limit_left = -10000000
var target_limit_right = 10000000
var target_limit_top = -10000000
var target_limit_bottom = 10000000

var first_frame = true


func _ready():
	# Set camera limits to a default too large to have an effect.
	limit_left = -10000000
	limit_right = 10000000
	limit_top = -10000000
	limit_bottom = 10000000

	if get_path() != ^"/root/Main/Player/Camera":
		# Clean up player cameras which don't belong to the first player.
		# This comes into effect with cherry clones, and also ???.
		queue_free()
	else:
		# Set first-player camera as active.
		make_current()


func ease_out_expo(x: float) -> float:
	return 1 - pow(2, -10 * x)


## Begins a new zoom in/out animation.
func begin_rezoom() -> void:
	prev_zoom = current_zoom
	zoom_timer = 0
	rezooming = true


func _process(delta):
	# Advance the zoom in/out animation.
	if rezooming:
		# Ease toward the target zoom level.
		var dist_to_target = target_zoom - prev_zoom
		current_zoom = prev_zoom + dist_to_target * ease_out_expo(zoom_timer / ZOOM_TIME)
		
		# Tick the zoom timer.
		zoom_timer += delta
		# When the zoom timer rings, snap to the target and consider 
		# re-zooming finished.
		# (The easing function is asymptotic--so if we don't snap, we'll never land
		# exactly on the target zoom.)
		if zoom_timer >= ZOOM_TIME:
			current_zoom = target_zoom
			rezooming = false
	
	
	if get_window().size.x != 0:
		# If the game is not paused, handle zoom in/out inputs.
		if !get_tree().paused:
			# Zoom in when button is pressed and not already at max zoom.
			if Input.is_action_just_pressed("zoom+") and target_zoom < ZOOM_MAX:
				# Each zoom-in step doubles the onscreen pixel size.
				target_zoom *= 2
				begin_rezoom()
			
			# Likewise for zooming out.
			if Input.is_action_just_pressed("zoom-") and target_zoom > ZOOM_MIN:
				# Each zoom-out step halves the onscreen pixel size.
				target_zoom *= 0.5
				begin_rezoom()
		
		# Apply the current zoom factor and screen scaling.
		zoom = Vector2.ONE * current_zoom * Singleton.get_screen_scale(1)

		if first_frame:
			# Room just started. Immediately set position and limits to the
			# destination.
			position_smoothing_enabled = false
			limit_left = target_limit_left
			limit_right = target_limit_right
			limit_top = target_limit_top
			limit_bottom = target_limit_bottom
			
			first_frame = false
		else:
			# Move smoothly to target position and limits.
			position_smoothing_enabled = true
			limit_left = lerp(limit_left, target_limit_left, 0.05)
			limit_right = lerp(limit_right, target_limit_right, 0.05)
			limit_top = lerp(limit_top, target_limit_top, 0.05)
			limit_bottom = lerp(limit_bottom, target_limit_bottom, 0.05)
