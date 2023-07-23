extends AnimatedSprite2D

var _temp_frame: int = 0


func _ready():
	animation = "charge"
	frame = 0
	connect("animation_finished", Callable(self, "_on_animation_finished"))


func flash():
	play("flash")


func set_charge_level(num: int):
	if animation == "charge":
		frame = num
	else:
		_temp_frame = num


func _on_animation_finished():
	animation = "charge"
	frame = 0
	if _temp_frame != -1:
		frame = _temp_frame
		_temp_frame = -1
