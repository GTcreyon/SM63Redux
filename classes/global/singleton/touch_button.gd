extends TouchScreenButton

const ID_LIST = "sudlrzxcp"

export var id = ""
export var actions = PoolStringArray([])

func _ready():
	_setup_textures(id)


func _setup_textures(id: String):
	var ypos = ID_LIST.find(id) * 21
	normal.region.position.y = ypos
	pressed.region.position.y = ypos


func _on_TouchScreenButton_pressed():
	for action_id in actions:
		Input.action_press(action_id)


func _on_TouchScreenButton_released():
	for action_id in actions:
		Input.action_release(action_id)
