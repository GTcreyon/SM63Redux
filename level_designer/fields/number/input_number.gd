extends HBoxContainer

var mask: RegEx = RegEx.new()
var pre_text: String

onready var label: Label = $Label
onready var line_edit: LineEdit = $LineEdit
onready var parent_menu = $"../.."

func _init():
	mask.compile("[^0-9,\\-,.]+")


func _ready():
	line_edit.text = pre_text # can't set the text directly because the label isn't ready yet


func _on_Up_pressed():
	increment(1)


func _on_Down_pressed():
	increment(-1)
	

func increment(value):
	line_edit.text = str(int(line_edit.text) + value)
	parent_menu.on_value_changed(label.text, line_edit.text)


func _on_LineEdit_text_changed(new_text: String):
	var caret_store = line_edit.caret_position # we have to mess around with the caret a bit here otherwise it gets reset
	line_edit.text = mask.sub(new_text, "", true)
	line_edit.caret_position = caret_store
	if line_edit.text != new_text && line_edit.caret_position != new_text.length() - 1:
		line_edit.caret_position -= 1
	parent_menu.on_value_changed(label.text, line_edit.text)
