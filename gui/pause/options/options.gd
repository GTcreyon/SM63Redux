extends Control

const WHITELISTED_ACTIONS = [
	"left",
	"right",
	"jump",
	"dive",
	"spin",
	"interact",
	"skip",
]
const PREFAB_REBIND_OPTION = preload("res://gui/pause/options/rebind_option.tscn")

onready var camera_fix = $CameraFix
onready var touch_controls = $TouchControls


func _ready():
	camera_fix.pressed = Singleton.disable_limits
	touch_controls.pressed = Singleton.touch_controls()
	$TouchControls/Sprite.playing = touch_controls.pressed
	for action in WHITELISTED_ACTIONS:
		var inst = PREFAB_REBIND_OPTION.instance()
		inst.action_id = action
		add_child(inst)


func _process(_delta):
	Singleton.disable_limits = camera_fix.pressed
	Singleton.force_touch = touch_controls.pressed
