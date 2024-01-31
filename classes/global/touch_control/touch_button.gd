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
const TEXTURE_COLUMN_SIZE: int = 7
const BUTTON_SIZE: Vector2 = Vector2(20, 21)

@export var id = ""
@export var actions = PackedStringArray([])

@onready var parent = get_parent().get_parent()

func _ready():
	_setup_textures(id)


func _setup_textures(new_id: String):
	var index = ID_LIST.find(new_id)
	var pos = Vector2.ZERO
	# Get the column of the button
	pos.x = floor(float(index) / TEXTURE_COLUMN_SIZE)
	# Get the row
	pos.y = index % TEXTURE_COLUMN_SIZE
	# Multiply x coord by 2, because there are two buttons per cell
	pos.x *= 2
	# Multiply by the size of the button to snap to the grid
	pos *= BUTTON_SIZE
	
	if texture_normal is AtlasTexture and texture_pressed is AtlasTexture:
		texture_normal.region.position = pos
		texture_pressed.region.position = pos + Vector2(20, 0)
	else:
		push_error("Touch button's default graphics must be AtlasTextures for the touch controls to work properly!")


func _on_TouchScreenButton_pressed():
	for action_id in actions:
		parent.press(action_id)


func _on_TouchScreenButton_released():
	for action_id in actions:
		parent.release(action_id)
