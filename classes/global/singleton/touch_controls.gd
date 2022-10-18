extends Control

const ANCHOR_DIRECTION_OFFSETS = PoolVector2Array([Vector2(1, -1), Vector2(-1, -1), Vector2(1, 1), Vector2(-1, 1)])
const ANCHOR_PIVOT_OFFSETS = PoolVector2Array([Vector2(0, -1), Vector2(-1, -1), Vector2(0, 0), Vector2(-1, 0)])
const ANCHOR_REVERSE_OFFSETS = [false, true, false, true]
const BUTTON_PREFAB = preload("res://classes/global/singleton/touch_button.tscn")
const LAYOUT_PRESETS = {
	#"new": "u:jump,up/d:dive,down/z:pound,interact/x:spin,skip/c:fludd#s:switch_fludd/p:pause@l:left/r:right@_/s:feedback",
	"new": "u:jump,up/d:dive,down/z:pound,interact#c:fludd/x:spin,skip@l:left/r:right#s:switch_fludd/p:pause@_/s:feedback",
	"kid": "s:switch_fludd,skip/z:pound,interact/d:down#p:pause@l:left/x:spin,skip/r:right/_#d:dive,left/u:jump,left/u:jump,up/u:jump,right/d:dive,right#c:fludd,left/c:fludd/c:fludd,right/_@_/s:feedback",
	"classic": "z:pound,interact/x:spin,skip/c:fludd#s:switch_fludd/p:pause@l:left/d:down,dive/r:right#u:up,jump/_@_/s:feedback",
}

var button_scale = 3
var action_presses = {} # Record how many buttons are pressing each action

onready var anchors = [$AnchorLeft, $AnchorRight, $AnchorLeftUp, $AnchorRightUp]

func _init():
	visible = false


func _ready():
	var scale = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	#var button_scale = min(floor(OS.window_size.x / (120 * scale)), floor(OS.window_size.y / (42 * scale)))
	$AnchorRight.rect_scale = Vector2.ONE * scale * button_scale
	$AnchorLeft.rect_scale = Vector2.ONE * scale * button_scale
	$AnchorLeftUp.rect_scale = Vector2.ONE * scale * button_scale
	_generate_buttons(LAYOUT_PRESETS["kid"])
#	$AnchorLeftUp.margin_left = 80 * scale


func _process(_delta):
	visible = Singleton.touch_control


func _physics_process(_delta):
	if Singleton.touch_control:
		for action in action_presses:
			if action_presses[action] > 0:
				if !Input.is_action_pressed(action):
					Input.action_press(action)
			elif Input.is_action_pressed(action):
				Input.action_release(action)


func press(action_id: String) -> void:
	action_presses[action_id] += 1


func release(action_id: String) -> void:
	action_presses[action_id] -= 1


func _generate_buttons(pattern: String) -> void:
	var offset = Vector2.ZERO
	var anchor_index = 0
	var offset_multiplier = Vector2(1, -1)
	for corner in pattern.split("@"):
		for row in corner.split("#"):
			var buttons: PoolStringArray = row.split("/")
			if ANCHOR_REVERSE_OFFSETS[anchor_index]:
				buttons.invert()
			for button in buttons:
				if button != "_":
					var parts = button.split(":")
					var actions = parts[1].split(",")
					for action in actions:
						if !action_presses.has(action):
							action_presses[action] = 0
					var inst = BUTTON_PREFAB.instance()
					inst.id = parts[0]
					inst.actions = actions
					inst.position = (
						# Change the direction that the offset applies in based current corner
						offset * ANCHOR_DIRECTION_OFFSETS[anchor_index]
						# Offset the button because its pivot is in the top left of its sprite
						+ Vector2(20, 21) * ANCHOR_PIVOT_OFFSETS[anchor_index]
					)
					anchors[anchor_index].add_child(inst)
				offset.x += 20
			offset.x = 0
			offset.y += 21
		offset.y = 0
		anchor_index += 1

