extends CanvasLayer

onready var cam = $"/root/Main/Player/Camera2D"
onready var sky = $Sky
onready var layer_1 = $Layer1
onready var layer_2 = $Layer2
onready var layer_3 = $Layer3

func _process(_delta):
	var cam_pos = cam.get_camera_position()
	if OS.window_size.x > 448:
		sky.offset = Vector2.ZERO
		sky.scale = Vector2.ONE / 2
	else:
		sky.offset = Vector2(-224, -152)
		sky.scale = Vector2.ONE
	
	#$Layer2.texture_offset.x = -get_viewport().canvas_transform.get_origin().x / 5
	#$Sky.position.y = - $"/root/Main/Player".position.y / 20
	layer_1.texture_offset.x = cam_pos.x / 10
	layer_1.position.y = max(211, 211 - cam_pos.y / 20)
	layer_2.texture_offset.x = cam_pos.x / 20
	layer_2.position.y = -70 -cam_pos.y / 50
	layer_3.texture_offset.x = cam_pos.x / 10
	layer_3.position.y = lerp(layer_3.position.y, max(76, 76 -cam_pos.y / 5), 0.05)
	scale = Vector2.ONE * OS.window_size.x / 448
