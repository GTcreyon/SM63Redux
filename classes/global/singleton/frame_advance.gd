extends Node


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event):
	if Input.is_action_pressed("frame_pause"):
		get_tree().paused = not get_tree().paused


func _physics_process(_delta):
	if Input.is_action_just_pressed("frame_advance"):
		if get_tree().paused:
			get_tree().paused = false
		await get_tree().physics_frame
		get_tree().paused = true
