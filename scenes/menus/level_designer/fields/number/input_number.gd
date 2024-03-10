extends HBoxContainer

var mask: RegEx = RegEx.new()
@export var pre_text: String

@onready var label: Label = $Label
@onready var line_edit: LineEdit = $LineEdit
@onready var parent_menu = $"../.."

func _init():
	mask.compile("[^0-9,\\-,.]+")


func _ready():
	line_edit.text = pre_text # Can't set the text directly because the label isn't ready yet


func _on_Up_pressed():
	increment(1)


func _on_Down_pressed():
	increment(-1)
	

func increment(value):
	line_edit.text = str(int(line_edit.text) + value)
	parent_menu.on_value_changed(label.text, float(line_edit.text))


func _on_LineEdit_text_changed(new_text: String):
	var caret_store = line_edit.caret_column # We have to mess around with the caret a bit here otherwise it gets reset
	line_edit.text = mask.sub(new_text, "", true)
	line_edit.caret_column = caret_store
	if line_edit.text != new_text and line_edit.caret_column != new_text.length() - 1:
		line_edit.caret_column -= 1
	parent_menu.on_value_changed(label.text, float(line_edit.text))
