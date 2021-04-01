extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)

var velocity = Vector2()

onready var main = $"/root/Main/Items/Fludd_box".type_fludd

onready var fl1 = $Normal_fludd
onready var fl2 = $Rocket_fludd
onready var fl3 = $I_forgot_how_this_fludd_was_called

func switch_type(main):
	match main:
		0:
			fl1.visible = false
			fl1.monitoring = false
			fl2.visible = false
			fl2.monitoring = false
			fl3.visible = false
			fl3.monitoring = false
		1:
			fl1.visible = true
			fl1.monitoring = true
			fl2.visible = false
			fl2.monitoring = false
			fl3.visible = false
			fl3.monitoring = false
		2:
			fl1.visible = false
			fl1.monitoring = false
			fl2.visible = true
			fl2.monitoring = true
			fl3.visible = false
			fl3.monitoring = false
		3:
			fl1.visible = false
			fl1.monitoring = false
			fl2.visible = false
			fl2.monitoring = false
			fl3.visible = true
			fl3.monitoring = true

func _process(_delta):
	if Engine.editor_hint:
		switch_type(main)

func _ready():
	switch_type(main)

func _physics_process(_delta):
	velocity.y += GRAVITY
	
	velocity = move_and_slide(velocity, FLOOR)
