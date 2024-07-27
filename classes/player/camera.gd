extends Camera2D

const ZOOM_TIME = 0.5

var current_zoom: float = 1
var prev_zoom: float = 1
var target_zoom: float = 1
var zoom_timer: float = 0
var rezooming: bool = false
var target_limit_left = -10000000
var target_limit_right = 10000000
var target_limit_top = -10000000
var target_limit_bottom = 10000000
var first_frame = true

var shake_impulse: Vector2
var shake_period: float
var shake_length: float
var shake_time: float


func _ready():
	limit_left = -10000000
	limit_right = 10000000
	limit_top = -10000000
	limit_bottom = 10000000
	if get_path() != ^"/root/Main/Player/Camera":
		queue_free()
	else:
		make_current()


func ease_out_expo(x: float) -> float:
	return 1 - pow(2, -10 * x)


## Shake the camera.
## [param impulse] is the initial velocity applied to the camera.
## [param period] is the time in frames taken for one full oscillation.
## [param length] is the time in frames taken for the shake to end.
func shake(impulse: Vector2, period: float, length: float) -> void:
	shake_impulse = impulse
	shake_period = period
	shake_length = length
	shake_time = 0


func manage_shake() -> void:
	if shake_length == 0:
		return
	
	offset = shake_impulse * cos(TAU * shake_time / shake_period) * (1 - shake_time / shake_length)
	shake_time += 1.0
	if shake_time >= shake_length:
		shake_length = 0


func manage_zoom(delta) -> void:
	var diff = target_zoom - prev_zoom
	zoom_timer += delta
	current_zoom = prev_zoom + diff * ease_out_expo(float(zoom_timer) / ZOOM_TIME)
	if zoom_timer >= ZOOM_TIME:
		current_zoom = target_zoom
		rezooming = false


func rezoom() -> void:
	prev_zoom = current_zoom
	zoom_timer = 0
	rezooming = true


func _process(delta):
	if rezooming:
		manage_zoom(delta)

	manage_shake()

	# TODO: Explain why this check is here.
	if get_window().size.x != 0:
		var zoom_factor: float = 1 * float(Singleton.get_screen_scale(1))
		if !get_tree().paused:
			if Input.is_action_just_pressed("zoom+") and target_zoom < 4:
				target_zoom *= 2
				rezoom()
			if Input.is_action_just_pressed("zoom-") and target_zoom > 1:
				target_zoom *= 0.5
				rezoom()
		zoom = Vector2.ONE * zoom_factor * current_zoom
		if first_frame:
			limit_left = target_limit_left
			limit_right = target_limit_right
			limit_top = target_limit_top
			limit_bottom = target_limit_bottom
			position_smoothing_enabled = false
			first_frame = false
		else:
			position_smoothing_enabled = true
			limit_left = lerp(limit_left, target_limit_left, 0.05)
			limit_right = lerp(limit_right, target_limit_right, 0.05)
			limit_top = lerp(limit_top, target_limit_top, 0.05)
			limit_bottom = lerp(limit_bottom, target_limit_bottom, 0.05)
