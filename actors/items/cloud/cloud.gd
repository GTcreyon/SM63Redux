tool
extends StaticBody2D

onready var safety_net = $SafetyNet

export var disabled = false setget set_disabled
export var width = 1 setget set_width

func _ready():
	set_width(width) #don't ask

func set_width(new_width):
	width = new_width
	if width <= 0:
		$Middle.visible = false
	else:
		$Middle.visible = true
	#if !Engine.editor_hint:
	$Collision.shape.extents.x = 8 * width + 15
	$SafetyNet/CollisionShape2D.shape.extents.x = 8 * width + 15
	$Middle.rect_size.x = 16 * width
	$Middle.rect_position.x = -8 * width
	
	$Left.position.x = -8 * width - 8
	$Right.position.x = 8 * width + 8


func set_disabled(val):
	disabled = val
	if safety_net == null:
		safety_net = $SafetyNet
	set_collision_layer_bit(0, 0 if val else 1)
	safety_net.monitoring = !val
