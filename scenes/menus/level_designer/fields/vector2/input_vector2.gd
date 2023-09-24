extends HBoxContainer

var mask: RegEx = RegEx.new()
@export var pre_value: Vector2 = Vector2.ZERO

@onready var label: Label = $Label
@onready var line_edit_x: LineEdit = $LineEditX
@onready var line_edit_y: LineEdit = $LineEditY
@onready var parent_menu = $"../.."

func _init():
	mask.compile("[^0-9,\\-,.]+")

func _ready():
	line_edit_x.text = str(pre_value.x)
	line_edit_y.text = str(pre_value.y)
#	label.text = pre_text # Can't set the text directly because the label isn't ready yet


func _on_Up_pressed(axis):
	increment(axis, 1)

func _on_Down_pressed(axis):
	increment(axis, -1)

func increment(axis, value):
	if axis == "X":
		line_edit_x.text = str(int(line_edit_x.text) + value)
	else:
		line_edit_y.text = str(int(line_edit_y.text) + value)
	
	parent_menu.on_value_changed(label.text, Vector2(
		float(line_edit_x.text),
		float(line_edit_y.text)
	))

func _on_LineEdit_text_changed(new_text: String, axis):
	var line_edit = line_edit_x if axis == "X" else line_edit_y
	var caret_store = line_edit.caret_column # We have to mess around with the caret a bit here otherwise it gets reset
	line_edit.text = mask.sub(new_text, "", true)
	line_edit.caret_column = caret_store
	if line_edit.text != new_text and line_edit.caret_column != new_text.length() - 1:
		line_edit.caret_column -= 1
	parent_menu.on_value_changed(label.text, Vector2(
		float(line_edit_x.text),
		float(line_edit_y.text)
	))
