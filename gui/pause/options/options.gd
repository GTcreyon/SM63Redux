extends Control

const SCROLL_SPEED = 16
const WHITELISTED_ACTIONS = [
	"left",
	"right",
	"jump",
	"dive",
	"spin",
	"pound",
	"fludd",
	"switch_fludd",
	"pause",
	"interact",
	"skip",
]
const PREFAB_REBIND_OPTION = preload("res://gui/pause/options/rebind_option.tscn")

onready var list = $List
onready var camera_fix = $List/CameraFix
onready var touch_controls = $List/TouchControls
var start_height
var max_height
var height_set = false


func _ready():
	camera_fix.pressed = Singleton.disable_limits
	touch_controls.pressed = Singleton.touch_controls()
	$List/TouchControls/Sprite.playing = touch_controls.pressed
	print(rect_size.y )
	print(list.margin_top)
	start_height = rect_size.y - list.margin_top + list.margin_bottom
	height_set = true
	for action in WHITELISTED_ACTIONS:
		var inst = PREFAB_REBIND_OPTION.instance()
		inst.action_id = action
		list.add_child(inst)


func _process(_delta):
	max_height = list.rect_size.y
	Singleton.disable_limits = camera_fix.pressed
	Singleton.force_touch = touch_controls.pressed


func _on_OptionsMenu_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			list.margin_top = max(list.margin_top - SCROLL_SPEED, -(max_height - start_height) + list.margin_left)
			list.margin_bottom = list.margin_top - 16
		elif event.button_index == BUTTON_WHEEL_UP:
			list.margin_top = min(list.margin_top + SCROLL_SPEED, 8)
			list.margin_bottom = list.margin_top - 16


func _notification(what):
	if what == NOTIFICATION_RESIZED && height_set:
		start_height = rect_size.y - list.margin_top + list.margin_bottom
