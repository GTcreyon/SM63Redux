extends CanvasLayer

onready var cam = $"/root/Main/Player/Camera2D"
onready var sky = $Sky
onready var clouds_lower = $CloudsLower
onready var clouds_upper = $CloudsUpper
onready var hills = $Hills

func _process(_delta):
	var cam_pos = cam.get_camera_position()
	var bg_scale = round(OS.window_size.x / Singleton.DEFAULT_SIZE.x)
#	if OS.window_size.x > Singleton.DEFAULT_SIZE.x:
#		sky.offset = Vector2.ZERO
#		sky.scale = Vector2.ONE / 2
#	else:
#		sky.offset = Vector2(-320, -180)
#		sky.scale = Vector2.ONE
#
#	#$Layer2.texture_offset.x = -get_viewport().canvas_transform.get_origin().x / 5
#	#$Sky.position.y = - $"/root/Main/Player".position.y / 20
#	layer_1.texture_offset.x = cam_pos.x / 10
#	layer_1.position.y = max(267, 267 - cam_pos.y / 20)
#	layer_2.texture_offset.x = cam_pos.x / 20
#	layer_2.position.y = -70 -cam_pos.y / 50
#	layer_3.texture_offset.x = cam_pos.x / 10
#	layer_3.position.y = lerp(layer_3.position.y, max(132, 132 -cam_pos.y / 5), 0.05)
#	scale = Vector2.ONE * OS.window_size.x / Singleton.DEFAULT_SIZE.x
	var clouds_lower_size = clouds_lower.texture.get_size().x
	clouds_lower.margin_left = fmod(-cam_pos.x / 10, clouds_lower_size) - clouds_lower_size
	clouds_lower.margin_top = max(-93, -93 - cam_pos.y / 20)
	clouds_lower.rect_scale = Vector2.ONE * bg_scale
	
	var clouds_upper_size = clouds_upper.texture.get_size().x
	clouds_upper.margin_left = fmod(-cam_pos.x / 20, clouds_upper_size) - clouds_upper_size
	clouds_upper.margin_top = max(-50, -50 - cam_pos.y / 50)
	clouds_upper.rect_scale = Vector2.ONE * bg_scale
	
	var hills_size = hills.texture.get_size().x
	hills.margin_left = fmod(-cam_pos.x / 5, hills_size) - hills_size
	hills.margin_top = lerp(hills.margin_top, max(-228, -228 -cam_pos.y / 5), 0.05)
	hills.rect_scale = Vector2.ONE * bg_scale
	#hills.margin_top = max(-50, -50 - cam_pos.y / 50)
