extends TouchScreenButton

const ID_LIST: Array = [
	"shift",
	"up", "down", "left", "right",
	"z", "x", "c",
	"pause",
	"fleft", "fludd", "fright",
	"jleft", "jump", "jright",
	"nozzle",
	"pipe",
	"ul", "ur", "dl", "dr",
]

export var id = ""
export var actions = PoolStringArray([])

onready var parent = get_parent().get_parent()

func _ready():
	_setup_textures(id)


func _setup_textures(new_id: String):
	var index = ID_LIST.find(new_id)
	var pos = Vector2(floor(index / 7), index % 7)
	pos *= Vector2(40, 21)
	normal.region.position = pos
	pressed.region.position = pos + Vector2(20, 0)


func _on_TouchScreenButton_pressed():
	for action_id in actions:
		parent.press(action_id)


func _on_TouchScreenButton_released():
	for action_id in actions:
		parent.release(action_id)
